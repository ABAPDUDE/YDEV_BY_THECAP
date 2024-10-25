*&---------------------------------------------------------------------*
*& Report YMD_GIT0198
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0198.

DATA go_alv               TYPE REF TO cl_salv_table.
DATA go_functions         TYPE REF TO cl_salv_functions_list.
DATA gt_dwmsg             TYPE ztt_em_berichten_dw.
DATA gv_caseid            TYPE zde_cl_caseid.
DATA gv_berichttype       TYPE zem_berichttype.
DATA gv_datumverzonden    TYPE zem_datum_verzonden.
DATA gv_requestid         TYPE zem_requestid.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS s_caseid FOR gv_caseid.
SELECT-OPTIONS s_btype  FOR gv_berichttype.
SELECT-OPTIONS s_sdate  FOR gv_datumverzonden.
SELECT-OPTIONS s_rqid   FOR gv_requestid.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

PARAMETERS p_status TYPE zem_bericht_status.

SELECTION-SCREEN END OF BLOCK b2.

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

      READ TABLE gt_dwmsg ASSIGNING FIELD-SYMBOL(<fs>) INDEX ls_row_selected.

      CASE e_salv_function.

        WHEN 'SUBMIT'.

          IF <fs> IS ASSIGNED.

            IF p_status IS NOT INITIAL.

              UPDATE zem_berichten_dw
              SET status = p_status
              WHERE caseid =  <fs>-caseid
              AND berichttype = <fs>-berichttype
              AND datum_verzonden = <fs>-datum_verzonden
              AND tijd_verzonden = <fs>-tijd_verzonden.

              COMMIT WORK.
*             ls_bericht-status  = p_status.
*             MODIFY zem_berichten_dw FROM ls_bericht.

            ENDIF.

*           go_alv->refresh( ).

          ENDIF.

        WHEN OTHERS.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION

*AT SELECTION-SCREEN.
START-OF-SELECTION.

  DATA lr_events            TYPE REF TO lcl_event_handler.

  SELECT *
    FROM zem_berichten_dw
    INTO CORRESPONDING FIELDS OF TABLE gt_dwmsg
    WHERE caseid IN s_caseid
      AND berichttype IN s_btype
      AND datum_verzonden IN s_sdate
      AND requestid IN s_rqid.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_dwmsg ).
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
        pfstatus      = 'ZDWMSGCHANGE'
        set_functions = go_alv->c_functions_all ).

  "  Event object ophalen
  DATA(lo_events) = go_alv->get_event( ).

  " Event handler instantieren
  CREATE OBJECT lr_events.
  "Event handler koppelen aan ALV events.
  SET HANDLER lr_events->on_user_command FOR lo_events.

  go_functions = go_alv->get_functions( ).
  go_functions->set_all( ).
  go_alv->display( ).
