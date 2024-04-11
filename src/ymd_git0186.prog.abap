*&---------------------------------------------------------------------*
*& Report ZR_MASS_CHANGE_CASE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ymd_git0186.

DATA: lt_ean    TYPE          ztt_poc_ean,
      lv_ean    TYPE          ext_ui,
      lv_dynsql TYPE          string,
      lt_dynsql TYPE TABLE OF string,
      lr_table  TYPE REF TO   cl_salv_table.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_ean FOR lv_ean.
PARAMETERS:
    pa_dats TYPE dats "DEFAULT sy-datum.
.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS:
  pa_stat  TYPE zde_cl_ean_status,
  pa_st_rd TYPE zstatus_reden AS LISTBOX VISIBLE LENGTH 15,
  pa_scen  TYPE zde_cl_scenario,
  pa_kenm  TYPE zkenmerk_aansluiting AS LISTBOX VISIBLE LENGTH 11,
  pa_bouw  TYPE zde_cl_type_bouw,
  pa_datc  TYPE dats,
  pa_adate TYPE dats,
  pa_nochg TYPE c AS CHECKBOX,
  pa_clp5 type c as checkbox.

SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.

PARAMETERS:
  pa_idoc TYPE wdy_boolean.

SELECTION-SCREEN END OF BLOCK b3.

FIELD-SYMBOLS: <fs> LIKE LINE OF lt_ean.
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
        DATA: lv_ommit_datechange TYPE wdy_boolean.
        DATA lv_teller TYPE zteller.

        lv_teller = 0.

        LOOP AT lt_rows_selected INTO DATA(ls_row_selected).
          CLEAR: lv_ommit_datechange.

          READ TABLE lt_ean ASSIGNING <fs> INDEX ls_row_selected.

          CASE pa_nochg.
            WHEN abap_true.
              IF pa_datc IS INITIAL.
                " Wel vinkje bij Wijzigingsdatum niet wijzigen / Geen Aangepaste wijzigingsdatum: Wijzigingsdatum niet aanpassen
                lv_ommit_datechange = abap_true.
              ELSEIF pa_datc IS NOT INITIAL.
                " Wel vinkje bij Wijzigingsdatum niet wijzigen / Wel Aangepaste wijzigingsdatum: Wijzigingsdatum niet aanpassen
                lv_ommit_datechange = abap_true.
              ELSE.
              ENDIF.
            WHEN abap_false.
              IF pa_datc IS INITIAL.
                " Geen vinkje bij Wijzigingsdatum niet wijzigen / Geen Aangepaste wijzigingsdatum: Wijzigingsdatum aanpassen naar datum vandaag
                lv_ommit_datechange = abap_false.
                IF pa_datc IS INITIAL.
                  DATA(lv_eff_date) = sy-datum.
                ELSE.
                  lv_eff_date = pa_datc.
                ENDIF.
              ELSEIF pa_datc IS NOT INITIAL.
                " Geen vinkje bij Wijzigingsdatum niet wijzigen / Wel Aangepaste wijzigingsdatum: Wijzigingsdatum aanpassen naar ingegeven datum
                lv_ommit_datechange = abap_true.
                <fs>-datum_gewijzigd = pa_datc.
              ELSE.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.

          " Aanpassen alternatieve actiedatum
          IF pa_adate IS NOT INITIAL.
            <fs>-alt_actie_datum = pa_adate.
          ENDIF.

          "Aanpassen status
          IF pa_stat IS NOT INITIAL.
            <fs>-status_reden = pa_st_rd.
            <fs>-status = pa_stat.
            IF <fs>-status BETWEEN 10 AND 19. " Between is kleiner/groter dan of gelijk aan.
              lv_ommit_datechange = abap_true.
            ENDIF.
          ENDIF.

          "Aanpassen type bouw
          IF pa_bouw IS NOT INITIAL.
            <fs>-type_bouw  = pa_bouw.
          ENDIF.

          "Aanpassen scenario
          IF pa_scen IS NOT INITIAL.
            <fs>-scenario  = pa_scen.
          ENDIF.

          "Aanpassen kenmerk GV
          "Deze mag alleen worden gevuld voor GV dus Scenario 09/10
          "Of worden leeggemaakt voor Scenario <> 09/10
          IF pa_kenm IS NOT INITIAL.
            "Indien huidige scenario 09/10 is of toekomstige scenario 09/10 is
            IF <fs>-scenario EQ '09' OR
               <fs>-scenario EQ '10'.
              <fs>-kenmerk  = pa_kenm.
            ENDIF.
          ELSE.
            "Indien huidige scenario <> 09/10 is of toekomstige scenario <> 09/10 is
            IF <fs>-scenario NE '09' AND
               <fs>-scenario NE '10'.
              <fs>-kenmerk  = ''.
            ENDIF.
          ENDIF.

          IF pa_clp5 IS NOT INITIAL.
            CLEAR <fs>-verbruik.
            CLEAR <fs>-datum_meter_uitlezen.
          ENDIF.

          "
          IF pa_idoc IS NOT INITIAL.
            IF pa_stat EQ zcl_isu_poc_fw=>co_stat_ean_createidocnaarcrm OR
               pa_stat EQ zcl_isu_poc_fw=>co_stat_ean_updateidocnaarcrm OR
               pa_stat EQ zcl_isu_poc_fw=>co_stat_ean_woco_naar_crm.

              zcl_isu_poc_fw=>send_idoc_to_crm(
                EXPORTING
                  iv_ean            = <fs>-ean    " POC: Case Structuur
                  iv_status         = pa_stat  " POC: Ean Status
                  iv_skip_a3_check  = pa_idoc ).
              COMMIT WORK.

            ELSEIF pa_stat EQ zcl_isu_poc_fw=>co_stat_ean_closed_poc.

              zcl_isu_poc_fw=>send_ean_status_to_crm(
                EXPORTING iv_ean_status         = COND #( WHEN pa_st_rd EQ 'IN' THEN |{ zcl_isu_poc_fw=>co_movein }|
                                                          WHEN pa_st_rd EQ 'BG' THEN |{ zcl_isu_poc_fw=>co_connend }|
                                                          WHEN pa_st_rd EQ 'UB' THEN |{ zcl_isu_poc_fw=>co_conndact }|
                                                          WHEN pa_st_rd EQ ''   THEN || )
                          iv_effectueringsdatum = lv_eff_date
                          iv_case_id            = <fs>-caseid
                          iv_ean                = <fs>-ean ).

              zcl_isu_poc_ean_crudl=>update(
                 EXPORTING
                   is_ean             =   <fs>  " POC: EAN
                   iv_ommit_datechange = lv_ommit_datechange ).
            ELSE.

              zcl_isu_poc_ean_crudl=>update(
               EXPORTING
                 is_ean             =   <fs>  " POC: EAN
                 iv_ommit_datechange = lv_ommit_datechange ).

            ENDIF.
          ELSE.

            zcl_isu_poc_ean_crudl=>update(
              EXPORTING
                is_ean             =   <fs>  " POC: EAN
                iv_ommit_datechange = lv_ommit_datechange ).

          ENDIF.
          lv_teller = lv_teller + 1.

        ENDLOOP.
        MESSAGE |Er is/zijn { lv_teller } EAN(s) aangepast| TYPE 'S'.
    ENDCASE.

  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION

