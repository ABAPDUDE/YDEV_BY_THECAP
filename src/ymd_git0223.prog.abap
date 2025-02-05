*&---------------------------------------------------------------------*
*& Report  BCALV_TREE_DEMO                                             *
*&---------------------------------------------------------------------*

REPORT  bcalv_tree_demo.

DATA gv_effdatum_eosupply TYPE zisu_poc_message-effectueringsdatum.
DATA gt_node_key TYPE lvc_t_nkey.
*  DATA l_ean_key TYPE lvc_nkey.
*  DATA l_dtype_key TYPE lvc_nkey.
*  DATA l_last_key TYPE lvc_nkey.
CONSTANTS mc_msg_type_eosupply TYPE zde_msgtype_car VALUE 'EOSUPPLY' ##NO_TEXT.
CONSTANTS mc_status_msg_fout TYPE zde_cl_msg_status VALUE '97' ##NO_TEXT.

*PARAMETERS p_date TYPE zde_effectueringdatum.
SELECT-OPTIONS: s_date FOR gv_effdatum_eosupply.

CLASS cl_gui_column_tree DEFINITION LOAD.
CLASS cl_gui_cfw DEFINITION LOAD.

DATA tree1  TYPE REF TO cl_gui_alv_tree.
DATA mr_toolbar TYPE REF TO cl_gui_toolbar.

INCLUDE <icon>.
INCLUDE ymd_git0223_toolbar_event.
*include rjs_toolbar_event_receiver.
*include bcalv_toolbar_event_receiver.
INCLUDE ymd_git0223_tree_event.
*include rjs_tree_event_receiver.
*include bcalv_tree_event_receiver.

DATA toolbar_event_receiver TYPE REF TO lcl_toolbar_event_receiver.

DATA gt_crosscheck   TYPE STANDARD TABLE OF zst_vzc_cross_check WITH NON-UNIQUE SORTED KEY vzc COMPONENTS ean caseid.
DATA gt_fieldcatalog TYPE lvc_t_fcat.
DATA ok_code         TYPE syst_ucomm.

**
DATA : gs_crosscheck TYPE zst_vzc_cross_check,
       g_last_key    TYPE lvc_nkey.

**
START-OF-SELECTION.

END-OF-SELECTION.

  CALL SCREEN 9000.

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
*       process before output
*----------------------------------------------------------------------*
MODULE pbo OUTPUT.

  SET PF-STATUS 'MAIN100'.
  IF tree1 IS INITIAL.
    PERFORM init_tree.
  ENDIF.
*  PERFORM test .
  CALL METHOD cl_gui_cfw=>flush.

ENDMODULE.                             " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       process after input
*----------------------------------------------------------------------*
MODULE pai INPUT.

  CASE ok_code.
    WHEN 'EXIT' OR 'CANC'.
      PERFORM exit_program.
    WHEN 'BACK'.

    WHEN OTHERS.
      CALL METHOD cl_gui_cfw=>dispatch.
  ENDCASE.
  CLEAR ok_code.
  CALL METHOD cl_gui_cfw=>flush.
ENDMODULE.                             " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Form  build_fieldcatalog
*&---------------------------------------------------------------------*
*       build fieldcatalog for structure sflight
*----------------------------------------------------------------------*
FORM build_fieldcatalog.

* get fieldcatalog
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZST_VZC_CROSS_CHECK'
    CHANGING
      ct_fieldcat      = gt_fieldcatalog.

* change fieldcatalog
  DATA: ls_fieldcatalog TYPE lvc_s_fcat.
  LOOP AT gt_fieldcatalog INTO ls_fieldcatalog.
    CASE ls_fieldcatalog-fieldname.
      WHEN 'CARRID' OR 'CONNID' OR 'FLDATE'.
        ls_fieldcatalog-no_out = 'X'.
        ls_fieldcatalog-key    = ''.
      WHEN 'PRICE' OR 'SEATSOCC' OR 'SEATSMAX' OR 'PAYMENTSUM'.
        ls_fieldcatalog-do_sum = 'X'.
    ENDCASE.
    MODIFY gt_fieldcatalog FROM ls_fieldcatalog.
  ENDLOOP.

