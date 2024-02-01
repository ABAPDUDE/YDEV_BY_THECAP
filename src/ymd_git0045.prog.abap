*&---------------------------------------------------------------------*
*& Report YMD_0008
*&---------------------------------------------------------------------*

*/**
* report example EVENTS: SALV_TEST_HIERSEQ_EVENTS
*/*


REPORT ymd_git0045.

TYPES: BEGIN OF ty_tree,
         caseid             TYPE zde_cl_caseid,
         ean                TYPE ext_ui,
*        status_case        TYPE zde_cl_status,
         scenario           TYPE zde_cl_scenario,
         scenario_txt       TYPE val_text,            " scenario omschrijving CASEID
         prioriteit         TYPE zde_cl_prioriteit,
         status             TYPE zde_cl_ean_status,   " status EAN
         omschrijving       TYPE zde_cl_omschrijving, " status omschrijving EAN
         status_reden       TYPE zstatus_reden,
         statusreden_txt    TYPE val_text,
         effectueringsdatum TYPE zeffectueringsdatum,
         product            TYPE sparte,
*        scenario_ean       TYPE zde_cl_scenario,
         einddatum          TYPE zeinddatum_cl,
       END OF ty_tree.
TYPES tty_tree TYPE STANDARD TABLE OF ty_tree WITH NON-UNIQUE SORTED KEY sort_key
COMPONENTS caseid ean.

" Definition is later
CLASS lcl_handle_events DEFINITION DEFERRED.
" object for handling the events of cl_salv_table
DATA: gr_events TYPE REF TO lcl_handle_events.

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
* §5.1 define a local class for handling events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_before_salv_function FOR EVENT before_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_after_salv_function FOR EVENT after_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_double_click FOR EVENT double_click OF cl_salv_events_hierseq
        IMPORTING level row column,

      on_link_click FOR EVENT link_click OF cl_salv_events_hierseq
        IMPORTING level row column.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* §5.2 implement the events for handling the events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    PERFORM show_function_info USING e_salv_function.
  ENDMETHOD.                    "on_user_command

  METHOD on_before_salv_function.
*    PERFORM show_function_info USING e_salv_function TEXT-i09.
  ENDMETHOD.                    "on_before_salv_function

  METHOD on_after_salv_function.
*    PERFORM show_function_info USING e_salv_function TEXT-i10.
  ENDMETHOD.                    "on_after_salv_function

  METHOD on_double_click.
*    PERFORM show_cell_info USING level row column TEXT-i07.
  ENDMETHOD.                    "on_double_click

  METHOD on_link_click.
*    PERFORM show_cell_info USING level row column TEXT-i06.
  ENDMETHOD.                    "on_single_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    DATA: tree_data        TYPE STANDARD TABLE OF ty_tree,
          alv_tree_object  TYPE REF TO cl_salv_tree,
          empty_tree_table TYPE STANDARD TABLE OF ty_tree.
    METHODS:
      get_data,
      present_data.
  PRIVATE SECTION.
    METHODS:
      create_node_hierarchy,
      set_headers,
      set_aggregations,
      set_columns_technical.
ENDCLASS.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE title_b1.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_caseid TYPE zde_cl_caseid DEFAULT '0001370417'.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN END OF BLOCK b1.


INITIALIZATION.
  title_b1 = | Selectie Case-ID contractloos |.

START-OF-SELECTION.
  DATA: my_report TYPE REF TO lcl_report.
  CREATE OBJECT my_report.
  my_report->get_data( ).
  my_report->present_data( ).

CLASS lcl_report IMPLEMENTATION.

  METHOD get_data.

    SELECT zisu_poc_case~caseid zisu_poc_ean~ean
           zisu_poc_case~scenario zisu_poc_case~prioriteit
           zisu_poc_ean~status zisu_poc_statust~omschrijving
           zisu_poc_ean~status_reden zisu_poc_ean~effectueringsdatum
           zisu_poc_ean~product zisu_poc_ean~einddatum
      FROM zisu_poc_case AS zisu_poc_case
      INNER JOIN zisu_poc_ean AS zisu_poc_ean
      ON zisu_poc_case~caseid EQ zisu_poc_ean~caseid
      INNER JOIN zisu_poc_statust AS zisu_poc_statust
      ON  zisu_poc_ean~status EQ zisu_poc_statust~status
      INTO CORRESPONDING FIELDS OF TABLE tree_data   " UP TO p_rows ROWS
      WHERE zisu_poc_statust~taal EQ sy-langu
        AND zisu_poc_case~caseid EQ p_caseid.
