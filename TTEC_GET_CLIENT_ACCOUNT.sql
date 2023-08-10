create or replace FUNCTION TTEC_GET_CLIENT_ACCOUNT  (p_asg_id in Number )
 RETURN VARCHAR2
 IS
 
 
 /************************************************************************************
        Program Name: TTEC_PO_TSG_INTERFACE 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI(ARGANO)            1.0      19-May-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/
 
 
 
v_client varchar2(4) DEFAULT NULL ;
V_VALUE VARCHAR2(60)   DEFAULT NULL ;
V_PERSON_ID    VARCHAR2(10)  DEFAULT NULL;

BEGIN


BEGIN
   V_CLIENT := NULL;
   SELECT pcak.segment2
     INTO v_client
     FROM per_all_assignments_f paaf,
          apps.pay_cost_allocations_f pcaf,
          apps.pay_cost_allocation_keyflex pcak
    WHERE paaf.primary_flag = 'Y' AND paaf.assignment_id = pcaf.assignment_id
          AND pcaf.cost_allocation_keyflex_id =
                 pcak.cost_allocation_keyflex_id
          AND SYSDATE BETWEEN paaf.effective_start_date
                          AND paaf.effective_end_date
          AND SYSDATE BETWEEN pcaf.effective_start_date
                          AND pcaf.effective_end_date
          AND paaf.assignment_id = p_asg_id;                   --706279
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      V_CLIENT := '11111';
   WHEN OTHERS
   THEN
      V_CLIENT := '11111';
END;
/* Formatted on 2/11/2013 2:04:55 PM (QP5 v5.163.1008.3004) */
BEGIN
   V_VALUE := NULL;
   SELECT info.VALUE
     INTO V_VALUE
     /*
	 START R12.2 Upgrade Remediation
	 code commented by RXNETHI,19/05/23
	 FROM hr.pay_user_columns col,
          hr.pay_user_rows_f rowt,
          hr.PAY_USER_COLUMN_INSTANCES_F info,
          hr.pay_user_tables tab
     */
	 --code added by RXNETHI-ARGANO,19/05/23
	 FROM apps.pay_user_columns col,
          apps.pay_user_rows_f rowt,
          apps.PAY_USER_COLUMN_INSTANCES_F info,
          apps.pay_user_tables tab
	 --END R12.2 Upgrade Remediation
	WHERE     tab.user_table_Name = 'TTEC_PHL_CLIENT_CODES'
          AND tab.user_table_id = col.user_table_id
          AND tab.user_table_id = rowt.user_table_id
          AND col.USER_COLUMN_ID = info.USER_COLUMN_ID
          AND rowt.user_row_id = info.user_row_id
          AND SYSDATE BETWEEN info.effective_start_date
                          AND info.effective_end_date
          AND col.user_column_name = 'CLIENT_CODES'
          AND SYSDATE BETWEEN rowt.effective_start_date
                          AND rowt.effective_end_date
          AND SUBSTR (rowt.row_low_range_or_name, 1, 4) = V_CLIENT;    -- 0188
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      V_VALUE := 'N/A';
   WHEN OTHERS
   THEN
      V_VALUE := 'N/A';
END;

/* Formatted on 2/11/2013 2:11:09 PM (QP5 v5.163.1008.3004) */
BEGIN
V_PERSON_ID := NULL ;
   SELECT rowt.ROW_LOW_RANGE_OR_NAME
     INTO V_PERSON_ID
     /*
	 START R12.2 Upgrade Remediation
	 code commented by RXNETHI-ARGANO,19/05/23
	 FROM hr.pay_user_columns col,
          hr.pay_user_rows_f rowt,
          hr.PAY_USER_COLUMN_INSTANCES_F info,
          hr.pay_user_tables tab
     */
	 --code added by RXNETHI-ARGANO,19/05/23
	 FROM apps.pay_user_columns col,
          apps.pay_user_rows_f rowt,
          apps.PAY_USER_COLUMN_INSTANCES_F info,
          apps.pay_user_tables tab
	 --END R12.2 Upgrade Remediation
	WHERE     tab.user_table_Name = 'TTEC_PHL_CLIENT_AME_APPROVER'
          AND tab.user_table_id = col.user_table_id
          AND tab.user_table_id = rowt.user_table_id
          AND col.USER_COLUMN_ID = info.USER_COLUMN_ID
          AND rowt.user_row_id = info.user_row_id
          AND SYSDATE BETWEEN info.effective_start_date
                          AND info.effective_end_date
          AND col.user_column_name = V_VALUE
          AND SYSDATE BETWEEN rowt.effective_start_date
                          AND rowt.effective_end_date;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      V_VALUE := '0000';
   WHEN OTHERS
   THEN
      V_VALUE := '0000';
END;
        RETURN(V_PERSON_ID) ;

END ;
/
show errors;
/