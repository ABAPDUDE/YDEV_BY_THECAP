*&---------------------------------------------------------------------*
*& Report YMD_0004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0052.


*/**
* use report <b>RSTXICON</b> to get a list of the icons and their codes
* TYPE POOL ICON
*
* button in line - parkeren en checkbox aan begin -> nieuw scherm met status adres en bevestigen?
* https://blogs.sap.com/2020/12/21/alv-tree-simple-report-multiple-orders-single-delivery/
*
*/*

TYPES: BEGIN OF g_type_s_test,
         amount  TYPE i,
         repid   TYPE syrepid,
         display TYPE i,
         dynamic TYPE sap_bool,
       END OF g_type_s_test.

DATA go_alvtree  TYPE REF TO cl_salv_tree.
DATA nodes TYPE REF TO cl_salv_nodes.
DATA node  TYPE REF TO cl_salv_node.
DATA docking TYPE REF TO cl_gui_docking_container.
DATA go_container TYPE REF TO cl_gui_custom_container.
DATA ok_code TYPE syucomm.

CONSTANTS: gc_true TYPE sap_bool VALUE 'X',

           BEGIN OF gcs_display,
             tree       TYPE i VALUE 1,
             fullscreen TYPE i VALUE 2,
           END   OF gcs_display.

DATA gs_test TYPE g_type_s_test.

TYPES: BEGIN OF ty_treedata,
         product            TYPE sparte,
*         status_case        TYPE zde_cl_status,
         scenario_case      TYPE zde_cl_scenario,
         status_ean         TYPE zde_cl_ean_status,
         status_reden       TYPE zstatus_reden,
         effectueringsdatum TYPE zeffectueringsdatum,
*         scenario_ean       TYPE zde_cl_scenario,
         einddatum          TYPE zeinddatum_cl,
       END OF ty_treedata.
TYPES tty_treedata TYPE STANDARD TABLE OF ty_treedata WITH NON-UNIQUE DEFAULT KEY.
TYPES: BEGIN OF ty_caseid,
         caseid             TYPE zde_cl_caseid,
         ean                TYPE ext_ui,
*         status_case        TYPE zde_cl_status,
         scenario_case      TYPE zde_cl_scenario,
         prioriteit         TYPE zde_cl_prioriteit,
         status_ean         TYPE zde_cl_ean_status,
         status_reden       TYPE zstatus_reden,
         effectueringsdatum TYPE zeffectueringsdatum,
         product            TYPE sparte,
*         scenario_ean       TYPE zde_cl_scenario,
         einddatum          TYPE zeinddatum_cl,
       END OF ty_caseid.
TYPES tty_caseid TYPE STANDARD TABLE OF ty_caseid WITH NON-UNIQUE SORTED KEY sort_key
COMPONENTS caseid ean.

*DATA gt_alvtab2 TYPE tty_caseid.
DATA gt_treedata TYPE tty_treedata.

DATA gv_caseid TYPE zde_cl_caseid.
DATA gv_cldate TYPE dats.

*----------------------------------------------------------------------*
* SELECTION-SCREEN - meerdere mogelijkheden: demonstration only                   *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE title_b1.
PARAMETERS: p_caseid TYPE zde_cl_caseid DEFAULT '0001370417'.
SELECTION-SCREEN SKIP 1.
*SELECT-OPTIONS s_caseid FOR gv_caseid.
*SELECT-OPTIONS s_cldate FOR gv_cldate.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE title_b2.
*SELECTION-SCREEN SKIP 1.
*PARAMETERS p_amount TYPE i DEFAULT 10.
SELECTION-SCREEN SKIP 1.
PARAMETERS p_full RADIOBUTTON GROUP dsp.
PARAMETERS p_tree RADIOBUTTON GROUP dsp DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN END OF BLOCK b1.

*AT SELECTION-SCREEN OUTPUT.
*
*  CREATE OBJECT docking
*    EXPORTING
**     PARENT = CL_GUI_CONTAINER=>SCREEN0
*      side  = cl_gui_docking_container=>dock_at_right
*      ratio = 55.

INITIALIZATION.
  title_b1 = | Selectie Case-ID en/of tijdvak contractloos |.
  title_b2 = |Alleen TEST: Selectie scherm type|.

START-OF-SELECTION.
*  gs_test-amount = p_amount.
  gs_test-repid = sy-repid.
  CASE gc_true.
    WHEN p_tree.
      gs_test-display = gcs_display-tree.
    WHEN p_full.
      gs_test-display = gcs_display-fullscreen.
  ENDCASE.

