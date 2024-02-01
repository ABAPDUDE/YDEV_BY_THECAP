*&---------------------------------------------------------------------*
*& Report YMD_402
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0057.

SELECT land1, landx
INTO TABLE @DATA(lt_itab)
FROM t005t
  WHERE spras EQ 'E'.

IF 1 EQ 2.

ENDIF.

DATA lo_alv               TYPE REF TO cl_salv_table.
DATA lo_columns           TYPE REF TO cl_salv_columns_table.
DATA lo_functions         TYPE REF TO cl_salv_functions_list.

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
