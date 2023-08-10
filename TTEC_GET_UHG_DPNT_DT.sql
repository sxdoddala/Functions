

 /************************************************************************************
        Program Name: TTEC_GET_UHG_DPNT_DT 

        Description:   

        Developed by : 
        Date         :  

       Modification Log
       Name                  Version #    Date            Description
       -----                 --------     -----           -------------
    RXNETHI(ARGANO)            1.0      19-May-2023      R12.2 Upgrade Remediation
    ****************************************************************************************/


create or replace FUNCTION      ttec_get_uhg_dpnt_dt (
   p_prtt_enrt_person_id   NUMBER,
   p_prtt_enrt_rslt_id     NUMBER
)
   RETURN DATE
IS
   l_result   DATE;

   CURSOR c1
   IS
      SELECT a.cvg_strt_dt
        FROM ben_elig_cvrd_dpnt_f a
       WHERE a.dpnt_person_id = p_prtt_enrt_person_id
         AND a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         AND a.cvg_strt_dt IN (
                SELECT MAX (b.cvg_strt_dt)
                  FROM ben_elig_cvrd_dpnt_f b
                 WHERE b.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
                   AND b.dpnt_person_id = p_prtt_enrt_person_id);

   CURSOR c2
   IS
       --SELECT a.enrt_cvg_strt_dt FROM ben.BEN_PRTT_ENRT_RSLT_F a   --code commented by RXNETHI-ARGANO,19/05/23
       SELECT a.enrt_cvg_strt_dt FROM apps.BEN_PRTT_ENRT_RSLT_F a    --code added by RXNETHI-ARGANO,19/05/23
        WHERE prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        AND PERSON_ID =  p_prtt_enrt_person_id
        --AND enrt_cvg_strt_dt IN (SELECT MAX(b. enrt_cvg_strt_dt) FROM    ben.BEN_PRTT_ENRT_RSLT_F B     --code commented by RXNETHI-ARGANO,19/05/23
        AND enrt_cvg_strt_dt IN (SELECT MAX(b. enrt_cvg_strt_dt) FROM    apps.BEN_PRTT_ENRT_RSLT_F B      --code added by RXNETHI-ARGANO,19/05/23
                                                    WHERE B.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
                                                    AND B.PERSON_ID =  p_prtt_enrt_person_id);

BEGIN

   OPEN c1;
   FETCH c1
    INTO l_result;
   CLOSE c1;

  IF l_result IS NOT NULL THEN
           IF l_result < '01-JAN-2013'
           THEN
              l_result := '01-JAN-2013';
           END IF;
  ELSE
       OPEN c2;
       FETCH c2
        INTO l_result;
       CLOSE c2;
  END IF;

   RETURN l_result;
END ttec_get_uhg_dpnt_dt;
/
show errors;
/