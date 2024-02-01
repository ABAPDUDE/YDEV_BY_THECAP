*&---------------------------------------------------------------------*
*& Report YMD_045
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0145.

DATA lv_date_ceres TYPE dec15.
DATA lv_date_ceres_string TYPE string.
DATA lv_date_dats TYPE dats.

lv_date_ceres_string = '2022-04-06T06:04:10.700Z'.
* lv_date_ceres = '2022-04-06T06:04:10.700Z'.
* lv_date_ceres_string = lv_date_ceres.
DATA(lv_date_sap) = lv_date_ceres_string(10).

DATA : lv_regex TYPE string VALUE '[-]'.

REPLACE ALL OCCURRENCES OF REGEX lv_regex IN lv_date_sap WITH ''.

lv_date_dats = lv_date_sap.

IF 1 EQ 2.
ELSE.
ENDIF.
