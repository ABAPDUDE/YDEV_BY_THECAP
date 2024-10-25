*&---------------------------------------------------------------------*
*&  Include           ZEIGENAAR_UPD_FORM
*&---------------------------------------------------------------------*

FORM selectfile USING p_file TYPE localfile.

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
  LOOP AT lt_it_tab INTO p_file.
  ENDLOOP.

ENDFORM. " SELECTFILE

FORM uploadexceldata .

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_field_seperator    = '|'
      i_line_header        = abap_true " excel heeft kolom beschrijving op regel 1

      i_tab_raw_data       = g_raw_data
      i_filename           = p_file
    TABLES
      i_tab_converted_data = gt_excel_tab
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
    " error handling here
    WRITE: / 'Error met upload bestand'.
  ENDIF.

ENDFORM.

FORM updatefield .

  DATA ls_evbs TYPE evbs.
  DATA x_evbs  TYPE evbs.
  DATA ls_alv  TYPE ty_alv.

  LOOP AT gt_excel_tab
    INTO DATA(ls_tab).

    DATA(lv_index) = sy-tabix.

    CALL FUNCTION 'ISU_DB_EVBS_SINGLE'
      EXPORTING
        x_vstelle = ls_tab-vstelle
      IMPORTING
        y_evbs    = ls_evbs.

    x_evbs = CORRESPONDING #( ls_evbs ).
    x_evbs-eigent = ls_tab-eigent.

    CALL FUNCTION 'ISU_DB_EVBS_UPDATE'
      EXPORTING
        x_upd_mode        = 'U'
        x_evbs            = x_evbs
        x_old_evbs        = ls_evbs
      EXCEPTIONS
        update_incomplete = 1
        modus_incorrect   = 2
        system_error      = 3
        OTHERS            = 4.

    IF sy-subrc EQ 0.
      "COMMIT WORK.
      ls_alv = CORRESPONDING #( ls_tab ).
      ls_alv-result = 'Correcte update verbruiksplaats met ZP-nummer'.
      APPEND ls_alv TO gt_alv.
    ELSE.
      "COMMIT WORK.
      ls_alv = CORRESPONDING #( ls_tab ).
      ls_alv-result =  'GEEN correcte update verbruiksplaats met ZP-nummer'.
      APPEND ls_alv TO gt_alv.
    ENDIF.

    CLEAR ls_tab.
    CLEAR ls_alv.

  ENDLOOP.

ENDFORM.

FORM displayupdatedata .

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

      SORT gt_alv BY vstelle.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_alv ).
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
  lo_display_settings->set_list_header( 'UPLOAD ZP resultaten' ).
  " Display the ALV in ABAP in the whole main screen
  "-----------------------------------------------------------"
  " Change ALV Columns Name ( Short, medium and Long text)
  "-----------------------------------------------------------"
*  TRY.
*      lo_column = lo_columns->get_column( 'DATUM' ).
*      lo_column->set_short_text( 'Datum' ).
*      lo_column->set_medium_text( 'Datum' ).
**     lo_column->set_long_text( 'put some long text here' ).
*      lo_column = lo_columns->get_column( 'METER' ).
*      lo_column->set_short_text( 'Meter' ).
*      lo_column->set_medium_text( 'Meter' ).
**     lo_column->set_long_text( 'put some long text here' ).
*      lo_column = lo_columns->get_column( 'WERK' ).
*      lo_column->set_short_text( 'Werk' ).
*      lo_column->set_medium_text( 'Werk' ).
**     lo_column->set_long_text( 'put some long text here' ).
*      lo_column = lo_columns->get_column( 'METERSTAND' ).
*      lo_column->set_short_text( 'Meterstand' ).
*      lo_column->set_medium_text( 'Meterstand' ).
**     lo_column->set_long_text( 'put some long text here' ).
*
*    CATCH cx_salv_not_found INTO lex_not_found.
*      " write some error handling
*  ENDTRY.

  lo_alv->display( ).

ENDFORM.
