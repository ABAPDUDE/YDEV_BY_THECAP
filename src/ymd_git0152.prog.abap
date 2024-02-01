*&---------------------------------------------------------------------*
*& Report YMD_052
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0152.

SELECT caseid, ean, status, status_reden, effectueringsdatum, scenario
INTO TABLE @DATA(lt_contractloos)
FROM zisu_poc_ean
  WHERE status LT '49'.

DATA(lv_lines) = lines( lt_contractloos ).

SORT lt_contractloos DESCENDING BY effectueringsdatum.
IF lv_lines GT 0.
ELSE.
ENDIF.
