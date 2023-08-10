create or replace FUNCTION      TTEC_GET_ATELKA_OT (
  p_assignment_id     IN    NUMBER
   ,p_pay_start_dt    IN DATE
   ,p_pay_end_dt    IN DATE
   ,p_earned_date IN DATE
  )
    RETURN NUMBER
  IS

  /*



Program Name    : TTEC_GET_ATELKA_OT

Desciption      : To  calculate Prime overtime calculation using weighter average calc method


Input/Output Parameters

Called From     :  TTEC_GET_ATELKA_OT Formula function. PRIME_OVT_HOURS_X_RATE_PREPROD Formula attached
                  to Prime OVT Element


Created By      :  Elango Pandu
Date            :  20-NOV- 2017

Modification Log:
-----------------
Ver        Developer             Date                    Description

1.0        RXNETHI-ARGANO        19/MAY/2023             R12.2 Upgrade Remediation

  1044597

  */

   v_employee_number VARCHAR2(10);
   v_prov VARCHAR2(10);


    v_assignment_id NUMBER;
    l_return NUMBER := 0;
    v_tot_ot_wages NUMBER := 0;
    v_tot_reg_wages NUMBER := 0;
    v_tot_hours NUMBER := 0;
    v_ot_hours NUMBER := 0;
    v_ot_prem_rate NUMBER := 0;
    v_return NUMBER := 0;
    v_ot_count NUMBER := 0;

   a number := 0;
   b number := 0;
   c number := 0;
   d number := 0;
   e number := 0;

    v_rate NUMBER := 0;
    v_reg_hours NUMBER := 0;
    v_ovt_hours NUMBER := 0;
    v_total NUMBER := 0;
    v_comm_hours  NUMBER := 0;
    v_strt_dt DATE;
    v_end_dt DATE ;

    CURSOR c_prov IS
     SELECT papf.employee_number,pa.region_1 FROM apps.per_addresses pa, apps.per_all_people_f papf,apps.per_all_assignments_f paaf
     WHERE papf.person_id = paaf.person_id
     AND papf.person_id = pa.person_id
     AND paaf.assignment_id = p_assignment_id
     AND TRUNC(SYSDATE) BETWEEN papf.effective_start_date AND papf.effective_end_date
     AND TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date
     AND pa.primary_flag = 'Y'
     AND TRUNC(SYSDATE) BETWEEN date_from AND NVL( date_to,'31-DEC-4712');


     CURSOR c_ele_hours(p_ele_name IN VARCHAR2,p_strt_dt IN DATE, p_end_dt IN DATE) IS
      SELECT
            SUM(NVL(to_number(peevf.screen_entry_value),0))
        FROM apps.per_all_assignments_f       paf,
             apps.pay_element_entries_f       peef,
             apps.pay_element_entry_values_f  peevf,
             apps.pay_element_links_f         pelf,
             apps.pay_element_types_f         petf,
             apps.pay_input_values_f          pivf,
             apps.pay_element_classifications pec
       WHERE TRUNC(p_pay_end_dt) BETWEEN paf.effective_start_date AND
             paf.effective_end_date
         AND paf.assignment_id = peef.assignment_id
         AND TRUNC(p_pay_end_dt) BETWEEN peef.effective_start_date AND  peef.effective_end_date
         AND peef.element_entry_id = peevf.element_entry_id
         AND TRUNC(p_pay_end_dt) BETWEEN peevf.effective_start_date AND peevf.effective_end_date
         AND peef.element_link_id = pelf.element_link_id
         AND TRUNC(p_pay_end_dt) BETWEEN pelf.effective_start_date AND pelf.effective_end_date
         AND pelf.element_type_id = petf.element_type_id
         AND TRUNC(p_pay_end_dt) BETWEEN petf.effective_start_date AND petf.effective_end_date
         AND peevf.input_value_id = pivf.input_value_id
         AND TRUNC(p_pay_end_dt) BETWEEN pivf.effective_start_date AND pivf.effective_end_date
         AND peevf.screen_entry_value IS NOT NULL
         AND petf.classification_id = pec.classification_id
         AND petf.reporting_name = p_ele_name --'Prime OVT'
         AND pivf.name = 'Hours'
         AND PAF.ASSIGNMENT_ID = p_assignment_id
         AND date_earned BETWEEN p_strt_dt AND p_end_dt;


     CURSOR c_ele_wages( p_strt_dt IN DATE, p_end_dt IN DATE) IS
      SELECT
            SUM((NVL(peevf.screen_entry_value,0) *
                      NVL((SELECT p.proposed_salary_n
                            --FROM hr.per_pay_proposals p    --code commented by RXNETHI-ARGANO,19/05/23
                            FROM apps.per_pay_proposals p    --code added by RXNETHI-ARGANO,19/05/23
                            WHERE p.assignment_id = paf.assignment_id
                            AND peef.date_earned BETWEEN p.change_date AND NVL(p.date_to,'31-DEC-4712')),0))) wage
        FROM apps.per_all_assignments_f       paf,
             apps.pay_element_entries_f       peef,
             apps.pay_element_entry_values_f  peevf,
             apps.pay_element_links_f         pelf,
             apps.pay_element_types_f         petf,
             apps.pay_input_values_f          pivf,
             apps.pay_element_classifications pec
       WHERE TRUNC(p_pay_end_dt) BETWEEN paf.effective_start_date AND
             paf.effective_end_date
         AND paf.assignment_id = peef.assignment_id
         AND TRUNC(p_pay_end_dt) BETWEEN peef.effective_start_date AND  peef.effective_end_date
         AND peef.element_entry_id = peevf.element_entry_id
         AND TRUNC(p_pay_end_dt) BETWEEN peevf.effective_start_date AND peevf.effective_end_date
         AND peef.element_link_id = pelf.element_link_id
         AND TRUNC(p_pay_end_dt) BETWEEN pelf.effective_start_date AND pelf.effective_end_date
         AND pelf.element_type_id = petf.element_type_id
         AND TRUNC(p_pay_end_dt) BETWEEN petf.effective_start_date AND petf.effective_end_date
         AND peevf.input_value_id = pivf.input_value_id
         AND TRUNC(p_pay_end_dt) BETWEEN pivf.effective_start_date AND pivf.effective_end_date
         AND peevf.screen_entry_value IS NOT NULL
         AND petf.classification_id = pec.classification_id
         AND petf.reporting_name = 'TT Time Entry Wages'
         AND pivf.name = 'Hours'
         AND PAF.ASSIGNMENT_ID = p_assignment_id
         AND date_earned BETWEEN p_strt_dt AND p_end_dt;
        -- AND date_earned BETWEEN (peef.effective_start_date + 7) AND peef.effective_end_date

     CURSOR c_comm_hours(p_strt_dt IN DATE, p_end_dt IN DATE) IS
      SELECT
            SUM(NVL(to_number(peevf.screen_entry_value),0))
        FROM apps.per_all_assignments_f       paf,
             apps.pay_element_entries_f       peef,
             apps.pay_element_entry_values_f  peevf,
             apps.pay_element_links_f         pelf,
             apps.pay_element_types_f         petf,
             apps.pay_input_values_f          pivf,
             apps.pay_element_classifications pec
       WHERE TRUNC(p_pay_end_dt) BETWEEN paf.effective_start_date AND
             paf.effective_end_date
         AND paf.assignment_id = peef.assignment_id
         AND TRUNC(p_pay_end_dt) BETWEEN peef.effective_start_date AND  peef.effective_end_date
         AND peef.element_entry_id = peevf.element_entry_id
         AND TRUNC(p_pay_end_dt) BETWEEN peevf.effective_start_date AND peevf.effective_end_date
         AND peef.element_link_id = pelf.element_link_id
         AND TRUNC(p_pay_end_dt) BETWEEN pelf.effective_start_date AND pelf.effective_end_date
         AND pelf.element_type_id = petf.element_type_id
         AND TRUNC(p_pay_end_dt) BETWEEN petf.effective_start_date AND petf.effective_end_date
         AND peevf.input_value_id = pivf.input_value_id
         AND TRUNC(p_pay_end_dt) BETWEEN pivf.effective_start_date AND pivf.effective_end_date
         AND peevf.screen_entry_value IS NOT NULL
         AND petf.classification_id = pec.classification_id
         --AND petf.reporting_name IN ('Commission','CommissionBillable_Atelka')
         AND petf.reporting_name IN ('Commission','Commission_Billable')
         AND pivf.name = 'Amount'
         AND paf.assignment_id = p_assignment_id
         AND date_earned BETWEEN p_strt_dt AND p_end_dt;


     CURSOR c_rate(p_date IN DATE) IS
            SELECT p.proposed_salary_n
            --FROM hr.per_pay_proposals p   --code commented by RXNETHI-ARGANO,19/05/23
            FROM apps.per_pay_proposals p   --code added by RXNETHI-ARGANO,19/05/23
            WHERE p.assignment_id = p_assignment_id
            AND p_date BETWEEN p.change_date AND NVL(p.date_to,'31-DEC-4712');


     CURSOR c_ot_count IS
      SELECT
            COUNT(*)
        FROM apps.per_all_assignments_f       paf,
             apps.pay_element_entries_f       peef,
             apps.pay_element_entry_values_f  peevf,
             apps.pay_element_links_f         pelf,
             apps.pay_element_types_f         petf,
             apps.pay_input_values_f          pivf,
             apps.pay_element_classifications pec
       WHERE TRUNC(p_pay_end_dt) BETWEEN paf.effective_start_date AND
             paf.effective_end_date
         AND paf.assignment_id = peef.assignment_id
         AND TRUNC(p_pay_end_dt) BETWEEN peef.effective_start_date AND  peef.effective_end_date
         AND peef.element_entry_id = peevf.element_entry_id
         AND TRUNC(p_pay_end_dt) BETWEEN peevf.effective_start_date AND peevf.effective_end_date
         AND peef.element_link_id = pelf.element_link_id
         AND TRUNC(p_pay_end_dt) BETWEEN pelf.effective_start_date AND pelf.effective_end_date
         AND pelf.element_type_id = petf.element_type_id
         AND TRUNC(p_pay_end_dt) BETWEEN petf.effective_start_date AND petf.effective_end_date
         AND peevf.input_value_id = pivf.input_value_id
         AND TRUNC(p_pay_end_dt) BETWEEN pivf.effective_start_date AND pivf.effective_end_date
         AND peevf.screen_entry_value IS NOT NULL
         AND petf.classification_id = pec.classification_id
         AND petf.reporting_name = 'Prime OVT'
         AND pivf.name = 'Hours'
         AND PAF.ASSIGNMENT_ID = p_assignment_id
         AND date_earned BETWEEN p_pay_start_dt AND p_pay_end_dt;



  --
