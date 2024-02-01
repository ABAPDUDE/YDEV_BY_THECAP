*&---------------------------------------------------------------------*
*& Report YMD_023
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0103.

PARAMETERS pa_value TYPE zdt_transaction_request_qualif-value DEFAULT '25-05-2022'.

DATA ls_input TYPE zdt_transaction_request_qualif.
DATA lv_datum_sleuteloverdracht TYPE dats.

IF pa_value IS INITIAL.
  ls_input-value = '25-05-2022'.
ELSE.
  ls_input-value = pa_value.
ENDIF.

DATA(lv_date_webform) = ls_input-value.

REPLACE ALL OCCURRENCES OF '-' IN lv_date_webform WITH space.

lv_datum_sleuteloverdracht = lv_date_webform .

CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
  EXPORTING
    date_external            = lv_datum_sleuteloverdracht
*   ACCEPT_INITIAL_DATE      =
  IMPORTING
    date_internal            = lv_datum_sleuteloverdracht
  EXCEPTIONS
    date_external_is_invalid = 1
    OTHERS                   = 2.

IF sy-subrc EQ 0.

  WRITE: /5 'datumformat Webform ', pa_value, 'is getransformeerd naar SAP format', lv_datum_sleuteloverdracht.
ENDIF.
