*&---------------------------------------------------------------------*
*& Report YMD_00016
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0016.

DATA gt_telwerken TYPE ztt_fokv_telwerken.

CONSTANTS : co_einddatum TYPE egerh-bis VALUE '99991231'.

PARAMETERS p_equnr TYPE equnr DEFAULT '5012469986'.   " 5016444119

SELECT
 " etdz~logikzw,
  ezwg~zwgruppe,
  ezwg~zwnummer,
  etdz~stanzvor,
  etdz~zwart  AS srt_telwerk,
  etdz~zwkenn,     "ezwg~zwkenn,
 " etdz~kennziff,   "ezwg~kennziff ,
  etdz~nablesen,   "ezwg~nablesen
  ezwg~anzart

  FROM equi
  INNER JOIN etdz   ON etdz~equnr     = equi~equnr
  INNER JOIN egerh  ON egerh~equnr    = equi~equnr
  INNER JOIN ezwg   ON ezwg~zwgruppe  = egerh~zwgruppe
                    AND ezwg~zwnummer = etdz~zwnummer
  INTO CORRESPONDING FIELDS OF TABLE @gt_telwerken
  " INTO TABLE @DATA(lt_telwerken)
  WHERE equi~equnr   EQ @p_equnr
    AND egerh~bis    EQ @co_einddatum  " '99991231'
    AND etdz~bis     EQ @co_einddatum  " '99991231'
    AND loeschvm     EQ @space.

IF sy-subrc EQ '0'.
  " just 4 test
ELSE.
ENDIF.

" ophalen installatie. Installatie en etdz-logikzw vormen samen de sleutel voor lezen van de tariefsoort
"  DATA(lv_installatie) = zcl_isu_utils=>get_installation_for_equipment( EXPORTING i_equnr   = is_meters-equnr
"                                                                                    i_keydate = syst-datum ).

"   SORT lt_telwerken BY logikzw.
"    LOOP AT lt_telwerken ASSIGNING FIELD-SYMBOL(<telw>).
"      APPEND INITIAL LINE TO rt_telwerken ASSIGNING FIELD-SYMBOL(<telwerk>).
"      MOVE-CORRESPONDING <telw> TO <telwerk>.
"      IF NOT <telw>-logikzw IS INITIAL.

"        <telwerk>-tarifart = get_tariefsoort( EXPORTING iv_installatie = lv_installatie
"                                                        iv_logikzw     = <telw>-logikzw ).

"      ENDIF.
"   ENDLOOP.
