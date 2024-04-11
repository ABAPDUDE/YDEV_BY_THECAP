*&---------------------------------------------------------------------*
*& Report YMD_GIT0185
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0185.

DATA gv_handoff_date TYPE char10.
DATA lv_date TYPE dats.

gv_handoff_date = |2024-03-21|.

SPLIT gv_handoff_date AT |-|
  INTO DATA(lv_year) DATA(lv_month) DATA(lv_day).
CONCATENATE lv_year lv_month lv_day INTO DATA(lv_handoff_date).

lv_date = lv_handoff_date.

IF 1 EQ 2.

ENDIF.
