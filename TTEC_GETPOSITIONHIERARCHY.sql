create or replace FUNCTION TTEC_GETPOSITIONHIERARCHY(p_emp_id          IN NUMBER
                                                    ,p_supervisor_type IN VARCHAR2)
                  RETURN VARCHAR2
               IS

   /*
   --   For BA ->  AP_AmExCreditCardTermination
   --
   --  Author  : Christiane Chan
   --  Created : 15-Feb-2007
   --
   --  Description :
   --      This Stored function will return the name of the person who is assuming the
   --      the supervisor TITLE that come through the parameter p_supervisor_type.
   --
   --      For example: The direct VP Report of the employee who is being terminated
   --
   --       ,NVL(apps.TTEC_GETPOSITIONHIERARCHY(ppos.person_id,'Vice-President 1'),NVL(apps.TTEC_GETPOSITIONHIERARCHY(ppos.person_id,'Senior Vice President'),apps.TTEC_GETPOSITIONHIERARCHY(ppos.person_id,'Operating Committee Mem'))) VP_Report
   --
   --
   --  MODIFICATION HISTORY :
   --     Version    Date Modified    Author    Description
   --
   --     1.0        19/MAY/2023      RXNETHI-ARGANO  R12.2 Upgrade Remediation

   */

                  l_full_name               VARCHAR2(500);
                  l_supervisor_job_title    VARCHAR2(500);
                  l_supervisor_type         VARCHAR2(500);
                  l_supervisor_id           NUMBER(15);
                  l_employee_id             NUMBER(15);
                  l_hierarchy_str           VARCHAR2(4000);

               BEGIN

                  -- Get name for employee of leaf node
                  SELECT papf1.full_name,paaf.supervisor_id,j.name Supervisor_job_title,j.attribute6
                  INTO   l_full_name,l_supervisor_id,l_supervisor_job_title,l_supervisor_type
                  FROM   per_all_assignments_f paaf,
                         per_all_assignments_f paaf2,
                         per_all_people_f papf1,
                  	   --hr.per_jobs j    --code commented by RXNETHI-ARGANO,19/05/23
                  	   apps.per_jobs j    --code added by RXNETHI-ARGANO,19/05/23
                  WHERE  paaf.supervisor_id = papf1.person_id
                  and    paaf.supervisor_id = paaf2.person_id
                  and    paaf2.job_id = j.job_id
                  and    TRUNC(sysdate) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                  and    TRUNC(sysdate) BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
                  and    TRUNC(sysdate) BETWEEN papf1.effective_start_date AND papf1.effective_end_date
                  and    paaf.person_id = p_emp_id;

                  l_hierarchy_str := l_full_name;
                  l_employee_id   := l_supervisor_id;

                  WHILE l_supervisor_id IS NOT NULL LOOP
                  SELECT papf1.full_name,paaf.supervisor_id,j.name Supervisor_job_title,j.attribute6
                  INTO   l_full_name,l_supervisor_id,l_supervisor_job_title,l_supervisor_type
                  FROM   per_all_assignments_f paaf,
                         per_all_assignments_f paaf2,
                         per_all_people_f papf1,
                  	   --hr.per_jobs j     --code commented by RXNETHI-ARGANO,19/05/23
                  	   apps.per_jobs j     --code added by RXNETHI-ARGANO,19/05/23
                  WHERE  paaf.supervisor_id = papf1.person_id
                  and    paaf.supervisor_id = paaf2.person_id
                  and    paaf2.job_id = j.job_id
                  and    TRUNC(sysdate) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                  and    TRUNC(sysdate) BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
                  and    TRUNC(sysdate) BETWEEN papf1.effective_start_date AND papf1.effective_end_date
                  and    paaf.person_id = l_employee_id;

                  l_hierarchy_str := l_full_name;
                  l_employee_id   := l_supervisor_id;

                     EXIT WHEN l_supervisor_type = p_supervisor_type;

                  END LOOP;
                  RETURN l_hierarchy_str;
               END;
/
show errors;
/
