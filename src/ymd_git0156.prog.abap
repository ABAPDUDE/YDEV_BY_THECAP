*&---------------------------------------------------------------------*
*& Report YMD_056
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0156.

DATA lv_date TYPE datum.
DATA lv_begin_date TYPE datum VALUE '20220505'.
DATA lt_processing_dates TYPE datum_tab.
CONSTANTS lco_tvarvc_date TYPE rvari_vnam VALUE 'ZCERES_LAATSTE_OPHAALDATUM'.

MOVE lv_begin_date TO lv_date.
lv_date = lv_date + 1.

" job runs every day but in case it doesn't we collect the dates since last run
WHILE lv_date LT sy-datum.
  APPEND lv_date TO lt_processing_dates.
  lv_date = lv_date + 1.
ENDWHILE.

SORT lt_processing_dates DESCENDING.
READ TABLE lt_processing_dates
INTO DATA(ls_date)
INDEX 1.

IF ls_date IS NOT INITIAL.
  UPDATE tvarvc
    SET low = ls_date
    WHERE name EQ lco_tvarvc_date.
ENDIF.
