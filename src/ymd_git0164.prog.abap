*&---------------------------------------------------------------------*
*& Report YMD_064
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0164.

DATA : BEGIN OF li_makt OCCURS 0,
         matnr TYPE matnr,
         maktx TYPE maktx,
       END OF li_makt.

DATA: BEGIN OF li_head OCCURS 0,
        field(30) TYPE c,
      END OF li_head.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS:
  p_file TYPE rlgrap-filename OBLIGATORY DEFAULT 'C:\TEMP\test_password_excel.xlsx'.
SELECTION-SCREEN END OF BLOCK b2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM browse_file CHANGING p_file.

START-OF-SELECTION.

  REFRESH li_head.

  DEFINE mc_head.
    li_head-field = &1.
    APPEND li_head.
  END-OF-DEFINITION.

  SELECT matnr maktx INTO TABLE li_makt FROM makt UP TO 20 ROWS WHERE spras = sy-langu .

  mc_head : 'Material No', 'Material Description'.

  CALL FUNCTION 'EXCEL_OLE_STANDARD_DAT'
    EXPORTING
      file_name                 = p_file
      create_pivot              = 0
      data_sheet_name           = 'Data Material'
      pivot_sheet_name          = ' '
      password                  = 'plazapp'
      password_option           = 1
    TABLES
      data_tab                  = li_makt
      fieldnames                = li_head
    EXCEPTIONS
      file_not_exist            = 1
      filename_expected         = 2
      communication_error       = 3
      ole_object_method_error   = 4
      ole_object_property_error = 5
      invalid_filename          = 6
      invalid_pivot_fields      = 7
      download_problem          = 8
      OTHERS                    = 9.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


FORM browse_file CHANGING p_file LIKE rlgrap-filename.
  DATA: filetab   TYPE filetable,
        rc        TYPE i,
        lv_offset TYPE i.

  FREE filetab.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Choose File'
      default_extension       = '*.*'
      default_filename        = 'c:\*.xls'
    CHANGING
      file_table              = filetab
      rc                      = rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      OTHERS                  = 4.
  IF sy-subrc = 0.
    READ TABLE filetab INTO p_file INDEX 1.
  ENDIF.
ENDFORM. " browse_file
