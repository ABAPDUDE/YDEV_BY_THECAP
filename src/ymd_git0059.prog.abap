*&---------------------------------------------------------------------*
*& Report YMD_400
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0059.

TYPES: BEGIN OF ty_em_msg,
         caseid               TYPE  zde_cl_caseid,
         berichttype          TYPE  zem_berichttype,
         datum_verzonden      TYPE  zem_datum_verzonden,
         tijd_verzonden       TYPE  zem_tijd_verzonden,
*         bericht              TYPE  zem_json_bericht,
         requestid            TYPE  zem_requestid,
         status               TYPE  zem_bericht_status,
*         response             TYPE  zem_json_response,
         response_datum       TYPE  zem_response_datum,
         response_tijd        TYPE  zem_response_tijd,
*         request_failed       TYPE  zem_json_request_failed,
         request_failed_datum TYPE  zem_request_failed_datum,
         request_failed_tijd  TYPE  zem_request_failed_tijd,
*         bevestiging          TYPE  zem_json_bevestiging,
         bevestiging_datum    TYPE  zem_bevestiging_datum,
         bevestiging_tijd     TYPE  zem_bevestiging_tijd,
         dossiernummer        TYPE  zem_dossiernumber,
       END OF ty_em_msg.

TYPES: tt_em_msg TYPE STANDARD TABLE OF ty_em_msg.

DATA lt_berichten TYPE ztt_em_berichten_dw.
DATA lt_em_msg TYPE tt_em_msg.
DATA lv_caseid TYPE zde_cl_caseid.

lv_caseid = '0001477632'.

lt_berichten = zcl_poc_em_berichten=>get_dw_berichten_met_caseid( iv_caseid = lv_caseid
                                                                  iv_alleen_open = abap_true ).

IF lines( lt_berichten ) GE 1.

  lt_em_msg[] = CORRESPONDING #( lt_berichten ).

  CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
    EXPORTING
      endpos_col   = 150
      endpos_row   = 30
      startpos_col = 1
      startpos_row = 1
      titletext    = 'Openstaande communicatie SAP Event Mesh'
* IMPORTING
*     CHOISE       =
    TABLES
      valuetab     = lt_em_msg
    EXCEPTIONS
      break_off    = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ELSE.
  " geen open EM berichten
ENDIF.