BEGIN

 v_prov := NULL;

 OPEN c_prov;
 FETCH c_prov INTO v_employee_number,v_prov;
 CLOSE c_prov;

 IF NVL(v_prov,'XX')  = 'ON' THEN -- 'ON' THEN

       FOR I IN 1 .. 2 LOOP

         IF I = 1 THEN

            v_strt_dt := TRUNC(p_pay_start_dt);
            v_end_dt :=  TRUNC(p_pay_start_dt) +6 ;

         ELSIF I = 2 THEN

            v_strt_dt := TRUNC(p_pay_start_dt) +7 ;
            v_end_dt :=  TRUNC(p_pay_end_dt) ;

         END IF; -- End if for strt AND end dt asg



             v_ovt_hours := 0;

             OPEN c_ele_hours('Prime OVT',v_strt_dt,v_end_dt);
             FETCH c_ele_hours INTO v_ovt_hours;
             CLOSE c_ele_hours;


             v_comm_hours := 0;

             OPEN c_comm_hours(v_strt_dt,v_end_dt);
             FETCH c_comm_hours INTO v_comm_hours;
             CLOSE c_comm_hours;


             IF NVL(v_ovt_hours,0) <> 0 AND NVL(v_comm_hours,0) <> 0 THEN

                     v_tot_reg_wages := 0;

                     OPEN c_ele_wages(v_strt_dt,v_end_dt);
                     FETCH c_ele_wages INTO v_tot_reg_wages;
                     CLOSE c_ele_wages;



                     v_reg_hours := 0;

                     OPEN c_ele_hours('TT Time Entry Wages',v_strt_dt,v_end_dt);
                     FETCH c_ele_hours INTO v_reg_hours;
                     CLOSE c_ele_hours;

                     v_rate := 0;

                     OPEN c_rate(v_end_dt);   -- End of week rate so passing week end date
                     FETCH c_rate INTO v_rate;
                     CLOSE c_rate;

                     -- Used variables as  a b c d as they defined in BRD

                     a := NVL(v_tot_reg_wages,0) + NVL(v_comm_hours,0);

                     IF NVL(v_reg_hours,0) <> 0 THEN
                       b := NVL(a,0) / v_reg_hours;
                     END IF;


                     c := NVL(b,0) * 1.5 ;

                     d := NVL(c,0) * NVL(v_ovt_hours,0);

                     e := (d - ( NVL(v_ovt_hours,0) * (1.5 * NVL(v_rate,0))) );

                    -- INSERT INTO ttec_atelka_testing(ee_num,asg_id, strt_dt, wages, commision, hours, ot,rate ,a, b,c,d,e,dtl ) VALUES (v_employee_number,p_assignment_id,v_strt_dt,v_tot_reg_wages,v_comm_hours,v_reg_hours,v_ovt_hours,v_rate,a,b,c,d,e,'Success');



             ELSE
                    v_tot_reg_wages := 0;
                    v_reg_hours := 0;
                    v_rate := 0;

                       a := 0;
                       b := 0;
                       c := 0;
                       d := 0;
                       e := 0 ;


             END IF;  -- OV HOURS AND COMMISSION HOURS  END IF

                v_return := NVL(v_return,0) + NVL(e,0);

        END LOOP;


         v_ot_count:= 0;

         OPEN c_ot_count;
         FETCH c_ot_count INTO v_ot_count;
         CLOSE c_ot_count;

         IF NVL(v_ot_count,0) > 0 THEN
           v_return := v_return/v_ot_count;
         END IF;
    ELSE
      v_return := 0 ;
    END IF; -- Province end if
    RETURN v_return;

  EXCEPTION
     WHEN OTHERS THEN
        v_return := -1;
         RETURN v_return ;
  END TTEC_GET_ATELKA_OT;
  /
  show errors;
  /