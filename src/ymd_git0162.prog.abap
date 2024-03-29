*&---------------------------------------------------------------------*
*& Report YMD_062
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0162.
*REPORT zpw_excelupload.

FIELD-SYMBOLS : <gt_data>       TYPE STANDARD TABLE .

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
  ENDIF.

  DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .

  TRY .
      lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                              document_name = lv_filename
                              xdocument     = lv_headerxstring ) .
    CATCH cx_fdt_excel_core.
      "Implement suitable error handling here
  ENDTRY .

  "Get List of Worksheets
  lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING
      worksheet_names = DATA(lt_worksheets) ).

  IF NOT lt_worksheets IS INITIAL.
    READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

    DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                             lv_woksheetname ).
    "now you have excel work sheet data in dyanmic internal table
    ASSIGN lo_data_ref->* TO <gt_data>.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Form PROCESS_FILE
*---------------------------------------------------------------------*
FORM process_file .

  DATA : lv_numberofcolumns   TYPE i,
         lv_date_string       TYPE string,
         lv_target_date_field TYPE datum.


  FIELD-SYMBOLS : <ls_data>  TYPE any,
                  <lv_field> TYPE any.

  TYPES:
    BEGIN OF x_data,
      field1 TYPE char1,
      field2 TYPE i,
      field3 TYPE string,
      field4 TYPE p LENGTH 3 DECIMALS 2,
    END OF x_data.

  DATA:
    i_data        TYPE STANDARD TABLE OF x_data INITIAL SIZE 0,
    oref_table    TYPE REF TO cl_abap_tabledescr,
    oref_struc    TYPE REF TO cl_abap_structdescr,
    wa_components LIKE LINE OF oref_struc->components,
    oref_error    TYPE REF TO cx_root,
    text          TYPE string.
  TRY.
      oref_table ?= cl_abap_tabledescr=>describe_by_data( <gt_data> ).
    CATCH cx_root INTO oref_error.
      text = oref_error->get_text( ).
      WRITE: / text.
      EXIT.
  ENDTRY.

  TRY.
      oref_struc ?= oref_table->get_table_line_type( ).
    CATCH cx_root INTO oref_error.
      text = oref_error->get_text( ).
      WRITE: / text.
      EXIT.
  ENDTRY.

  DESCRIBE TABLE oref_struc->components LINES DATA(lv_count).
  lv_numberofcolumns = lv_count .

*  LOOP AT oref_struc->components INTO wa_components.
*    WRITE: / wa_components-name, wa_components-type_kind,
*           wa_components-length, wa_components-decimals.
*  ENDLOOP.

  LOOP AT <gt_data> ASSIGNING <ls_data> FROM 2 .

    "processing columns
    DO lv_numberofcolumns TIMES.
      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data> TO <lv_field> .
      IF sy-subrc = 0 .
        CASE sy-index .
*          when 1 .
*          when 2 .
          WHEN 10 .
            lv_date_string = <lv_field> .
            PERFORM date_convert USING lv_date_string CHANGING lv_target_date_field .
            WRITE lv_target_date_field .
          WHEN OTHERS.
            WRITE : <lv_field> .
        ENDCASE .
      ENDIF.
    ENDDO .
    NEW-LINE .
  ENDLOOP .
ENDFORM.

*---------------------------------------------------------------------*
* Form DATE_CONVERT
*---------------------------------------------------------------------*
FORM date_convert USING iv_date_string TYPE string CHANGING cv_date TYPE datum .

  DATA: lv_convert_date(10) TYPE c.

  lv_convert_date = iv_date_string .

  "date format YYYY/MM/DD
  FIND REGEX '^\d{4}[/|-]\d{1,2}[/|-]\d{1,2}$' IN lv_convert_date.
  IF sy-subrc = 0.
    CALL FUNCTION '/SAPDMC/LSM_DATE_CONVERT'
      EXPORTING
        date_in             = lv_convert_date
        date_format_in      = 'DYMD'
        to_output_format    = ' '
        to_internal_format  = 'X'
      IMPORTING
        date_out            = lv_convert_date
      EXCEPTIONS
        illegal_date        = 1
        illegal_date_format = 2
        no_user_date_format = 3
        OTHERS              = 4.
  ELSE.

    " date format DD/MM/YYYY
    FIND REGEX '^\d{1,2}[/|-]\d{1,2}[/|-]\d{4}$' IN lv_convert_date.
    IF sy-subrc = 0.
      CALL FUNCTION '/SAPDMC/LSM_DATE_CONVERT'
        EXPORTING
          date_in             = lv_convert_date
          date_format_in      = 'DDMY'
          to_output_format    = ' '
          to_internal_format  = 'X'
        IMPORTING
          date_out            = lv_convert_date
        EXCEPTIONS
          illegal_date        = 1
          illegal_date_format = 2
          no_user_date_format = 3
          OTHERS              = 4.
    ENDIF.

  ENDIF.

  IF sy-subrc = 0.
    cv_date = lv_convert_date .
  ENDIF.

ENDFORM .