ENDFORM.                               " build_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  build_hierarchy_header
*&---------------------------------------------------------------------*
*       build hierarchy-header-information
*----------------------------------------------------------------------*
*      -->P_L_HIERARCHY_HEADER  strucxture for hierarchy-header
*----------------------------------------------------------------------*
FORM build_hierarchy_header CHANGING
                               p_hierarchy_header TYPE treev_hhdr.

  p_hierarchy_header-heading = 'Hierarchy Header'.          "#EC NOTEXT
  p_hierarchy_header-tooltip =
                         'This is the Hierarchy Header !'.  "#EC NOTEXT
  p_hierarchy_header-width = 50.
  p_hierarchy_header-width_pix = ''.

ENDFORM.                               " build_hierarchy_header

*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       free object and leave program
*----------------------------------------------------------------------*
FORM exit_program.

  CALL METHOD tree1->free.
  LEAVE PROGRAM.

ENDFORM.                               " exit_program

*&---------------------------------------------------------------------*
*&      Form  build_header
*&---------------------------------------------------------------------*
*       build table for html_header
*----------------------------------------------------------------------*
FORM build_comment USING
      pt_list_commentary TYPE slis_t_listheader
      p_logo             TYPE sdydo_value.

* DATA: ls_line TYPE slis_listheader.
*
* LIST HEADING LINE: TYPE H
*  CLEAR ls_line.
*  ls_line-typ  = 'H'.
* LS_LINE-KEY:  NOT USED FOR THIS TYPE
*  ls_line-info = 'ALV-tree-demo: flight-overview'.          "#EC NOTEXT
*  APPEND ls_line TO pt_list_commentary.
* STATUS LINE: TYPE S
*  CLEAR ls_line.
*  ls_line-typ  = 'S'.
*  ls_line-key  = 'valid until'.                             "#EC NOTEXT
*  ls_line-info = 'January 29 1999'.                         "#EC NOTEXT
*  APPEND ls_line TO pt_list_commentary.
*  ls_line-key  = 'time'.
*  ls_line-info = '2.00 pm'.                                 "#EC NOTEXT
*  APPEND ls_line TO pt_list_commentary.
* ACTION LINE: TYPE A
* CLEAR ls_line.
* ls_line-typ  = 'A'.
* LS_LINE-KEY:  NOT USED FOR THIS TYPE
* ls_line-info = 'actual data'.                             "#EC NOTEXT
* APPEND ls_line TO pt_list_commentary.
*
* p_logo = 'ENJOYSAP_LOGO'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  create_hierarchy
*&---------------------------------------------------------------------*
FORM create_hierarchy.

*/**
* 01  ZP5_MEETDATA_EL
* 02  Z310_DISPUTEN
* 03  ZTVZC_WORKLOAD
* 04  ZVZC_WORKLOAD_ST ( TEST )
*/*

* DATA ls_msg_eosupply TYPE zisu_poc_message.
* DATA lt_msg_eosupply TYPE TABLE OF zisu_poc_message.
  DATA lt_crosscheck   TYPE STANDARD TABLE OF zst_vzc_cross_check WITH NON-UNIQUE SORTED KEY vzc COMPONENTS ean caseid.

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

*  SELECT *
*    INTO TABLE @DATA(lt_msg)
*    FROM zisu_poc_message
*    WHERE berichttype EQ 'EOSUPPLY'
*      AND effectueringsdatum in @p_date.

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

*/**
* fill 'TREE' table
*/*

  SORT lt_vzcfac BY ean stand_volgorde caseid.
  DELETE ADJACENT DUPLICATES FROM lt_vzcfac COMPARING ean stand_volgorde caseid.

  LOOP AT lt_vzcfac
     INTO DATA(ls_vzcfac).

    gs_crosscheck-ean = ls_vzcfac-ean.
    gs_crosscheck-data_type = '01'.
    gs_crosscheck-stand_volgorde = ls_vzcfac-stand_volgorde.
    gs_crosscheck-caseid = ls_vzcfac-caseid.
    gs_crosscheck-effectueringsdatum = ls_vzcfac-effectueringsdatum.
    gs_crosscheck-begin_opnamedatum = ls_vzcfac-selectie_begindatum.
    gs_crosscheck-eind_opnamedatrum = ls_vzcfac-selectie_einddatum.
    gs_crosscheck-beginstand_t1 = ls_vzcfac-beginstand_t1.
    gs_crosscheck-eindstand_t1 = ls_vzcfac-eindstand_t1.
    gs_crosscheck-verbruik_t1 = ls_vzcfac-verbruik_t1.
    gs_crosscheck-beginstand_t2 = ls_vzcfac-beginstand_t2.
    gs_crosscheck-eindstand_t2 = ls_vzcfac-eindstand_t1.
    gs_crosscheck-verbruik_t2 = ls_vzcfac-verbruik_t2.
    gs_crosscheck-berichttype = mc_msg_type_eosupply.

    APPEND gs_crosscheck TO lt_crosscheck.

  ENDLOOP.

