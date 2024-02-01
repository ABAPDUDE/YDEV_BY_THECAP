*&---------------------------------------------------------------------*
*& Report YMD_013
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0093.

DATA lv_external_date TYPE c VALUE '22-11-2021' LENGTH 10.
DATA lv_internal_date TYPE sydatum.

REPLACE ALL OCCURRENCES OF '-' IN lv_external_date WITH space.

CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
  EXPORTING
    date_external            = lv_external_date
*   ACCEPT_INITIAL_DATE      =
  IMPORTING
    date_internal            = lv_internal_date
  EXCEPTIONS
    date_external_is_invalid = 1
    OTHERS                   = 2.
IF sy-subrc <> 0.
* Implement suitable error handling here
ELSE.
  WRITE: /5 lv_internal_date.
ENDIF.
