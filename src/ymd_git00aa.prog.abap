*&---------------------------------------------------------------------*
*& Report YMD_GITS00AA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git00aa.


DATA lo_alv          TYPE REF TO cl_salv_table.
DATA lo_columns  TYPE REF TO cl_salv_columns_table.
DATA lo_functions TYPE REF TO cl_salv_functions_list.
DATA lt_itab          TYPE stringtab.

TRY.
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = lt_itab ).
  CATCH cx_salv_msg INTO DATA(lr_message).
ENDTRY.

lo_functions = lo_alv->get_functions( ).
lo_functions->set_all( ).
lo_columns = lo_alv->get_columns( ).
lo_columns->set_optimize( ).
lo_alv->display( ).
