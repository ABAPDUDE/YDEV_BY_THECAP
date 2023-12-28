*&---------------------------------------------------------------------*
*& Report YMD_00004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0004.

" op de oude manier
DATA lv_orderno_1 TYPE char10 VALUE 875545.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = lv_orderno_1
  IMPORTING
    output = lv_orderno_1.

WRITE lv_orderno_1.

" op de nieuwe manier
DATA lv_orderno_2 TYPE char10 VALUE '875545'.
lv_orderno_2 = |{ lv_orderno_2 ALPHA = IN }|.
WRITE lv_orderno_2.

DATA bag_id TYPE  zbag_id VALUE 1234875545.
bag_id = |{ bag_id ALPHA = IN }|.
WRITE bag_id.

DATA pand_id  TYPE  zpand_id VALUE 5678875545.
pand_id = |{ pand_id ALPHA = IN }|.
WRITE pand_id.
