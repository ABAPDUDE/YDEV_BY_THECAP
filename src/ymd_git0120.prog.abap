*&---------------------------------------------------------------------*
*& Report YMD_020
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0120.

CONSTANTS lco_gasmethode_uit TYPE rvari_val_255 VALUE ' '.

SELECT SINGLE *
   FROM tvarvc
   INTO @DATA(ls_tvarvc)
   WHERE name EQ @lco_gasmethode_uit.

IF ls_tvarvc-low EQ abap_false.

  WRITE: /5  | value is empty |.

ELSE.

  WRITE: /5  | value is abap_true |.

ENDIF.
