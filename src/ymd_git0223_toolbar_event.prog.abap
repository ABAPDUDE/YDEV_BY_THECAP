*----------------------------------------------------------------------*
*   INCLUDE BCALV_TOOLBAR_EVENT_RECEIVER                               *
*----------------------------------------------------------------------*

class lcl_toolbar_event_receiver definition.

  public section.
    methods: on_function_selected
               for event function_selected of cl_gui_toolbar
                 importing fcode,

             on_toolbar_dropdown
               for event dropdown_clicked of cl_gui_toolbar
                 importing fcode
                           posx
                           posy.

endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_toolbar_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
class lcl_toolbar_event_receiver implementation.

  method on_function_selected.
    data: ls_sflight type sflight.
    case fcode.
      when 'DELETE'.
*       get selected node
        data: lt_selected_node type lvc_t_nkey.
        call method tree1->get_selected_nodes
               changing
                  ct_selected_nodes = lt_selected_node.
        call method cl_gui_cfw=>flush.
        data l_selected_node type lvc_nkey.
        read table lt_selected_node into l_selected_node index 1.

*       delete subtree
        if not l_selected_node is initial.
          call method tree1->delete_subtree
                  exporting
                     i_node_key                = l_selected_node
                     i_update_parents_expander = ''
                     i_update_parents_folder   = 'X'.
        else.
          message i227(0h).
        endif.
      when 'INSERT_LC'.
*       get selected node
        call method tree1->get_selected_nodes
               changing
                  ct_selected_nodes = lt_selected_node.
        call method cl_gui_cfw=>flush.
        read table lt_selected_node into l_selected_node index 1.
*       get current Line
        if not l_selected_node is initial.
          call method tree1->get_outtab_line
                  exporting
                      i_node_key = l_selected_node
                  importing
                      e_outtab_line = ls_sflight.
          ls_sflight-seatsmax = ls_sflight-price + 99.
          ls_sflight-price = ls_sflight-seatsmax + '99.99'.
          call method tree1->add_node
            exporting
              i_relat_node_key = l_selected_node
              i_relationship   = cl_tree_control_base=>relat_last_child
              is_outtab_line   = ls_sflight
*             is_node_layout
*             it_item_layout
              i_node_text      = 'Last Child'.           "#EC NOTEXT
*           importing
*             e_new_node_key
        else.
          message i227(0h).
        endif.
      when 'INSERT_FC'.
*       get selected node
        call method tree1->get_selected_nodes
               changing
                  ct_selected_nodes = lt_selected_node.
        call method cl_gui_cfw=>flush.
        read table lt_selected_node into l_selected_node index 1.
*       get current Line
        if not l_selected_node is initial.
          call method tree1->get_outtab_line
                  exporting
                      i_node_key = l_selected_node
                  importing
                      e_outtab_line = ls_sflight.
          ls_sflight-seatsmax = ls_sflight-price + 99.
          ls_sflight-price = ls_sflight-seatsmax + '99.99'.
          call method tree1->add_node
            exporting
              i_relat_node_key = l_selected_node
              i_relationship   = cl_tree_control_base=>relat_first_child
              is_outtab_line   = ls_sflight
*             is_node_layout
*             it_item_layout
              i_node_text      = 'First Child'.          "#EC NOTEXT
*           importing
*             e_new_node_key
        else.
          message i227(0h).
        endif.
      when 'INSERT_FS'.
*       get selected node
        call method tree1->get_selected_nodes
               changing
                  ct_selected_nodes = lt_selected_node.
        call method cl_gui_cfw=>flush.
        read table lt_selected_node into l_selected_node index 1.
*       get current Line
        if not l_selected_node is initial.
          call method tree1->get_outtab_line
                  exporting
                      i_node_key = l_selected_node
                  importing
                      e_outtab_line = ls_sflight.
          ls_sflight-seatsmax = ls_sflight-price + 99.
          ls_sflight-price = ls_sflight-seatsmax + '99.99'.
          call method tree1->add_node
            exporting
              i_relat_node_key = l_selected_node
              i_relationship   =
                             cl_tree_control_base=>relat_first_sibling
              is_outtab_line   = ls_sflight
