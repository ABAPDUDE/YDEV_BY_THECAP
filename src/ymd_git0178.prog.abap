*&---------------------------------------------------------------------*
*& Report ymd_git0178
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0178.

DATA lv_postcode TYPE ad_pstcd1 VALUE '6521 CN'.

zcl_adres=>converteer_postcode_2_velden(
  EXPORTING
    iv_postcode        =   lv_postcode  " Postcode van de plaats
  IMPORTING
    ev_postcode_letter =  DATA(lv_letter)   " Postcode van de plaats
    ev_postcode_nummer =  DATA(lv_number)   " IS-H NL: LAZR-cijfers in postcode
).

IF 1 EQ 2.
ELSE.
ENDIF.
