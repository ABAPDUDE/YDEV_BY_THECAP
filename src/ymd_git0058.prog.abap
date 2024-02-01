*&---------------------------------------------------------------------*
*& Report YMD_401
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0058.

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

  READ TABLE lt_em_msg
  ASSIGNING FIELD-SYMBOL(<fs_msg>)
  INDEX 1.

  DATA(lv_status_descr) = zcl_poc_em_berichten=>get_status_omschrijving( iv_status = <fs_msg>-status ).
  DATA(lv_msg) = | { <fs_msg>-caseid } - {  <fs_msg>-berichttype } - { lv_status_descr }|.

  CALL FUNCTION 'POPUP_TO_INFORM'
    EXPORTING
      titel  = 'waarschuwing'
      txt1   = ' Er is al openstaande communicatie, deze actie kan niet worden uitgevoerd'
      txt2   = lv_msg
    EXCEPTIONS
      OTHERS = 1.

  RETURN.
ELSE.
  " geen open EM berichten - gereed deurwaarder status proces gaat verder
ENDIF.
