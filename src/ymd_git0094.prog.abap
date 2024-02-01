*&---------------------------------------------------------------------*
*& Report YMD_014
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0094.

TYPES: BEGIN OF ty_excel_coloms,
         datum      TYPE string,
         meter      TYPE string,
         werk       TYPE string,
         meterstand TYPE string,
       END OF ty_excel_coloms.

TYPES: tty_excel_coloms TYPE STANDARD TABLE OF ty_excel_coloms.

TYPE-POOLS : truxs.
DATA  g_raw_data TYPE truxs_t_text_data.
DATA gt_excel_tab TYPE tty_excel_coloms.  " type stringtab.

SELECTION-SCREEN BEGIN OF BLOCK block-1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_file LIKE rlgrap-filename
             DEFAULT 'C:\Users\al24361\OneDrive - Alliander NV\Documents\report_usage_data11 Test.xlsx'.
SELECTION-SCREEN END OF BLOCK block-1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM u_selectfile USING p_file.

START-OF-SELECTION.

  PERFORM u_uploadexceldata.
  PERFORM u_displayinternaltabledata.


*&---------------------------------------------------------------------*
*& Form U_UPLOADEXCELDATA
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM u_uploadexceldata .
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_field_seperator    = '|'
      i_line_header        = abap_true
      i_tab_raw_data       = g_raw_data
      i_filename           = p_file
    TABLES
      i_tab_converted_data = gt_excel_tab
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM. " U_UPLOADEXCELDATA

*&---------------------------------------------------------------------*
*& Form U_DISPLAYINTERNALTABLEDATA
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
FORM u_displayinternaltabledata .

  "-----------------------------------------------------------"
  TRY.
      DATA lo_alv               TYPE REF TO cl_salv_table.
      DATA lex_message          TYPE REF TO cx_salv_msg.
      DATA lo_layout_settings   TYPE REF TO cl_salv_layout.
      DATA lo_layout_key        TYPE        salv_s_layout_key.
      DATA lo_columns           TYPE REF TO cl_salv_columns_table.
      DATA lo_column            TYPE REF TO cl_salv_column.
      DATA lex_not_found        TYPE REF TO cx_salv_not_found.
      DATA lo_functions         TYPE REF TO cl_salv_functions_list.
      DATA lo_display_settings  TYPE REF TO cl_salv_display_settings.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_excel_tab ).
      "@ the ABAP Internal Table to display in ALV with ABAP
      "@ LT_ITAB to be defined and filled of course
    CATCH cx_salv_msg INTO lex_message.
      " error handling
  ENDTRY.

  " Set the ALV Layouts
  "-----------------------------------------------------------"
  lo_layout_settings   = lo_alv->get_layout( ).
  lo_layout_key-report = sy-repid.
  lo_layout_settings->set_key( lo_layout_key ).
  lo_layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).

  " set the ALV Toolbars
  "-----------------------------------------------------------"
  lo_functions = lo_alv->get_functions( ).
  lo_functions->set_all( ).

  " Optimize ALV Columns size
  "-----------------------------------------------------------"
  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( ).

  " Set Zebra Lines display
  "-----------------------------------------------------------"
  lo_display_settings = lo_alv->get_display_settings( ).
  lo_display_settings->set_striped_pattern( if_salv_c_bool_sap=>true ).

  " Set ALV Header title
  "-----------------------------------------------------------"
  lo_display_settings->set_list_header( 'Your ALV Title' ).
  " Display the ALV in ABAP in the whole main screen
  "-----------------------------------------------------------"
  " Change ALV Columns Name ( Short, medium and Long text)
  "-----------------------------------------------------------"
  TRY.
      lo_column = lo_columns->get_column( 'DATUM' ).
      lo_column->set_short_text( 'Datum' ).
      lo_column->set_medium_text( 'Datum' ).
*     lo_column->set_long_text( 'put some long text here' ).
      lo_column = lo_columns->get_column( 'METER' ).
      lo_column->set_short_text( 'Meter' ).
      lo_column->set_medium_text( 'Meter' ).
*     lo_column->set_long_text( 'put some long text here' ).
      lo_column = lo_columns->get_column( 'WERK' ).
      lo_column->set_short_text( 'Werk' ).
      lo_column->set_medium_text( 'Werk' ).
*     lo_column->set_long_text( 'put some long text here' ).
      lo_column = lo_columns->get_column( 'METERSTAND' ).
      lo_column->set_short_text( 'Meterstand' ).
      lo_column->set_medium_text( 'Meterstand' ).
*     lo_column->set_long_text( 'put some long text here' ).

    CATCH cx_salv_not_found INTO lex_not_found.
      " write some error handling
  ENDTRY.

  lo_alv->display( ).

ENDFORM. " U_DISPLAYINTERNALTABLEDATA

*&---------------------------------------------------------------------*
*& Form U_SELECTFILE
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* -->P_PA_FILE text
*----------------------------------------------------------------------*
FORM u_selectfile USING p_pa_file TYPE localfile.

  DATA :
    lv_subrc  LIKE sy-subrc,
    lt_it_tab TYPE filetable.

  " Display File Open Dialog control/screen
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title     = 'Select Source Excel File'
      default_filename = '*.xls'
      multiselection   = ' '
    CHANGING
      file_table       = lt_it_tab
      rc               = lv_subrc.

  " Write path on input area
  LOOP AT lt_it_tab INTO p_pa_file.
  ENDLOOP.

ENDFORM. " U_SELECTFILE
