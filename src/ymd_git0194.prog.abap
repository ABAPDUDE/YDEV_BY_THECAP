*&---------------------------------------------------------------------*
*& Report ZCONTRACTLOOS_FACTURATIE_DW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0194.

*/**
* Het gaat om inzicht in de dossiers met status = 49
* waarbij ‘Datum dossier gesloten’ ligt in de periode waarover de factuur is vastgesteld.
* Die periode is door de medewerker in te geven;
*
* Details die zichtbaar moeten worden bij dit inzicht:
* Case ID
* Dossiernummer;
* EAN('s);
* Status van het dossier;
* Datum van sluiten van het dossier door Bosveld;
* Decalration_amount - Bedrag dat door Bosveld in rekening gebracht gaat worden bij Alliander;
* Settlement_amount - Bedrag dat door Bosveld aan Liander betaald wordt. Dit veld is altijd E 0.
*/*

INCLUDE zcontractloos_facturatie_sel.

START-OF-SELECTION.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_facdw
    FROM zpoc_dossier
    WHERE datum_gesloten_dw IN s_date
      AND status EQ '99'.

  DATA(lv_lines_facdw) = lines( gt_facdw ).

  IF lv_lines_facdw GE '1'.

    SELECT caseid, ean, product
      INTO TABLE @DATA(lt_ean)
      FROM zisu_poc_ean
     FOR ALL ENTRIES IN @gt_facdw
      WHERE caseid EQ @gt_facdw-caseid.

    LOOP AT gt_facdw
      ASSIGNING FIELD-SYMBOL(<fs_facdw>).

      READ TABLE lt_ean INTO DATA(ls_ean_n)
      WITH KEY caseid = <fs_facdw>-caseid
               product = 'N'.
      <fs_facdw>-ean_elec = ls_ean_n-ean.

      READ TABLE lt_ean INTO DATA(ls_ean_ng)
       WITH KEY caseid = <fs_facdw>-caseid
                product = 'NG'.
      <fs_facdw>-ean_gas = ls_ean_ng-ean.

    ENDLOOP.

    gt_facdw_alv[] = gt_facdw[].


    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = gt_facdw_alv ).
      CATCH cx_salv_msg INTO DATA(lr_message).
    ENDTRY.

    go_aggregations = go_alv->get_aggregations( ).

    TRY.

        CALL METHOD go_aggregations->add_aggregation(
            columnname  = 'BEDRAG_TE_BETALEN'
            aggregation = if_salv_c_aggregation=>total ).

        CALL METHOD go_aggregations->add_aggregation(
            columnname  = 'BEDRAG_TE_BETALEN_BTW'
            aggregation = if_salv_c_aggregation=>total ).

        CALL METHOD go_aggregations->add_aggregation(
            columnname  = 'BEDRAG_TE_ONTVANGEN'
            aggregation = if_salv_c_aggregation=>total ).

        CALL METHOD go_aggregations->add_aggregation(
            columnname  = 'BEDRAG_TE_ONTVANGEN_BTW'
            aggregation = if_salv_c_aggregation=>total ).

      CATCH cx_salv_data_error.                         "#EC NO_HANDLER
      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
      CATCH cx_salv_existing.                           "#EC NO_HANDLER

    ENDTRY.

    go_functions = go_alv->get_functions( ).
    go_functions->set_all( ).
    go_columns = go_alv->get_columns( ).
    go_columns->set_optimize( ).
    go_alv->display( ).

  ELSE.
    MESSAGE 'Er zijn geen facturen gevonden voor sit tijdvak!' TYPE 'I'.
  ENDIF.
