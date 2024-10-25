*&---------------------------------------------------------------------*
*& Report ZCONTRACTLOOS_SLUITEN_DW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0195.

* INCLUDE zcontractloos_sluiten_dw
DATA go_alv               TYPE REF TO cl_salv_table.
DATA go_columns           TYPE REF TO cl_salv_columns_table.
DATA go_functions         TYPE REF TO cl_salv_functions_list.
DATA gt_dossier           TYPE ztt_dossier_dw.

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

          READ TABLE gt_dossier ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row_selected.

          IF <fs> IS ASSIGNED.

            "-------------------------------------------------------------------
            "Acties tbv logging
            "-------------------------------------------------------------------
            " er is geen actieve log, dan moet deze eerst worden aangemaakt

            DATA(lv_log_handle) = zcl_slg1_logging=>create_log( iv_extnumber  = |{ <fs>-caseid }|
                                                                iv_object     = 'ZPOC'
                                                                iv_subobject  = 'GENERIEK' ).

            " Pas de status van het dossier aan zodat de CallBack kan worden verstuurd
            DATA(lv_ok) = zcl_poc_dossier=>aanpassen_dossier( iv_dossiernummer = <fs>-dossiernummer
                                                              iv_status        = '01'
                                                              iv_status_reden  = space
                                                              iv_log_handle    = lv_log_handle ).

            " het verzoek van Bosveld om dossier te sluiten is afgewezen -> status naar 99 - correct verwerkt
            UPDATE zem_berichten_dw
             SET status = '99'
                 WHERE caseid EQ <fs>-caseid
                   AND dossiernummer EQ <fs>-dossiernummer
                   AND berichttype EQ 'CloseRequest'.

            DELETE gt_dossier INDEX ls_row_selected.
            go_alv->refresh( ).

          ENDIF.

        ENDLOOP.


    ENDCASE.

  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION

START-OF-SELECTION.

  DATA lr_events            TYPE REF TO lcl_event_handler.

  SELECT *
    FROM zpoc_dossier
    INTO CORRESPONDING FIELDS OF TABLE gt_dossier
    WHERE status EQ '06'.     " status_reden GE '50'.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_dossier ).
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
        pfstatus      = 'ZDWCLOSEREQUEST'
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
