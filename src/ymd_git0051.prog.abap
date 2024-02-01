*&---------------------------------------------------------------------*
*& Report YMD_0006
*&---------------------------------------------------------------------*
*& demo SALV_DEMO_TREE_FUNCTIONS
* demo - SALV_DEMO_TREE_EVENTS
*&---------------------------------------------------------------------*
REPORT ymd_git0051.

TYPES: BEGIN OF ty_final,

         caseid              TYPE zde_cl_caseid,
         ean                 TYPE ext_ui,
*        status_case         TYPE zde_cl_status,
         scenario_case       TYPE zde_cl_scenario,
         prioriteit          TYPE zde_cl_prioriteit,
         status_ean          TYPE zde_cl_ean_status,
         status_omschrijving TYPE zde_cl_omschrijving,
         status_reden        TYPE zstatus_reden,
         effectueringsdatum  TYPE zeffectueringsdatum,
         product             TYPE sparte,
*        scenario_ean        TYPE zde_cl_scenario,
         einddatum           TYPE zeinddatum_cl,
         parkeren            TYPE char20,
       END OF ty_final.
TYPES tty_final TYPE STANDARD TABLE OF ty_final WITH NON-UNIQUE SORTED KEY sort_key
COMPONENTS caseid ean.

DATA gt_final  TYPE tty_final.
DATA gt_final1 TYPE tty_final.
DATA go_tree   TYPE REF TO cl_salv_tree.


CLASS lcl_handle_events DEFINITION DEFERRED.
DATA go_events TYPE REF TO lcl_handle_events.

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_tree
        IMPORTING node_key columnname,
      on_link_click FOR EVENT link_click OF cl_salv_events_tree
        IMPORTING columnname node_key,
      on_before_user_command FOR EVENT before_salv_function OF cl_salv_events
        IMPORTING e_salv_function,
      on_after_user_command FOR EVENT after_salv_function OF cl_salv_events
        IMPORTING e_salv_function,
      on_keypress FOR EVENT keypress OF cl_salv_events_tree
        IMPORTING node_key columnname key.

    METHODS add_tree_node_caseid IMPORTING iv_nkey        TYPE salv_de_node_key OPTIONAL   " related_node
                                           is_data        TYPE ty_final         OPTIONAL   " data_row
                                           iv_text        TYPE lvc_value        OPTIONAL   " text
                                           iv_set_type    TYPE i                OPTIONAL
                                           iv_set_style   TYPE recpalvbox       OPTIONAL   " row_style
                                 RETURNING VALUE(rv_nkey) TYPE salv_de_node_key.
    METHODS add_tree_node_ean IMPORTING iv_nkey        TYPE salv_de_node_key OPTIONAL   " related_node
                                        is_data        TYPE ty_final         OPTIONAL   " data_row
                                        iv_text        TYPE lvc_value        OPTIONAL   " text
                                        iv_set_type    TYPE i                OPTIONAL
                                        iv_set_style   TYPE recpalvbox       OPTIONAL   " row_style
                              RETURNING VALUE(rv_nkey) TYPE salv_de_node_key.
    METHODS parkeren_caseid IMPORTING io_node TYPE REF TO cl_salv_node.

ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_double_click.
*    PERFORM show_event_info USING node_key columnname TEXT-i06.
  ENDMETHOD.                    "on_double_click

  METHOD on_link_click.

    DATA: key TYPE salv_de_node_key.

    " Method when the user clicks on Link or button
    DATA: lo_nodes TYPE REF TO cl_salv_nodes,
          lo_node  TYPE REF TO cl_salv_node.

    lo_nodes = go_tree->get_nodes( ).

    " Get the parent node
    TRY.
        lo_node = lo_nodes->get_node( node_key ).
      CATCH cx_salv_msg.
        EXIT.
    ENDTRY.

    go_events->parkeren_caseid( lo_node ).

  ENDMETHOD.                    "on_single_click

  METHOD on_before_user_command.
*    PERFORM show_function_info USING e_salv_function TEXT-i09.
  ENDMETHOD.                    "on_before_user_command

  METHOD on_after_user_command.
*    PERFORM show_function_info USING e_salv_function TEXT-i10.
  ENDMETHOD.                    "on_after_user_command

  METHOD on_keypress.
    DATA: text TYPE string.
    MOVE key TO text.
    CONCATENATE TEXT-i12 text INTO text.
