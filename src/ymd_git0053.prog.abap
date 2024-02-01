*&---------------------------------------------------------------------*
*& Report YMD_0004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0053.

DATA: gt_outtab1 TYPE TABLE OF sflight,
      gt_outtab2 TYPE TABLE OF sflight.

DATA: ls_outtab TYPE sflight.

DATA: gr_tree  TYPE REF TO cl_salv_tree.
DATA: nodes TYPE REF TO cl_salv_nodes,
      node  TYPE REF TO cl_salv_node.
DATA: docking TYPE REF TO cl_gui_docking_container.

PARAMETERS: p_check.

AT SELECTION-SCREEN OUTPUT.

  CREATE OBJECT docking
    EXPORTING
*     PARENT = CL_GUI_CONTAINER=>SCREEN0
      side  = cl_gui_docking_container=>dock_at_right
      ratio = 90.



*... Select Data
  SELECT * FROM sflight INTO CORRESPONDING FIELDS OF TABLE gt_outtab1 UP TO 5 ROWS.

*... Create Instance with an Empty Table

  CALL METHOD cl_salv_tree=>factory
    EXPORTING
      r_container = docking
    IMPORTING
      r_salv_tree = gr_tree
    CHANGING
      t_table     = gt_outtab2.

*... Add the Nodes to the Tree
  nodes = gr_tree->get_nodes( ).
  LOOP AT gt_outtab1 INTO ls_outtab.
    TRY.
        node = nodes->add_node( related_node = ' '
                                relationship = cl_gui_column_tree=>relat_first_child ).
        node->set_data_row( ls_outtab ).
      CATCH cx_salv_msg.
    ENDTRY.
  ENDLOOP.

*... Display Table
  gr_tree->display( ).
