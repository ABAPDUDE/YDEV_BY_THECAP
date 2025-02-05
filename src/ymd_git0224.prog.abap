*&---------------------------------------------------------------------*
*& Report YMD_0008
*&---------------------------------------------------------------------*

*/**
* report example EVENTS: SALV_TEST_HIERSEQ_EVENTS
* copy from YMD_GIT0045
*/*


REPORT ymd_git0224.

TYPES: BEGIN OF ty_tree,
         caseid             TYPE  zde_cl_caseid,
         ean                TYPE  ext_ui,
         data_type          TYPE  zde_datatype_vzc,
         data_type_txt      TYPE  char25,
         stand_volgorde     TYPE  zstand_volgorde,
         effectueringsdatum TYPE  zde_effectueringdatum,
         begin_opnamedatum  TYPE  zperiode_begin,
         eind_opnamedatrum  TYPE  zperiode_eind,
         beginstand_t1      TYPE  zbegin_meterstand_t1,
         eindstand_t1       TYPE  zeind_meterstand_t1,
         verbruik_t1        TYPE  zverbruik_t1,
         beginstand_t2      TYPE  zbegin_meterstand_t2,
         eindstand_t2       TYPE  zeind_meterstand_t2,
         verbruik_t2        TYPE  zverbruik_t2,
         berichttype        TYPE  zde_cl_berichttype,
       END OF ty_tree.

TYPES tty_tree TYPE STANDARD TABLE OF ty_tree WITH NON-UNIQUE SORTED KEY sort_key
COMPONENTS caseid ean stand_volgorde.

" Definition is later
CLASS lcl_handle_events DEFINITION DEFERRED.
" object for handling the events of cl_salv_table
DATA: gr_events TYPE REF TO lcl_handle_events.

DATA gv_effdatum_eosupply TYPE zisu_poc_message-effectueringsdatum.
CONSTANTS mc_msg_type_eosupply TYPE zde_msgtype_car VALUE 'EOSUPPLY' ##NO_TEXT.
CONSTANTS mc_status_msg_fout TYPE zde_cl_msg_status VALUE '97' ##NO_TEXT.

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
SELECT-OPTIONS: s_date FOR gv_effdatum_eosupply.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN END OF BLOCK b1.


INITIALIZATION.
  title_b1 = | Selectie VZC maandelijks factureren Cross-Check Workload en RP16 |.

START-OF-SELECTION.
  DATA: my_report TYPE REF TO lcl_report.
  CREATE OBJECT my_report.
  my_report->get_data( ).
  my_report->present_data( ).

CLASS lcl_report IMPLEMENTATION.

  METHOD get_data.

    DATA lt_crosscheck TYPE STANDARD TABLE OF zst_vzc_cross_check WITH NON-UNIQUE SORTED KEY vzc COMPONENTS ean caseid.
    DATA ls_crosscheck TYPE zst_vzc_cross_check.

    DATA lv_domain TYPE dd07l-domname.
    DATA lt_domtab TYPE TABLE OF dd07v.

    SELECT msg~ean, msg~berichttype, msg~effectueringsdatum, msg~status, msg~marktsegment, ean~status AS status_ean,
            case~caseid, case~verbruiksplaats
      INTO TABLE @DATA(lt_msg)
      FROM zisu_poc_message AS msg
      INNER JOIN zisu_poc_ean AS ean
      ON msg~ean EQ ean~ean
      INNER JOIN zisu_poc_case AS case
      ON ean~caseid EQ case~caseid
      AND msg~effectueringsdatum EQ ean~effectueringsdatum
        WHERE msg~effectueringsdatum IN @s_date
          AND msg~berichttype EQ @mc_msg_type_eosupply
          AND msg~status NE @mc_status_msg_fout.              " het bericht is 'afgekeurd'!

    LOOP AT lt_msg
    INTO DATA(ls_msg).

      SELECT *
      APPENDING TABLE @DATA(lt_vzcfac)
      FROM zp5_meetdata_el
       WHERE ean EQ @ls_msg-ean
         AND effectueringsdatum EQ @ls_msg-effectueringsdatum.

      SELECT *
       APPENDING TABLE @DATA(lt_rp16)
       FROM zx310_disputen
        WHERE ext_ui EQ @ls_msg-ean
          AND opnamedatum_dr EQ @ls_msg-effectueringsdatum.

      SELECT *
         APPENDING TABLE @DATA(lt_workload)
          FROM ztvzc_workload
      WHERE ext_ui EQ @ls_msg-ean
        AND caseid EQ @ls_msg-caseid.

      SELECT *
          APPENDING TABLE @DATA(lt_workload_st)
           FROM zvzc_workload_st
       WHERE ext_ui EQ @ls_msg-ean
         AND caseid EQ @ls_msg-caseid.

    ENDLOOP.

    LOOP AT lt_vzcfac
        INTO DATA(ls_vzcfac).

      ls_crosscheck-ean = ls_vzcfac-ean.
      ls_crosscheck-data_type = '01'.
      ls_crosscheck-stand_volgorde = ls_vzcfac-stand_volgorde.
      ls_crosscheck-caseid = ls_vzcfac-caseid.
      ls_crosscheck-effectueringsdatum = ls_vzcfac-effectueringsdatum.
      ls_crosscheck-begin_opnamedatum = ls_vzcfac-selectie_begindatum.
      ls_crosscheck-eind_opnamedatrum = ls_vzcfac-selectie_einddatum.
      ls_crosscheck-beginstand_t1 = ls_vzcfac-beginstand_t1.
      ls_crosscheck-eindstand_t1 = ls_vzcfac-eindstand_t1.
      ls_crosscheck-verbruik_t1 = ls_vzcfac-verbruik_t1.
      ls_crosscheck-beginstand_t2 = ls_vzcfac-beginstand_t2.
      ls_crosscheck-eindstand_t2 = ls_vzcfac-eindstand_t1.
      ls_crosscheck-verbruik_t2 = ls_vzcfac-verbruik_t2.
      ls_crosscheck-berichttype = mc_msg_type_eosupply.

      APPEND ls_crosscheck TO lt_crosscheck.

    ENDLOOP.

    LOOP AT lt_rp16
   INTO DATA(ls_rp16).

      ls_crosscheck-ean = ls_rp16-ext_ui.
      ls_crosscheck-data_type = '02'.
