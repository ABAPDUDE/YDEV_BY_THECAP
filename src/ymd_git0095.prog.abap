*&---------------------------------------------------------------------*
*& Report YMD_015
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0095.

TYPES: BEGIN OF ty_excel_colom,
         datum      TYPE string,
         meter      TYPE string,
         werk       TYPE string,
         meterstand TYPE string,
       END OF ty_excel_colom.

TYPES: tty_excel_colom TYPE STANDARD TABLE OF ty_excel_colom.

DATA gt_excel_data  TYPE tty_excel_colom.

CLASS lcl_excel_uploader DEFINITION.
  PUBLIC SECTION.
    DATA: header_rows_count TYPE i.
    DATA: max_rows          TYPE i.
    DATA: filename          TYPE localfile.
    METHODS:
      constructor.
    METHODS:
      upload CHANGING ct_data TYPE ANY TABLE.
  PRIVATE SECTION.
    DATA: lv_tot_components TYPE i.
    METHODS:
      do_upload
        IMPORTING
          iv_begin TYPE i
          iv_end   TYPE i
        EXPORTING
          rv_empty TYPE flag
        CHANGING
          ct_data  TYPE STANDARD TABLE.

ENDCLASS.                    "lcl_excel_uploader DEFINITION

*
CLASS lcl_excel_uploader IMPLEMENTATION.
  METHOD constructor.
    max_rows = 9999.
  ENDMETHOD.                    "constructor
  METHOD upload.
    DATA: lo_struct TYPE REF TO cl_abap_structdescr,
          lo_table  TYPE REF TO cl_abap_tabledescr,
          lt_comp   TYPE cl_abap_structdescr=>component_table.

    lo_table ?= cl_abap_structdescr=>describe_by_data( ct_data ).
    lo_struct ?= lo_table->get_table_line_type( ).
    lt_comp    = lo_struct->get_components( ).
*
    lv_tot_components = lines( lt_comp ).
*
    DATA: lv_empty TYPE flag,
          lv_begin TYPE i,
          lv_end   TYPE i.
*
    lv_begin = header_rows_count + 1.
    lv_end   = max_rows.
    WHILE lv_empty IS INITIAL.
      do_upload(
        EXPORTING
            iv_begin = lv_begin
            iv_end   = lv_end
        IMPORTING
            rv_empty = lv_empty
        CHANGING
            ct_data  = ct_data
      ).
      lv_begin = lv_end + 1.
      lv_end   = lv_begin + max_rows.
    ENDWHILE.
  ENDMETHOD.                    "upload
*
  METHOD do_upload.

    DATA: li_exceldata  TYPE STANDARD TABLE OF alsmex_tabline.
    DATA: ls_exceldata  LIKE LINE OF li_exceldata.
    DATA: lv_tot_rows   TYPE i.
    DATA: lv_packet     TYPE i.
    FIELD-SYMBOLS: <struc> TYPE any,
                   <field> TYPE any.

*   Upload this packet
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = filename
        i_begin_col             = 1
        i_begin_row             = iv_begin
        i_end_col               = lv_tot_components
        i_end_row               = iv_end
      TABLES
        intern                  = li_exceldata
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.
*   something wrong, exit
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      rv_empty = 'X'.
      EXIT.
    ENDIF.

*   No rows uploaded, exit
    IF li_exceldata IS INITIAL.
      rv_empty = 'X'.
      EXIT.
    ENDIF.

*   Move from Row, Col to Flat Structure
    LOOP AT li_exceldata INTO ls_exceldata.
      " Append new row
      AT NEW row.
        APPEND INITIAL LINE TO ct_data ASSIGNING <struc>.
      ENDAT.

      " component and its value
      ASSIGN COMPONENT ls_exceldata-col OF STRUCTURE <struc> TO <field>.
      IF sy-subrc EQ 0.
        <field> = ls_exceldata-value.
      ENDIF.

      " add the row count
      AT END OF row.
        IF <struc> IS NOT INITIAL.
          lv_tot_rows = lv_tot_rows + 1.
        ENDIF.
      ENDAT.
    ENDLOOP.

*   packet has more rows than uploaded rows,
*   no more packet left. Thus exit
    lv_packet = iv_end - iv_begin.
    IF lv_tot_rows LT lv_packet.
      rv_empty = 'X'.
    ENDIF.

  ENDMETHOD.                    "do_upload
ENDCLASS.                    "lcl_excel_uploader IMPLEMENTATION

START-OF-SELECTION.
  DATA: lo_uploader TYPE REF TO lcl_excel_uploader.
  CREATE OBJECT lo_uploader.
  lo_uploader->max_rows = 9000.
  lo_uploader->filename = 'C:\Users\al24361\OneDrive - Alliander NV\Documents\report_usage_data11 Test.xlsx'.
  lo_uploader->header_rows_count = 1.
  lo_uploader->upload( CHANGING ct_data = gt_excel_data ).

*