*             is_node_layout
*             it_item_layout
              i_node_text      = 'First Sibling'.           "#EC NOTEXT
*           importing
*             e_new_node_key
        else.
          message i227(0h).
        endif.
      when 'INSERT_LS'.
*       get selected node
        call method tree1->get_selected_nodes
               changing
                  ct_selected_nodes = lt_selected_node.
        call method cl_gui_cfw=>flush.
        read table lt_selected_node into l_selected_node index 1.
*       get current Line
        if not l_selected_node is initial.
          call method tree1->get_outtab_line
                  exporting
                      i_node_key = l_selected_node
                  importing
                      e_outtab_line = ls_sflight.
          ls_sflight-seatsmax = ls_sflight-price + 99.
          ls_sflight-price = ls_sflight-seatsmax + '99.99'.
          call method tree1->add_node
            exporting
              i_relat_node_key = l_selected_node
              i_relationship   =
                             cl_tree_control_base=>relat_last_sibling
              is_outtab_line   = ls_sflight
*             is_node_layout
*             it_item_layout
              i_node_text      = 'Last Sibling'.            "#EC NOTEXT
*           importing
*             e_new_node_key
        else.
          message i227(0h).
        endif.
      when 'INSERT_NS'.
*       get selected node
        call method tree1->get_selected_nodes
               changing
                  ct_selected_nodes = lt_selected_node.
        call method cl_gui_cfw=>flush.
        read table lt_selected_node into l_selected_node index 1.
*       get current Line
        if not l_selected_node is initial.
          call method tree1->get_outtab_line
                  exporting
                      i_node_key = l_selected_node
                  importing
                      e_outtab_line = ls_sflight.
          ls_sflight-seatsmax = ls_sflight-price + 99.
          ls_sflight-price = ls_sflight-seatsmax + '99.99'.
          call method tree1->add_node
            exporting
              i_relat_node_key = l_selected_node
              i_relationship   =
                             cl_tree_control_base=>relat_next_sibling
              is_outtab_line   = ls_sflight
*             is_node_layout
*             it_item_layout
              i_node_text      = 'Next Sibling'.            "#EC NOTEXT
*           importing
*             e_new_node_key
        else.
          message i227(0h).
        endif.

    endcase.
*   update frontend
    call method tree1->frontend_update.
  endmethod.

  method on_toolbar_dropdown.
* create contextmenu
    data: l_menu type ref to cl_ctmenu,
          l_fc_handled type as4flag.

    create object l_menu.
    clear l_fc_handled.

    case fcode.
      when 'INSERT_LC'.
        l_fc_handled = 'X'.
*       insert as last child
        call method l_menu->add_function
                exporting fcode   = 'INSERT_LC'
                text    = 'Insert New Line as Last Child'.  "#EC NOTEXT
*       insert as first child
        call method l_menu->add_function
                exporting fcode   = 'INSERT_FC'
                text    = 'Insert New Line as First Child'. "#EC NOTEXT
*       insert as next sibling
        call method l_menu->add_function
                exporting fcode   = 'INSERT_NS'
                text    = 'Insert New Line as Next Sibling'. "#EC NOTEXT
*       insert as last sibling
        call method l_menu->add_function
                exporting fcode   = 'INSERT_LS'
                text    = 'Insert New Line as Last Sibling'. "#EC NOTEXT
*       insert as first sibling
        call method l_menu->add_function
                exporting fcode   = 'INSERT_FS'
              text    = 'Insert New Line as First Sibling'. "#EC NOTEXT
    endcase.

* show dropdownbox
    if l_fc_handled = 'X'.
      call method mr_toolbar->track_context_menu
        exporting
            context_menu = l_menu
            posx         = posx
            posy         = posy.
    endif.

  endmethod.
endclass.