END-OF-SELECTION.
  CASE gs_test-display.
    WHEN gcs_display-fullscreen.
      PERFORM display_fullscreen.

    WHEN gcs_display-tree.
      PERFORM display_tree.
  ENDCASE.

  " Display Table
  go_alvtree->display( ).

*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
FORM select_data .

  DATA lt_alvtab1 TYPE tty_caseid.

  " Select Data DDIC
  SELECT zisu_poc_case~caseid zisu_poc_ean~ean
         zisu_poc_case~scenario zisu_poc_case~prioriteit
         zisu_poc_ean~status
         zisu_poc_ean~status_reden zisu_poc_ean~effectueringsdatum
         zisu_poc_ean~product zisu_poc_ean~einddatum
    FROM zisu_poc_case AS zisu_poc_case
    INNER JOIN zisu_poc_ean AS zisu_poc_ean
    ON zisu_poc_case~caseid EQ zisu_poc_ean~caseid
    INTO TABLE lt_alvtab1 "  UP TO p_amount ROWS
  WHERE zisu_poc_case~caseid EQ p_caseid.  "IN s_caseid
  "    AND zisu_poc_ean~effectueringsdatum IN s_cldate.

  PERFORM supply_data_alv USING lt_alvtab1.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SUPPLY_DATA_ALV
*&---------------------------------------------------------------------*
FORM supply_data_alv USING ut_alvtab1 TYPE tty_caseid.

  DATA l_caseid_key TYPE lvc_nkey.
  DATA l_ean_key TYPE lvc_nkey.
  DATA l_last_key TYPE lvc_nkey.

  LOOP AT ut_alvtab1
    INTO DATA(ls_alvtab1).

    ON CHANGE OF ls_alvtab1-caseid.
      PERFORM add_caseid_line USING    ls_alvtab1
                                       ''
                              CHANGING l_caseid_key.
    ENDON.

    ON CHANGE OF ls_alvtab1-ean.
      PERFORM add_ean_line USING    ls_alvtab1
                                       l_caseid_key
                              CHANGING l_ean_key.
    ENDON.

    PERFORM add_complete_line USING  ls_alvtab1
                                     l_ean_key
                            CHANGING l_last_key.



  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_CASEID_LINE
*&---------------------------------------------------------------------*
FORM add_caseid_line  USING    p_ls_alvtab1 TYPE ty_caseid
                               p_key
                      CHANGING p_l_caseid_key.

  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node,
        item  TYPE REF TO cl_salv_item.

  " working with nodes
  nodes = go_alvtree->get_nodes( ).

  DATA lv_node_text TYPE lvc_value.
  lv_node_text = p_ls_alvtab1-caseid.

  TRY.
      " add a new node
      " set the data for the nes node
      node = nodes->add_node( related_node   = p_key
*                             data_row       = p_ls_alvtab1
                              text           = lv_node_text
                              expanded_icon  = '@3P@' " icon_defect
                              collapsed_icon = '@3P@' " icon_defect
                              relationship   = cl_gui_column_tree=>relat_last_child ).

*     node = nodes->add_node(
*                 related_node   =
*                 relationship   =
*           data_row       =
*           collapsed_icon =
*           expanded_icon  =
*           row_style      =
*           text           =
*           visible        = ABAP_TRUE
*           expander       =
*           enabled        = ABAP_TRUE
*           folder         =
*             )
*         CATCH cx_salv_msg.  "

      p_l_caseid_key = node->get_key( ).
    CATCH cx_salv_msg.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_EAN_LINE
*&---------------------------------------------------------------------*
FORM add_ean_line  USING    p_ls_alvtab1 TYPE ty_caseid
                            p_l_caseid_key
                   CHANGING p_l_ean_key.

  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node.

  nodes = go_alvtree->get_nodes( ).

  DATA lv_node_text TYPE lvc_value.
  lv_node_text = | EAN:  | && p_ls_alvtab1-ean.

  TRY.
      node = nodes->add_node( related_node = p_l_caseid_key
*                              data_row     = p_ls_alvtab1
                              text           = lv_node_text
                              expanded_icon  = '@3R@' " icon_detail
                              collapsed_icon = '@3R@' " icon_defect
                              relationship = cl_gui_column_tree=>relat_last_child ).

      p_l_ean_key = node->get_key( ).
                  nodes->expand_all( ).

    CATCH cx_salv_msg.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_COMPLETE_LINE
