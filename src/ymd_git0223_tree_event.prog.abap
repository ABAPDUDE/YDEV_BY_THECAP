*----------------------------------------------------------------------*
*   INCLUDE BCALV_TREE_EVENT_RECEIVER                                  *
*----------------------------------------------------------------------*
class lcl_tree_event_receiver definition.

  public section.

    methods handle_node_ctmenu_request
      for event node_context_menu_request of cl_gui_alv_tree
        importing node_key
                  menu.
    methods handle_node_ctmenu_selected
      for event node_context_menu_selected of cl_gui_alv_tree
        importing node_key
                  fcode.
    methods handle_item_ctmenu_request
      for event item_context_menu_request of cl_gui_alv_tree
        importing node_key
                  fieldname
                  menu.
    methods handle_item_ctmenu_selected
      for event item_context_menu_selected of cl_gui_alv_tree
        importing node_key
                  fieldname
                  fcode.

    methods handle_item_double_click
      for event item_double_click of cl_gui_alv_tree
      importing node_key
                fieldname.

    methods handle_button_click
      for event button_click of cl_gui_alv_tree
      importing node_key
                fieldname.

    methods handle_link_click
      for event link_click of cl_gui_alv_tree
      importing node_key
                fieldname.

    methods handle_header_click
      for event header_click of cl_gui_alv_tree
      importing fieldname.

endclass.

class lcl_tree_event_receiver implementation.

  method handle_node_ctmenu_request.
*   append own functions
    call method menu->add_function
                exporting fcode   = 'USER1'
                          text    = 'Usercmd 1'.          "#EC NOTEXT
    call method menu->add_function
                exporting fcode   = 'USER2'
                          text    = 'Usercmd 2'.          "#EC NOTEXT
    call method menu->add_function
                exporting fcode   = 'USER3'
                          text    = 'Usercmd 3'.          "#EC NOTEXT
  endmethod.

  method handle_node_ctmenu_selected.
    case fcode.
      when 'USER1' or 'USER2' or 'USER3'.
        message i000(0h) with 'Node-Context-Menu on Node ' node_key
                              'fcode : ' fcode.           "#EC NOTEXT
    endcase.
  endmethod.

  method handle_item_ctmenu_request .
*   append own functions
    call method menu->add_function
                exporting fcode   = 'USER1'
                          text    = 'Usercmd 1'.
    call method menu->add_function
                exporting fcode   = 'USER2'
                          text    = 'Usercmd 2'.
    call method menu->add_function
                exporting fcode   = 'USER3'
                          text    = 'Usercmd 3'.
  endmethod.

  method handle_item_ctmenu_selected.
    case fcode.
      when 'USER1' or 'USER2' or 'USER3'.
        message i000(0h) with 'Item-Context-Menu on Node ' node_key
                              'Fieldname : ' fieldname.    "#EC NOTEXT
    endcase.
  endmethod.

  method handle_item_double_click.
  endmethod.

  method handle_button_click.
  endmethod.

  method handle_link_click.
  endmethod.

  method handle_header_click.
  endmethod.

endclass.
