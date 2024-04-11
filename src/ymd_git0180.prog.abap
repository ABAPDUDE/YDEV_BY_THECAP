*&---------------------------------------------------------------------*
*& Report YMD_GIT0180
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0180.

DATA lt_x310        TYPE TABLE OF zx310_disputen.
DATA lv_begda       TYPE dats.
DATA lv_endda       TYPE dats.
DATA lt_ean         TYPE zrange_t_eancode.
DATA lv_status      TYPE zx310_disputen_status.

DATA: ls_x310 TYPE zx310_disputen.

SELECT-OPTIONS: so_ean FOR ls_x310-ext_ui.

INITIALIZATION.
  MOVE 'EQ' TO so_ean-option.
  MOVE 'I' TO so_ean-sign.
  MOVE '871685900003521490' TO so_ean-low.
* move '456788' to so_ean-high

  APPEND so_ean.

START-OF-SELECTION.

  lv_begda = '20210101'.
  lv_endda = '20240226'	.
  lt_ean[] = so_ean[].

  SELECT * FROM  zx310_disputen
             INTO CORRESPONDING FIELDS OF TABLE lt_x310
             WHERE ext_ui IN lt_ean     "DB: multiple EAN selection
               AND opnamedatum BETWEEN lv_begda AND lv_endda
               AND herkomst IN (6, 7)
               AND status EQ lv_status.

  IF 1 EQ 2.
  ELSE.
  ENDIF.
