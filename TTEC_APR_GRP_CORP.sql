create or replace FUNCTION      ttec_apr_grp_corp(p_dept IN VARCHAR2,p_position IN VARCHAR2 ) RETURN VARCHAR2 IS

/********************************************************************************
    PROGRAM NAME:   ttec_apr_grp_corp

    DESCRIPTION:    This function is returns employee name for authorize apporval limit

    INPUT      :   department,  position

    OUTPUT     :   Emeployee Name

    CREATED BY:     Elango Pandurangan

    DATE:           24-MAR-2009

    CALLING FROM   :  TeleTech Corporate Purchase Requisition Approval Matrix - Finance

    ----------------
    MODIFICATION LOG
    ----------------


    DEVELOPER             DATE          DESCRIPTION
    -------------------   ------------  -----------------------------------------
    Elango Pandu
	
	RXNETHI-ARGANO        19/MAY/2023   R12.2 Upgrade Remediation
********************************************************************************/

    v_emp_name per_all_people_f.full_name%TYPE;


    CURSOR c_apr_grp(p_location IN VARCHAR2,p_dept IN VARCHAR2) IS
    SELECT DISTINCT papf.full_name
      --FROM po.po_control_rules a    --code commented by RXNETHI-ARGANO,19/05/23
      FROM apps.po_control_rules a    --code added by RXNETHI-ARGANO,19/05/23
         , po_control_groups_all b
         , per_all_people_f papf
     WHERE a.control_group_id = b.control_group_id
       AND b.attribute10 = papf.person_id
       AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
       AND a.object_code = 'ACCOUNT_RANGE'
       AND a.rule_type_code = 'INCLUDE'
       AND segment1_low = p_location
       AND segment3_low = p_dept
        AND b.attribute10 IS NOT NULL
      AND TO_NUMBER(a.amount_limit) BETWEEN 0 AND 100000;



   CURSOR c_apr_grp2(p_location IN VARCHAR2,p_dept IN VARCHAR2) IS
    SELECT DISTINCT papf.full_name
      --FROM po.po_control_rules a   --code commented by RXNETHI-ARGANO,19/05/23
      FROM apps.po_control_rules a   --code added by RXNETHI-ARGANO,19/05/23
         , po_control_groups b
         , per_all_people_f papf
     WHERE a.control_group_id = b.control_group_id
       AND a.object_code = 'ACCOUNT_RANGE'
       AND a.rule_type_code = 'INCLUDE'
       AND b.attribute10 = papf.person_id
       AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
       AND p_location BETWEEN segment1_low AND segment1_high
       AND p_dept  BETWEEN segment3_low AND segment3_high
       AND b.attribute10 IS NOT NULL
       AND TO_NUMBER(a.amount_limit) BETWEEN 100001 AND 250000;

/*
    CURSOR c_mx_apr_grp(p_location IN VARCHAR2,p_dept IN VARCHAR2) IS
    SELECT DISTINCT papf.full_name
      FROM po.po_control_rules a
         , po_control_groups b
         , per_all_people_f papf
     WHERE a.control_group_id = b.control_group_id
       AND b.attribute10 = papf.person_id
       AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
       AND a.object_code = 'ACCOUNT_RANGE'
       AND a.rule_type_code = 'INCLUDE'
       AND p_location BETWEEN segment1_low AND segment1_high
       AND p_dept  BETWEEN segment3_low AND segment3_high
       AND b.attribute10 IS NOT NULL
       AND TO_NUMBER(a.amount_limit) > 250001; */

    CURSOR c_mx_apr_grp IS
    SELECT DISTINCT papf.full_name
      --FROM po.po_control_rules a   --code commented by RXNETHI-ARGANO,19/05/23
      FROM apps.po_control_rules a   --code added by RXNETHI-ARGANO,19/05/23
         , po_control_groups b
         , per_all_people_f papf
     WHERE a.control_group_id = b.control_group_id
       AND b.attribute10 = papf.person_id
       AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
       AND a.object_code LIKE 'DOCUMENT_TOTAL'
       AND b.attribute10 IS NOT NULL
      AND TO_NUMBER(a.amount_limit) > 250000;

BEGIN

   v_emp_name    := NULL;
   IF p_position = 1 THEN

      OPEN c_apr_grp('01002',p_dept);
      FETCH c_apr_grp INTO v_emp_name;
      CLOSE c_apr_grp;

   ELSIF p_position = 2 THEN

      OPEN c_apr_grp2('01002',p_dept);
      FETCH c_apr_grp2 INTO v_emp_name;
      CLOSE c_apr_grp2;

   ELSIF p_position = 3 THEN

      OPEN c_mx_apr_grp;
      FETCH c_mx_apr_grp INTO v_emp_name;
      CLOSE c_mx_apr_grp;

   ELSIF p_position = 4 THEN

      OPEN c_apr_grp('01050',p_dept);
      FETCH c_apr_grp INTO v_emp_name;
      CLOSE c_apr_grp;

   ELSIF p_position = 5 THEN
      OPEN c_apr_grp2('01050',p_dept);
      FETCH c_apr_grp2 INTO v_emp_name;
      CLOSE c_apr_grp2;
   ELSIF p_position = 6 THEN
      OPEN c_mx_apr_grp;
      FETCH c_mx_apr_grp INTO v_emp_name;
      CLOSE c_mx_apr_grp;

   END IF;


RETURN v_emp_name;

EXCEPTION
  WHEN OTHERS THEN
  RETURN 'ERR';
END ttec_apr_grp_corp;
/
show errors;
/