*  WHERE zisu_poc_case~caseid IN s_caseid
*    AND zisu_poc_ean~effectueringsdatum IN s_cldate.

    DATA: lv_domain TYPE dd07l-domname.
    DATA: lt_domtab TYPE TABLE OF dd07v,
          gwa_tab   TYPE dd07v.

    lv_domain = 'ZDO_CL_SCENARIO'.

    CALL FUNCTION 'GET_DOMAIN_VALUES'
      EXPORTING
        domname         = lv_domain
      TABLES
        values_tab      = lt_domtab
      EXCEPTIONS
        no_values_found = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    ELSE.

      LOOP AT tree_data
        ASSIGNING FIELD-SYMBOL(<fs_tree>).

        READ TABLE lt_domtab
        WITH KEY domvalue_l = <fs_tree>-scenario
                 ddlanguage = 'N'
        INTO DATA(ls_domain).

        <fs_tree>-scenario_txt = ls_domain-ddtext.

      ENDLOOP.

    ENDIF.

    CLEAR lt_domtab[].

    lv_domain = 'ZSTATUS_REDEN'.

    CALL FUNCTION 'GET_DOMAIN_VALUES'
      EXPORTING
        domname         = lv_domain
      TABLES
        values_tab      = lt_domtab
      EXCEPTIONS
        no_values_found = 1
        OTHERS          = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

    ELSE.

      LOOP AT tree_data
        ASSIGNING FIELD-SYMBOL(<fs_tree1>).

        READ TABLE lt_domtab
        WITH KEY domvalue_l = <fs_tree1>-status_reden
                 ddlanguage = 'N'
        INTO DATA(ls_domain1).

        <fs_tree>-statusreden_txt = ls_domain1-ddtext.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD present_data.
    TRY.
        cl_salv_tree=>factory(
        IMPORTING
        r_salv_tree = alv_tree_object
        CHANGING
        t_table = empty_tree_table ).
      CATCH cx_salv_no_new_data_allowed
      cx_salv_error.
    ENDTRY.
    me->create_node_hierarchy( ).
    me->set_headers( ).
    me->set_columns_technical( ).
*   me->set_aggregations( ).


    " include own functions by setting own status
    DATA lr_functions TYPE REF TO cl_salv_functions_tree.

    alv_tree_object->set_screen_status(
         pfstatus   =  'SALV_STANDARD'
         report     =  sy-repid ).

    " activate ALV generic Functions
    lr_functions = alv_tree_object->get_functions( ).
    lr_functions->set_all( abap_true ).

    " register to the events of cl_salv_hierseq_table
*    DATA: lr_events TYPE REF TO cl_salv_events_hierseq.
*    lr_events = gr_hierseq->get_event( ).

    DATA: lr_events TYPE REF TO cl_salv_events_tree.
    lr_events = alv_tree_object->get_event( ).

    CREATE OBJECT gr_events.

*... §6.1 register to the event USER_COMMAND
    SET HANDLER gr_events->on_user_command FOR lr_events.
*... §6.2 register to the event BEFORE_SALV_FUNCTION
    SET HANDLER gr_events->on_before_salv_function FOR lr_events.
*... §6.3 register to the event AFTER_SALV_FUNCTION
    SET HANDLER gr_events->on_after_salv_function FOR lr_events.
*... §6.4 register to the event DOUBLE_CLICK
*   SET HANDLER gr_events->on_double_click FOR lr_events.
*... §6.5 register to the event LINK_CLICK
*    SET HANDLER gr_events->on_link_click FOR lr_events.


    alv_tree_object->display( ).

  ENDMETHOD.

  METHOD create_node_hierarchy.
    DATA: parent_node_key TYPE lvc_nkey,
          child_node_key  TYPE lvc_nkey,
          nodes           TYPE REF TO cl_salv_nodes,
          node            TYPE REF TO cl_salv_node,
          node_text       TYPE lvc_value.
    FIELD-SYMBOLS: <hierarchy_line> TYPE ty_tree.
    nodes = alv_tree_object->get_nodes( ).
    TRY.
        LOOP AT tree_data ASSIGNING <hierarchy_line>.
          AT NEW caseid.

            node = nodes->add_node(
                related_node = space
                relationship = if_salv_c_node_relation=>parent
                folder = abap_true
                expanded_icon  = '@3P@' " icon_header
                collapsed_icon = '@3P@' " icon_header
                ).

            node_text = <hierarchy_line>-caseid.
            SHIFT node_text LEFT DELETING LEADING '0'.
            node->set_text( node_text ).
