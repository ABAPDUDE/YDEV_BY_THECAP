*&---------------------------------------------------------------------*
*& Report YMD_GIT0196
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0196.

TYPES: BEGIN OF ty_vzc,
         factuurnummer    TYPE vbeln_vf,
         datum_gemaakt    TYPE erdat,
         tijd_gemaakt     TYPE time,
         klantnummer      TYPE kunnr,
         meterstand_e_tw1 TYPE zmstand_e_tw1,
         meterstand_e_tw2 TYPE zmstand_e_tw2,
         meterstand_g_tw1 TYPE zmstand_g_tw1,
         caseid           TYPE zde_cl_caseid,
         toelichting      TYPE zvzc_toelichting,
       END OF ty_vzc.

TYPES tty_vzc TYPE STANDARD TABLE OF ty_vzc WITH NON-UNIQUE KEY factuurnummer.

TYPES: BEGIN OF ty_vzc_done,
         factuurnummer    TYPE vbeln_vf,
         datum_gemaakt    TYPE erdat,
         tijd_gemaakt     TYPE time,
         klantnummer      TYPE kunnr,
         meterstand_e_tw1 TYPE zmstand_e_tw1,
         meterstand_e_tw2 TYPE zmstand_e_tw2,
         meterstand_g_tw1 TYPE zmstand_g_tw1,
         caseid           TYPE zde_cl_caseid,
         behandelaar      TYPE zvzc_behandelaar,
         datum_behandeld  TYPE zvzc_datum_behandeld,
         toelichting      TYPE zvzc_toelichting,
       END OF ty_vzc_done.

TYPES tty_vzc_done TYPE STANDARD TABLE OF ty_vzc_done WITH NON-UNIQUE KEY factuurnummer.

DATA go_alv               TYPE REF TO cl_salv_table.
DATA go_columns           TYPE REF TO cl_salv_columns_table.
DATA go_functions         TYPE REF TO cl_salv_functions_list.
DATA gt_vzc               TYPE tty_vzc.
DATA gt_vzc_done          TYPE tty_vzc_done.
DATA gv_factuurnummer     TYPE vbeln_vf.
DATA gv_datumgemaakt      TYPE erdat.

*DATA: cols_tab TYPE REF TO cl_salv_columns_table,
*      col_tab  TYPE REF TO cl_salv_column_table.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS s_factnr FOR gv_factuurnummer.
SELECT-OPTIONS s_date   FOR gv_datumgemaakt.
SELECTION-SCREEN SKIP 1.
* PARAMETERS p_new AS CHECKBOX TYPE sap_bool DEFAULT abap_true.
* PARAMETERS p_done AS CHECKBOX TYPE sap_bool.

PARAMETERS rb_new RADIOBUTTON GROUP rbg1.
PARAMETERS rb_done RADIOBUTTON GROUP rbg1.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Event Handler Klasse voor ALV - Definitie
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.

ENDCLASS.                    "lcl_event_handler DEFINITION

*----------------------------------------------------------------------*
* Event Handler Klasse voor ALV - Impelementatie
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_user_command.

    DATA(lr_selections)    = go_alv->get_selections( ).
    DATA(lt_rows_selected) = lr_selections->get_selected_rows( ).

    LOOP AT lt_rows_selected INTO DATA(ls_row_selected).


      CASE e_salv_function.

        WHEN 'SUBMIT'.

          READ TABLE gt_vzc ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row_selected.

          IF <fs> IS ASSIGNED.

            UPDATE ztvzc_webform
            SET verwerking_gereed = abap_true
                behandelaar = sy-uname
                datum_behandeld = sy-datum
                WHERE factuurnummer = <fs>-factuurnummer
                  AND datum_gemaakt = <fs>-datum_gemaakt
                  AND tijd_gemaakt = <fs>-tijd_gemaakt.

            DELETE gt_vzc INDEX ls_row_selected.
            go_alv->refresh( ).

          ENDIF.


        WHEN 'TOELICHT'.

          READ TABLE gt_vzc_done ASSIGNING FIELD-SYMBOL(<fs_done>) INDEX ls_row_selected.

          IF <fs_done> IS ASSIGNED.
            DATA lt_alv_string TYPE string_table.

            APPEND <fs_done>-toelichting TO lt_alv_string.

            CALL TRANSFORMATION id SOURCE itab = lt_alv_string
                                 RESULT XML DATA(xml).

            cl_abap_browser=>show_xml( xml_xstring = xml
                                       title = | TOELICHTING: |
                                       size = 'L'
                                       ).
          ENDIF.
        WHEN OTHERS.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION

