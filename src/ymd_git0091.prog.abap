*&---------------------------------------------------------------------*
*& Report YMD_011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0091.

DATA lv_pstlz1 TYPE pstlz VALUE '2525fg'.
DATA lv_pstlz2 TYPE pstlz VALUE '5621Cn'.
DATA lv_pstlz3 TYPE pstlz VALUE '7811eT'.

DO 3 TIMES.

  DATA(lv_index) = sy-index.

  CASE lv_index.
    WHEN '1'.
      IF lv_pstlz1 IS NOT INITIAL.
        DATA(lv_postcode) =  lv_pstlz1.
      ENDIF.
    WHEN '2'.
      IF lv_pstlz2 IS NOT INITIAL.
        lv_postcode =  lv_pstlz2.
      ENDIF.
    WHEN '3'.
      IF lv_pstlz3 IS NOT INITIAL.
        lv_postcode =  lv_pstlz3.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

  IF lv_postcode+4(1) IS NOT INITIAL.
    CONCATENATE lv_postcode(4) lv_postcode+4(2)
    INTO DATA(lv_postcode_fixed)
      SEPARATED BY space.
  ELSE.
    lv_postcode_fixed = lv_postcode.
  ENDIF.

  TRANSLATE lv_postcode_fixed  TO UPPER CASE.
  DATA lv_fm_postcode TYPE pstlz.
  lv_fm_postcode = lv_postcode_fixed.

  " format postcode and check if SAP compliancy
  CALL FUNCTION 'POSTAL_CODE_CHECK'
    EXPORTING
      country     = 'NL'
      postal_code = lv_fm_postcode
    IMPORTING
      postal_code = lv_postcode
    EXCEPTIONS
      not_valid   = 1
      OTHERS      = 2.

  IF sy-subrc <> 0.
    MESSAGE ID 'ZMSG_VZC' TYPE 'E' NUMBER 153
     WITH lv_postcode
          INTO DATA(lv_dummy).
    zcl_isu_vzc_fw=>get_instance( )->add_symsg_to_applog( '4' ).
*        returning = abap_true.
  ELSE.

    CASE lv_index.
      WHEN '1'.
        IF lv_pstlz1 IS NOT INITIAL.
          lv_pstlz1 = lv_postcode.
        ENDIF.
      WHEN '2'.
        IF lv_pstlz2 IS NOT INITIAL.
          lv_pstlz2 = lv_postcode.
        ENDIF.
      WHEN '3'.
        IF lv_pstlz3 IS NOT INITIAL.
          lv_pstlz3 = lv_postcode.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
*        returning = abap_false.

  ENDIF.

ENDDO.

WRITE: /5 lv_pstlz1,
       /5 lv_pstlz2,
       /5 lv_pstlz3.
