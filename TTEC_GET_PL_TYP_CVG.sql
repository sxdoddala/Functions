create or replace FUNCTION TTEC_GET_PL_TYP_CVG(P_EFFECTIVE_DATE IN DATE, P_ASSIGNMENT_ID IN NUMBER, P_PL_TYP_ID IN NUMBER)
    RETURN VARCHAR2 IS
	
	
	/************************************************************************************
        Program Name: TTEC_GET_PL_TYP_CVG 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI(ARGANO)            1.0      19-May-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/
	
	
	

    CURSOR CSR_ENRT_RSLT IS
 SELECT 'Y' FROM
     PER_ALL_ASSIGNMENTS_F                ASSIGN,
     /*
	 START R12.2 Upgrade Remediation
	 code commented by RXNETHI-ARGANO,19/05/23
	 BEN.BEN_PRTT_ENRT_RSLT_F                PEN,
     BEN.BEN_PL_F                             PL
	 */
	 --code added by RXNETHI-ARGANO,19/05/23
	 APPS.BEN_PRTT_ENRT_RSLT_F                PEN,
     APPS.BEN_PL_F                             PL
	 --END R12.2 Upgrade Remediation
    WHERE  P_EFFECTIVE_DATE BETWEEN PEN.EFFECTIVE_START_DATE               AND PEN.EFFECTIVE_END_DATE
      AND  P_EFFECTIVE_DATE BETWEEN PEN.ENRT_CVG_STRT_DT                   AND PEN.ENRT_CVG_THRU_DT
      AND  P_EFFECTIVE_DATE BETWEEN ASSIGN.EFFECTIVE_START_DATE            AND ASSIGN.EFFECTIVE_END_DATE
      AND  P_EFFECTIVE_DATE BETWEEN PL.EFFECTIVE_START_DATE                AND PL.EFFECTIVE_END_DATE
      AND  PEN.PRTT_ENRT_RSLT_STAT_CD IS NULL
      AND  ASSIGN.ASSIGNMENT_ID = P_ASSIGNMENT_ID
      AND  ASSIGN.PERSON_ID     = PEN.PERSON_ID
      AND  PEN.PL_TYP_ID = P_PL_TYP_ID
      AND  PL.PL_ID = PEN.PL_ID
      AND UPPER(PL.NAME) NOT LIKE 'WAIVE %';

    L_CVG    VARCHAR2(1);

  BEGIN
    OPEN CSR_ENRT_RSLT;

    FETCH CSR_ENRT_RSLT
      INTO L_CVG;

    IF CSR_ENRT_RSLT%NOTFOUND THEN
      L_CVG := 'N';
    END IF;

    CLOSE CSR_ENRT_RSLT;
    RETURN L_CVG;

END TTEC_GET_PL_TYP_CVG;
/
show errors;
/