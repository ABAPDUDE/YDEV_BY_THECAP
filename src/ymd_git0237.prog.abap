*&---------------------------------------------------------------------*
*& Report YMD_GIT0237
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0237.

PARAMETERS p_anlage TYPE anlage DEFAULT '6502173869'.
PARAMETERS p_sparte TYPE sparte DEFAULT 'CE'.
PARAMETERS p_einzdt TYPE einzdat DEFAULT '20250502'.
PARAMETERS p_vkonto TYPE vkont_kk DEFAULT '3008260124'.
PARAMETERS p_gpart  TYPE bu_partner DEFAULT '25111296'.

DATA lt_products TYPE zwf_ma_products_t.
DATA lv_movein_doc TYPE einzbeleg.

DATA(lo_movein) = NEW zcl_wf_gvinhuizen( im_idocnr =  '123' ).

lo_movein->create_move_in(
  EXPORTING
    miw_gpart      = p_gpart   " Nummer zakenpartner
    miw_vkont_new  = p_vkonto   " Contractrekeningnummer (new)
    miw_einzdat    = p_einzdt   " Inhuizingsdatum
*    miw_switchdoc  =     " Nummer switchdocument
*    miw_ma         =     " M&A proces
*    miw_klant_type =     " Type klant
  IMPORTING
    mew_einzbeleg  = lv_movein_doc   " Volgnummer van inhuizingsdocument
  CHANGING
    mct_products   = lt_products  " Producten voor WF
  EXCEPTIONS
    general_error  = 1
    OTHERS         = 2
).

IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
