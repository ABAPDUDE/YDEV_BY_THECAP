*&---------------------------------------------------------------------*
*& Report YMD_0016
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0038.

SELECT aansluitobject, verbruiksplaats, eigenaar, postcode, huisnummer,
         huisnummer_toev, straat, plaats, bag_id, pand_id, ao_soort, vp_soort
    FROM zdsync_sap_adr
    WHERE data_oorsprong EQ 'VIA-ADRES' " @me->mc_via_zakenpartner
      AND data_wijziging EQ @( VALUE #( ) )
*     AND data_wijziging NE 'ZAKENPARTNER ONTKOPPELD'
    INTO TABLE @DATA(lt_nodril_2)
    UP TO 5 ROWS.

DESCRIBE TABLE lt_nodril_2 LINES DATA(lv_nr_nodril).
IF lv_nr_nodril GE 1.
  " data gevonden
ELSE.
  " geen data gevonden die voldoet aan de selectie criteria
ENDIF.
