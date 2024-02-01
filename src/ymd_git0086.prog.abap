*&---------------------------------------------------------------------*
*& Report YMD_006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0086.

START-OF-SELECTION.

  DATA lv_caseid TYPE zde_cl_caseid VALUE '1371899'.
  DATA lv_case_id TYPE zde_cl_caseid.

  lv_case_id = |{ lv_caseid ALPHA = OUT }|.

  DATA(go_status) = NEW zcl_crm_status( iv_caseid = lv_case_id ).

  DATA(lv_cancel_sw) = go_status->start_app( ).

  IF lv_cancel_sw EQ abap_true.
    WRITE: /5 'no SW needed!'.
  ELSE.
    WRITE: /5 'SW needed!'.
  ENDIF.
