*&---------------------------------------------------------------------*
*& Report YMD_062
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0163.
*REPORT zpw_excelupload.

FIELD-SYMBOLS : <gt_data>       TYPE STANDARD TABLE .
DATA gv_xstring_xlsdata  TYPE xstring.
DATA gv_string_xlsdata  TYPE string.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME .
PARAMETERS : p_file TYPE ibipparms-path OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1 .

*--------------------------------------------------------------------*
* at selection screen
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  DATA: lv_rc TYPE i.
  DATA: lt_file_table TYPE filetable,
        ls_file_table TYPE file_table.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Select a file'
    CHANGING
      file_table   = lt_file_table
      rc           = lv_rc.
  IF sy-subrc = 0.
    READ TABLE lt_file_table INTO ls_file_table INDEX 1.
    p_file = ls_file_table-filename.
  ENDIF.

START-OF-SELECTION .

  PERFORM read_file .
  PERFORM process_file.

*---------------------------------------------------------------------*
* Form READ_FILE
*---------------------------------------------------------------------*
FORM read_file .

  DATA : lv_filename      TYPE string,
         lt_records       TYPE solix_tab,
         lv_headerxstring TYPE xstring,
         lv_filelength    TYPE i.

  lv_filename = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_filelength
      header                  = lv_headerxstring
    TABLES
      data_tab                = lt_records
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  "convert binary data to xstring
  "if you are using cl_fdt_xl_spreadsheet in odata then skips this step
  "as excel file will already be in xstring
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_filelength
    IMPORTING
      buffer       = lv_headerxstring
    TABLES
      binary_tab   = lt_records
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    "Implement suitable error handling here
  ELSE.
    gv_xstring_xlsdata = lv_headerxstring.

    DATA: lt_tab    TYPE solix_tab,
          lv_lenght TYPE i.
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_headerxstring
*       APPEND_TO_TABLE       = ' '
      IMPORTING
        output_length = lv_lenght
      TABLES
        binary_tab    = lt_tab.

    CALL FUNCTION 'SCMS_BINARY_TO_STRING'
      EXPORTING
        input_length  = lv_lenght
*       FIRST_LINE    = 0
*       LAST_LINE     = 0
*       MIMETYPE      = ' '
*       ENCODING      =
      IMPORTING
        text_buffer   = gv_string_xlsdata
        output_length = lv_lenght
      TABLES
        binary_tab    = lt_tab
      EXCEPTIONS
        failed        = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.


ENDFORM.

*---------------------------------------------------------------------*
* Form PROCESS_FILE
*---------------------------------------------------------------------*
FORM process_file .

  DATA lv_base64_cl TYPE string.
  DATA lv_base64_fm TYPE string.

* Encode String to Base64
  CALL METHOD cl_http_utility=>if_http_utility~encode_base64
    EXPORTING
      unencoded = gv_string_xlsdata
    RECEIVING
      encoded   = lv_base64_cl.

  SKIP 1.
  WRITE:/5 'met behulp van CLASS: STRING 2 BASE64'.
  ULINE.
  SKIP 1.
  WRITE:/10 lv_base64_cl.

  SKIP 2.

* Encode Xstring to Base64
  CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
    EXPORTING
      input  = gv_xstring_xlsdata
    IMPORTING
      output = lv_base64_fm.

  WRITE:/5 'met behulp van FM: XTSTRING 2 BASE64'.
  ULINE.
  SKIP 1.
  WRITE:/10 lv_base64_fm.

ENDFORM.
