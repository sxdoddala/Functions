

/************************************************************************************
        Program Name: TT_PER_SEL_RULE 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI-ARGANO           1.0      19-May-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/


create or replace FUNCTION Tt_Per_Sel_Rule
     ( p_assignment_id IN NUMBER
      ,p_effective_date IN DATE
      ,p_business_group_id IN NUMBER
	  ,p_sel_start_date IN DATE )
	   RETURN VARCHAR2 AS

CURSOR c1 IS
(SELECT 1
 /*
 START R12.2 Upgrade Remediation
 code commented by RXNETHI-ARGANO,19/05/23
 FROM   hr.per_all_people_f pap,
         hr.per_all_assignments_f paa,
         hr.per_person_types ppt,
         hr.per_person_type_usages_f ptu,
         hr.per_periods_of_service pos
 */
 --code added by RXNETHI-ARGANO,19/05/23
  FROM   apps.per_all_people_f pap,
         apps.per_all_assignments_f paa,
         apps.per_person_types ppt,
         apps.per_person_type_usages_f ptu,
         apps.per_periods_of_service pos
 --END R12.2 Upgrade Remediation
 WHERE  pap.person_id NOT IN (SELECT  person_id
                                           --FROM       ben.ben_prtt_enrt_rslt_f    --code commented by RXNETHI-ARGANO,19/05/23
                                           FROM       apps.ben_prtt_enrt_rslt_f     --code added by RXNETHI-ARGANO,19/05/23
                                     WHERE      pl_id = 80
                                     AND       p_effective_date  BETWEEN effective_start_date AND effective_end_date
                                     AND       p_effective_date  BETWEEN enrt_cvg_strt_dt AND enrt_cvg_thru_dt
                                     AND       prtt_enrt_rslt_stat_cd IS NULL)
         AND pap.person_id = paa.person_id
         AND p_effective_date  BETWEEN pap.effective_start_date AND pap.effective_end_date
         AND p_effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date
         AND pap.person_id = ptu.person_id
         AND ptu.person_type_id = ppt.person_type_id
         AND ppt.person_type_id = 87
         AND p_effective_date BETWEEN ptu.effective_start_date AND ptu.effective_end_date
        AND pap.business_group_id = p_business_group_id
         AND pap.person_id = pos.person_id
         AND pos.final_process_date IS NULL
         AND pos.date_start < p_sel_start_date
         AND paa.employment_category = 'FR'
		 AND pap.benefit_group_id IS NOT NULL
		 AND paa.assignment_id = p_assignment_id );
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

END ;
/
show errors;
/
