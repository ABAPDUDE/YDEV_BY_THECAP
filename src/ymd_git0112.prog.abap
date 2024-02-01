*&---------------------------------------------------------------------*
*& Report YMD_032
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0112.


SELECT vbak~vbeln, workload~vstelle, workload~status, workload~ext_ui,
       vbak~auart, vbak~vkorg, vbak~spart, vbak~vkgrp, vbak~vkbur
  INTO TABLE @DATA(lt_salesord)
  FROM vbak AS vbak
  INNER JOIN ztvzc_workload AS workload
  ON vbak~vbeln EQ workload~vbeln
  WHERE workload~status EQ '41'.

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
        t_table      = lt_salesord ).
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
