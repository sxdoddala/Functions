create or replace FUNCTION TT_GET_BILL_TO_SITE_USE_GL_LOC (P_CUST_TRX_LINE_ID BINARY_INTEGER)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
/* $Header: TT_GET_BILL_TO_SITE_USE_GL_LOC.fnc 1.0 $                                                                  */
/*== START ================================================================================================*\
   Date:  August 26, 2009
   Desc:  This function return the CLIENT CODE of the Bill_to_Site to override the AutoAccounting 's TAX
          ACCOUNT CLASS, if the override tax code flag is set to 'YES'

   Call from: arp_auto_accounting.flex_manager

   Parameter: ra_customer_trx_lines_all.CUSTOMER_TRX_LINE_ID

  Modification History:

 Mod#  Developer           Date     Comments
---------------------------------------------------------------------------
 1.0  Christiane Chan      26-AUG-09 Created package
 1.0  RXNETHI-ARGANO        19/MAY/2023   R12.2 Upgrade Remediation
\*== END ==================================================================================================*/

   l_result				VARCHAR2(4):='';

/**** SELECT PROGRAM AND PLAN INFORMATION ****/

CURSOR c_client_code IS
select cc.segment2
from ra_customer_trx_all t
   , ra_customer_trx_lines_all tl
   --, ra_site_uses_all su -- R12.2 upg
   ,hz_cust_site_uses_all su -- R12.2 upg
   , ar_vat_tax_all_b vt
   , gl_code_combinations cc
where tl.CUSTOMER_TRX_LINE_ID = P_CUST_TRX_LINE_ID
and tl.CUSTOMER_TRX_ID = t.CUSTOMER_TRX_ID
and tl.VAT_TAX_ID = vt.VAT_TAX_ID
and su.SITE_USE_ID = t.BILL_TO_SITE_USE_ID
and cc.code_combination_id = su.gl_id_tax
and vt.GLOBAL_ATTRIBUTE9 = 'Y'
;

BEGIN
  OPEN c_client_code;
  FETCH c_client_code INTO l_result;
  CLOSE c_client_code;

  RETURN l_result;
EXCEPTION WHEN others THEN
     fnd_file.put_line(FND_FILE.LOG,
     --DBMS_OUTPUT.put_line(
                            'EXCEPTION WHEN OTHERS is raised in Function TT_GET_BILL_TO_SITE_USE_GL_LOC ERROR: '||SQLCODE||'-'|| SQLERRM);
      RETURN l_result; -- EXCEPTION WHEN OTHERS is raised in Function TTEC_TranslateCCID ERROR:

END TT_GET_BILL_TO_SITE_USE_GL_LOC;
/
show errors;
/
