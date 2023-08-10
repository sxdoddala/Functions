create or replace FUNCTION      ttec_apr_grp(p_location IN VARCHAR2,p_position IN NUMBER ) RETURN VARCHAR2 IS

/********************************************************************************
    PROGRAM NAME:   ttec_apr_grp

    DESCRIPTION:    This function is returns employee name for authorize apporval limit

    INPUT      :   person id, amount limit and position limit

    OUTPUT     :   Emeployee Name

    CREATED BY:     Elango Pandurangan

    DATE:           09-MAR-2009

    CALLING FROM   :  TeleTech PR Approval Group Matrix (N/A)

    ----------------
    MODIFICATION LOG
    ----------------


    DEVELOPER             DATE          DESCRIPTION
    -------------------   ------------  -----------------------------------------
    Elango Pandu            18-mar-2009  For 100+ approvers needs to look for range scan and others
                                         specify for segment1_low in location condition
	
	RXNETHI-ARGANO          19/MAY/2023  R12.2 Upgrade Remediation
********************************************************************************/

    v_emp_name per_all_people_f.full_name%TYPE;
    v_attribute10  po_control_groups.attribute10%TYPE;

    CURSOR c_emp_name IS
    SELECT a.full_name
    FROM per_all_people_f a
    WHERE a.person_id = v_attribute10
    AND SYSDATE BETWEEN a.effective_start_date AND a.effective_end_date;

    CURSOR c_apr_grp(p_min IN NUMBER, p_max IN NUMBER) IS
    SELECT DISTINCT b.attribute10
      --FROM po.po_control_rules a    --code commented by RXNETHI-ARGANO,19/05/23
      FROM apps.po_control_rules a    --code added by RXNETHI-ARGANO,19/05/23
         , po_control_groups_all b--, po_control_groups b
     WHERE a.control_group_id = b.control_group_id
       AND a.object_code = 'ACCOUNT_RANGE'
       AND a.rule_type_code = 'INCLUDE'
       AND p_location = segment1_low
        AND b.attribute10 IS NOT NULL
      AND TO_NUMBER(NVL(a.amount_limit,0)) <> 1
      AND TO_NUMBER(a.amount_limit) BETWEEN p_min AND p_max;



    CURSOR c_100k_apr_grp IS
    SELECT DISTINCT b.attribute10
      --FROM po.po_control_rules a    --code commented by RXNETHI-ARGANO,19/05/23
      FROM apps.po_control_rules a    --code added by RXNETHI-ARGANO,19/05/23
         , po_control_groups_all b
     WHERE a.control_group_id = b.control_group_id
       AND a.object_code = 'ACCOUNT_RANGE'
       AND a.rule_type_code = 'INCLUDE'
       AND p_location = segment1_low
        AND b.attribute10 IS NOT NULL
        AND NVL(INSTR(UPPER(b.control_group_name),'100K'),0) <> 0;


    CURSOR c_apr_grp2(p_min IN NUMBER, p_max IN NUMBER) IS
    SELECT DISTINCT b.attribute10
      --FROM po.po_control_rules a    --code commented by RXNETHI-ARGANO,19/05/23
      FROM apps.po_control_rules a    --code added by RXNETHI-ARGANO,19/05/23
         , po_control_groups b--, po_control_groups b
     WHERE a.control_group_id = b.control_group_id
       AND a.object_code = 'ACCOUNT_RANGE'
       AND a.rule_type_code = 'INCLUDE'
       AND p_location BETWEEN segment1_low AND segment1_high
      -- AND p_location = segment1_low
--       AND p_location = segment1_high
        AND b.attribute10 IS NOT NULL
--       AND a.control_group_id IN ( SELECT c.control_group_id
--                                     FROM po.po_control_groups_all c
--                                    WHERE c.attribute10 IS NOT NULL )
      AND TO_NUMBER(a.amount_limit) BETWEEN p_min AND p_max;
--      AND b.description = p_apr_grp;

    CURSOR c_mx_apr_grp(p_min IN NUMBER) IS
    SELECT DISTINCT b.attribute10
      --FROM po.po_control_rules a    --code commented by RXNETHI-ARGANO,19/05/23
      FROM apps.po_control_rules a    --code added by RXNETHI-ARGANO,19/05/23
         , po_control_groups b
     WHERE a.control_group_id = b.control_group_id
       AND a.object_code = 'ACCOUNT_RANGE'
       AND a.rule_type_code = 'INCLUDE'
       AND p_location BETWEEN segment1_low AND segment1_high
--       AND p_location = segment1_low
--       AND p_location = segment1_high
        AND b.attribute10 IS NOT NULL
--       AND a.control_group_id IN ( SELECT c.control_group_id
--                                     FROM po.po_control_groups_all c
--                                    WHERE c.attribute10 IS NOT NULL )
      AND TO_NUMBER(a.amount_limit) > p_min;
--      AND b.description = p_apr_grp;


BEGIN

   v_attribute10 := NULL;
   v_emp_name    := NULL;

   IF p_position = 1 THEN

      OPEN c_apr_grp(0,100000);
      FETCH c_apr_grp INTO v_attribute10;
      CLOSE c_apr_grp;



      IF v_attribute10 IS NULL THEN

      OPEN c_100k_apr_grp;
      FETCH c_100k_apr_grp INTO v_attribute10;
      CLOSE c_100k_apr_grp;

      END IF;

   ELSIF p_position = 2 THEN

      OPEN c_apr_grp2(100001,250000);
      FETCH c_apr_grp2 INTO v_attribute10;
      CLOSE c_apr_grp2;

   ELSIF p_position = 3 THEN

      OPEN c_mx_apr_grp(250001);
      FETCH c_mx_apr_grp INTO v_attribute10;
      CLOSE c_mx_apr_grp;

   END IF;

   IF v_attribute10 IS NOT NULL THEN

     OPEN c_emp_name;
     FETCH c_emp_name INTO v_emp_name;
     CLOSE c_emp_name;

   ELSE
    v_emp_name := NULL;
   END IF;

RETURN v_emp_name;

EXCEPTION
  WHEN OTHERS THEN
  RETURN NULL;
END ttec_apr_grp;
/
show errors;
/