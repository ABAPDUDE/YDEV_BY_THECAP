*&---------------------------------------------------------------------*
*& Report ymd_git0208
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0208.

DATA lv_currdate      TYPE sy-datum.
DATA lv_backmonths(3) TYPE n.
DATA lv_newdate       TYPE sy-datum.

lv_currdate = sy-datum.
lv_backmonths = '1'.

CALL FUNCTION 'CCM_GO_BACK_MONTHS'
  EXPORTING
    currdate   = lv_currdate
    backmonths = lv_backmonths
  IMPORTING
    newdate    = lv_newdate.

DATA(lv_startdate) = lv_newdate.

SELECT ean~ean, zp5_el~stand_volgorde, zp5_el~referentie, case~caseid, ean~scenario, ean~product,
          ean~effectueringsdatum, ean~fysieke_capaciteit, case~verbruiksplaats, zp5_el~selectie_einddatum
   INTO TABLE @DATA(lt_ean_contractloos)
   FROM zisu_poc_ean AS ean
   INNER JOIN zisu_poc_case AS case
     ON ean~caseid EQ case~caseid
   INNER JOIN zp5_meetdata_el AS zp5_el
     ON ean~ean EQ zp5_el~ean
     WHERE ean~effectueringsdatum LT @lv_startdate
       AND ean~status LT '49'
       AND zp5_el~stand_volgorde = ( SELECT MAX( stand_volgorde ) FROM zp5_meetdata_el WHERE ean = ean~ean ).

LOOP AT lt_ean_contractloos
INTO DATA(ls_ean_cl)
WHERE selectie_einddatum EQ lv_startdate.

  IF 1 EQ 2.
  ELSE.
  ENDIF.

ENDLOOP.

IF 1 EQ 2.

ELSE.

ENDIF.
