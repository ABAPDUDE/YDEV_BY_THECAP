*&---------------------------------------------------------------------*
*& Report YMD_079
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0140.

TYPES ty_datum TYPE dats.
DATA lv_datum TYPE ty_datum.

DATA:
  lr_klak  TYPE REF TO zcl_iu_klak_download_kv,
  ls_aansl TYPE tplnr,
  ls_erdat TYPE erdat.

DATA ls_datum TYPE erdat_ran.
DATA lv_yesterday1 TYPE dats.
DATA lv_yesterday2 TYPE dats.

CONSTANTS:
  cc_doelfile1(34) TYPE c VALUE '/isu/conversie/KLAK_kv_',
  cc_doelfile2(4)  TYPE c VALUE '.txt'.

SELECTION-SCREEN BEGIN OF BLOCK select1 WITH FRAME TITLE TEXT-001.
PARAMETERS:
  pa_upd  TYPE xfeld RADIOBUTTON GROUP rbgr DEFAULT 'X'
                     USER-COMMAND rb,
  "pa_hdat   TYPE erdat MODIF ID dat,
  pa_init TYPE xfeld RADIOBUTTON GROUP rbgr.
SELECT-OPTIONS so_aansl FOR ls_aansl MODIF ID asl.
SELECT-OPTIONS so_erdat FOR lv_datum.
SELECTION-SCREEN END OF BLOCK select1.

SELECTION-SCREEN BEGIN OF BLOCK select2 WITH FRAME TITLE TEXT-002.
PARAMETERS:
    pa_file TYPE zserverfile. " OBLIGATORY.
SELECTION-SCREEN END OF BLOCK select2.

*----------------------------------------------------------------------*
* Initialization
*----------------------------------------------------------------------*
INITIALIZATION.
  CONCATENATE cc_doelfile1 sy-datum cc_doelfile2 INTO pa_file.
  pa_file = zcl_file_handler=>build_filename( pa_file ).

  lv_yesterday1 = ( sy-datum - 1 ).
  lv_yesterday2 = ( sy-datum - 3 ).

  ls_datum-sign = 'I'.
  ls_datum-option = 'BT'.
  ls_datum-low = lv_yesterday2.
  ls_datum-high = lv_yesterday1.
  APPEND ls_datum TO so_erdat.

*----------------------------------------------------------------------*
* At selection-screen.
*----------------------------------------------------------------------*

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF pa_upd = 'X'.
      IF screen-group1 = 'ASL'.
        screen-input = 0.
      ELSE.
        screen-input = 1.
      ENDIF.
    ELSEIF pa_init = 'X'.
*      IF screen-group1 = 'DAT'.
*        screen-input = 0.
*      ELSE.
      screen-input = 1.
*      ENDIF.
    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.


AT SELECTION-SCREEN ON pa_file.
  CHECK  sy-ucomm NE 'RB'.
  zcl_file_handler=>check_write_access( filename = pa_file ).

*----------------------------------------------------------------------*
* Start of selection
*----------------------------------------------------------------------*
START-OF-SELECTION.
