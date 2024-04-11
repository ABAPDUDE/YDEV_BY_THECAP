*&---------------------------------------------------------------------*
*& Report ZRE_CASEID_UITVAL_DW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0187.

INCLUDE zcaseid_uitval_sel.

DATA ls_caseid            TYPE ty_msg.
DATA lt_caseid            TYPE tty_msg.
DATA lv_valpos_status     TYPE valpos.
DATA lv_valpos_proxyevent TYPE valpos.
DATA ls_input             TYPE zst_dw_input_01.

CONSTANTS mc_status_handoff_failure TYPE zem_msg_status VALUE '03'.
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

      WHEN 'SUBMIT'.

        DATA(lr_selections)    = go_alv->get_selections( ).
        DATA(lt_rows_selected) = lr_selections->get_selected_rows( ).

        LOOP AT lt_rows_selected INTO DATA(ls_row_selected).

          READ TABLE lt_caseid ASSIGNING <fs> INDEX ls_row_selected.

          IF <fs> IS ASSIGNED.

            ls_input-caseid       = <fs>-caseid.

            DATA(go_data) = zcl_dw_factory=>get( )->create_object_bosveld_01( is_parameters = ls_input ).
            go_data->start_app( ).

            " markeer deze regel in table ZEM_MSG_DW als 'Opnieue verstuurd'
            SELECT SINGLE *
            INTO @DATA(ls_msgdw)
            FROM zem_msg_dw
             WHERE caseid EQ @<fs>-caseid
             AND message_id EQ @<fs>-message_id
             AND abap_proxyevent EQ @mc_status_handoff_failure.

            UPDATE zem_msg_dw FROM @( VALUE #( BASE ls_msgdw opnieuw_verstuurd = abap_true ) ).

          ENDIF.

        ENDLOOP.

    ENDCASE.

  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION


AT SELECTION-SCREEN.

  DATA lr_events            TYPE REF TO lcl_event_handler.

  SELECT *
  INTO TABLE @DATA(lt_msg)
  FROM zem_msg_dw
  WHERE datum_verzonden IN @so_date
    AND ( status EQ '03' OR
        status EQ '07' OR
        status EQ '11' OR
        status EQ '14' ) AND
        opnieuw_verstuurd NE @abap_true.

  LOOP AT lt_msg
  INTO DATA(ls_msg).

    lv_valpos_status = ls_msg-status.
    lv_valpos_proxyevent = ls_msg-abap_proxyevent.

    ls_caseid = VALUE #( caseid = ls_msg-caseid
                         message_id = ls_msg-message_id
                         status = ls_msg-status
                         status_txt = zcl_dw_bosveld_00=>get_domvalue_description(
                                               iv_value   = lv_valpos_status
                                               iv_domname = |ZEM_MSG_STATUS|
                                           )
                         bericht = ls_msg-bericht
                         datum_verzonden = ls_msg-datum_verzonden
                         tijd_verzonden = ls_msg-tijd_verzonden
                         abap_proxyevent = ls_msg-abap_proxyevent
                         abap_proxyevent_txt = zcl_dw_bosveld_00=>get_domvalue_description(
                                               iv_value   = lv_valpos_proxyevent
                                               iv_domname = |ZDO_PROXYEVENT_ID|
                                           )

                         ).

    APPEND ls_caseid TO lt_caseid.

  ENDLOOP.

  IF lines( lt_caseid ) EQ 0.

    DATA(lv_message) = |Er is geen data gevonden voor deze datum / tijdvak|.
    MESSAGE lv_message TYPE 'I' DISPLAY LIKE 'I'.
    LEAVE TO LIST-PROCESSING.

  ELSE.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = lt_caseid ).
      CATCH cx_salv_msg INTO DATA(lr_message).
    ENDTRY.

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
          pfstatus      = 'ZDWUITVAL'
          set_functions = go_alv->c_functions_all ).

*set PF-STATUS 'ZPOCEAN'.

    "  Event object ophalen
    DATA(lo_events) = go_alv->get_event( ).

    " lr_table->get_columns( )->set_exception_column( value = 'STATUS' ).

    " Event handler instantieren
    CREATE OBJECT lr_events.
    "Event handler koppelen aan ALV events.
    SET HANDLER lr_events->on_user_command FOR lo_events.


    go_functions = go_alv->get_functions( ).
    go_functions->set_all( ).
    go_columns = go_alv->get_columns( ).
    go_columns->set_optimize( ).
    go_alv->display( ).

  ENDIF.
