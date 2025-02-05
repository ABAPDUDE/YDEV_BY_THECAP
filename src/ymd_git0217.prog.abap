*&---------------------------------------------------------------------*
*& Report ymd_git0217
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0217.

DATA lv_closing_date TYPE sy-datum.

lv_closing_date = ( sy-datum - 39 ).  " P5 verbruik is tot 40 dagen beschikbaar

IF 1 EQ 2.

ENDIF.
