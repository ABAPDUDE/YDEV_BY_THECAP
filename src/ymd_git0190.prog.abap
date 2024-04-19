*&---------------------------------------------------------------------*
*& Report ymd_git0190
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0190.

*TYPES: BEGIN OF t_test,
*         key  TYPE string,
*         data TYPE REF TO data,
*       END OF t_test.
*
*DATA: lt_test TYPE TABLE OF t_test WITH DEFAULT KEY.
*
*FIELD-SYMBOLS: <l_test> TYPE any.
*
*DATA(ref) = lt_test[ key = '123123' ].
*
*ASSIGN ref-data->* TO <l_test>.

TYPES: BEGIN OF t_test,
       key Type string,
       r_data TYPE REF TO scarr, " <--- a NON-generic reference
       END OF t_test.
DATA: lt_test TYPE TABLE OF t_test.
FIELD-SYMBOLS: <l_test> TYPE any.

ASSIGN lt_test[ key = '123123' ]-r_data->* TO <l_test>.
IF 1 EQ 2.

ENDIF.
