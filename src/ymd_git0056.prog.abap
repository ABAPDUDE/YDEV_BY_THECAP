*&---------------------------------------------------------------------*
*& Report YMD_403
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0056.



TABLES t005t.

PARAMETERS : par_land TYPE t005t-landx.

SELECT * FROM t005t
WHERE landx = par_land AND spras = 'E'.
  WRITE : / t005t-mandt,  t005t-natio.
ENDSELECT.
