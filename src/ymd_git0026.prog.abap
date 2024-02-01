*&---------------------------------------------------------------------*
*& Report YMD_0026
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0026.


SELECT caseid, ean
  FROM zv_isu_poc_case
  INTO TABLE @DATA(lt_case)
  WHERE ( scenario NE @zcl_isu_poc_fw=>co_sloop          " 05
       AND scenario NE @zcl_isu_poc_fw=>co_lv_loos_gv    " 09
       AND scenario NE @zcl_isu_poc_fw=>co_mv_loos_gv )  " 10
  ORDER BY PRIMARY KEY.

*IF me->mr_input->ms_input-caseid[] IS NOT INITIAL.
*  DELETE lt_case WHERE caseid NOT IN me->mr_input->ms_input-caseid.
*ENDIF.

DATA(lv_lines) = lines( lt_case ).

IF lv_lines GE 1.

  SELECT caseid, status, datum_gewijzigd, scenario
  FROM zisu_poc_caseh
  INTO TABLE @DATA(lt_case_h)
  FOR ALL ENTRIES IN @lt_case
  WHERE caseid EQ @lt_case-caseid
    AND scenario EQ @zcl_isu_poc_fw=>co_sloop.

  LOOP AT lt_case_h
   INTO DATA(ls_case_h).

    READ TABLE lt_case
    WITH KEY caseid = ls_case_h-caseid
    INTO DATA(ls_case_del).

    IF sy-subrc EQ 0.
      " clear all EANs belonging to CASE_ID
      DELETE lt_case WHERE caseid EQ ls_case_del-caseid.
      CLEAR ls_case_h.
      CLEAR ls_case_del.
    ENDIF.

  ENDLOOP.

ELSE.
  " selection has not resulted in any data lines - internal table is empty
  MESSAGE |er zijn voor deze selectie geen caseIDs / EAN's verwerkt| TYPE 'S'.
ENDIF.

IF 1 EQ 2.
ENDIF.


SELECT case~caseid, case~ean, caseh~datum_gewijzigd, caseh~tijd_gewijzigd, caseh~status, caseh~scenario
  FROM zv_isu_poc_case AS case
  INNER JOIN zisu_poc_caseh AS caseh
  ON caseh~caseid = case~caseid
  INTO TABLE @DATA(lt_case_join)
  WHERE ( case~scenario NE @zcl_isu_poc_fw=>co_sloop         " 05
      AND case~scenario NE @zcl_isu_poc_fw=>co_lv_loos_gv    " 09
      AND case~scenario NE @zcl_isu_poc_fw=>co_mv_loos_gv    " 10
      AND caseh~scenario NE @zcl_isu_poc_fw=>co_sloop
      AND caseh~status LT '49' )
  ORDER BY  case~caseid, case~ean, caseh~datum_gewijzigd, caseh~tijd_gewijzigd.

SORT lt_case_join BY caseid ASCENDING ean ASCENDING datum_gewijzigd DESCENDING tijd_gewijzigd DESCENDING.
DELETE ADJACENT DUPLICATES FROM lt_case_join COMPARING caseid ean.
DELETE lt_case_join WHERE scenario GE '11'.

IF 1 EQ 2.
ENDIF.

DATA(lt_case_join_copy) = lt_case_join[].

" check if the two internal tables have the same result
LOOP AT lt_case
  INTO DATA(ls_case).

  READ TABLE lt_case_join
  WITH KEY caseid = ls_case-caseid
           ean = ls_case-ean
  INTO DATA(ls_case_join).

  DATA(lv_index) = sy-tabix.

  IF sy-subrc EQ 0.
    " clear all EANs belonging to CASE_ID
    DELETE lt_case_join INDEX lv_index.
    CLEAR ls_case.
    CLEAR ls_case_del.
  ENDIF.

ENDLOOP.

IF 1 EQ 2.
ENDIF.

LOOP AT lt_case_join_copy
  INTO DATA(ls_case_join_copy).

  READ TABLE lt_case
  WITH KEY caseid = ls_case_join_copy-caseid
           ean = ls_case_join_copy-ean
  INTO ls_case.

  lv_index = sy-tabix.

  IF sy-subrc EQ 0.
    " clear all EANs belonging to CASE_ID
    DELETE lt_case INDEX lv_index.
    CLEAR ls_case_join_copy.
    CLEAR ls_case_del.
  ENDIF.

ENDLOOP.

IF 1 EQ 2.
ENDIF.