*&---------------------------------------------------------------------*
FORM add_complete_line  USING    p_ls_alvtab1
                                 p_l_ean_key
                        CHANGING p_l_last_key.

  DATA ls_treedata TYPE ty_treedata.

  DATA: nodes TYPE REF TO cl_salv_nodes,
        node  TYPE REF TO cl_salv_node.

  nodes = go_alvtree->get_nodes( ).

  ls_treedata = CORRESPONDING #( p_ls_alvtab1 ).

  TRY.
      node = nodes->add_node( related_node = p_l_ean_key
                      data_row     = ls_treedata                            " p_ls_alvtab1
                      relationship = cl_gui_column_tree=>relat_last_child ).

      p_l_last_key = node->get_key( ).
    CATCH cx_salv_msg.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FULLSCREEN
*&---------------------------------------------------------------------*
FORM display_fullscreen .

  " create an ALV tree
  TRY.
      cl_salv_tree=>factory(
        IMPORTING
          r_salv_tree = go_alvtree
        CHANGING
          t_table      = gt_treedata ).
    CATCH cx_salv_no_new_data_allowed cx_salv_error.
      EXIT.
  ENDTRY.

  PERFORM create_tree.

*... set the columns technical
  DATA: lr_columns TYPE REF TO cl_salv_columns_tree.

  lr_columns = go_alvtree->get_columns( ).
  lr_columns->set_optimize( gc_true ).

  PERFORM set_columns_technical USING lr_columns.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_TREE
*&---------------------------------------------------------------------*
FORM create_tree .

  PERFORM build_header.

  PERFORM select_data.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BUILD_HEADER
*&---------------------------------------------------------------------*
FORM build_header .

  " build the hierarchy header
  DATA: settings TYPE REF TO cl_salv_tree_settings.

  settings = go_alvtree->get_tree_settings( ).
  settings->set_hierarchy_header( TEXT-hd1 ).
  settings->set_hierarchy_tooltip( TEXT-ht1 ).
  settings->set_hierarchy_size( 40 ).

  DATA: title TYPE salv_de_tree_text.
  title = sy-title.
  settings->set_header( title ).

ENDFORM.

*&--------------------------------------------------------------------*
*&      Form  display_grid
*&--------------------------------------------------------------------*
FORM display_tree.

  CALL SCREEN 100.

ENDFORM.                    "display_grid

*&---------------------------------------------------------------------*
*&      Module  d0100_pbo  OUTPUT
*&---------------------------------------------------------------------*
MODULE d0100_pbo OUTPUT.
  PERFORM d0100_pbo.
ENDMODULE.                 " d0100_pbo  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  d0100_pai  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE d0100_pai INPUT.
  PERFORM d0100_pai.
ENDMODULE.                 " d0100_pai  INPUT

*&---------------------------------------------------------------------*
*&      Form  d0100_pbo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM d0100_pbo .

  SET PF-STATUS '100'.

  IF go_container IS NOT BOUND.
    IF cl_salv_tree=>is_offline( ) EQ if_salv_c_bool_sap=>false.
      CREATE OBJECT go_container
        EXPORTING
          container_name = 'CONTAINER'.
    ENDIF.

*... §1 create an ALV table
    TRY.
        cl_salv_tree=>factory(
          EXPORTING
            r_container  = go_container
          IMPORTING
            r_salv_tree = go_alvtree
          CHANGING
            t_table      = gt_treedata ).
      CATCH cx_salv_no_new_data_allowed cx_salv_error.
        EXIT.
    ENDTRY.

    PERFORM create_tree.

*... §3 Functions
*... §3.1 activate ALV generic Functions
    DATA: lr_functions TYPE REF TO cl_salv_functions_tree.

    lr_functions = go_alvtree->get_functions( ).
    lr_functions->set_all( gc_true ).

*... set the columns technical
    DATA: lr_columns TYPE REF TO cl_salv_columns_tree.

    lr_columns = go_alvtree->get_columns( ).
    lr_columns->set_optimize( gc_true ).

    PERFORM set_columns_technical USING lr_columns.
    PERFORM set_columns_custom USING lr_columns.

    " display CL data
    go_alvtree->display( ).
  ENDIF.

ENDFORM.                                                    " d0100_pbo

*&---------------------------------------------------------------------*
*&      Form  d0100_pai
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM d0100_pai .

  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'QUIT'.
      CLEAR ok_code.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDFORM.                                                    " d0100_pai

