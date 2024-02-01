*&---------------------------------------------------------------------*
*& Report YMD_080
*&---------------------------------------------------------------------*
REPORT ymd_git0139.

*/**
* mission objective: find string inside string
*/*

TYPES: BEGIN OF ty_bp,
         bp        TYPE bu_partner,
         name_last TYPE text100,
       END OF ty_bp.
TYPES tty_bp TYPE STANDARD TABLE OF ty_bp
                  WITH NON-UNIQUE KEY bp.

DATA lt_bp TYPE tty_bp.
DATA lv_resultaat TYPE c.
CONSTANTS gco_woco_name1 TYPE text100 VALUE 'WoonWaartS'.

SELECT bp, name_last
      INTO TABLE @DATA(lt_zakenpartner)
      FROM zisu_poc_owner
      WHERE valid_to EQ '99991231'.

TRY.
    DATA(lv_zoek_succes_1) = cl_abap_matcher=>contains(
                                pattern       = gco_woco_name1
*                                text          =
                                table         = lt_zakenpartner
                                ignore_case   = abap_true
*                           simple_regex  = ABAP_FALSE
*                           no_submatches = ABAP_FALSE
       ).

  CATCH cx_sy_matcher.  "
  CATCH cx_sy_regex.  "
ENDTRY.

DATA(lv_index1) = sy-tabix.
READ TABLE lt_zakenpartner
INTO DATA(ls_zakenpartner)
INDEX lv_index1.


LOOP AT lt_zakenpartner
  INTO DATA(ls_zp).

  DATA(lv_index2) = sy-tabix.

  TRY.
      DATA(lv_zoek_succes_2) = cl_abap_matcher=>contains(
                                  pattern       = gco_woco_name1
                                  text          = ls_zp-name_last
*                                 table         = lt_zakenpartner
                                  ignore_case   = abap_true
*                           simple_regex  = ABAP_FALSE
*                           no_submatches = ABAP_FALSE
         ).

    CATCH cx_sy_matcher.  "
    CATCH cx_sy_regex.  "
  ENDTRY.

*  READ TABLE lt_zakenpartner
*  INTO ls_zakenpartner
*  INDEX lv_index2.

  IF lv_zoek_succes_2 EQ abap_true.
    APPEND ls_zp TO lt_bp.
  ENDIF.

ENDLOOP.

LOOP AT lt_bp
  INTO DATA(ls_bp).

  WRITE: /10 ls_bp-bp, 25 ls_bp-name_last.
ENDLOOP.
*SORT lt_zakenpartner.
*DELETE ADJACENT DUPLICATES FROM lt_zakenpartner COMPARING bp.

*DATA(lv_lines) = lines( lt_zakenpartner ).
*IF lv_lines EQ 1.

*ELSE.

*ENDIF.
