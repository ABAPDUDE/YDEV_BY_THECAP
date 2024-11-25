*&---------------------------------------------------------------------*
*& Report YMD_GIT0214
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0214.

DATA lv_startdate TYPE sy-datum.
DATA lco_status_crm TYPE zde_cl_status VALUE '20'.
DATA lco_product_n TYPE sparte VALUE 'N'.
DATA lco_product_ng TYPE sparte VALUE 'NG'.

lv_startdate = '20241028'.

SELECT ean~ean, zp5_el~referentie, case~caseid, ean~scenario, ean~status, ean~product,
       ean~effectueringsdatum, ean~fysieke_capaciteit, case~verbruiksplaats, zp5_el~stand_volgorde, zp5_el~selectie_einddatum
   FROM zisu_poc_ean AS ean
   INNER JOIN zisu_poc_case AS case
     ON ean~caseid EQ case~caseid
   INNER JOIN zp5_meetdata_el AS zp5_el
     ON ean~ean EQ zp5_el~ean
*         WHERE ean~effectueringsdatum LT @me->mv_startdate
*           AND zp5_el~selectie_einddatum EQ @me->mv_startdate
       WHERE ean~status LE @lco_status_crm
*       AND zp5_el~stand_volgorde = ( SELECT MAX( stand_volgorde ) FROM zp5_meetdata_el WHERE ean = ean~ean )
            AND zp5_el~datum_request EQ @lv_startdate
      AND ean~einddatum EQ @( VALUE #( ) )
       AND ( ean~product EQ @lco_product_n OR
            ean~product EQ @lco_product_ng )
          AND zp5_el~stand_volgorde NE '999'
      INTO TABLE @DATA(lt_ean_contractloos).


SORT lt_ean_contractloos BY ean stand_volgorde DESCENDING.
DELETE ADJACENT DUPLICATES FROM lt_ean_contractloos COMPARING ean.

IF sy-subrc EQ 0.


ELSE.

ENDIF.