*   ls_crosscheck-stand_volgorde = .
      ls_crosscheck-caseid = ls_rp16-caseid.
*   ls_crosscheck-effectueringsdatum = .
      ls_crosscheck-begin_opnamedatum = ls_rp16-opnamedatum_dr.
      ls_crosscheck-eind_opnamedatrum = ls_rp16-opnamedatum.
      ls_crosscheck-beginstand_t1 = ls_rp16-stand_e11_dr.
      ls_crosscheck-eindstand_t1 = ls_rp16-stand_e11_x310.
      ls_crosscheck-verbruik_t1 = ls_rp16-verbruik_e11.
      ls_crosscheck-beginstand_t2 = ls_rp16-stand_e10_dr.
      ls_crosscheck-eindstand_t2 = ls_rp16-stand_e10_x310.
      ls_crosscheck-verbruik_t2 = ls_rp16-verbruik_e10.
      ls_crosscheck-berichttype = mc_msg_type_eosupply.

      APPEND ls_crosscheck TO lt_crosscheck.

    ENDLOOP.

    LOOP AT lt_workload
     INTO DATA(ls_workload).

      ls_crosscheck-ean = ls_workload-ext_ui.
      ls_crosscheck-data_type = '03'.
*   ls_crosscheck-stand_volgorde = .
      ls_crosscheck-caseid = ls_workload-caseid.
*   ls_crosscheck-effectueringsdatum = .
      ls_crosscheck-begin_opnamedatum = ls_workload-begda.
      ls_crosscheck-eind_opnamedatrum = ls_workload-endda.
      ls_crosscheck-beginstand_t1 = ls_workload-stand_e11_dr.
      ls_crosscheck-eindstand_t1 = ls_workload-stand_e11_x310.
      ls_crosscheck-verbruik_t1 = ls_workload-verbruik_e11.
      ls_crosscheck-beginstand_t2 = ls_workload-stand_e10_dr.
      ls_crosscheck-eindstand_t2 = ls_workload-stand_e10_x310.
      ls_crosscheck-verbruik_t2 = ls_workload-verbruik_e10.
      ls_crosscheck-berichttype = mc_msg_type_eosupply.

      APPEND ls_crosscheck TO lt_crosscheck.

    ENDLOOP.

    LOOP AT lt_workload_st
     INTO DATA(ls_workload_st).

      ls_crosscheck-ean = ls_workload_st-ext_ui.
      ls_crosscheck-data_type = '04'.
*   ls_crosscheck-stand_volgorde = .
      ls_crosscheck-caseid = ls_workload_st-caseid.
