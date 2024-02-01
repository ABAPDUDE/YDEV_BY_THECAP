*&---------------------------------------------------------------------*
*& Report YMD_0017
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0037.

TYPES:
  BEGIN OF ty_aansluit,
    ext_ui  TYPE ext_ui,
    anlage  TYPE anlage,
    vstelle TYPE vstelle,
  END OF ty_aansluit .
TYPES:
  tty_aansluit TYPE SORTED TABLE OF ty_aansluit WITH UNIQUE KEY ext_ui anlage vstelle .

DATA lv_lines         TYPE char10.
DATA lt_aansluitingen TYPE tty_aansluit.
DATA lt_aansluiting   TYPE ztt_aansluitingen_meter.

DATA ls_ean TYPE zisu_poc_ean.
DATA lt_ean TYPE STANDARD TABLE OF zisu_poc_ean.

DATA lv_ean TYPE ext_ui.
lv_ean = '871690910001399870'.
ls_ean-ean = lv_ean.
APPEND ls_ean TO lt_ean.

CONSTANTS mc_actief_datum TYPE sy-datum VALUE '99991231'.
CONSTANTS mc_actief_tijd TYPE sy-uzeit VALUE '235959'.
CONSTANTS mc_usagetype_kv TYPE zusagetype VALUE 'KV'.

" Selecteer aansluitingen
SELECT euitrans~ext_ui euiinstln~anlage eanl~vstelle
eanl~zzstatus_aansl eanl~sparte eanl~zzusage_type
eanl~zz_levrichting
INTO TABLE lt_aansluiting
FROM euitrans AS euitrans
INNER JOIN euiinstln AS euiinstln
ON euitrans~int_ui EQ euiinstln~int_ui
INNER JOIN eanl AS eanl
ON euiinstln~anlage EQ eanl~anlage
FOR ALL ENTRIES IN lt_ean
WHERE euitrans~ext_ui     EQ lt_ean-ean
  AND euitrans~dateto     EQ mc_actief_datum
  AND euitrans~timeto     EQ mc_actief_tijd
  AND euiinstln~dateto    EQ mc_actief_datum
  AND euiinstln~timeto    EQ mc_actief_tijd
  AND eanl~zzusage_type   EQ mc_usagetype_kv
  AND eanl~sparte         IN ('N','NG').

lv_lines = lines( lt_aansluiting ).
CONDENSE lv_lines NO-GAPS.

" Selecteer actieve meters
SELECT eastl~anlage, eastl~ab, eastl~bis, egerh~equnr, equi~sernr
     INTO TABLE @DATA(lt_actieve_meters)
     FROM eastl AS eastl
     INNER JOIN egerh AS egerh
     ON eastl~logiknr EQ egerh~logiknr
     INNER JOIN equi AS equi
     ON egerh~equnr EQ equi~equnr
     FOR ALL ENTRIES IN @lt_aansluiting
     WHERE eastl~anlage EQ @lt_aansluiting-anlage
       AND eastl~ab  LE @sy-datum   " bij rapportage: datum selectiescherm
       AND eastl~bis GE @sy-datum.

lv_lines = lines( lt_actieve_meters ).
CONDENSE lv_lines NO-GAPS.

" Vul de aansluitingen aan met alleen actieve meters
LOOP AT lt_aansluiting
ASSIGNING FIELD-SYMBOL(<fs_data>).

  READ TABLE lt_actieve_meters
  WITH KEY anlage = <fs_data>-anlage
  INTO DATA(ls_actieve_meters).

  IF ls_actieve_meters IS NOT INITIAL.
    <fs_data>-equnr = ls_actieve_meters-equnr.
    <fs_data>-sernr = ls_actieve_meters-sernr.
  ELSE.
    " aansluiting zonder actieve meter!  EQUNR / SERNR blijft leeg!
  ENDIF.
  CLEAR ls_actieve_meters.


ENDLOOP.
