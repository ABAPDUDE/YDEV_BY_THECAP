*&---------------------------------------------------------------------*
*& Report YMD_018
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0098.

TYPES: BEGIN OF ty_excel_colom,
         datum      TYPE string,
         meter      TYPE string,
         werk       TYPE string,
         meterstand TYPE string,
       END OF ty_excel_colom.

TYPES: tty_excel_colom TYPE STANDARD TABLE OF ty_excel_colom.

DATA gt_filetable   TYPE filetable.
DATA g_window_title TYPE string.
DATA g_file_filter  TYPE string.
DATA g_subrc        TYPE i.
DATA gt_upload      TYPE tty_excel_colom.
DATA gs_upload      TYPE ty_excel_colom.


CONSTANTS: gc_initial_dir TYPE string  VALUE 'C:\',
           gc_delimiter   VALUE '|'.

PARAMETERS: p_test AS CHECKBOX DEFAULT 'X',
            p_file TYPE filename.

* _____________________________________________________________________
*|                A T   S E L E C T I O N - S C R E E N                |
* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = g_window_title
      file_filter             = g_file_filter
      initial_directory       = gc_initial_dir
    CHANGING
      file_table              = gt_filetable
      rc                      = g_subrc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE gt_filetable INTO p_file INDEX 1.

START-OF-SELECTION.

  DATA lt_table TYPE TABLE OF string.

  CALL FUNCTION 'FAA_FILE_UPLOAD_EXCEL'
    EXPORTING
      i_filename           = p_file
      i_delimiter          = gc_delimiter
    TABLES
      et_filecontent       = lt_table
    EXCEPTIONS
      error_accessing_file = 1
      OTHERS               = 2.

  IF sy-subrc = 0.
*    DELETE lt_table INDEX 1.        "Delete the header line
    LOOP AT lt_table INTO DATA(wa_table).
      CLEAR gs_upload.
      SPLIT wa_table AT gc_delimiter
       INTO gs_upload-datum
            gs_upload-meter
            gs_upload-meterstand
            gs_upload-werk.

      APPEND gs_upload TO gt_upload.
    ENDLOOP.
  ENDIF.
