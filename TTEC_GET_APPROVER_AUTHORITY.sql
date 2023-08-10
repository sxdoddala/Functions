set define off;
create or replace FUNCTION      TTEC_GET_APPROVER_AUTHORITY(p_emp_id                   IN NUMBER
                                                           ,p_approval_authority_level IN VARCHAR2
                                                           ,p_return_info              IN VARCHAR2) --EmpName or EmpNo or EmpId or EmpEmail
                  RETURN VARCHAR2
               IS
-- Program Name:  TTEC_GET_APPROVER_AUTHORITY
-- /* $Header: TTEC_GET_APPROVER_AUTHORITY.fnc 1.0 2013/07/01  chchan ship $ */
--
-- /*== START ================================================================================================*\
--    Author: Christiane Chan
--      Date: 01-JUL2013
--
-- Call From: Concurrent Program ->TeleTech Egencia Outbound Interface
--
--      Desc: This Stored function will return the full_name/employee_number/person_id of the person
--            who is assuming the approval authority in the employee's hierachy
--            the approval authority LEVEL that come through the parameter p_approval_authority_level.
--
--     Parameter Description:
--
--           p_emp_id                  :   Oracle employee id ->person_id
--           p_approval_authority_level:   Approval Authority Level; Valid values can be either 10 or 12
--                                           10 This number represent Final approver authority for SVP( Senior VP))
--                                           12 This number represent Final approver authority for OCM (Operating Comitee Members)
--           p_Approval_Return_Value   :   can be any of the following values (EmpName or EmpNo or EmpId or EmpEmail)
--
--
--       Oracle Standard Parameters:
--
--   Modification History:
--
--  Version    Date     Author   Description (Include Ticket--)
--  -------  --------  --------  ------------------------------------------------------------------------------
--      1.0  07/01/13   C.Chan     Initial Version TTSD R#2601803 - Egencia Extract
--      1.1  08/14/13   C.Chan     TTSD R#2652121 - Enhancement
--      1.2  09/12/13   C.Chan     TTSD R#??????? - pickup approver with higher Level
--      1.3  12/11/13   C.Chan     OCM enhancement
--      1.4  04/20/17   C.Chan     Prevent infinit loop where supervisors going round n round
--      1.5  11/15/17   C.Chan     Added EmpEmail for Oracle Alert on aging card transactions
--      1.0  19/MAY/23  RXNETHI-ARGANO   R12.2 Upgrade Remediation
--
                  l_full_name                VARCHAR2(500);
                  l_supervisor_job_title     VARCHAR2(500);
                  l_job_family               VARCHAR2(500);
                  l_supervisor_type          VARCHAR2(500);
                  l_oracle_id                VARCHAR2(500);
                  l_email_address            VARCHAR2(500);   /* 1.5  */
                  l_email_address_r          VARCHAR2(500);   /* 1.5  */
                  l_supervisor_id            NUMBER(15);
                  l_approval_authority_level NUMBER(15);
                  l_sup_sup_approval_level   NUMBER(15);
                  l_sup_aprv_auth_level      NUMBER(15);
                  l_employee_id              NUMBER(15);
                  l_loop_count               NUMBER(2) := 0; /* 1.4 */
                  l_hierarchy_str1            VARCHAR2(4000);
                  l_hierarchy_str2            VARCHAR2(4000);

               BEGIN


                  -- Get name for employee of leaf node
                  SELECT papf1.employee_number,papf1.full_name,paaf.supervisor_id,j.name Supervisor_job_title,j.attribute5,j.attribute6,j.APPROVAL_AUTHORITY,
                                    (
                    SELECT j3.approval_authority
                      FROM per_all_assignments_f paaf3
                         --, hr.per_jobs j3    --code commented by RXNETHI-ARGANO,19/05/23
                         , apps.per_jobs j3    --code added by RXNETHI-ARGANO,19/05/23
                     WHERE paaf3.job_id = j3.job_id
                       AND paaf3.assignment_type IN ('C', 'E')
                       AND TRUNC (SYSDATE) BETWEEN paaf3.effective_start_date
                                               AND paaf3.effective_end_date
                       AND paaf3.person_id = paaf2.supervisor_id
                  ) sup_sup_approval_level /* 1.3 */
                  INTO   l_oracle_id,l_full_name,l_supervisor_id,l_supervisor_job_title,l_job_family,l_supervisor_type,l_approval_authority_level,l_sup_sup_approval_level
                  FROM   per_all_assignments_f paaf,
                         per_all_assignments_f paaf2,
                         per_all_people_f papf1,
                  	   --hr.per_jobs j     --code commented by RXNETHI-ARGANO,19/05/23
                   	   apps.per_jobs j     --code added by RXNETHI-ARGANO,19/05/23
                  WHERE  paaf.supervisor_id = papf1.person_id
                  and    paaf.supervisor_id = paaf2.person_id
                  AND    paaf.assignment_type in ('C', 'E')
                  and    paaf2.job_id = j.job_id
                  and    TRUNC(sysdate) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                  and    TRUNC(sysdate) BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
                  and    TRUNC(sysdate) BETWEEN papf1.effective_start_date AND papf1.effective_end_date
                  and    paaf.person_id = p_emp_id
                  and    rownum <2 /* 1.1 */
                  order by paaf.effective_start_date desc;  /* 1.1 */

                  l_hierarchy_str1 := l_full_name;
                  l_hierarchy_str2 := l_oracle_id;
                  l_employee_id   := l_supervisor_id;
                  l_loop_count    := 0; /* 1.4 */

                  dbms_output.put_line('############################################' || l_oracle_id);
                  dbms_output.put_line('Level 1: l_oracle_id ->' || l_oracle_id);
                  dbms_output.put_line('Level 1: l_full_name ->' || l_full_name);
                  dbms_output.put_line('Level 1: l_job_family ->' || l_job_family);
                  dbms_output.put_line('Loop l_loop_count ->' || l_loop_count);
                  dbms_output.put_line('Level 1: l_sup_sup_approval_level ->' || l_sup_sup_approval_level);

                  IF l_approval_authority_level <=  p_approval_authority_level
                     and (   ( l_approval_authority_level < 13 and l_job_family <> 'Exec') /* 1.3 */
                          OR ( l_sup_aprv_auth_level = 13 and l_job_family = 'G&A') /* 1.3 */
                          )
                  THEN /* 1.2 */
                      WHILE ((l_supervisor_id IS NOT NULL
                          and  l_sup_sup_approval_level <> 13 )
                          and l_loop_count < 10) LOOP  /* 1.4 */

                      dbms_output.put_line('Loop l_supervisor_id ->' || l_supervisor_id);
                      dbms_output.put_line('Loop l_loop_count ->' || l_loop_count);

                      SELECT papf1.employee_number,papf1.full_name,papf1.EMAIL_ADDRESS,  /* 1.5  */
                             paaf.supervisor_id,j.name Supervisor_job_title,j.attribute5,j.attribute6,j.APPROVAL_AUTHORITY,
                              (
                                SELECT j3.approval_authority
                                  FROM per_all_assignments_f paaf3
                                     --, hr.per_jobs j3    --code commented by RXNETHI-ARGANO,19/05/23
                                     , apps.per_jobs j3    --code added by RXNETHI-ARGANO,19/05/23
                                 WHERE paaf3.job_id = j3.job_id
                                   AND paaf3.assignment_type IN ('C', 'E')
                                   AND TRUNC (SYSDATE) BETWEEN paaf3.effective_start_date
                                                           AND paaf3.effective_end_date
                                   AND paaf3.person_id = paaf2.supervisor_id
                              ) sup_sup_approval_level /* 1.3 */
                      INTO   l_oracle_id,l_full_name,l_email_address,  /* 1.5  */
                             l_supervisor_id,l_supervisor_job_title,l_job_family
                             ,l_supervisor_type,l_approval_authority_level,l_sup_sup_approval_level
                      FROM   per_all_assignments_f paaf,
                             per_all_assignments_f paaf2,
                             per_all_people_f papf1,
                             --hr.per_jobs j     --code commented by RXNETHI-ARGANO,19/05/23
                             apps.per_jobs j     --code added by RXNETHI-ARGANO,19/05/23
                      WHERE  paaf.supervisor_id = papf1.person_id
                      and    paaf.supervisor_id = paaf2.person_id
                      and    paaf2.job_id = j.job_id
                      AND    paaf.assignment_type in ('C', 'E')
                      and    TRUNC(sysdate) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                      and    TRUNC(sysdate) BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
                      and    TRUNC(sysdate) BETWEEN papf1.effective_start_date AND papf1.effective_end_date
                      and    paaf.person_id = l_employee_id
                      and    rownum <2  /* 1.1 */
                      order by paaf.effective_start_date desc;   /* 1.1 */

                      l_hierarchy_str1 := l_full_name;
                      l_hierarchy_str2 := l_oracle_id;
                      l_employee_id   := l_supervisor_id;
                      l_email_address_r := l_email_address;  /* 1.5  */
                      l_loop_count    := l_loop_count + 1; /* 1.4 */
                        dbms_output.put_line('Loop l_approval_authority_level ->' || l_approval_authority_level);
                        dbms_output.put_line('l_job_family ->' || l_job_family);
                        dbms_output.put_line('l_sup_sup_approval_level ->' || l_sup_sup_approval_level);


                      EXIT WHEN l_approval_authority_level >= p_approval_authority_level
                               OR l_loop_count = 10; /* 1.4 */


                      END LOOP;
                  END IF;

                  IF p_return_info = 'EmpName' THEN
                     RETURN l_hierarchy_str1;
                  ELSIF p_return_info = 'EmpNo' THEN
                     RETURN l_hierarchy_str2;
                  ELSIF p_return_info = 'EmpId' THEN
                     RETURN to_char(l_employee_id);
                  ELSIF p_return_info = 'EmpEmail' THEN  /* 1.5  */
                     RETURN to_char(l_email_address_r);   /* 1.5  */
                  ELSE
                     RETURN l_hierarchy_str1;
                  END IF;
               END;
               /
               show errors;
               /