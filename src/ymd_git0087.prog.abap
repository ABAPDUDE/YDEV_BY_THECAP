*&---------------------------------------------------------------------*
*& Report YMD_007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0087.

DATA lv_tot_laag TYPE char10.
DATA lv_tot_laagnew TYPE char10.
DATA lv_tot_laag_num TYPE num10.

lv_tot_laagnew = 0.
lv_tot_laag = lv_tot_laag + lv_tot_laagnew.

MOVE lv_tot_laag TO lv_tot_laag_num.

IF lv_tot_laag_num CO '0'.
  CLEAR lv_tot_laag. " remove value '0'
ENDIF.

WRITE /5 lv_tot_laag.
