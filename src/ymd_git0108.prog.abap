*&---------------------------------------------------------------------*
*& Report ymd_028
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0108.

DATA lv_ean TYPE ext_ui.
DATA lv_vstelle TYPE vstelle.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_ean FOR lv_ean,
                so_prem FOR lv_vstelle.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK bl_log WITH FRAME TITLE TEXT-log.
PARAMETERS: p_prio TYPE probcl_kk AS LISTBOX VISIBLE LENGTH 20 DEFAULT '4'.
SELECTION-SCREEN END OF BLOCK bl_log.

* Select cases marked by employee to be picked up
SELECT * FROM ztvzc_workload
  INTO TABLE @DATA(lt_workload)
  WHERE status EQ @zcl_isu_vzc_fw=>co_wl_stat_create_order
      AND ext_ui IN @so_ean
      AND vstelle IN @so_prem.

IF lt_workload[] IS INITIAL.
  " no entries found for selection
ELSE.

  IF ( so_ean[] IS INITIAL OR so_prem[]
    IS INITIAL ).

    READ TABLE lt_workload
    INDEX 2
    INTO DATA(ls_workload).


  ENDIF.

  lv_ean  = ls_workload-ext_ui.
  lv_vstelle = ls_workload-vstelle.

*   IF so_ean[] IS INITIAL.
  DATA ls_ean TYPE eedm_sel_ext_ui.
*      ls_ean-sign = 'I'.
*      ls_ean-option = 'EQ'.
  ls_ean-low = lv_ean.
*     ls_ean-high = ''.
  APPEND ls_ean TO so_ean.
*   ENDIF.

*   IF so_prem[] IS INITIAL.
  DATA ls_prem TYPE isur_rvstelle.
*      ls_prem-sign = 'I'.
*      ls_prem-option = 'EQ'.
  ls_prem-low = lv_vstelle.
*      ls_prem-high = ''.
  APPEND ls_prem TO so_prem.
*   ENDIF.


  SUBMIT zrp_vzc_create_order
    WITH so_ean in so_ean
    WITH so_prem in so_prem
    AND RETURN.

  SELECT ext_ui, docnum_x310, opnamedatum, begda, datum_gewijzigd, tijd_gewijzigd, gewijzigd_door,
         datum_gemaakt, tijd_gemaakt, gemaakt_door, status, sparte, vstelle, caseid, vbeln, vbeln_vf
  INTO TABLE @DATA(lt_output)
  FROM ztvzc_workload
  WHERE ext_ui EQ @lv_ean
    AND vstelle EQ @lv_vstelle.

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
          t_table      = lt_output ).
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

ENDIF.