START-OF-SELECTION.

  DATA lr_events            TYPE REF TO lcl_event_handler.

  IF rb_new EQ abap_true.

    SELECT *
      FROM ztvzc_webform
      INTO CORRESPONDING FIELDS OF TABLE gt_vzc
      WHERE factuurnummer IN s_factnr
        AND datum_gemaakt IN s_date
        AND verwerking_gereed EQ abap_false.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = gt_vzc ).
      CATCH cx_salv_msg INTO DATA(lr_message).
    ENDTRY.

  ENDIF.

  IF rb_done EQ abap_true.

    SELECT *
      FROM ztvzc_webform
      INTO CORRESPONDING FIELDS OF TABLE gt_vzc_done
      WHERE factuurnummer IN s_factnr
        AND datum_gemaakt IN s_date
        AND verwerking_gereed EQ abap_true.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = gt_vzc_done ).
      CATCH cx_salv_msg INTO lr_message.
    ENDTRY.

  ENDIF.

  " omzetten repid in een datatype dat de methodes slikken.
  DATA(lv_repid) = sy-repid.

  " Referentie ophalen naar de selectiesturing
  DATA(lr_sel) = go_alv->get_selections( ).
  " Aanzetten sturingsparameter voor meervoudige selectie.
  lr_sel->set_selection_mode( if_salv_c_selection_mode=>multiple ).
* Create the event reciever

  " PF status zetten op ALV status + eigen knoppen.
  go_alv->set_screen_status(
        report        = lv_repid
        pfstatus      = 'ZVZCREPORT'
        set_functions = go_alv->c_functions_all ).

  "  Event object ophalen
  DATA(lo_events) = go_alv->get_event( ).

  " lr_table->get_columns( )->set_exception_column( value = 'STATUS' ).

  " Event handler instantieren
  CREATE OBJECT lr_events.
  "Event handler koppelen aan ALV events.
  SET HANDLER lr_events->on_user_command FOR lo_events.

  " configure columns & column funtions
  DATA(columns) = go_alv->get_columns( ).
  DATA(col_tab) = columns->get( ).

  LOOP AT col_tab ASSIGNING FIELD-SYMBOL(<column>).
    CASE <column>-columnname.
      WHEN 'TOELICHTING'.
        <column>-r_column->set_output_length( '125' ).
*       <column>-r_column->set_visible( 'X' ).
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

* Get all functions
  DATA lt_func_list TYPE salv_t_ui_func.
  DATA la_func_list LIKE LINE OF lt_func_list.

  go_functions = go_alv->get_functions( ).
  lt_func_list = go_functions->get_functions( ).

* Verberg de 'Afgehandeld' button voor afgehandelde cases overzicht
  IF rb_done EQ abap_true.
    LOOP AT lt_func_list INTO la_func_list.
      IF la_func_list-r_function->get_name( ) = 'SUBMIT'.
        la_func_list-r_function->set_visible( ' ' ).
      ENDIF.
    ENDLOOP.
  ENDIF.

  go_functions->set_all( ).
*  go_columns = go_alv->get_columns( ).
*  go_columns->set_optimize( ).
  go_alv->display( ).
