create or replace function TTEC_TranslateCCID (p_old_coa  IN NUMBER,
                                               p_old_ccid IN NUMBER,
                                               p_new_coa  IN NUMBER,
                                               p_ccid_source_name  IN VARCHAR2,
                                               p_source_info1_type IN VARCHAR2,
                                               p_source_info1      IN VARCHAR2,
                                               p_source_info2_type IN VARCHAR2,
                                               p_source_info2      IN VARCHAR2)
RETURN NUMBER AS
/********************************************************************************
    PROGRAM NAME:   TTTEC_TranslateCCID

    DESCRIPTION:    This function takes the old CCID and corresponding COA,
                    it obtains the segment 1-6 values from GL_CODE_COMBINATIONS
                    follows by obtaining the corresponding/mapped code from
                    CUST.TTEC_GL_CLIENTS_MAPPING and CUST.TTEC_GL_ACCOUNTS_MAPPING.
                    Once, the new codes on CLIENT and ACCOUNT are mapped,
                    it goes back to GL_CODE_COMBINATIONS table to obtain the
                    corresponding CCID and return the value to the calling function.

                    In the event that the mapping code is missing
                    or the CCID doesn't exist in GL_CODE_COMBINATIONS table,
                    the function will return the following values:

                    RETUNR NULL: CCID Field to Mapped is null
                    RETURN -1: CCID doesn't exist for the SEGMENTS values 1-6
                    RETURN -2: Invalid CCID. Failed to find GL SEGMENTS 1-6 values
                    RETURN -3: No Mapping found for old GL ACCOUNT
                    RETURN -4: No Mapping found for old GL CLIENT
                    RETURN -5: EXCEPTION WHEN OTHERS is raised in Function TTEC_TranslateCCID ERROR: '||SQLCODE||'-'|| SQLERRM

    BUSINESS RULES: 1. TeleTech GL Accounting FlexFields are defined as follow:

                       SEGMENT1 - TTEC GL Location
                       SEGMENT2 - TTEC GL Client
                       SEGMENT3 - TTEC GL Department
                       SEGMENT4 - TTEC GL Account
                       SEGMENT5 - TTEC GL Future 1
                       SEGMENT6 - TTEC GL Future 2

                    2. This function is designed to translate only the TeleTech
                       GL Accounting FlexFields listed below:

                       SEGMENT2 - TTEC GL Client
                       SEGMENT4 - TTEC GL Account

                    3. Traslation will work on SEGMENT2 - TTEC GL Client only if SEGMENT2 is numeric
                       Due to the mapping of GL Client is provided is a range format and the condition
                       is using BETWEEN statement and TO_NUMBER function.

                       WHERE TO_NUMBER(TRIM(Old_client_code)) BETWEEN TO_NUMBER(TRIM(am.OLD_CLIENT_CODE_FROM))
                                                                  and TO_NUMBER(TRIM(am.OLD_CLIENT_CODE_TO));

                       CREATE TABLE CUST.TTEC_GL_CLIENTS_MAPPING
                       (
                         NEW_CLIENT_CODE        VARCHAR2(15 BYTE),
                         OLD_CLIENT_CODE_FROM   VARCHAR2(15 BYTE),
                         OLD_CLIENT_CODE_TO     VARCHAR2(15 BYTE)
                       )

    CREATED BY:     Christiane Chan

    DATE:           07-NOV-2008

    ----------------
    MODIFICATION LOG
    ----------------


    DEVELOPER             DATE          DESCRIPTION
    -------------------   ------------  -----------------------------------------
    RXNETHI-ARGANO        19/MAY/2023   R12.2 Upgrade Remediation
********************************************************************************/

  CURSOR GetOldSegments_cur IS
     SELECT cc.SEGMENT1,
            cc.SEGMENT2,
            cc.SEGMENT3,
            cc.SEGMENT4,
            cc.SEGMENT5,
            cc.SEGMENT6
       --FROM gl.gl_code_combinations cc   --code commented by RXNETHI-ARGANO,19/05/23
       FROM apps.gl_code_combinations cc   --code added by RXNETHI-ARGANO,19/05/23
      WHERE cc.CODE_COMBINATION_ID  = p_old_ccid
        AND cc.CHART_OF_ACCOUNTS_ID = p_old_coa;

  CURSOR GetNewAccountCode_cur(old_acct_code IN VARCHAR2) IS
     SELECT am.NEW_GL_ACCOUNT_CODE
       --FROM CUST.TTEC_GL_ACCOUNTS_MAPPING am     --code commented by RXNETHI-ARGANO,19/05/23
       FROM APPS.TTEC_GL_ACCOUNTS_MAPPING am       --code added by RXNETHI-ARGANO,19/05/23
      WHERE am.OLD_GL_ACCOUNT = old_acct_code;

  CURSOR GetNewClientCode_cur(old_client_code IN VARCHAR2) IS
     SELECT TRIM(am.NEW_CLIENT_CODE)
       --FROM CUST.TTEC_GL_CLIENTS_MAPPING am      --code commented by RXNETHI-ARGANO,19/05/23
       FROM APPS.TTEC_GL_CLIENTS_MAPPING am        --code added by RXNETHI-ARGANO,19/05/23
      WHERE TO_NUMBER(TRIM(Old_client_code)) BETWEEN TO_NUMBER(TRIM(am.OLD_CLIENT_CODE_FROM)) and TO_NUMBER(TRIM(am.OLD_CLIENT_CODE_TO));

  CURSOR GetNewCCID_cur(new_segment1 IN VARCHAR2,
                        new_segment2 IN VARCHAR2,
                        new_segment3 IN VARCHAR2,
                        new_segment4 IN VARCHAR2,
                        new_segment5 IN VARCHAR2,
                        new_segment6 IN VARCHAR2) IS
     SELECT cc.CODE_COMBINATION_ID ccid
       --FROM gl.gl_code_combinations cc           --code commented by RXNETHI-ARGANO,19/05/23
       FROM apps.gl_code_combinations cc           --code added by RXNETHI-ARGANO,19/05/23
      WHERE cc.SEGMENT1 = new_segment1
        AND cc.SEGMENT2 = new_segment2
        AND cc.SEGMENT3 = new_segment3
        AND cc.SEGMENT4 = new_segment4
        AND cc.SEGMENT5 = new_segment5
        AND cc.SEGMENT6 = new_segment6
        AND cc.CHART_OF_ACCOUNTS_ID = p_new_coa;

  -- VARIABLES

  v_segment1        VARCHAR2(15);
  v_old_segment2    VARCHAR2(15);
  v_new_segment2    VARCHAR2(15);
  v_segment3        VARCHAR2(15);
  v_old_segment4    VARCHAR2(15);
  v_new_segment4    VARCHAR2(15);
  v_segment5        VARCHAR2(15);
  v_segment6        VARCHAR2(15);
  v_new_ccid        NUMBER;
  v_return          VARCHAR2(100);

  l_concat_segments             VARCHAR2 (400) := NULL;