* SORT lt_rp_16 BY ean opnamedatum_dr.
* DELETE ADJACENT DUPLICATES FROM lt_vzcfac COMPARING ean opnamedatum_dr.

  LOOP AT lt_rp16
  INTO DATA(ls_rp16).

    gs_crosscheck-ean = ls_rp16-ext_ui.
    gs_crosscheck-data_type = '02'.
*   gs_crosscheck-stand_volgorde = .
    gs_crosscheck-caseid = ls_rp16-caseid.
*   gs_crosscheck-effectueringsdatum = .
    gs_crosscheck-begin_opnamedatum = ls_rp16-opnamedatum_dr.
    gs_crosscheck-eind_opnamedatrum = ls_rp16-opnamedatum.
    gs_crosscheck-beginstand_t1 = ls_rp16-stand_e11_dr.
    gs_crosscheck-eindstand_t1 = ls_rp16-stand_e11_x310.
    gs_crosscheck-verbruik_t1 = ls_rp16-verbruik_e11.
    gs_crosscheck-beginstand_t2 = ls_rp16-stand_e10_dr.
    gs_crosscheck-eindstand_t2 = ls_rp16-stand_e10_x310.
    gs_crosscheck-verbruik_t2 = ls_rp16-verbruik_e10.
    gs_crosscheck-berichttype = mc_msg_type_eosupply.

    APPEND gs_crosscheck TO lt_crosscheck.

  ENDLOOP.

* SORT lt_rp_16 BY ean opnamedatum_dr.
* DELETE ADJACENT DUPLICATES FROM lt_vzcfac COMPARING ean opnamedatum_dr.

  LOOP AT lt_workload
  INTO DATA(ls_workload).

    gs_crosscheck-ean = ls_workload-ext_ui.
    gs_crosscheck-data_type = '03'.
*   gs_crosscheck-stand_volgorde = .
    gs_crosscheck-caseid = ls_workload-caseid.
*   gs_crosscheck-effectueringsdatum = .
    gs_crosscheck-begin_opnamedatum = ls_workload-begda.
    gs_crosscheck-eind_opnamedatrum = ls_workload-endda.
    gs_crosscheck-beginstand_t1 = ls_workload-stand_e11_dr.
    gs_crosscheck-eindstand_t1 = ls_workload-stand_e11_x310.
    gs_crosscheck-verbruik_t1 = ls_workload-verbruik_e11.
    gs_crosscheck-beginstand_t2 = ls_workload-stand_e10_dr.
    gs_crosscheck-eindstand_t2 = ls_workload-stand_e10_x310.
    gs_crosscheck-verbruik_t2 = ls_workload-verbruik_e10.
    gs_crosscheck-berichttype = mc_msg_type_eosupply.

    APPEND gs_crosscheck TO lt_crosscheck.

  ENDLOOP.

  LOOP AT lt_workload_st
   INTO DATA(ls_workload_st).

    gs_crosscheck-ean = ls_workload_st-ext_ui.
    gs_crosscheck-data_type = '04'.
*   gs_crosscheck-stand_volgorde = .
    gs_crosscheck-caseid = ls_workload_st-caseid.
