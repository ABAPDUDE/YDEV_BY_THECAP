*&---------------------------------------------------------------------*
*& Report YMD_081
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0138.

DATA gs_input           TYPE zst_input_dsync.
DATA gv_3rdp_txt        TYPE val_text.
DATA gv_3rdp            TYPE domvalue_l.
DATA gco_vorige_verzoek TYPE rvari_vnam VALUE 'ZDATASYNC_LAATSTE_VERZOEK'.
DATA gv_vorige          TYPE c LENGTH 8.
DATA gv_halfjaar_terug  TYPE dats.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECTION-SCREEN SKIP.

PARAMETERS p_party TYPE zde_thirdparty_dsync OBLIGATORY DEFAULT 'ZSYNCW'.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b11 WITH FRAME TITLE TEXT-011.
PARAMETERS p_file TYPE rlgrap-filename.  " OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b11.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b12 WITH FRAME TITLE TEXT-012.
PARAMETERS p_report TYPE sap_bool.
SELECTION-SCREEN END OF BLOCK b12.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b13 WITH FRAME TITLE TEXT-013.
PARAMETERS p_test TYPE sap_bool DEFAULT abap_false.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b14 WITH FRAME TITLE TEXT-014.
PARAMETERS p_testzp TYPE bu_partner MODIF ID bl4.
PARAMETERS p_email TYPE ad_smtpadr MODIF ID bl4.
SELECTION-SCREEN END OF BLOCK b14.
SELECTION-SCREEN END OF BLOCK b13.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS p_req TYPE sap_bool AS CHECKBOX USER-COMMAND cb_verzoek.
PARAMETERS p_vorige TYPE dats MODIF ID bl5.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  DATA: gt_filetable TYPE filetable,
        gv_rc        TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title            = |Selecteer WOCO input bestand|
    CHANGING
      file_table              = gt_filetable
      rc                      = gv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5
  ).

  IF lines( gt_filetable ) EQ 1.
    p_file = gt_filetable[ 1 ]-filename.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN INTO DATA(screen_wa).
    IF screen_wa-group1 = 'BL5'.
*     screen_wa-active = '0'. " hele veld onzichtbaar
      screen_wa-input = '0'.
    ENDIF.
    MODIFY SCREEN FROM screen_wa.
  ENDLOOP.

  gv_3rdp = p_party.

  CALL FUNCTION 'DOMAIN_VALUE_GET'
    EXPORTING
      i_domname  = 'ZDE_THIRDPARTY_SYNC'
      i_domvalue = gv_3rdp
    IMPORTING
      e_ddtext   = gv_3rdp_txt
    EXCEPTIONS
      not_exist  = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
*    com1 = gv_3rdp_txt.
  ENDIF.

*----------------------------------------------------------------------*
*INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.

  SELECT SINGLE low
     FROM tvarvc
     INTO gv_vorige
     WHERE name EQ gco_vorige_verzoek.

  p_vorige = gv_vorige.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'CB_VERZOEK'.

      CALL FUNCTION 'CCM_GO_BACK_MONTHS'
        EXPORTING
          currdate   = sy-datum
          backmonths = '6'
        IMPORTING
          newdate    = gv_halfjaar_terug.

      IF gv_vorige GE gv_halfjaar_terug.
        MESSAGE w038(zdsync). " ==> " Het laatste verzoek is korter dan een half jaar geleden verstuurd "
      ENDIF.

  ENDCASE.
