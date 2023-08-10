# ---------------------------- CONFIDENTIAL ---------------------------------
# This file contains proprietary information of TTEC and is
# tendered subject to the condition that no copy or other reproduction be
# made, in whole or in part, and that no use be made of the information
# herein except for the purpose for which it is transmitted without express
# written permission of Enterprise Products.
# ---------------------------------------------------------------------------
#  MODULE       	: XX
#  Template Version : 1.0.0
#
#
# --------------------------------------------------------------------------
# VERSION  DATE        NAME                DESCRIPTION
# -------  --------   -----------------    ---------------------------------
# 1.0     28/Jun/2023  RPANIGRAHI(ARGANO)  Intial Version
# --------------------------------------------------------------------------
INSTALL_DIR=$CUST_TOP/install
OUT_DIR=$INSTALL_DIR/out
OUTFILE=$OUT_DIR/R122_TTEC_INSTALL_SQL.out

echo  "************* Custom Object Migration START **************"  > $OUTFILE
chmod 777 $OUTFILE

# ---------------------------------------------------------------------------
#  REQUIRED INPUT - START
# ---------------------------------------------------------------------------
#


#
# ---------------------------------------------------------------------------
#  REQUIRED MIGRATION FILES - START
# ---------------------------------------------------------------------------
#

echo " ----------------------------------------------------"
echo  "Please enter the following passwords :"
echo " ----------------------------------------------------"
echo Enter APPS Password :

read apps_pw


#CONNECT_STRING=`echo $APPS_JDBC_URL | cut -d @ -f2`

#
# ---------------------------------------------------------------------------
#  REQUIRED MIGRATION FILES - END
# ---------------------------------------------------------------------------
#

cd $CUST_TOP/install

echo "--------------------------------------------------------" >> $OUTFILE
echo " COPY FILES FROM INSTALL TO RESPECTIVE DIRECTORIES - END  " >> $OUTFILE
echo "--------------------------------------------------------" >> $OUTFILE


echo " --------------------------------------------------------------  " >> $OUTFILE
echo " Start Executing SQL scripts from sql directory                  " >> $OUTFILE
echo " --------------------------------------------------------------  " >> $OUTFILE

# echo "Executing ADP_PRINT_PKG.pkb"  >> $OUTFILE
# sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
# SET SCAN OFF
# SET DEFINE OFF
# @ADP_PRINT_PKG.pkb
# exit
# EOF
# echo "Completed ADP_PRINT_PKG.pkb" >> $OUTFILE
echo "Executing TTEC_GET_UHG_DPNT_DT.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GET_UHG_DPNT_DT.sql
exit
EOF
echo "Completed TTEC_GET_UHG_DPNT_DT.sql" >> $OUTFILE

echo "Executing TT_PER_AFTER_NOV.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TT_PER_AFTER_NOV.sql
exit
EOF
echo "Completed TT_PER_AFTER_NOV.sql" >> $OUTFILE

echo "Executing TT_PER_SEL_RULE.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TT_PER_SEL_RULE.sql
exit
EOF
echo "Completed TT_PER_SEL_RULE.sql" >> $OUTFILE

echo "Executing TTEC_F_GRADE_MIN.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_F_GRADE_MIN.sql
exit
EOF
echo "Completed TTEC_F_GRADE_MIN.sql" >> $OUTFILE

echo "Executing TTEC_INTR_COMP.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_INTR_COMP.sql
exit
EOF
echo "Completed TTEC_INTR_COMP.sql" >> $OUTFILE

echo "Executing TTEC_F_GRADE_MAX.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_F_GRADE_MAX.sql
exit
EOF
echo "Completed TTEC_F_GRADE_MAX.sql" >> $OUTFILE

echo "Executing TTEC_GET_CLIENT_ACCOUNT.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GET_CLIENT_ACCOUNT.sql
exit
EOF
echo "Completed TTEC_GET_CLIENT_ACCOUNT.sql" >> $OUTFILE

echo "Executing TTEC_GET_PTO_ELIG_INFO.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GET_PTO_ELIG_INFO.sql
exit
EOF
echo "Completed TTEC_GET_PTO_ELIG_INFO.sql" >> $OUTFILE

echo "Executing TTEC_GET_PL_TYP_CVG.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GET_PL_TYP_CVG.sql
exit
EOF
echo "Completed TTEC_GET_PL_TYP_CVG.sql" >> $OUTFILE

echo "Executing TTEC_F_GRADE_MID.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_F_GRADE_MID.sql
exit
EOF
echo "Completed TTEC_F_GRADE_MID.sql" >> $OUTFILE

echo "Executing TTEC_GET_APPROVER_AUTHORITY.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GET_APPROVER_AUTHORITY.sql
exit
EOF
echo "Completed TTEC_GET_APPROVER_AUTHORITY.sql" >> $OUTFILE

echo "Executing TTEC_APR_GRP.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_APR_GRP.sql
exit
EOF
echo "Completed TTEC_APR_GRP.sql" >> $OUTFILE

echo "Executing TTEC_APR_GRP_CORP.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_APR_GRP_CORP.sql
exit
EOF
echo "Completed TTEC_APR_GRP_CORP.sql" >> $OUTFILE

echo "Executing TTEC_GETPOSITIONHIERARCHY.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GETPOSITIONHIERARCHY.sql
exit
EOF
echo "Completed TTEC_GETPOSITIONHIERARCHY.sql" >> $OUTFILE

echo "Executing TTEC_GET_ATELKA_OT.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_GET_ATELKA_OT.sql
exit
EOF
echo "Completed TTEC_GET_ATELKA_OT.sql" >> $OUTFILE

echo "Executing TTEC_TRANSLATECCID.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_TRANSLATECCID.sql
exit
EOF
echo "Completed TTEC_TRANSLATECCID.sql" >> $OUTFILE

echo "Executing TTEC_RETRO.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TTEC_RETRO.sql
exit
EOF
echo "Completed TTEC_RETRO.sql" >> $OUTFILE

echo "Executing TT_GET_BILL_TO_SITE_USE_GL_LOC.func"  >> $OUTFILE
sqlplus APPS/$apps_pw <<EOF >> $OUTFILE
SET SCAN OFF
SET DEFINE OFF
@TT_GET_BILL_TO_SITE_USE_GL_LOC.sql
exit
EOF
echo "Completed TT_GET_BILL_TO_SITE_USE_GL_LOC.sql" >> $OUTFILE

echo " OUT FILE = "
ls -lrt $OUTFILE
echo  "************* Custom Object Migration  COMPLETE ************** " >> $OUTFILE
