*&---------------------------------------------------------------------*
*& Report YMD_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0090.

**/*
* Haal alle NIET-sloop cases op
*/*
SELECT caseid, ean, verbruiksplaats
  FROM zv_isu_poc_case
  INTO TABLE @DATA(lt_case_1)
  WHERE scenario NE @zcl_isu_poc_fw=>co_sloop.

SORT lt_case_1 BY caseid ean verbruiksplaats.

IF 1 EQ 2.
ENDIF.

DATA(lv_lines) = lines( lt_case_1 ).
IF lv_lines GE 1.
  SELECT caseid, status, datum_gewijzigd, scenario, verbruiksplaats
    FROM zisu_poc_caseh
    INTO TABLE @DATA(lt_case_2)
    FOR ALL ENTRIES IN @lt_case_1
    WHERE caseid EQ @lt_case_1-caseid
      AND scenario EQ @zcl_isu_poc_fw=>co_sloop.

  LOOP AT lt_case_2
    INTO DATA(ls_case_2).
    READ TABLE lt_case_1
    WITH KEY caseid = ls_case_2-caseid
             verbruiksplaats = ls_case_2-verbruiksplaats
    INTO DATA(ls_case_del).
*  TRANSPORTING NO FIELDS.


    IF sy-subrc EQ 0.
      DATA(lv_index) = sy-tabix.
*     DELETE lt_case_1 INDEX lv_index.
      DELETE lt_case_1 WHERE caseid EQ ls_case_del-caseid.
      CLEAR ls_case_del.
    ENDIF.
  ENDLOOP.

ENDIF.

IF 1 EQ 2.
ENDIF.

SELECT a~caseid, a~ean
  INTO TABLE @DATA(lt_case_join_1)
  FROM zv_isu_poc_case AS a
  INNER JOIN zisu_poc_caseh AS b
  ON a~caseid EQ b~caseid
  WHERE a~scenario NE @zcl_isu_poc_fw=>co_sloop
    AND b~scenario NE @zcl_isu_poc_fw=>co_sloop.

SORT lt_case_join_1 BY caseid ean.
DELETE ADJACENT DUPLICATES FROM lt_case_join_1 COMPARING caseid ean.

IF 1 EQ 2.
ENDIF.

SELECT a~caseid, a~ean
  INTO TABLE @DATA(lt_case_join_2)
  FROM zv_isu_poc_case AS a
  INNER JOIN zisu_poc_caseh AS b
  ON b~caseid EQ a~caseid
  WHERE a~scenario NE @zcl_isu_poc_fw=>co_sloop
    AND b~scenario NE @zcl_isu_poc_fw=>co_sloop.

SORT lt_case_join_2 BY caseid ean.
DELETE ADJACENT DUPLICATES FROM lt_case_join_2 COMPARING caseid ean.

IF 1 EQ 2.
ENDIF.

SELECT a~caseid, a~ean
  INTO TABLE @DATA(lt_case_join_3)
  FROM zv_isu_poc_case AS a
  LEFT OUTER JOIN zisu_poc_caseh AS b
  ON a~caseid EQ b~caseid
  AND ( b~scenario NE @zcl_isu_poc_fw=>co_sloop
          AND b~status NE '01')
  WHERE a~scenario NE @zcl_isu_poc_fw=>co_sloop.

IF 1 EQ 2.
ENDIF.

SELECT caseid, status, datum_gewijzigd, scenario
  FROM zisu_poc_caseh
  INTO TABLE @DATA(lt_case_3)
  WHERE scenario EQ @zcl_isu_poc_fw=>co_sloop
    AND status EQ '01'.

SORT lt_case_3 BY caseid datum_gewijzigd DESCENDING.
DELETE ADJACENT DUPLICATES FROM lt_case_3 COMPARING caseid.

IF 1 EQ 2.
ENDIF.
