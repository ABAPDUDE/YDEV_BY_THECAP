*&---------------------------------------------------------------------*
*& Report YMD_0011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0043.


DATA(lv_verbruik_aantaldagen) = zcl_alliander_generiek=>getcustparameter( 'Z_CL_VERBRUIK_AANTALDAGEN' ).
*lv_verbruik_aantaldagen = ( 0 - lv_verbruik_aantaldagen ).  " waarde moet voor interface negatief zijn

*WRITE :/10 lv_verbruik_aantaldagen.

lv_verbruik_aantaldagen = |-{ lv_verbruik_aantaldagen }|.  " waarde moet voor interface negatief zijn

WRITE :/10 lv_verbruik_aantaldagen.
