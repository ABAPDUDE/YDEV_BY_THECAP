*&---------------------------------------------------------------------*
*& Report YMD_GIT0206
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0206.

DATA lt_caseid TYPE ztt_case.
DATA lv_caseid TYPE zde_cl_caseid VALUE '0001478181'.

DATA lt_case_detail TYPE ztt_details_clcase.
DATA ls_case_detail TYPE zst_details_clcase.


APPEND lv_caseid TO lt_caseid.

DATA(lt_case) = zcl_poc_case=>get_case_met_caseids(
              EXPORTING
                it_caseid          = lt_caseid
                iv_alleen_open     = abap_true
*               iv_alleen_gesloten
 ).

DATA(lt_ean) = zcl_poc_ean=>get_ean_met_caseids(
                   it_caseid          = lt_caseid
                   iv_alleen_open     = abap_true
*                  iv_alleen_gesloten =
               ).

lt_case_detail = CORRESPONDING #( lt_case ).

LOOP AT lt_case_detail
   INTO DATA(ls_case).

  LOOP AT lt_ean
    INTO DATA(ls_ean)
  WHERE caseid EQ ls_case-caseid.

    IF ls_case-dossiernummer IS INITIAL.
      zcl_ean_mngr=>set_status_parkeer_proces( is_case = ls_case ).
    ELSE.
      zcl_ean_mngr=>set_status_sluiten_deurwaarder( is_case = ls_case ).
    ENDIF.

  ENDLOOP.

ENDLOOP.