BEGIN


     fnd_file.put_line(FND_FILE.LOG,
     --DBMS_OUTPUT.put_line(
           '-------------------------------------------------------------------------------------------------------------------------------');
     fnd_file.put_line(FND_FILE.LOG,
     --DBMS_OUTPUT.put_line(
                                      'Mapping CCID Source: ['||p_ccid_source_name ||'] '||
                                    p_source_info1_type||': ['||p_source_info1     ||'] '||
                                    p_source_info2_type||': ['||p_source_info2     ||'] '||
                                                'Old CCID : ['||p_old_ccid         ||']');
IF p_old_ccid IS NOT NULL
THEN
  OPEN  GetOldSegments_cur;
  FETCH GetOldSegments_cur INTO v_segment1,
                                v_old_segment2,
                                v_segment3,
                                v_old_segment4,
                                v_segment5,
                                v_segment6;

  IF GetOldSegments_cur%NOTFOUND THEN
     fnd_file.put_line(FND_FILE.LOG,
     --DBMS_OUTPUT.put_line(
                                     'Invalid CCID. Failed to find GL SEGMENTS 1-6 values on CCID -> ['||
                                      p_old_ccid    || '] for COA -> '||
                                      p_old_coa);
    CLOSE GetOldSegments_cur;
    RETURN -2; --Invalid CCID. Failed to find GL SEGMENTS 1-6 values

  ELSE

        fnd_file.put_line(FND_FILE.LOG,
        --DBMS_OUTPUT.put_line( 'Old GL Segments: [' ||
                                      RPAD(v_segment1     ||'-'||
                                           v_old_segment2 ||'-'||
                                           v_segment3     ||'-'||
                                           v_old_segment4 ||'-'||
                                           v_segment5     ||'-'||
                                           v_segment6     ||'] ',40,' ')||RPAD('for COA -> ['||
                                           p_old_coa      ||'] ',20,' ')||' Old CCID ->['||
                                           p_old_ccid     ||']');

        OPEN  GetNewAccountCode_cur(v_old_segment4);
        FETCH GetNewAccountCode_cur INTO v_new_segment4;

        IF GetNewAccountCode_cur%NOTFOUND THEN
           fnd_file.put_line(FND_FILE.LOG,
           --DBMS_OUTPUT.put_line(
                                          'No Mapping found for old GL ACCOUNT -> ['  ||
                                           v_old_segment4    || '] in the new COA -> '||
                                           p_new_coa);
           CLOSE GetNewAccountCode_cur;
           RETURN -3;-- No Mapping found for old GL ACCOUNT.

        END IF;

        CLOSE GetNewAccountCode_cur;


        OPEN  GetNewClientCode_cur(v_old_segment2);
        FETCH GetNewClientCode_cur INTO v_new_segment2;
        IF GetNewClientCode_cur%NOTFOUND THEN
           fnd_file.put_line(FND_FILE.LOG,
           --DBMS_OUTPUT.put_line( 'No Mapping found for old GL CLIENT -> ['   ||
                                           v_old_segment2    || '] in the new COA -> '||
                                           p_new_coa);
           CLOSE GetNewAccountCode_cur;
           RETURN -4;-- No Mapping found for old GL CLIENT
        END IF;
        CLOSE GetNewClientCode_cur;

        OPEN  GetNewCCID_cur(v_segment1,
                             v_new_segment2,
                             v_segment3,
                             v_new_segment4,
                             v_segment5,
                             v_segment6);
        FETCH GetNewCCID_cur INTO v_new_ccid;
        IF GetNewCCID_cur%FOUND THEN
           CLOSE GetNewCCID_cur;
           fnd_file.put_line(FND_FILE.LOG,
           --DBMS_OUTPUT.put_line( 'New GL Segments: [' ||
                                      RPAD(v_segment1     ||'-'||
                                           v_new_segment2 ||'-'||
                                           v_segment3     ||'-'||
                                           v_new_segment4 ||'-'||
                                           v_segment5     ||'-'||
                                           v_segment6     ||'] ',40,' ')||RPAD('for COA -> ['||
                                           p_new_coa      ||'] ',20,' ')||' New CCID ->['||
                                           v_new_ccid     ||']');
           RETURN v_new_ccid;
        ELSE
           --
           -- Call API to create a new CCID for COA
           --

           l_concat_segments := v_segment1
                             || '.'
                             || v_new_segment2
                             || '.'
                             || v_segment3
                             || '.'
                             || v_new_segment4
                             || '.'
                             || v_segment5
                             || '.'
                             || v_segment6;

          v_new_ccid := NULL;
          TTEC_concat_segs_to_ccid(p_new_coa,l_concat_segments,v_new_ccid);

          IF v_new_ccid IS NOT NULL THEN
             RETURN v_new_ccid;
          ELSE
           fnd_file.put_line(FND_FILE.LOG,
           --DBMS_OUTPUT.put_line(
                                          'CCID does not exist for the new mapped GL SEGMENTS 1-6 -> [' ||
                                           v_segment1     ||'-'||
                                           v_new_segment2 ||'-'||
                                           v_segment3     ||'-'||
                                           v_new_segment4 ||'-'||
                                           v_segment5     ||'-'||
                                           v_segment6     || '] for COA -> '||
                                           p_new_coa);

           RETURN -1;-- CCID doesn't exist for the SEGMENTS values 1-6.

          END IF;
        END IF;
  END IF;

  CLOSE GetOldSegments_cur;
ELSE
     fnd_file.put_line(FND_FILE.LOG,
     --DBMS_OUTPUT.put_line(
     'CCID is NULL. Skip Mapping Process');
  RETURN NULL;
END IF;

EXCEPTION WHEN others THEN
     fnd_file.put_line(FND_FILE.LOG,
     --DBMS_OUTPUT.put_line(
                            'EXCEPTION WHEN OTHERS is raised in Function TTEC_TranslateCCID ERROR: '||SQLCODE||'-'|| SQLERRM);
      RETURN -5; -- EXCEPTION WHEN OTHERS is raised in Function TTEC_TranslateCCID ERROR:

END TTEC_TranslateCCID;
