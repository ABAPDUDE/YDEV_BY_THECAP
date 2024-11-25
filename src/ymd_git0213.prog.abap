*&---------------------------------------------------------------------*
*& Report YMD_GIT0213
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0213.

DATA lv_startdate TYPE sy-datum.
DATA lco_status_niet_cl TYPE zde_cl_status VALUE '49'.
DATA lco_product_n TYPE sparte VALUE 'N'.
DATA lco_product_ng TYPE sparte VALUE 'NG'.

SELECT ean~ean, zp5_el~referentie, ean~scenario, ean~status, ean~product, ean~effectueringsdatum,
            ean~fysieke_capaciteit, zp5_el~stand_volgorde, zp5_el~selectie_einddatum, ean~einddatum
    INTO TABLE @DATA(lt_ean_contractloos)
    FROM zisu_poc_ean AS ean
    INNER JOIN zp5_meetdata_el AS zp5_el
      ON ean~ean EQ zp5_el~ean
      WHERE ean~status EQ @lco_status_niet_cl
*        AND zp5_el~selectie_einddatum EQ @me->mv_startdate
        AND ean~effectueringsdatum EQ zp5_el~effectueringsdatum
        AND ( ean~product EQ @lco_product_n OR
              ean~product EQ @lco_product_ng )
        AND zp5_el~stand_volgorde NE '999'.

*        AND zp5_el~stand_volgorde = ( SELECT MAX( stand_volgorde ) FROM zp5_meetdata_el WHERE ean = ean~ean
*                                      OR zp5_el~stand_volgorde NE '999' ).

SORT lt_ean_contractloos BY ean stand_volgorde DESCENDING.
DELETE ADJACENT DUPLICATES FROM lt_ean_contractloos COMPARING ean.

IF sy-subrc EQ 0.


ELSE.

ENDIF.
