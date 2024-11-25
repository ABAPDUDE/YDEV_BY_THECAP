*&---------------------------------------------------------------------*
*& Report ymd_git0215
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0215.


DATA lv_field_char20 TYPE char20.
DATA lv_field_char10 TYPE char10.
DATA lv_field_char20_test TYPE char20.

START-OF-SELECTION.

lv_field_char20 = '00000000001234567890'.
lv_field_char10 = lv_field_char20.

clear lv_field_char10.
lv_field_char10 = lv_field_char20+10(10).

lv_field_char20_test = lv_field_char20+10(10).


IF 1 EQ 2.

ENDIF.
