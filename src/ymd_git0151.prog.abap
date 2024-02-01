*&---------------------------------------------------------------------*
*& Report YMD_051
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0151.

*DATA go_data  TYPE REF TO zif_data_dsync.
DATA gs_input TYPE zst_input_dsync.
DATA gv_3rdp_txt TYPE val_text.
DATA gv_3rdp TYPE domvalue_l.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS p_party TYPE zde_thirdparty_dsync OBLIGATORY DEFAULT 'ZSYNCW'.
PARAMETERS p_file TYPE rlgrap-filename.  " OBLIGATORY.
PARAMETERS p_test TYPE sap_bool DEFAULT abap_true.
PARAMETERS p_report TYPE sap_bool.
SELECTION-SCREEN END OF BLOCK block1.

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

START-OF-SELECTION.

  gs_input-third_party   = p_party.
  gs_input-path_filename = p_file.
  gs_input-test_case     = p_test.

  IF p_file IS INITIAL
  AND p_report IS INITIAL.

    MESSAGE ID 'ZDSYNC' TYPE 'S' NUMBER 020 DISPLAY LIKE 'E'.
*            INTO DATA(mtext).
*         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  LEAVE TO SCREEN 1000.
*  SET SCREEN 1000.
*  LEAVE TO CURRENT TRANSACTION.
    LEAVE LIST-PROCESSING.

  ENDIF.