*    PERFORM show_event_info USING node_key columnname text.
  ENDMETHOD.
  METHOD add_tree_node_caseid.

    " Add a node to the ALV tree
    DATA: lo_nodes         TYPE REF TO cl_salv_nodes,
          lo_node          TYPE REF TO cl_salv_node,
          lo_item          TYPE REF TO cl_salv_item,
          lo_item_delivery TYPE REF TO cl_salv_item.

    lo_nodes = go_tree->get_nodes( ).

    " We use the standard method to add the node
    TRY.
        lo_node = lo_nodes->add_node(
         related_node   = iv_nkey
         relationship   = if_salv_c_node_relation=>last_child
*        data_row       = is_data
         collapsed_icon = '@5F@'    "space
         expanded_icon  = '@5F@'    "space
         text           = iv_text ).

        " We provided text only for CaseID node.
        " The below code will set the text of the node
        " Set the text for the node
        IF iv_text IS NOT INITIAL.
          lo_node->set_text( iv_text ).
        ENDIF.

        lo_item = lo_node->get_hierarchy_item( ).

        IF iv_nkey IS INITIAL.
          " For the CaseID node, we take the "PARK' column and set it to Button
          TRY.
              lo_item_delivery = lo_node->get_item( 'PARKEREN' ).
            CATCH cx_salv_msg.
              EXIT.
          ENDTRY.
          lo_item_delivery->set_type( if_salv_c_item_type=>button ).
          lo_item_delivery->set_value( |Parkeren CaseID| ).

        ELSE.
        ENDIF.

        " Return the node key
        rv_nkey = lo_node->get_key( ).

      CATCH cx_salv_msg.
        LEAVE LIST-PROCESSING.
    ENDTRY.

  ENDMETHOD.
  METHOD add_tree_node_ean.

    " Add a node to the ALV tree
    DATA: lo_nodes         TYPE REF TO cl_salv_nodes,
          lo_node          TYPE REF TO cl_salv_node,
          lo_item          TYPE REF TO cl_salv_item,
          lo_item_delivery TYPE REF TO cl_salv_item.

    lo_nodes = go_tree->get_nodes( ).

    " We use the standard method to add the node
    TRY.
        lo_node = lo_nodes->add_node(
         related_node   = iv_nkey
         relationship   = if_salv_c_node_relation=>last_child
         data_row       = is_data
         collapsed_icon = '@5F@'    "space
         expanded_icon  = '@5F@'    "space
         text           = iv_text ).

        " In order to distinguish between EANs, we set different background colors.
        " The below code sets blue color as background
        IF iv_set_style IS NOT INITIAL.
          lo_node->set_row_style( if_salv_c_tree_style=>emphasized_b ).
        ENDIF.

        lo_item = lo_node->get_hierarchy_item( ).


        IF iv_nkey IS INITIAL.
        ELSE.
          " For the EAN nodes, we get the entire row and Set it as editable checkbox
          lo_item->set_type( if_salv_c_item_type=>checkbox ).
          lo_item->set_editable( abap_true ).

          " Set the data of the node
          lo_node->set_data_row( is_data ).
          lo_nodes->expand_all( ).

        ENDIF.

        " Return the node key
        rv_nkey = lo_node->get_key( ).

      CATCH cx_salv_msg.
        LEAVE LIST-PROCESSING.
    ENDTRY.

  ENDMETHOD.

  METHOD parkeren_caseid.

*---------------------------------------------------------
* Create the delivery from the selected Orders
*---------------------------------------------------------

    DATA: lt_nodes TYPE salv_t_nodes,
          lo_item  TYPE REF TO cl_salv_item,
          lo_data  TYPE REF TO data.
*         lv_delivery      TYPE vbeln_vl,
*         lv_number        TYPE vbnum,
*         lt_sales_orders  TYPE STANDARD TABLE OF bapidlvreftosalesorder,
*         lt_created_items TYPE STANDARD TABLE OF bapidlvitemcreated,
*         lt_return        TYPE STANDARD TABLE OF bapiret2.

    FIELD-SYMBOLS: <ls_nodes>  TYPE salv_s_nodes,
                   <ls_data>   TYPE ty_final,
                   <ls_orders> TYPE bapidlvreftosalesorder,
                   <ls_items>  TYPE bapidlvitemcreated.

    " Get the entire subtree
    TRY.
        lt_nodes = io_node->get_subtree( ).
      CATCH cx_salv_msg.
        EXIT.
    ENDTRY.

    " Here we will loop at all the nodes, find the ones that were selected
    " and pass those orders to BAPI for Delivery creation
    LOOP AT lt_nodes ASSIGNING <ls_nodes>.

      " Get the item details
      lo_item = <ls_nodes>-node->get_hierarchy_item( ).

      " Get the node data if it is checked
      IF lo_item->is_enabled( ) = abap_true
      AND lo_item->is_checked( ) = abap_true.

        lo_data = <ls_nodes>-node->get_data_row( ).
        ASSIGN lo_data->* TO <ls_data>.
        IF sy-subrc EQ 0.

*          " Get the sales order and item
*          APPEND INITIAL LINE TO lt_sales_orders ASSIGNING <ls_orders>.
*          <ls_orders>-ref_doc  = <ls_data>-vbeln.
*          <ls_orders>-ref_item = <ls_data>-posnr.

        ENDIF.
      ENDIF.

    ENDLOOP.

