create or replace FUNCTION tt_per_after_nov
     ( p_assignment_id IN NUMBER)
RETURN VARCHAR2 AS

/***********************************************************************************
     Program Name: tt_per_after_nov

     Description:  This program used by TT_PER_AFTER_NOV fast formula

     Created by:        Elango Pandu

     Date:              Nov-27-05

     Modification Log
     Developer              Date      Description
     --------------------   --------  --------------------------------
     Elango Pandu           DEC-02-05  Modified this code to exclude PROCESSED Status
	 
     RXNETHI-ARGANO         MAY-19-2023 R12.2 Upgrade Remediation
***********************************************************************************/




CURSOR c1 IS
  SELECT  1
  /*
  START R12.2 Upgrade Remediation
  code commented by RXNETHI-ARGANO,19/05/23
  FROM   hr.per_all_people_f pap,
          hr.per_all_assignments_f paa,
          hr.hr_locations_all hrl,
          hr.per_person_types ppt,
          hr.per_person_type_usages_f ptu,
          hr.per_periods_of_service pos
  */
  --code added by RXNETHI-ARGANO,19/05/23
   FROM   apps.per_all_people_f pap,
          apps.per_all_assignments_f paa,
          apps.hr_locations_all hrl,
          apps.per_person_types ppt,
          apps.per_person_type_usages_f ptu,
          apps.per_periods_of_service pos
  --END R12.2 Upgrade Remediation
  WHERE   pap.person_id NOT IN  (SELECT person_id
                                 --FROM   ben.ben_per_in_ler pil   --code commented by RXNETHI-ARGANO,19/05/23
                                 FROM   apps.ben_per_in_ler pil    --code added by RXNETHI-ARGANO,19/05/23
                                 WHERE  pil.ler_id = 99
                                 AND    pil.lf_evt_ocrd_dt = '1-Jan-2006'
                                 AND    pil.per_in_ler_stat_cd IN ('PROCD','STRTD'))
          AND pap.person_id = paa.person_id
          AND paa.location_id = hrl.location_id
          AND sysdate between pap.effective_start_date and pap.effective_end_date
          AND sysdate between paa.effective_start_date and paa.effective_end_date
          AND pap.person_id = ptu.person_id
          AND ptu.person_type_id = ppt.person_type_id
          AND ppt.person_type_id = 87
          AND SYSDATE BETWEEN ptu.effective_start_date AND ptu.effective_end_date
          AND pap.business_group_id = 325
          AND pap.person_id = pos.person_id
          AND pos.final_process_date is null
          AND pos.date_start > to_date('1-Nov-2005')
          AND paa.employment_category = 'FR'
          AND paa.assignment_id = p_assignment_id;
--
l_var VARCHAR2(1);

BEGIN

--

OPEN c1 ;

FETCH c1 INTO l_var ;

IF c1%FOUND  THEN
      RETURN 'Y' ;
ELSE
    RETURN 'N';
END IF ;

CLOSE c1 ;

END tt_per_after_nov;
/
show errors;
/