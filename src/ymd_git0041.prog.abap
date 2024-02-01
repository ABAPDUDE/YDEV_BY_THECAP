*&---------------------------------------------------------------------*
*& Report YMD_0013
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0041.

DATA lv_verbruik_h    TYPE p DECIMALS 2.
DATA lv_verbruik_hoog TYPE CHAR10.

lv_verbruik_hoog = 203.

lv_verbruik_h = lv_verbruik_hoog.
lv_verbruik_hoog = ( lv_verbruik_h * '0.25' ).

IF 1 EQ 2.
ENDIF.
