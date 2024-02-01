*&---------------------------------------------------------------------*
*& Report YMD_00003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0022.

DATA(lv_postcode) = '123daB'.
CONDENSE lv_postcode NO-GAPS.

IF lv_postcode IS NOT INITIAL.
  CONCATENATE lv_postcode(4) lv_postcode+4(2)
  INTO DATA(lv_postcodeformat_nl)
  SEPARATED BY space.

*  TRANSLATE lv_postcodeformat_nl TO UPPER CASE.
  lv_postcodeformat_nl = to_upper( lv_postcodeformat_nl ).
ENDIF.

DATA lv_fm_postcode1 TYPE pstlz.
DATA lv_fm_postcode2 TYPE pstlz.

lv_fm_postcode1 = lv_postcodeformat_nl.

" format postcode and check if SAP compliancy
CALL FUNCTION 'POSTAL_CODE_CHECK'
  EXPORTING
    country     = 'NL'
    postal_code = lv_fm_postcode1
  IMPORTING
    postal_code = lv_fm_postcode2
  EXCEPTIONS
    not_valid   = 1
    OTHERS      = 2.

IF 1 EQ 2.
ELSE.
ENDIF.