AT SELECTION-SCREEN.
  DATA:       lr_events TYPE REF TO lcl_event_handler.

  CLEAR: lt_dynsql.

  IF pa_dats IS NOT INITIAL.
    SELECT e~* FROM zisu_poc_ean AS e
      INNER JOIN zisu_poc_case AS c
      ON e~caseid EQ c~caseid
    INTO CORRESPONDING FIELDS OF TABLE @lt_ean
          WHERE ean IN @so_ean
            AND c~status LT 49
            AND e~datum_gewijzigd EQ @pa_dats.
  ELSE.
    SELECT e~* FROM zisu_poc_ean AS e
     INNER JOIN zisu_poc_case AS c
     ON e~caseid EQ c~caseid
   INTO CORRESPONDING FIELDS OF TABLE @lt_ean
         WHERE ean IN @so_ean
           AND c~status LT 49.
  ENDIF.

  IF sy-subrc EQ 0 AND lt_ean IS NOT INITIAL.

*Generate an instance of the ALV table object
    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lr_table
      CHANGING
        t_table      = lt_ean.

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
          pfstatus      = 'ZPOCEAN'
          set_functions = lr_table->c_functions_all ).

*set PF-STATUS 'ZPOCEAN'.

    "  Event object ophalen
    DATA(lo_events) = lr_table->get_event( ).

    " lr_table->get_columns( )->set_exception_column( value = 'STATUS' ).

    " Event handler instantieren
    CREATE OBJECT lr_events.
    "Event handler koppelen aan ALV events.
    SET HANDLER lr_events->on_user_command FOR lo_events.

    "Display the ALV table.
    lr_table->display( ).
  ELSE.
    MESSAGE |Geen EAN's gevonden of CASE heeft nog status 49| TYPE 'E'.
  ENDIF.
