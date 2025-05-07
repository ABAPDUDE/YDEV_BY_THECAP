*&---------------------------------------------------------------------*
*& Report YMD_GIT0236
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0236.

DATA ls_auto      TYPE isu06_movein_auto.
DATA ls_vkontdata TYPE fkk20_account_auto.
DATA ls_autoc     TYPE isu01_contract_auto.
DATA ls_vkp       TYPE fkkvkp.
DATA ls_wever     TYPE ever.
DATA ls_contrdata TYPE isu01_contract_auto.
DATA ls_ever_new  TYPE ever.
DATA lt_ever_new  TYPE ieever.

DATA ls_new_eein TYPE eein.
DATA ls_new_acc  TYPE fkk20_account.
DATA lv_new_contact TYPE ct_contact.

PARAMETERS p_anlage TYPE anlage DEFAULT '6502173871'.
PARAMETERS p_sparte TYPE sparte DEFAULT 'CE'.
PARAMETERS p_einzdt TYPE einzdat DEFAULT '20250502'.
PARAMETERS p_vkonto TYPE vkont_kk DEFAULT '3008260124'.
PARAMETERS p_gpart  TYPE bu_partner DEFAULT '25111296'.
PARAMETERS p_bukrs  TYPE bukrs DEFAULT '7000'.
PARAMETERS p_kofiz  TYPE e_kofiz DEFAULT '01'.
PARAMETERS p_gemfak TYPE e_gemfakt DEFAULT '2'.

ls_ever_new-anlage  = p_anlage.          " <fs_products>-anlage.
ls_ever_new-sparte  = p_sparte.           " <fs_products>-sparte.
ls_ever_new-vkonto  = p_vkonto.           " miw_vkont_new.
ls_ever_new-einzdat = p_einzdt.           " miw_einzdat.
ls_ever_new-auszdat = '99991231'.
ls_ever_new-bukrs   = p_bukrs.
ls_ever_new-gemfakt = p_gemfak.
ls_ever_new-kofiz   = p_kofiz.
APPEND ls_ever_new TO lt_ever_new.

* Kontrolldaten setzen
ls_auto-contr-use-sample = space.
ls_auto-contr-use-okcode = 'X'.                             "#EC NOTEXT
ls_auto-contr-okcode     = cl_isu_okcode=>co_save.

DATA ls_fkkvkp1 TYPE fkkvkp1.
DATA lt_fkkvkp1 TYPE TABLE OF fkkvkp1 INITIAL SIZE 1.

ls_fkkvkp1-vkont = p_vkonto.
APPEND ls_fkkvkp1 TO lt_fkkvkp1.

CALL FUNCTION 'FKK_DB_FKKVKP1_FORALL'
  EXPORTING
    i_only_acc_holder = 'X'                             "#EC NOTEXT
  TABLES
    t_fkkvkp1         = lt_fkkvkp1
  EXCEPTIONS
    not_found         = 1
    system_error      = 2
    OTHERS            = 4.

IF sy-subrc <> 0.
  " foutmelding                                  "#EC RAISE_OK
ENDIF.

CLEAR ls_fkkvkp1.
READ TABLE lt_fkkvkp1 INDEX 1 INTO ls_fkkvkp1.

* Daten des Vertragskontos übernehmen
MOVE-CORRESPONDING ls_fkkvkp1 TO ls_vkontdata-vk.           "#EC ENHOK
MOVE-CORRESPONDING ls_fkkvkp1 TO ls_vkp.                    "#EC ENHOK
APPEND ls_vkp TO ls_vkontdata-vkp.
ls_auto-autoa   = ls_vkontdata.

* Vertragsdaten übernehmen
LOOP AT lt_ever_new INTO ls_wever.
  MOVE-CORRESPONDING ls_wever TO ls_contrdata-everd.        "#EC ENHOK
  APPEND ls_contrdata TO ls_auto-t_autoc.                   "#EC ENHOK
ENDLOOP.


" stuur parameters zetten
LOOP AT ls_auto-t_autoc INTO ls_autoc.
  MOVE 'X' TO ls_autoc-everd_use.                           "#EC NOTEXT
  MOVE 'X' TO ls_autoc-account_use.                         "#EC NOTEXT
  MOVE 'X' TO ls_autoc-instln_use.                          "#EC NOTEXT
  MODIFY ls_auto-t_autoc FROM ls_autoc.
ENDLOOP.
MOVE 'X' TO ls_auto-autoa-acc_use.                          "#EC NOTEXT

CALL FUNCTION 'ISU_S_MOVE_IN_CREATE'
  EXPORTING
    x_vkont                = ls_fkkvkp1-vkont
    x_vktyp                = ls_fkkvkp1-vktyp
    x_kunde                = ls_fkkvkp1-gpart
    x_upd_online           = 'X'                          "#EC NOTEXT
    x_no_dialog            = 'X'                          "#EC NOTEXT
    x_auto                 = ls_auto
  IMPORTING
    y_new_eein             = ls_new_eein
    y_new_acc              = ls_new_acc
    y_new_contact          = lv_new_contact
  TABLES
    ty_new_ever            = lt_ever_new        " iever
  EXCEPTIONS
    foreign_lock           = 1
    number_error           = 2
    internal_error         = 3
    existing               = 4
    invalid_key            = 5
    not_found              = 6
    contract_mismatch      = 7
    action_failed          = 8
    input_error            = 9
    not_authorized         = 10
    metdoctab_inconsistent = 12
    move_out_necessary     = 13
    OTHERS                 = 14.

IF sy-subrc <> 0.
*  CASE sy-subrc.
*    WHEN 1.
*      RAISE foreign_lock.                                 "#EC RAISE_OK
*    WHEN 2.
*      RAISE number_error.                                 "#EC RAISE_OK
*    WHEN 3.
*      RAISE internal_error.                               "#EC RAISE_OK
*    WHEN 4.
*      RAISE existing.                                     "#EC RAISE_OK
*    WHEN 5.
*      RAISE invalid_key.                                  "#EC RAISE_OK
*    WHEN 6.
*      RAISE not_found.                                    "#EC RAISE_OK
*    WHEN 7.
*      RAISE contract_mismatch.                            "#EC RAISE_OK
*    WHEN 8.
*      RAISE action_failed.                                "#EC RAISE_OK
*    WHEN 9.
*      RAISE input_error.                                  "#EC RAISE_OK
*    WHEN 10.
*      RAISE not_authorized.                               "#EC RAISE_OK
*    WHEN 12.
*      RAISE metdoctab_inconsistent.                       "#EC RAISE_OK
*    WHEN 13.
*      RAISE move_out_necessary.                           "#EC RAISE_OK
*    WHEN OTHERS.
*      RAISE internal_error.                               "#EC RAISE_OK
* ENDCASE.
ENDIF.