*            node->set_data_row( <hierarchy_line> ).
            parent_node_key = node->get_key( ).

          ENDAT.

          AT NEW ean.

            node = nodes->add_node(
                related_node = parent_node_key
                relationship = if_salv_c_node_relation=>first_child
                folder = abap_true
                expanded_icon  = '@3R@' " icon_detail
                collapsed_icon = '@3R@' " icon_detail
                ).

            node_text = | EAN: | && <hierarchy_line>-ean.
            SHIFT node_text LEFT DELETING LEADING '0'.
            node->set_text( node_text ).
            node->set_data_row( <hierarchy_line> ).
            nodes->expand_all( ).

            child_node_key = node->get_key( ).

          ENDAT.

*          node = nodes->add_node( related_node = parent_node_key
*          relationship = if_salv_c_node_relation=>first_child ).
*          node->set_data_row( <hierarchy_line> ).
        ENDLOOP.
      CATCH cx_salv_msg.
    ENDTRY.
  ENDMETHOD.

  METHOD set_headers.
    DATA: settings TYPE REF TO cl_salv_tree_settings.
    settings = alv_tree_object->get_tree_settings( ).
    settings->set_hierarchy_header( 'Contractloos CaseID' ).
    settings->set_hierarchy_size( 35 ).
    settings->set_header( 'COCO: Contractloos Cockpit' ).
  ENDMETHOD.

  METHOD set_aggregations.
*    DATA: aggregations TYPE REF TO cl_salv_aggregations.
*    aggregations = alv_tree_object->get_aggregations( ).
*    TRY.
*        aggregations->add_aggregation( columnname = 'LOCCURAM' ).
*      CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
*    ENDTRY.
  ENDMETHOD.

  METHOD set_columns_technical.
    DATA: columns TYPE REF TO cl_salv_columns,
          column  TYPE REF TO cl_salv_column.
    columns = alv_tree_object->get_columns( ).
    TRY.
        column = columns->get_column( 'CASEID' ).
        column->set_technical( abap_true ).

        column = columns->get_column( 'EAN' ).
        column->set_technical( abap_true ).

        column = columns->get_column( 'SCENARIO' ).
        column->set_short_text( 'Scenario' ).
        column->set_output_length( 10 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'SCENARIO_TXT' ).
        column->set_medium_text( 'Scenario tekst' ).
        column->set_output_length( 20 ).
        column->set_alignment( if_salv_c_alignment=>left ).

        column = columns->get_column( 'PRIORITEIT' ).
        column->set_short_text( 'Prioriteit' ).
        column->set_output_length( 10 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'STATUS' ).
        column->set_short_text( 'Status' ).
        column->set_output_length( 10 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'OMSCHRIJVING' ).
        column->set_technical( if_salv_c_bool_sap=>false ).
*        column->set_fixed_header_text( '1' ).
        column->set_optimized( abap_true ).
        column->set_medium_text( 'Status tekst' ).
        column->set_long_text( 'Status tekst' ).
        column->set_output_length( 30 ).
        column->set_alignment( if_salv_c_alignment=>left ).

        column = columns->get_column( 'STATUS_REDEN' ).
        column->set_long_text( 'Status reden' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'STATUSREDEN_TXT' ).
        column->set_long_text( 'Statusreden tekst' ).
        column->set_output_length( 30 ).
        column->set_alignment( if_salv_c_alignment=>left ).

        column = columns->get_column( 'EFFECTUERINGSDATUM' ).
        column->set_long_text( 'Effectueringsdatum' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>left ).

        column = columns->get_column( 'PRODUCT' ).
        column->set_long_text( 'Product' ).
        column->set_output_length( 16 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'EINDATUM' ).
        column->set_short_text( 'Einddatum' ).
        column->set_output_length( 16 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

      CATCH cx_salv_not_found.
    ENDTRY.
  ENDMETHOD.


ENDCLASS.


*&---------------------------------------------------------------------*
*&      Form  show_function_info
*&---------------------------------------------------------------------*
FORM show_function_info USING i_function TYPE salv_de_function.

  DATA: l_string TYPE string.

  CASE i_function.
    WHEN 'CUSTOM_BT1'.

      CONCATENATE 'je hebt gedrukt op: ' i_function 'parkeren CaseID'
      INTO l_string SEPARATED BY space.
      MESSAGE i000(0k) WITH l_string.

    WHEN 'CUSTOM_BT2'.

      CONCATENATE 'je hebt gedrukt op: ' i_function 'doorzetten naar DW'
      INTO l_string SEPARATED BY space.
      MESSAGE i000(0k) WITH l_string.

    WHEN 'CUSTOM_BT3'.

      CONCATENATE 'je hebt gedrukt op: ' i_function 'nog te bepalen'
      INTO l_string SEPARATED BY space.
      MESSAGE i000(0k) WITH l_string.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.                    " show_function_info
