*&---------------------------------------------------------------------*
*& Report YMD_031
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0111.

PARAMETERS pa_vbeln TYPE vbeln.

DATA ls_vbeln TYPE shp_vbeln_range.
DATA lt_vbeln TYPE shp_vbeln_range_t.

ls_vbeln-sign   = 'I'.
ls_vbeln-option = 'EQ'.
ls_vbeln-low    = pa_vbeln.
ls_vbeln-high   = ''.
APPEND ls_vbeln TO lt_vbeln.


DATA gt_bdcdata TYPE tab_bdcdata.
DATA ls_bdcdata TYPE bdcdata.
DATA gt_messtab TYPE trty_bdcmsgcoll.
DATA ls_messtab TYPE bdcmsgcoll.

* Create new dynpro
PERFORM bdc_newdynpro USING 'ZRP_VZC_AUTO_BILLING_BATCH' '1000'.

* Insert fields
PERFORM bdc_field USING 'BDC_CURSOR' 'SO_VBELN-LOW'.
PERFORM bdc_field USING 'BDC_OKCODE' '=ONLI'.
PERFORM bdc_field USING 'SO_VBELN-LOW' pa_vbeln.
PERFORM bdc_field USING 'PA_VZC' abap_true.
PERFORM bdc_field USING 'PA_SUBMT' abap_true.

** Create new dynpro
*PERFORM bdc_newdynpro USING 'SAPMSSY0' '0120'.
*
**PERFORM bdc_field USING 'BDC_CURSOR' '04/03'.
*PERFORM bdc_field USING 'RM06E-TCSELFLAG(01)' 'X'.
*PERFORM bdc_field USING 'BDC_OKCODE' '=CREATEBILL'.


*/**
* T CODE, is a transaction to which we are loading data ex:MM01
* bdcdata is a table which contains data related to each screen
* A/S asynchronous or synchronous method.
* A/E/N all screen mode or error screen mode or no screen mode.
* MESSTAB is a message table to store messages (success, error, warning etc)
*/*

CALL TRANSACTION 'ZVZC_FA'
USING gt_bdcdata
MODE 'A'
UPDATE 'S'
MESSAGES INTO gt_messtab.

LOOP AT gt_messtab
  INTO ls_messtab.
  IF ls_messtab-dynumb = '0104' AND ls_messtab-msgnr = '016'.
    DATA(lv_invoice_nr) = ls_messtab-msgv1.
  ENDIF.
ENDLOOP.

*******************************************************************
* Starts a new screen
*******************************************************************
FORM bdc_newdynpro USING program dynpro.
  CLEAR ls_bdcdata.
  ls_bdcdata-program = program.
  ls_bdcdata-dynpro = dynpro.
  ls_bdcdata-dynbegin = 'X'.
  APPEND ls_bdcdata TO gt_bdcdata.
ENDFORM.

*******************************************************************
* Inserts a field in bdc_tab
*******************************************************************
FORM bdc_field USING fnam fval.
  CLEAR ls_bdcdata.
  ls_bdcdata-fnam = fnam.
  ls_bdcdata-fval = fval.
  APPEND ls_bdcdata TO gt_bdcdata.
ENDFORM.