*   gs_crosscheck-effectueringsdatum = .
    gs_crosscheck-begin_opnamedatum = ls_workload_st-begda.
    gs_crosscheck-eind_opnamedatrum = ls_workload_st-endda.
    gs_crosscheck-beginstand_t1 = ls_workload_st-stand_e11_dr.
    gs_crosscheck-eindstand_t1 = ls_workload_st-stand_e11_x310.
    gs_crosscheck-verbruik_t1 = ls_workload_st-verbruik_e11.
    gs_crosscheck-beginstand_t2 = ls_workload_st-stand_e10_dr.
    gs_crosscheck-eindstand_t2 = ls_workload_st-stand_e10_x310.
    gs_crosscheck-verbruik_t2 = ls_workload_st-verbruik_e10.
    gs_crosscheck-berichttype = mc_msg_type_eosupply.

    APPEND gs_crosscheck TO lt_crosscheck.

  ENDLOOP.

  DATA l_ean_key TYPE lvc_nkey.
  DATA l_dtype_key TYPE lvc_nkey.
  DATA l_last_key TYPE lvc_nkey.

  LOOP AT lt_crosscheck
    INTO DATA(ls_crosscheck).

    ON CHANGE OF ls_crosscheck-ean.
      PERFORM add_ean_line USING ls_crosscheck
                                 ''
                        CHANGING l_ean_key.

    ENDON.

    ON CHANGE OF ls_crosscheck-data_type.
      PERFORM add_dtype_line USING ls_crosscheck
                                       l_ean_key
                              CHANGING l_dtype_key.

    ENDON.

    PERFORM add_complete_line USING ls_crosscheck
                                       l_dtype_key
                              CHANGING l_last_key.

    gs_crosscheck = ls_crosscheck .
    g_last_key = l_last_key.

  ENDLOOP.

*  DATA: ls_sflight TYPE sflight,
*        lt_sflight TYPE sflight OCCURS 0.
*
** get data
*  SELECT * FROM sflight INTO TABLE lt_sflight.
*  SORT lt_sflight BY carrid connid fldate.
*
** add data to tree
*  DATA: l_carrid_key TYPE lvc_nkey,
*        l_connid_key TYPE lvc_nkey,
*        l_last_key   TYPE lvc_nkey.
*  LOOP AT lt_sflight INTO ls_sflight.
*    ON CHANGE OF ls_sflight-carrid.
*      PERFORM add_carrid_line USING    ls_sflight
*                                       ''
*                              CHANGING l_carrid_key.
*
*    ENDON.
*    ON CHANGE OF ls_sflight-connid.
*      PERFORM add_connid_line USING    ls_sflight
*                                       l_carrid_key
*                              CHANGING l_connid_key.
*
*    ENDON.
*    PERFORM add_complete_line USING  ls_sflight
*                                     l_connid_key
*                            CHANGING l_last_key.
*** MF
*    gs_sflight = ls_sflight .
*    g_last_key = l_last_key.
***MF
*  ENDLOOP.

* calculate totals
  CALL METHOD tree1->update_calculations.

* this method must be called to send the data to the frontend
  CALL METHOD tree1->frontend_update.

ENDFORM.                               " create_hierarchy


*&---------------------------------------------------------------------*
*&      Form  add_ean_line
*&---------------------------------------------------------------------*
*       add hierarchy-level 1 to tree
*----------------------------------------------------------------------*
FORM add_ean_line USING ps_crosscheck TYPE zst_vzc_cross_check
                        p_relat_key TYPE lvc_nkey
                  CHANGING  p_node_key TYPE lvc_nkey.

  DATA: l_node_text     TYPE lvc_value,
        ls_msg_eosupply TYPE zisu_poc_message.

* set item-layout
  DATA: lt_item_layout TYPE lvc_t_layi,
        ls_item_layout TYPE lvc_s_layi.

  ls_item_layout-t_image   = '@3P@'.
  ls_item_layout-fieldname = tree1->c_hierarchy_column_name.
  ls_item_layout-style     = cl_gui_column_tree=>style_intensifd_critical.

  APPEND ls_item_layout TO lt_item_layout.

* add node
  DATA(lv_effdate_as_text) = |{ ps_crosscheck-effectueringsdatum DATE = USER }|.
  l_node_text = |{ ps_crosscheck-ean } { lv_effdate_as_text } { ps_crosscheck-berichttype }|.
  CALL METHOD tree1->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ps_crosscheck
      it_item_layout   = lt_item_layout
    IMPORTING
      e_new_node_key   = p_node_key.

  APPEND p_node_key TO gt_node_key.

ENDFORM.                               " add_ean_line

*&---------------------------------------------------------------------*
*&      Form  add_dtype_line
*&---------------------------------------------------------------------*
*       add hierarchy-level 2 to tree
*----------------------------------------------------------------------*
FORM add_dtype_line USING     ps_crcheck TYPE zst_vzc_cross_check
                               p_relat_key TYPE lvc_nkey
                     CHANGING  p_node_key TYPE lvc_nkey.

  DATA: l_node_text TYPE lvc_value,
        ls_crcheck  TYPE zst_vzc_cross_check.

