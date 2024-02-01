*&---------------------------------------------------------------------*
*& Report YMD_021
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0101.

DATA lv_udate TYPE syst_datum VALUE '20211030'.

DATA(lv_valid_date) = sy-datum - 180.
IF lv_udate GE lv_valid_date.
  DATA(lv_cancel_segmentwissel1) = abap_true.
ELSE.
  WRITE lv_valid_date.
ENDIF.

DATA lv_validation_date TYPE sydatum.
lv_validation_date = sy-datum - 180.
IF lv_udate GE lv_validation_date.
  DATA(lv_cancel_segmentwissel2) = abap_true.
ELSE.
  WRITE lv_validation_date.
ENDIF.

DATA(datum) = ( sy-datum + 14 ).
DATA lv_datum TYPE dats.
lv_datum = ( sy-datum + 14 ).

IF 1 EQ 2.
ENDIF.