*   ls_crosscheck-effectueringsdatum = .
      ls_crosscheck-begin_opnamedatum = ls_workload_st-begda.
      ls_crosscheck-eind_opnamedatrum = ls_workload_st-endda.
      ls_crosscheck-beginstand_t1 = ls_workload_st-stand_e11_dr.
      ls_crosscheck-eindstand_t1 = ls_workload_st-stand_e11_x310.
      ls_crosscheck-verbruik_t1 = ls_workload_st-verbruik_e11.
      ls_crosscheck-beginstand_t2 = ls_workload_st-stand_e10_dr.
      ls_crosscheck-eindstand_t2 = ls_workload_st-stand_e10_x310.
      ls_crosscheck-verbruik_t2 = ls_workload_st-verbruik_e10.
      ls_crosscheck-berichttype = mc_msg_type_eosupply.

      APPEND ls_crosscheck TO lt_crosscheck.

    ENDLOOP.

    tree_data[] = CORRESPONDING #( lt_crosscheck[] ).
    SORT tree_data BY caseid ean data_type.

    lv_domain = 'ZDO_DATATYPE_VZC'.

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
        WITH KEY domvalue_l = <fs_tree>-data_type
                 ddlanguage = 'N'
        INTO DATA(ls_domain1).

        <fs_tree>-data_type_txt = ls_domain1-ddtext.

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
          last_node_key   TYPE lvc_nkey,
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
*           node->set_data_row( <hierarchy_line> ).
            nodes->expand_all( ).

            child_node_key = node->get_key( ).

          ENDAT.

          node = nodes->add_node(
            related_node = child_node_key
            relationship = if_salv_c_node_relation=>last_child
            folder = abap_true
            expanded_icon  = '@0V\Qzuzuuzz@'
            collapsed_icon = '@0V\Qzuzuuzz@'
            ).

          DATA item TYPE REF TO cl_salv_item.

*... §5.1 add a checkbox to this node in the hierarchy column
          item = node->get_hierarchy_item( ).
          item->set_type( if_salv_c_item_type=>checkbox ).
          item->set_editable( abap_true ).

          node_text = | DATA: | && <hierarchy_line>-data_type.
          SHIFT node_text LEFT DELETING LEADING '0'.
          node->set_text( node_text ).

          node->set_data_row( <hierarchy_line> ).
          nodes->expand_all( ).

          last_node_key = node->get_key( ).

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
    settings->set_hierarchy_header( 'VZC- Contractloos CaseID' ).
    settings->set_hierarchy_size( 35 ).
    settings->set_header( 'VZC: Maandelijks Factureren' ).
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
        column->set_output_length( 10 ).

        column = columns->get_column( 'EAN' ).
        column->set_technical( abap_true ).
        column->set_output_length( 20 ).

        column = columns->get_column( 'DATA_TYPE' ).
        column->set_medium_text( 'Data oorsprong' ).
        column->set_output_length( 10 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'DATA_TYPE_TXT' ).
        column->set_medium_text( 'Omschrijving' ).
        column->set_output_length( 35 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'STAND_VOLGORDE' ).
        column->set_medium_text( 'P5 Stand volgorde' ).
        column->set_output_length( 15 ).
        column->set_alignment( if_salv_c_alignment=>left ).
        column->set_leading_zero(
            value = if_salv_c_bool_sap=>true ).
        column->has_leading_zero( ).

        column = columns->get_column( 'EFFECTUERINGSDATUM' ).
        column->set_short_text( 'Eff-datum' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'BEGIN_OPNAMEDATUM' ).
        column->set_short_text( 'Begindatum' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'EIND_OPNAMEDATRUM' ).
        column->set_short_text( 'Einddatum' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>centered ).

        column = columns->get_column( 'BEGINSTAND_T1' ).
        column->set_long_text( 'T1 beginstand' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>right ).

        column = columns->get_column( 'EINDSTAND_T1' ).
        column->set_long_text( 'T1 eindstand' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>right ).

        column = columns->get_column( 'VERBRUIK_T1' ).
        column->set_long_text( 'T1 verbruik' ).
        column->set_output_length( 10 ).
        column->set_alignment( if_salv_c_alignment=>right ).

        column = columns->get_column( 'BEGINSTAND_T2' ).
        column->set_long_text( 'T2 beginstand' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>right ).

        column = columns->get_column( 'EINDSTAND_T2' ).
        column->set_long_text( 'T2 eindstand' ).
        column->set_output_length( 12 ).
        column->set_alignment( if_salv_c_alignment=>right ).

        column = columns->get_column( 'VERBRUIK_T2' ).
        column->set_long_text( 'T2 verbruik' ).
        column->set_output_length( 10 ).
        column->set_alignment( if_salv_c_alignment=>right ).

        column = columns->get_column( 'BERICHTTYPE' ).
        column->set_long_text( 'Berichttype' ).
        column->set_output_length( 15 ).
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

      CONCATENATE 'je hebt gedrukt op: ' i_function 'Wijzig status regel Workload'
      INTO l_string SEPARATED BY space.
      MESSAGE i000(0k) WITH l_string.

    WHEN 'CUSTOM_BT2'.

      CONCATENATE 'je hebt gedrukt op: ' i_function 'Verwijder regel uit Workload'
      INTO l_string SEPARATED BY space.
      MESSAGE i000(0k) WITH l_string.

    WHEN 'CUSTOM_BT3'.

      CONCATENATE 'je hebt gedrukt op: ' i_function 'Nog nader te bepalen'
      INTO l_string SEPARATED BY space.
      MESSAGE i000(0k) WITH l_string.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.                    " show_function_info