* set item-layout
  DATA: lt_item_layout TYPE lvc_t_layi,
        ls_item_layout TYPE lvc_s_layi.
  ls_item_layout-t_image = '@3Y@'.
  ls_item_layout-style   =
                        cl_gui_column_tree=>style_intensified.
  ls_item_layout-fieldname = tree1->c_hierarchy_column_name.
  APPEND ls_item_layout TO lt_item_layout.

* add node
  CASE ps_crcheck-data_type.
    WHEN '01'.
      DATA(lv_data_type_as_text) = 'ZP5_MEETDATA_EL'.
    WHEN '02'.
      lv_data_type_as_text = 'Z310_DISPUTEN'.
    WHEN '03'.
      lv_data_type_as_text = 'ZTVZC_WORKLOAD'.
    WHEN '04'.
      lv_data_type_as_text = 'ZVZC_WORKLOAD_ST ( TEST )'.
    WHEN OTHERS.
  ENDCASE.

  l_node_text = |{ ps_crcheck-data_type } - { lv_data_type_as_text }|.
  CALL METHOD tree1->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_crcheck
      it_item_layout   = lt_item_layout
    IMPORTING
      e_new_node_key   = p_node_key.

  APPEND p_node_key TO gt_node_key.

ENDFORM.                               " add_dtype_line


*&---------------------------------------------------------------------*
*&      Form  add_complete_line
*&---------------------------------------------------------------------*
*       add hierarchy-level 3 to tree
*----------------------------------------------------------------------*
FORM add_complete_line USING   ps_crcheck TYPE zst_vzc_cross_check
                               p_relat_key TYPE lvc_nkey
                     CHANGING  p_node_key TYPE lvc_nkey.

  DATA: l_node_text TYPE lvc_value.

* set item-layout
  DATA: lt_item_layout TYPE lvc_t_layi,
        ls_item_layout TYPE lvc_s_layi.
  ls_item_layout-fieldname = tree1->c_hierarchy_column_name.
  ls_item_layout-class   = cl_gui_column_tree=>item_class_checkbox.
  ls_item_layout-editable = 'X'.
  APPEND ls_item_layout TO lt_item_layout.

  l_node_text =  ps_crcheck-begin_opnamedatum.
  CALL METHOD tree1->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      is_outtab_line   = ps_crcheck
      i_node_text      = l_node_text
      it_item_layout   = lt_item_layout
    IMPORTING
      e_new_node_key   = p_node_key.

  APPEND p_node_key TO gt_node_key.

ENDFORM.                               " add_complete_line

*&---------------------------------------------------------------------*
*&      Form  register_events
*&---------------------------------------------------------------------*
FORM register_events.
* define the events which will be passed to the backend
  DATA: lt_events TYPE cntl_simple_events,
        l_event   TYPE cntl_simple_event.

* define the events which will be passed to the backend
  l_event-eventid = cl_gui_column_tree=>eventid_expand_no_children.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_checkbox_change.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_header_context_men_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_node_context_menu_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_context_menu_req.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_header_click.
  APPEND l_event TO lt_events.
  l_event-eventid = cl_gui_column_tree=>eventid_item_keypress.
  APPEND l_event TO lt_events.

  CALL METHOD tree1->set_registered_events
    EXPORTING
      events                    = lt_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.

* set Handler
  DATA: l_event_receiver TYPE REF TO lcl_tree_event_receiver.
  CREATE OBJECT l_event_receiver.
  SET HANDLER l_event_receiver->handle_node_ctmenu_request
                                                        FOR tree1.
  SET HANDLER l_event_receiver->handle_node_ctmenu_selected
                                                        FOR tree1.
  SET HANDLER l_event_receiver->handle_item_ctmenu_request
                                                        FOR tree1.
  SET HANDLER l_event_receiver->handle_item_ctmenu_selected
                                                        FOR tree1.
ENDFORM.                               " register_events

*&---------------------------------------------------------------------*
*&      Form  change_toolbar
*&---------------------------------------------------------------------*
FORM change_toolbar.

