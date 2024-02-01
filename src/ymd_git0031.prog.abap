*&---------------------------------------------------------------------*
*& Report YMD_0022
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0031.

TYPES:
  BEGIN OF ty_adr_sync,
    aansluitobject  TYPE haus,
    verbruiksplaats TYPE vstelle,
    eigenaar        TYPE e_gpartner,
    id              TYPE zdsync_id,
    postcode        TYPE ad_pstcd1,
    huisnummer      TYPE ad_hsnm1,
    huisnummer_toev TYPE ad_hsnm2,
*     huisletter_toev TYPE zhuisletter,
    straat          TYPE ad_street,
    plaats          TYPE ad_city1,
    bag_id          TYPE zbagid_adresseerbaar_obj,
    pand_id         TYPE zbagid_pand,
    ao_soort        TYPE z_aosoort,
    vp_soort        TYPE vbsart,
    locatiedetails  TYPE lgzusatz,
    data_oorsprong  TYPE zdata_oorsprong,
    zakenpartner    TYPE bu_partner,
    type            TYPE zde_thirdparty_dsync,
    actie           TYPE zdsync_actiecode,
  END OF ty_adr_sync .
TYPES:
  tty_adr_sync TYPE STANDARD TABLE OF ty_adr_sync WITH NON-UNIQUE KEY aansluitobject verbruiksplaats eigenaar .

DATA lv_index TYPE sy-index.
DATA ls_adr_ddic TYPE zdsync_sap_adr.
DATA ls_wodril TYPE ty_adr_sync.

SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
       zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
       zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
       zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
       zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
       zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
  FROM zdsync_sap_adr AS zdsync_sap_adr
  INNER JOIN zdsync_sap_ean AS zdsync_sap_ean
   ON zdsync_sap_adr~id EQ zdsync_sap_ean~id
    AND zdsync_sap_adr~zakenpartner EQ zdsync_sap_ean~zakenpartner
    AND zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
*        AND ( zdsync_sap_adr~data_oorsprong eq me->mc_via_adres OR
*              zdsync_sap_adr~data_oorsprong eq me->mc_via_bagid )
  INTO TABLE @DATA(lt_wodril).

DESCRIBE TABLE lt_wodril LINES DATA(lv_nr_wodril).
IF lv_nr_wodril GE 1.

  SORT lt_wodril BY aansluitobject verbruiksplaats.
  DELETE ADJACENT DUPLICATES FROM lt_wodril COMPARING aansluitobject verbruiksplaats.

  " het programma moet verbruiksplaatsen met meerdere installaties waarvan er minimaal 1
  " nog in gebruik is niet Buiten Gebruik plaatsten

  SELECT verbruiksplaats, anlage, product
    INTO TABLE @DATA(lt_anlage_ib)
    FROM zdsync_sap_ean
    FOR ALL ENTRIES IN @lt_wodril
    WHERE verbruiksplaats EQ @lt_wodril-verbruiksplaats
      AND aansluitobject EQ @lt_wodril-aansluitobject
      AND ( status_aansluit EQ 'IA' OR
            status_aansluit EQ 'IB' ).

  LOOP AT lt_anlage_ib
    INTO DATA(ls_anlage).

    READ TABLE lt_wodril
    WITH KEY verbruiksplaats = ls_anlage-verbruiksplaats
    ASSIGNING FIELD-SYMBOL(<fsanlage>).

    lv_index = sy-tabix.

    IF sy-subrc EQ 0.
      DELETE lt_wodril INDEX lv_index.
    ENDIF.

  ENDLOOP.

  LOOP AT lt_wodril INTO ls_wodril.

    ls_adr_ddic = CORRESPONDING #( ls_wodril ).

    IF ( ls_wodril-data_oorsprong EQ 'VIA-ADRES' OR
         ls_wodril-data_oorsprong EQ 'VIA-BAGID' ).

      UPDATE zdsync_sap_adr FROM @( VALUE #( BASE ls_adr_ddic actie = '00' ) ).

*      me->build_result_table(
*                      EXPORTING
*             is_result            = ls_wodril
*             iv_uitval            = abap_false
*             iv_opmerking         = 'De aansluiting van deze verbruiksplaats heeft status Buiten Gebruik (BG)'
*             iv_actiecode         = '00'
*             iv_actieomschrijving = 'GEEN ACTIE UITGEVOERD'
*             iv_zp_toevoegen      = abap_false
*             iv_zp_wijzigen       = abap_false
*             iv_zp_verwijderen    = abap_false
*        ).

    ELSEIF ls_wodril-data_oorsprong EQ 'VIA-ZAKENPARTNER'.

      DELETE zdsync_sap_adr FROM ls_adr_ddic. " deze regels wil je later niet terug zien in de resultaten tabel

    ENDIF.

  ENDLOOP.
  COMMIT WORK AND WAIT. " ZDSYNC_SAP_ADR moet worden ge-update voor de actie code


ENDIF.

IF 1 EQ 2.

ENDIF.