** Call the BAPI for Delivery Creation
*    CALL FUNCTION 'BAPI_OUTB_DELIVERY_CREATE_SLS'
*      IMPORTING
*        delivery          = lv_delivery
*        num_deliveries    = lv_number
*      TABLES
*        sales_order_items = lt_sales_orders
*        created_items     = lt_created_items
*        return            = lt_return.
*
*
*    SORT lt_created_items BY ref_doc ref_item.
*
*    IF lv_delivery IS NOT INITIAL.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*    ELSE.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*    ENDIF.

    " Next, loop at the nodes and display the delivery
    LOOP AT lt_nodes ASSIGNING <ls_nodes>.
      lo_item = <ls_nodes>-node->get_hierarchy_item( ).
      IF lo_item->is_checked( ) = abap_true.
        lo_item->set_checked( abap_false ).
        lo_data = <ls_nodes>-node->get_data_row( ).
        ASSIGN lo_data->* TO <ls_data>.
        IF sy-subrc EQ 0.
*         " Set the delivery
*          READ TABLE lt_created_items ASSIGNING <ls_items>
*            WITH KEY ref_doc  = <ls_data>-vbeln
*                     ref_item = <ls_data>-posnr
*                     BINARY SEARCH.
*          IF sy-subrc EQ 0.
*            <ls_data>-delivery = <ls_items>-deliv_numb.
*            <ls_nodes>-node->set_data_row( <ls_data> ).
*          ENDIF.
        ENDIF.

        " Disable the checkbox if 'parkeren_caseID' is executed
        IF <ls_data>-parkeren IS NOT INITIAL.
          lo_item->set_enabled( abap_false ).
          lo_item->set_icon( '@0V\QOK@' ).      "OK
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION




START-OF-SELECTION.

* DATA(go_logic) = NEW lcl_tree_logic( ).
* DATA(go_events) = NEW lcl_handle_events( ).
  CREATE OBJECT go_events.

  " Create ALV tree
  TRY.
      cl_salv_tree=>factory(
        IMPORTING
          r_salv_tree = go_tree
        CHANGING
          t_table     = gt_final1 ).
    CATCH cx_salv_error.
      LEAVE LIST-PROCESSING.
  ENDTRY.

  " Set the heading for the report
  DATA: lo_settings TYPE REF TO cl_salv_tree_settings.

  lo_settings = go_tree->get_tree_settings( ).
  lo_settings->set_hierarchy_header( | Contractloos CaseID | ).
  lo_settings->set_hierarchy_tooltip( | Contractloos CaseID | ).
  lo_settings->set_header(  | CaseID Park Report | ).

  " Register LINK_CLICK event
  DATA: lo_events TYPE REF TO cl_salv_events_tree.

  lo_events = go_tree->get_event( ).
  SET HANDLER go_events->on_link_click FOR lo_events.


  " get DDIC data
  " Select Data DDIC
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
    INTO TABLE gt_final UP TO 10 ROWS
    WHERE zisu_poc_statust~taal EQ sy-langu
      AND zisu_poc_ean~status EQ '26'.
*  WHERE zisu_poc_case~caseid IN s_caseid
*    AND zisu_poc_ean~effectueringsdatum IN s_cldate.

  DATA ls_previous TYPE ty_final.
  DATA lv_caseid_key TYPE salv_de_node_key.
  DATA lv_set_style TYPE recpalvbox.
  DATA lv_node_text TYPE lvc_value.

  " Supply the data and build the hierarchy
  LOOP AT gt_final ASSIGNING FIELD-SYMBOL(<ls_final>).

    " Check if there is a change in CaseID number
    " in which case a new folder needs to be created
    IF <ls_final>-caseid NE ls_previous-caseid.

      " Get the CaseID text
      CLEAR lv_node_text.
      lv_node_text = | CaseID:  | && <ls_final>-caseid.

      " Here we get the key to the CaseID node, we will use it for EANs belonging to this CaseID
      " Create new folder for CaseID
      CLEAR lv_caseid_key.
      lv_caseid_key = go_events->add_tree_node_caseid( iv_nkey =  ' '
                                                iv_text = lv_node_text ).

    ENDIF.

    " Keep changing the flag to get alternate background color - Changing colors as EAN no. changes
    IF ls_previous-ean NE <ls_final>-ean.
      IF lv_set_style IS INITIAL.
        lv_set_style = abap_true.
      ELSE.
        lv_set_style = abap_false.
      ENDIF.
    ENDIF.

    DATA(lv_set_type) = if_salv_c_item_type=>checkbox.
    " Add new item in the folder - * Add the node with the relevant data
    " Here we give the key to the CaseID node, this way the EAN becomes the child of the CaseID node
    go_events->add_tree_node_ean( iv_nkey      = lv_caseid_key
                              is_data      = <ls_final>
                              iv_set_type  = lv_set_type
                              iv_set_style = lv_set_style ).

    " Store the current line as "previous" for further processing
    ls_previous = <ls_final>.

  ENDLOOP.


  " Display Table
  go_tree->display( ).
