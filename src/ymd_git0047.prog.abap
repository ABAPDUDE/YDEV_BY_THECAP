*&---------------------------------------------------------------------*
*& Report YMD_0002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0047.

DATA: lt_msg    TYPE          ztt_poc_message,
      lv_ean    TYPE          ext_ui,
      lv_dynsql TYPE          string,
      lt_dynsql TYPE TABLE OF string,
      lr_table  TYPE REF TO   cl_salv_table.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_case FOR lv_ean.
PARAMETERS:
  pa_dats TYPE dats DEFAULT sy-datum,
  pa_btyp TYPE zde_cl_berichttype
  .
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS:
    pa_stat TYPE zde_cl_msg_status.
.
SELECTION-SCREEN END OF BLOCK b2.

FIELD-SYMBOLS: <fs> LIKE LINE OF lt_msg.
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
    CASE e_salv_function.
      WHEN 'CHANGEMASS'.
        DATA(lr_selections)       = lr_table->get_selections( ).
        DATA(lt_rows_selected)    = lr_selections->get_selected_rows( ).

        LOOP AT lt_rows_selected INTO DATA(ls_row_selected).

          READ TABLE lt_msg ASSIGNING <fs> INDEX ls_row_selected.

          IF pa_stat IS NOT INITIAL.
            <fs>-status = pa_stat.
          ENDIF.

          zcl_isu_poc_message_crudl=>update(
                            EXPORTING
                              is_message            =   <fs>  " POC: Case Structuur

                          ).

          IF sy-subrc <> 0.
*         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ELSE.
            COMMIT WORK.
          ENDIF.
        ENDLOOP.

    ENDCASE.
  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION

AT SELECTION-SCREEN OUTPUT.
  DATA:       lr_events TYPE REF TO lcl_event_handler.


  IF pa_dats IS NOT INITIAL.
    lv_dynsql = 'DATUM eq pa_dats'.
  ENDIF.
  IF pa_btyp IS NOT INITIAL.
    CONCATENATE lv_dynsql 'and BERICHTTYPE eq pa_btyp' INTO lv_dynsql SEPARATED BY space.
  ENDIF.


  SELECT * FROM zisu_poc_message
  INTO CORRESPONDING FIELDS OF TABLE lt_msg
        WHERE ean IN so_case
          AND (lv_dynsql).

  IF sy-subrc EQ 0 AND lt_msg IS NOT INITIAL.

*Generate an instance of the ALV table object
    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lr_table
      CHANGING
        t_table      = lt_msg.
    " omzetten repid in een datatype dat de methodes slikken.
    DATA(lv_repid) = sy-repid.

    " Referentie ophalen naar de selectiesturing
    DATA(lr_sel) = lr_table->get_selections( ).
    " Aanzetten sturingsparameter voor meervoudige selectie.
    lr_sel->set_selection_mode( if_salv_c_selection_mode=>multiple ).
* Create the event reciever

    " PF status zetten op ALV status + eigen knoppen.
    lr_table->set_screen_status(
          report        = lv_repid
          pfstatus      = 'ZPOCMSG'
          set_functions = lr_table->c_functions_all ).

    "  SET PF-STATUS 'ZPOCMSG'.

    "  Event object ophalen
    DATA(lo_events) = lr_table->get_event( ).

    " lr_table->get_columns( )->set_exception_column( value = 'STATUS' ).

    " Event handler instantieren
    CREATE OBJECT lr_events.
    "Event handler koppelen aan ALV events.
    SET HANDLER lr_events->on_user_command FOR lo_events.

    "Display the ALV table.
    lr_table->display( ).




  ENDIF.