* get toolbar control
  CALL METHOD tree1->get_toolbar_object
    IMPORTING
      er_toolbar = mr_toolbar.

  CHECK NOT mr_toolbar IS INITIAL.

* add seperator to toolbar
  CALL METHOD mr_toolbar->add_button
    EXPORTING
      fcode     = ''
      icon      = ''
      butn_type = cntb_btype_sep
      text      = ''
      quickinfo = 'This is a Seperator'.         "#EC NOTEXT

* add Standard Button to toolbar (for Delete Subtree)
  CALL METHOD mr_toolbar->add_button
    EXPORTING
      fcode     = 'DELETE'
      icon      = '@18@'
      butn_type = cntb_btype_button
      text      = ''
      quickinfo = 'Delete subtree'.              "#EC NOTEXT

* add Dropdown Button to toolbar (for Insert Line)
  CALL METHOD mr_toolbar->add_button
    EXPORTING
      fcode     = 'INSERT_LC'
      icon      = '@17@'
      butn_type = cntb_btype_dropdown
      text      = ''
      quickinfo = 'Insert Line'.           "#EC NOTEXT

* set event-handler for toolbar-control
  CREATE OBJECT toolbar_event_receiver.
  SET HANDLER toolbar_event_receiver->on_function_selected
                                                      FOR mr_toolbar.
  SET HANDLER toolbar_event_receiver->on_toolbar_dropdown
                                                      FOR mr_toolbar.

ENDFORM.                               " change_toolbar

*&---------------------------------------------------------------------*
*&      Form  init_tree
*&---------------------------------------------------------------------*
FORM init_tree.

* create fieldcatalog for structure sflight
  PERFORM build_fieldcatalog.

* create container for alv-tree
  DATA: l_tree_container_name(30) TYPE c,
        l_custom_container        TYPE REF TO cl_gui_custom_container.
  l_tree_container_name = 'TREE1'.

  CREATE OBJECT l_custom_container
    EXPORTING
      container_name              = l_tree_container_name
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.

* create tree control
  CREATE OBJECT tree1
    EXPORTING
      parent                      = l_custom_container
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = 'X'
      no_html_header              = ''
      no_toolbar                  = ''
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.

* create Hierarchy-header
  DATA l_hierarchy_header TYPE treev_hhdr.
  PERFORM build_hierarchy_header CHANGING l_hierarchy_header.

* create info-table for html-header
  DATA lt_list_commentary TYPE slis_t_listheader.
  DATA l_logo             TYPE sdydo_value.

  PERFORM build_comment USING
                 lt_list_commentary
                 l_logo.

* repid for saving variants
  DATA: ls_variant TYPE disvariant.
  ls_variant-report = sy-repid.

* create empty tree-control
  CALL METHOD tree1->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = l_hierarchy_header
      it_list_commentary  = lt_list_commentary
      i_logo              = l_logo
      i_background_id     = 'ALV_BACKGROUND'
      i_save              = 'A'
      is_variant          = ls_variant
    CHANGING
      it_outtab           = gt_crosscheck            " table must be emty !!
      it_fieldcatalog     = gt_fieldcatalog.

* expand first level
  CALL METHOD tree1->expand_nodes
    EXPORTING
      it_node_key             = gt_node_key
    EXCEPTIONS
      failed                  = 1
      cntl_system_error       = 2
      error_in_node_key_table = 3
      dp_error                = 4
      node_not_found          = 5
      OTHERS                  = 6.
  IF sy-subrc <> 0.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* optimize column-width
  CALL METHOD tree1->column_optimize
    EXPORTING
      i_start_column = tree1->c_hierarchy_column_name
      i_end_column   = tree1->c_hierarchy_column_name.

* create hierarchy
  PERFORM create_hierarchy.

* add own functioncodes to the toolbar
  PERFORM change_toolbar.

* register events
  PERFORM register_events.

ENDFORM.                    " init_tree

*&---------------------------------------------------------------------*
*&      Form  TEST
*&---------------------------------------------------------------------*
FORM test.

  CALL METHOD tree1->change_node
    EXPORTING
      i_node_key    = g_last_key
      i_outtab_line = gs_crosscheck.

*    IS_NODE_LAYOUT =
*    IT_ITEM_LAYOUT =
*    I_NODE_TEXT    =
*    I_U_NODE_TEXT  =
  .

  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    " TEST
