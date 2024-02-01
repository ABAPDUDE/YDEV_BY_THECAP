*&---------------------------------------------------------------------*
*& Report YMD_009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0089.

DATA lv_postcode TYPE pstlz VALUE '6521cn'.
DATA lv_postcode_changed TYPE pstlz.
DATA lv_postcode_correct TYPE pstlz.

IF lv_postcode+4(1) IS NOT INITIAL.
  CONCATENATE lv_postcode(4)  lv_postcode+4(2)
  INTO lv_postcode
  SEPARATED BY space.
ENDIF.

TRANSLATE lv_postcode  TO UPPER CASE.
" format postcode first check if SAP complient
CALL FUNCTION 'POSTAL_CODE_CHECK'
  EXPORTING
    country     = 'NL'
    postal_code = lv_postcode
  IMPORTING
    postal_code = lv_postcode_correct
  EXCEPTIONS
    not_valid   = 1
    OTHERS      = 2.

WRITE: /5 lv_postcode, 'is transformed to: ', lv_postcode_correct.
