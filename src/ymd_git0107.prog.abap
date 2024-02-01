*&---------------------------------------------------------------------*
*& Report YMD_027
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0107.

DATA lt_date   TYPE emma_date_range_tab.
DATA ls_date   TYPE emma_date_range.

CONSTANTS gco_vzcstatus_10 TYPE zde_vzc_status VALUE '10'.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.

PARAMETERS pa_ean   TYPE ext_ui.
PARAMETERS pa_begin TYPE begda OBLIGATORY.
PARAMETERS pa_end   TYPE endda OBLIGATORY.
PARAMETERS pa_test  AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK bl1.

START-OF-SELECTION.

  ls_date-sign   = 'I'.
  ls_date-option = 'BT'.
  ls_date-low    = pa_begin.
  ls_date-high   = pa_end.

  APPEND ls_date TO lt_date.

  " requirement 1
  IF pa_ean IS NOT INITIAL.

    SELECT *
    INTO TABLE @DATA(lt_workload)
    FROM ztvzc_workload
    WHERE opnamedatum IN @lt_date
      AND ext_ui EQ @pa_ean
      AND status EQ @gco_vzcstatus_10.

  ELSE.

    SELECT *
    INTO TABLE lt_workload
    FROM ztvzc_workload
    WHERE opnamedatum IN lt_date
      AND status EQ gco_vzcstatus_10.

  ENDIF.

  SORT lt_workload BY ext_ui begda opnamedatum datum_gemaakt DESCENDING tijd_gemaakt DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_workload COMPARING ext_ui begda opnamedatum.