*&---------------------------------------------------------------------*
*&      Form  set_columns_technical
*&---------------------------------------------------------------------*
FORM set_columns_technical USING ir_columns TYPE REF TO cl_salv_columns_tree.

* those columns which should not be seen by the user at all are set technical
  DATA: lr_column TYPE REF TO cl_salv_column.

  TRY.
      lr_column = ir_columns->get_column( 'MANDT' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'FLOAT_FI' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'STRING_F' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'XSTRING' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'INT_FIEL' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'HEX_FIEL' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'DROPDOWN' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'TAB_INDEX' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

* those columns which should not be displayed from start can be set visible via layou
* dialog are set to invisible.

  TRY.
      lr_column = ir_columns->get_column( 'AIRPTO' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'AIRPFROM' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'FLTIME' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'COUNTRYFR' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'DEPTIME' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'ARRTIME' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'PERIOD' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'DISTANCE' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'DISTID' ).
      lr_column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

ENDFORM.                    " set_columns_technical(
*&---------------------------------------------------------------------*
*&      Form  SET_COLUMNS_CUSTOM
*&---------------------------------------------------------------------*
FORM set_columns_custom USING io_columns TYPE REF TO cl_salv_columns_tree.

  DATA: lr_column TYPE REF TO cl_salv_column.

  TRY.
      lr_column = io_columns->get_column( 'EFFECTUERINGSDATUM' ).
      DATA(lv_lenght) = lr_column->get_ddic_outputlen( ).
      lr_column->set_output_length( value = 15 ).

    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

ENDFORM.

***&SPWIZARD: DATA DECLARATION FOR TABLECONTROL 'TC_HISTORY'
*&SPWIZARD: DEFINITION OF DDIC-TABLE
TABLES:   zisu_poc_eanh.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'TC_HISTORY'
TYPES: BEGIN OF t_tc_history,
         ean                  LIKE zisu_poc_eanh-ean,
         status               LIKE zisu_poc_eanh-status,
         datum_gewijzigd      LIKE zisu_poc_eanh-datum_gewijzigd,
         tijd_gewijzigd       LIKE zisu_poc_eanh-tijd_gewijzigd,
         gemaakt_door         LIKE zisu_poc_eanh-gemaakt_door,
         datum_gemaakt        LIKE zisu_poc_eanh-datum_gemaakt,
         tijd_gemaakt         LIKE zisu_poc_eanh-tijd_gemaakt,
         gewijzigd_door       LIKE zisu_poc_eanh-gewijzigd_door,
         laatste_reactiedatum LIKE zisu_poc_eanh-laatste_reactiedatum,
         alt_actie_datum      LIKE zisu_poc_eanh-alt_actie_datum,
         kenmerk              LIKE zisu_poc_eanh-kenmerk,
         datum_email_1        LIKE zisu_poc_eanh-datum_email_1,
         datum_email_2        LIKE zisu_poc_eanh-datum_email_2,
       END OF t_tc_history.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'TC_HISTORY'
DATA: g_tc_history_itab TYPE t_tc_history OCCURS 0,
      g_tc_history_wa   TYPE t_tc_history. "work area
DATA:     g_tc_history_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_HISTORY' ITSELF
CONTROLS: tc_history TYPE TABLEVIEW USING SCREEN 0100.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_HISTORY'
DATA:     g_tc_history_lines  LIKE sy-loopc.

*DATA:     OK_CODE LIKE SY-UCOMM.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_HISTORY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE tc_history_init OUTPUT.
  IF g_tc_history_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZISU_POC_EANH'
*&SPWIZARD: INTO INTERNAL TABLE 'g_TC_HISTORY_itab'
    SELECT * FROM zisu_poc_eanh
       INTO CORRESPONDING FIELDS OF TABLE g_tc_history_itab
      WHERE caseid EQ p_caseid.

    SORT g_tc_history_itab BY ean.
    g_tc_history_copied = 'X'.
    REFRESH CONTROL 'TC_HISTORY' FROM SCREEN '0100'.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_HISTORY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE tc_history_move OUTPUT.
  MOVE-CORRESPONDING g_tc_history_wa TO zisu_poc_eanh.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_HISTORY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_history_get_lines OUTPUT.
  g_tc_history_lines = sy-loopc.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_HISTORY'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_history_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_HISTORY'
                              'G_TC_HISTORY_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE l_ok.
    WHEN 'INSR'.                      "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE'.                      "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
  IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
    l_tc_new_top_line = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
