*&---------------------------------------------------------------------*
*& Report YMD_00019
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0019.

TYPE-POOLS: vrm.

FIELD-SYMBOLS <lt_table> TYPE STANDARD TABLE .
DATA dref TYPE REF TO data.

FIELD-SYMBOLS <ls_table> TYPE any.

DATA lv_guid TYPE guid_32.
DATA lv_ean TYPE zean.

*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  DATA lt_list TYPE vrm_values.

  APPEND VALUE #( key  = 'ZPILOT_VZC_P5'
                  text = 'ZPILOT_VZC_P5' ) TO lt_list.
  APPEND VALUE #( key  = 'ZCARM_VERBRUIKEN'
                  text = 'ZCARM_VERBRUIKEN' ) TO lt_list.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_TABL'
      values          = lt_list
    EXCEPTIONS
      id_illegal_name = 0
      OTHERS          = 0.

*--------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_double_click.
*-- get line
    READ TABLE <lt_table> INDEX row ASSIGNING <ls_table>.

*-- Show XML
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'INPUT_RESPONSE' OF STRUCTURE <ls_table> TO FIELD-SYMBOL(<ls_xml_response>).
      IF <ls_xml_response> IS ASSIGNED.
        PERFORM show_xml USING <ls_xml_response>.
      ENDIF.
    ENDIF.
    IF sy-subrc EQ 0.
      ASSIGN COMPONENT 'INPUT_READING' OF STRUCTURE <ls_table> TO FIELD-SYMBOL(<ls_xml_reading>).
      IF <ls_xml_reading> IS ASSIGNED.
        PERFORM show_xml USING <ls_xml_reading>.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "on_double_click
ENDCLASS.


DATA lv_tabname TYPE dd02l-tabname.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS s_ean  FOR lv_ean NO INTERVALS.
*SELECT-OPTIONS s_guid FOR lv_guid  NO INTERVALS.
PARAMETERS p_tabl TYPE dd02l-tabname AS LISTBOX VISIBLE LENGTH 20 DEFAULT 'ZPILOT_VZC_P5'.
SELECTION-SCREEN END OF BLOCK b01.

*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON p_tabl.
  IF p_tabl IS INITIAL.
    MESSAGE e016(38) WITH 'Maak een keuze'.
  ENDIF.


*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM do_lijst.

*--------------------------------------------------------------------*
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  DO_LIJST
*&---------------------------------------------------------------------*
FORM do_lijst .
  DATA gr_table     TYPE REF TO cl_salv_table.
  DATA gr_functions TYPE REF TO cl_salv_functions.
  DATA gr_layout    TYPE REF TO cl_salv_layout.
  DATA gr_display   TYPE REF TO cl_salv_display_settings.
  DATA gr_events TYPE REF TO cl_salv_events_table.
  DATA lr_events TYPE REF TO lcl_handle_events.
  DATA lo_cxroot TYPE REF TO cx_root.

  TRY.

*--   get stuff
      TRY.
          CREATE DATA dref TYPE STANDARD TABLE OF (p_tabl) WITH NON-UNIQUE DEFAULT KEY.
          ASSIGN dref->* TO <lt_table>.
      ENDTRY.

      CASE p_tabl.
        WHEN 'ZPILOT_VZC_P5'.

          SELECT * FROM (p_tabl) INTO TABLE @<lt_table> WHERE ean IN @s_ean.
        WHEN 'ZCARM_VERBRUIKEN'.

          SELECT * FROM (p_tabl) INTO TABLE @<lt_table> WHERE eanid IN @s_ean.

        WHEN OTHERS.
      ENDCASE.
*--------------------------------------------------------------------*
*--   show one

      IF sy-subrc EQ 0 AND lines( <lt_table> ) EQ 1.
        ASSIGN COMPONENT 'XML_RESPONSE' OF STRUCTURE <lt_table>[ 1 ] TO FIELD-SYMBOL(<ls_xml_input>).
        IF <ls_xml_input> IS ASSIGNED.
          PERFORM show_xml USING <ls_xml_input>.
        ENDIF.
        ASSIGN COMPONENT 'XML_DATA' OF STRUCTURE <lt_table>[ 1 ] TO FIELD-SYMBOL(<ls_xml_reading>).
        IF <ls_xml_reading> IS ASSIGNED.
          PERFORM show_xml USING <ls_xml_reading>.
        ENDIF.

      ELSE.
*--     show all stuff
        CALL METHOD cl_salv_table=>factory(
          IMPORTING
            r_salv_table = gr_table
          CHANGING
            t_table      = <lt_table> ).

*--------------------------------------------------------------------*
*--     Activate toolbar functions
        gr_functions = gr_table->get_functions( ).
        gr_functions->set_all( if_salv_c_bool_sap=>false ).

        gr_layout = gr_table->get_layout( ).
        gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

        gr_display = gr_table->get_display_settings( ).
        gr_display->set_list_header( |{ p_tabl }|  ).

        gr_events = gr_table->get_event( ).

        CREATE OBJECT lr_events.
        SET HANDLER lr_events->on_double_click FOR gr_events.


        CALL METHOD gr_table->display.
      ENDIF.
    CATCH cx_root INTO lo_cxroot.
      MESSAGE e016(38) WITH 'Er is een fout opgetreden'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SHOW_XML
*&---------------------------------------------------------------------*
FORM show_xml  USING p_xml_data TYPE string.
  DATA: l_xml TYPE REF TO cl_xml_document .

  CREATE OBJECT l_xml.

  CALL METHOD l_xml->parse_string
    EXPORTING
      stream = p_xml_data.

  CALL METHOD l_xml->display.
ENDFORM.
