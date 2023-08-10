/*
START R12.2 Upgrade Remediation
code commented by RXNETHI-ARGANO,19/05/23
create or replace FUNCTION      ttec_f_grade_mid (p_location hr.hr_locations_all.location_code%type,
                                        p_job hr.per_jobs.name%type,
                                        p_business_group apps.per_business_groups.business_group_id%type,
                                        p_job_information3 hr.per_jobs.job_information3%type,
                                        p_attribute9 hr.per_jobs.attribute9%type,
                                        p_attribute5 hr.per_jobs.attribute5%type
*/
--code added by RXNETHI-ARGANO,19/05/23
create or replace FUNCTION      ttec_f_grade_mid (p_location apps.hr_locations_all.location_code%type,
                                        p_job apps.per_jobs.name%type,
                                        p_business_group apps.per_business_groups.business_group_id%type,
                                        p_job_information3 apps.per_jobs.job_information3%type,
                                        p_attribute9 apps.per_jobs.attribute9%type,
                                        p_attribute5 apps.per_jobs.attribute5%type
--END R12.2 Upgrade Remediation
                                        )
                           RETURN PLS_INTEGER IS

-- Program Name:  TTEC_F_GRADE_MID
-- /* $Header: TTEC_F_GRADE_MID.fnc 1.0  */
--
-- /*== START ================================================================================================*\
--    Author: Morinigo Laura
--      Date: 09-DEC2013
--
-- Call From: Discoverer Report-> Data For Population Review With Grades
--
--      Desc: This function returns the middle grade of salary depending on the location and job code of an employee.
--
--     Parameter Description:
--
--           p_location                :   Employee's Location
--           p_job					   :   Employee's job name
--           p_business_group   	   :   Employee's business group
--			 p_job_information3        :   Indicates if the employee's job type is NEX or EX if the employee belongs to USA or CANADA
--           p_attribute9              :   Indicates if the employee's job type is NEX or EX if the employee belongs to PHILLIPPINES
--			 p_attribute5              :   Indicates the job family of the employee
--
--   Modification History:
--
--  Version    Date     Author  	 Description (Include Ticket--)
--  -------  --------  --------  	 ------------------------------------------------------------------------------
--      1.0  07/01/13   LXMORINIGO   Creation of the function
--      1.0  19/MAY/2023  RXNETHI-ARGANO  R12.2 Upgrade Remediation

P_MID NUMBER(16,2);


BEGIN

   BEGIN



    SELECT   pgrf.mid_value

    INTO     p_mid

    /*
	START R12.2 Upgrade Remediation
	code commented by RXNETHI-ARGANO,19/05/23
	FROM   hr.pay_grade_rules_f pgrf,
           hr.pay_grade_rules_f pgrf_min,
           hr.per_grades pg,
    */
    --code added by RXNETHI-ARGANO,19/05/23
    FROM   apps.pay_grade_rules_f pgrf,
           apps.pay_grade_rules_f pgrf_min,
           apps.per_grades pg,
	--END R12.2 Upgrade Remediation    
	       apps.fnd_currencies_vl cur
    WHERE   pg.business_group_id = p_business_group
    AND NVL (pg.date_to, '31-DEC-4712') = NVL ((SELECT  MAX (pg_sub.date_to)
                                                --FROM    hr.per_grades pg_sub    --code commented by RXNETHI-ARGANO,19/05/23
                                                FROM    apps.per_grades pg_sub    --code added by RXNETHI-ARGANO,19/05/23
                                                WHERE   pg_sub.grade_id = pg.grade_id), '31-DEC-4712')
    AND pgrf.effective_end_date = (SELECT   MAX (pgrf_sub.effective_end_date)
                                    --FROM   hr.pay_grade_rules_f pgrf_sub   --code commented by RXNETHI-ARGANO,19/05/23
                                    FROM   apps.pay_grade_rules_f pgrf_sub   --code added by RXNETHI-ARGANO,19/05/23
                                    WHERE   pgrf.grade_rule_id = pgrf_sub.grade_rule_id)
    AND pgrf_min.grade_or_spinal_point_id = pgrf.grade_or_spinal_point_id
    AND pgrf_min.effective_start_date = (SELECT   MIN (pgrf_sub2.effective_start_date)
                                         --FROM    hr.pay_grade_rules_f pgrf_sub2    --code commented by RXNETHI-ARGANO,19/05/23
                                         FROM    apps.pay_grade_rules_f pgrf_sub2    --code added by RXNETHI-ARGANO,19/05/23
                                         WHERE   pgrf_min.grade_rule_id = pgrf_sub2.grade_rule_id)
    AND pg.grade_id = pgrf.grade_or_spinal_point_id
    AND cur.currency_code(+) = pgrf.currency_code
    AND  REPLACE(SUBSTR(pg.name,INSTR (pg.name, '.') + 1),'\') = p_location
    AND  SUBSTR(pg.name, 1, INSTR (pg.name, '.') - 1)  = p_job;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_mid := null;
    END;


      IF p_job_information3 = 'NEX' AND p_business_group IN (325,326)  THEN

            p_mid := ROUND( TO_NUMBER (p_mid) * 2080 , -3);


      ELSIF p_attribute9 = 'NEX' AND p_business_group IN (1517)   THEN

            p_mid := ROUND( TO_NUMBER (p_mid) * 12, -3 );

      END IF;

    RETURN p_mid;

EXCEPTION



WHEN OTHERS THEN
RETURN 0;

END;
/
show errors;
/