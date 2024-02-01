*&---------------------------------------------------------------------*
*& Report YMD_00009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0009.

START-OF-SELECTION.

  SELECT *
    INTO TABLE @DATA(lt_itab)
    FROM zem_berichten_dw
    UP TO 200 ROWS.

  INSERT zem_bericht_test FROM TABLE lt_itab ACCEPTING DUPLICATE KEYS.

*  INSERT zem_bericht_test FROM ( SELECT * FROM zem_berichten_dw ).

  WRITE:  sy-dbcnt, sy-tabix, sy-index.
