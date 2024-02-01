REPORT ymd_git0126 .

DATA t1 TYPE i.
DATA t2 TYPE i.


DATA lt_adrdata TYPE ztt_adr_dsync.
DATA lt_eandata TYPE ztt_ean_dsync.

DATA lv_zakenpartner TYPE bu_partner VALUE '0028483826'.

CONSTANTS mc_actief_datum	TYPE sy-datum	VALUE	'99991231'.
CONSTANTS mc_actief_tijd TYPE sy-uzeit VALUE  '235959'.
CONSTANTS mc_usagetype_kv TYPE zusagetype VALUE 'KV'.
CONSTANTS mc_aansluitobj_isu TYPE fltyp VALUE 'A'.
CONSTANTS mc_via_zakenpartner TYPE zdata_oorsprong VALUE 'VIA-ZAKENPARTNER'.

START-OF-SELECTION.

  GET RUN TIME FIELD t1.

  SELECT iflot~tplnr, iflot~bagid_adresseerb_obj, iflot~bagid_pand, iflot~aosoort,
          iloa~iloan, iloa~adrnr,
          evbs~vstelle, evbs~haus, evbs~vbsart, evbs~eigent, evbs~lgzusatz,
          adrc~post_code1, adrc~house_num1, adrc~house_num2, adrc~street, adrc~city1
        INTO TABLE @DATA(lt_join)
        FROM evbs AS evbs
          INNER JOIN iflot AS iflot
          ON evbs~haus EQ iflot~tplnr
          INNER JOIN iloa AS iloa
          ON iflot~iloan EQ iloa~iloan AND
             iflot~tplnr EQ iloa~tplnr
          INNER JOIN adrc AS adrc
          ON adrc~addrnumber EQ iloa~adrnr
          WHERE evbs~eigent EQ @lv_zakenpartner
            AND iflot~fltyp EQ @mc_aansluitobj_isu.

  " er wordt geen SAP ID gegenereerd omdat de functieplaats zich niet in de originele upload file bevind
  LOOP AT lt_join
  ASSIGNING FIELD-SYMBOL(<fs_join>).

    APPEND VALUE #(
           functieplaats   = <fs_join>-tplnr
           bag_id          = <fs_join>-bagid_adresseerb_obj
           pand_id         = <fs_join>-bagid_pand
           verbruiksplaats = <fs_join>-vstelle
           aansluitobject  = <fs_join>-haus
           eigenaar        = <fs_join>-eigent
           id              = '0000000000'
           ao_soort        = <fs_join>-aosoort
           vp_soort        = <fs_join>-vbsart
           postcode        = <fs_join>-post_code1
           huisnummer      = <fs_join>-house_num1
           huisnummer_toev = <fs_join>-house_num2
           straat          = <fs_join>-street
           plaats          = <fs_join>-city1
           locatiedetails  = <fs_join>-lgzusatz
           data_oorsprong  = mc_via_zakenpartner
           zakenpartner    = lv_zakenpartner
           type            = 'ZSYNCW'
            ) TO lt_adrdata.
  ENDLOOP.

  DATA lt_aansluiting TYPE ztt_aansluitingen_meter.

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
  FOR ALL ENTRIES IN lt_adrdata
  WHERE eanl~vstelle        EQ lt_adrdata-verbruiksplaats
    AND euitrans~dateto     EQ mc_actief_datum
    AND euitrans~timeto     EQ mc_actief_tijd
    AND euiinstln~dateto    EQ mc_actief_datum
    AND euiinstln~timeto    EQ mc_actief_tijd
    AND eanl~zzusage_type   EQ mc_usagetype_kv
    AND eanl~sparte         IN ('N','NG').

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
         AND eastl~ab  LE @sy-datum "bij rapportage: datum selectiescherm
         AND eastl~bis GE @sy-datum.

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

    "Eventueel kan je ook meteen lt_eandata vullen
    APPEND VALUE #(
    ean             = <fs_data>-ext_ui
*        id              = me->read_id( <fs_join>-vstelle )
*        aansluitobject  = me->read_haus( <fs_join>-vstelle )
    verbruiksplaats = <fs_data>-vstelle
    product         = <fs_data>-sparte
    status_aansluit = <fs_data>-zzstatus_aansl
    usage_type      = <fs_data>-zzusage_type
    serienummer     = <fs_data>-sernr
    leverrichting   = <fs_data>-zz_levrichting
    zakenpartner    = lv_zakenpartner
    type            = 'ZSYNCW'
    ) TO  lt_eandata.

  ENDLOOP.

  " breakppoint position 4 testing
  IF 1 EQ 2.
  ELSE.
    GET RUN TIME FIELD t2.
  ENDIF.

  DATA(lv_runtime) = t2 - t1.

  WRITE: /5 lv_runtime, 'MS'.
