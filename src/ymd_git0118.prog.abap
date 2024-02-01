*&---------------------------------------------------------------------*
*& Report YMD_038
*&---------------------------------------------------------------------*
REPORT ymd_git0118.

DATA lv_overlijdens_datum     TYPE string VALUE '2022-04-15'.
DATA lv_sap_overlijdens_datum TYPE sy-datum.


IF to_upper( lv_overlijdens_datum )          NE |NULL|       AND
             lv_overlijdens_datum            IS NOT INITIAL  AND
             strlen( lv_overlijdens_datum  ) EQ 10.
  lv_sap_overlijdens_datum = lv_overlijdens_datum(4)   +
                             lv_overlijdens_datum+5(2) +
                             lv_overlijdens_datum+8(2).
ENDIF.

WRITE: /10 lv_sap_overlijdens_datum.
CLEAR lv_sap_overlijdens_datum.

IF to_upper( lv_overlijdens_datum )          NE |NULL|       AND
             lv_overlijdens_datum            IS NOT INITIAL  AND
             strlen( lv_overlijdens_datum  ) EQ 10.
  lv_sap_overlijdens_datum = |{ lv_overlijdens_datum(4) }{
                                lv_overlijdens_datum+5(2) }{
                                lv_overlijdens_datum+8(2) }|.
ENDIF.

SKIP 2.


WRITE: /10 lv_sap_overlijdens_datum.
