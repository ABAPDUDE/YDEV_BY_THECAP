*&---------------------------------------------------------------------*
*& Report YMD_048
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0148.

SELECT caseid, ean, scenario
FROM zv_isu_poc_case
INTO TABLE @DATA(lt_case1).

IF 1 EQ 2.

ENDIF.

SELECT caseid, ean, scenario
FROM zv_isu_poc_case
INTO TABLE @DATA(lt_case2)
WHERE ( scenario NE '05'
OR scenario NE '09'
OR scenario NE '10' ).

IF 1 EQ 2.

ENDIF.

SELECT caseid, ean, scenario
FROM zv_isu_poc_case
INTO TABLE @DATA(lt_case3)
WHERE ( scenario NE '05'
AND scenario NE '09'
AND scenario NE '10' ).

IF 1 EQ 2.

ENDIF.
