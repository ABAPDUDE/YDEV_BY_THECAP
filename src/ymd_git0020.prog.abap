*&---------------------------------------------------------------------*
*& Report YMD_00020
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0020.

DATA lv_peil_datum_min TYPE sy-datum.
DATA lv_peil_datum_max TYPE sy-datum.
DATA lv_2_weken        TYPE sy-datum.

DATA(lv_verbruik_significant_n)  = zcl_alliander_generiek=>getcustparameter( 'Z_CL_VERBRUIK_SIGNIFICANT_N' ).
DATA(lv_verbruik_significant_ng) = zcl_alliander_generiek=>getcustparameter( 'Z_CL_VERBRUIK_SIGNIFICANT_NG' ).
DATA(lv_verbruik_aantaldagen)    = zcl_alliander_generiek=>getcustparameter( 'Z_CL_VERBRUIK_AANTALDAGEN' ).

DATA mo_input TYPE REF TO zcl_input_cl_assist.

SELECT DISTINCT zisu_poc_ean~caseid, zisu_poc_ean~ean, zisu_poc_ean~datum_meter_uitlezen,
                zisu_poc_case~scenario, zisu_poc_case~status, zisu_poc_ean~effectueringsdatum,
                zisu_poc_ean~product
  FROM zisu_poc_ean AS zisu_poc_ean
  INNER JOIN zisu_poc_case AS zisu_poc_case
  ON zisu_poc_ean~caseid EQ zisu_poc_case~caseid
  INTO TABLE @DATA(lt_cases)
  WHERE zisu_poc_ean~effectueringsdatum LE @lv_peil_datum_min
*         AND zisu_poc_ean~effectueringsdatum GE @lv_peil_datum_max
    AND zisu_poc_case~scenario          IN @mo_input->ms_input-scenario
    AND zisu_poc_ean~verbruik           LT @lv_verbruik_significant_n
    AND zisu_poc_ean~status             LT '49'
    AND  zisu_poc_ean~product           EQ 'N'.

SELECT DISTINCT zisu_poc_ean~caseid, zisu_poc_ean~ean, zisu_poc_ean~datum_meter_uitlezen,
                zisu_poc_case~scenario, zisu_poc_case~status, zisu_poc_ean~effectueringsdatum,
                zisu_poc_ean~product
  FROM zisu_poc_ean AS zisu_poc_ean
  INNER JOIN zisu_poc_case AS zisu_poc_case
  ON zisu_poc_ean~caseid EQ zisu_poc_case~caseid
  APPENDING TABLE @lt_cases
  WHERE zisu_poc_ean~effectueringsdatum LE @lv_peil_datum_min
*         AND zisu_poc_ean~effectueringsdatum GE @lv_peil_datum_max
    AND zisu_poc_case~scenario          IN @mo_input->ms_input-scenario
    AND zisu_poc_ean~verbruik           LT @lv_verbruik_significant_ng
    AND zisu_poc_ean~status             LT '49'
    AND  zisu_poc_ean~product           EQ 'NG'.
