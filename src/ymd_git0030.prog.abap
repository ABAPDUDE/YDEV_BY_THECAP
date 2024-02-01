*&---------------------------------------------------------------------*
*& Report YMD_0023
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0030.

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
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
  WHERE zdsync_sap_ean~usage_type EQ 'GV'
        INTO TABLE @DATA(lt_gv).

IF 1 EQ 2.

ENDIF.
