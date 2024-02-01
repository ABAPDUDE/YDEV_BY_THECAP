*&---------------------------------------------------------------------*
*& Report YMD_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git002.


SELECT *
  INTO TABLE @DATA(lt_bg_ean_1)
  FROM zdsync_sap_ean
  WHERE status_aansluit EQ 'BG'.

SELECT *
  INTO TABLE @DATA(lt_bg_ean_2)
  FROM zdsync_sap_ean
  WHERE zakenpartner EQ '0010010565'   " @me->mo_input->ms_input-zaken_partner
    AND status_aansluit EQ 'BG'.

SELECT *
  INTO TABLE @DATA(lt_bg_ean_3)
  FROM zdsync_sap_ean
  WHERE zakenpartner EQ '0028342284'   " @me->mo_input->ms_input-zaken_partner
    AND status_aansluit EQ 'BG'.

SELECT *
  FROM zdsync_sap_adr
  WHERE actie EQ @( VALUE #( ) )
  INTO TABLE @DATA(lt_bg_adr_1).

SELECT *
  FROM zdsync_sap_adr
  WHERE zakenpartner EQ '0028342284'   " @me->mo_input->ms_input-zaken_partner
    AND actie EQ @( VALUE #( ) )
  INTO TABLE @DATA(lt_bg_adr_3).

" query ADR met INNER JOIN EAN - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
       zdsync_sap_ean~status_aansluit,
       zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
       zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
       zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
       zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
       zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
  FROM zdsync_sap_adr AS zdsync_sap_adr
  INNER JOIN zdsync_sap_ean AS zdsync_sap_ean
     ON zdsync_sap_adr~id EQ zdsync_sap_ean~id
    AND zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
    AND zdsync_sap_adr~verbruiksplaats EQ zdsync_sap_ean~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
*   AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
   INTO TABLE @DATA(lt_bg_1a).

DATA(lv_lines_1a) = lines( lt_bg_1a ).

IF lv_lines_1a GE 1.
ELSE.
ENDIF.

" query ADR met INNER JOIN EAN - ZONDER - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
       zdsync_sap_ean~status_aansluit,
       zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
       zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
       zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
       zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
       zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
  FROM zdsync_sap_adr AS zdsync_sap_adr
  INNER JOIN zdsync_sap_ean AS zdsync_sap_ean
     ON zdsync_sap_adr~verbruiksplaats EQ zdsync_sap_ean~verbruiksplaats
    AND zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
*   AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
   INTO TABLE @DATA(lt_bg_1b).

DATA(lv_lines_1b) = lines( lt_bg_1b ).

IF lv_lines_1b GE 1.
ELSE.
ENDIF.

" query EAN met INNER JOIN ADR - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_ean AS zdsync_sap_ean
   INNER JOIN zdsync_sap_adr AS zdsync_sap_adr
     ON zdsync_sap_ean~id EQ zdsync_sap_adr~id
    AND zdsync_sap_ean~aansluitobject EQ zdsync_sap_adr~aansluitobject
    AND zdsync_sap_ean~verbruiksplaats EQ zdsync_sap_adr~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
*   AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
   INTO TABLE @DATA(lt_bg_2a).

DATA(lv_lines_2a) = lines( lt_bg_2a ).

IF lv_lines_2a GE 1.
ELSE.
ENDIF.

*     AND zdsync_sap_adr~zakenpartner EQ zdsync_sap_ean~zakenpartner

" query EAN met INNER JOIN ADR - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_ean AS zdsync_sap_ean
   INNER JOIN zdsync_sap_adr AS zdsync_sap_adr
     ON zdsync_sap_ean~aansluitobject EQ zdsync_sap_adr~aansluitobject
    AND zdsync_sap_ean~verbruiksplaats EQ zdsync_sap_adr~verbruiksplaats
   WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
*    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
   INTO TABLE @DATA(lt_bg_2b).

DATA(lv_lines_2b) = lines( lt_bg_2b ).

IF lv_lines_2b GE 1.
ELSE.
ENDIF.

*/**
*  voeg parameter ACTIE veld moet leeg zijn
*  gevulde actie velden zijn al bepaald en worden niet meer meegenomen in de query
*/*

" query ADR met INNER JOIN EAN - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
       zdsync_sap_ean~status_aansluit,
       zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
       zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
       zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
       zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
       zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
  FROM zdsync_sap_adr AS zdsync_sap_adr
  INNER JOIN zdsync_sap_ean AS zdsync_sap_ean
     ON zdsync_sap_adr~id EQ zdsync_sap_ean~id
    AND zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
    AND zdsync_sap_adr~verbruiksplaats EQ zdsync_sap_ean~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
   INTO TABLE @DATA(lt_bg_1c).

DATA(lv_lines_1c) = lines( lt_bg_1c ).

IF lv_lines_1c GE 1.
ELSE.
ENDIF.

" query ADR met INNER JOIN EAN - ZONDER - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
       zdsync_sap_ean~status_aansluit,
       zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
       zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
       zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
       zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
       zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
  FROM zdsync_sap_adr AS zdsync_sap_adr
  INNER JOIN zdsync_sap_ean AS zdsync_sap_ean
    ON  zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
    AND zdsync_sap_adr~verbruiksplaats EQ zdsync_sap_ean~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
   INTO TABLE @DATA(lt_bg_1d).

DATA(lv_lines_1d) = lines( lt_bg_1d ).

IF lv_lines_1d GE 1.
ELSE.
ENDIF.

" query EAN met INNER JOIN ADR - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_ean AS zdsync_sap_ean
   INNER JOIN zdsync_sap_adr AS zdsync_sap_adr
     ON zdsync_sap_ean~id EQ zdsync_sap_adr~id
    AND zdsync_sap_ean~aansluitobject EQ zdsync_sap_adr~aansluitobject
    AND zdsync_sap_ean~verbruiksplaats EQ zdsync_sap_adr~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
   INTO TABLE @DATA(lt_bg_2c).

DATA(lv_lines_2c) = lines( lt_bg_2c ).

IF lv_lines_2c GE 1.
ELSE.
ENDIF.


" query EAN met INNER JOIN ADR - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_ean AS zdsync_sap_ean
   INNER JOIN zdsync_sap_adr AS zdsync_sap_adr
     ON zdsync_sap_ean~aansluitobject EQ zdsync_sap_adr~aansluitobject
    AND zdsync_sap_ean~verbruiksplaats EQ zdsync_sap_adr~verbruiksplaats
   WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
     AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
   INTO TABLE @DATA(lt_bg_2d).

DATA(lv_lines_2d) = lines( lt_bg_2d ).

IF lv_lines_2d GE 1.
ELSE.
ENDIF.

*/**
*  voeg parameter ZAKENPARTNER veld toe
*  gevulde actie velden zijn al bepaald en worden niet meer meegenomen in de query
*/*

" query ADR met INNER JOIN EAN - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
       zdsync_sap_ean~status_aansluit,
       zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
       zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
       zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
       zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
       zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
  FROM zdsync_sap_adr AS zdsync_sap_adr
  INNER JOIN zdsync_sap_ean AS zdsync_sap_ean
     ON zdsync_sap_adr~id EQ zdsync_sap_ean~id
    AND zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
    AND zdsync_sap_adr~verbruiksplaats EQ zdsync_sap_ean~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
    AND zdsync_sap_adr~zakenpartner EQ '0028342284'
   INTO TABLE @DATA(lt_bg_1e).

DATA(lv_lines_1e) = lines( lt_bg_1e ).

IF lv_lines_1e GE 1.
ELSE.
ENDIF.

" query ADR met INNER JOIN EAN - ZONDER - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
       zdsync_sap_ean~status_aansluit,
       zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
       zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
       zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
       zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
       zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
  FROM zdsync_sap_adr AS zdsync_sap_adr
  INNER JOIN zdsync_sap_ean AS zdsync_sap_ean
     ON zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
    AND zdsync_sap_adr~verbruiksplaats EQ zdsync_sap_ean~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
    AND zdsync_sap_adr~zakenpartner EQ '0028342284'
   INTO TABLE @DATA(lt_bg_1f).

DATA(lv_lines_1f) = lines( lt_bg_1f ).

IF lv_lines_1f GE 1.
ELSE.
ENDIF.

" query EAN met INNER JOIN ADR - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_ean AS zdsync_sap_ean
   INNER JOIN zdsync_sap_adr AS zdsync_sap_adr
     ON zdsync_sap_ean~id EQ zdsync_sap_adr~id
    AND zdsync_sap_ean~aansluitobject EQ zdsync_sap_adr~aansluitobject
    AND zdsync_sap_ean~verbruiksplaats EQ zdsync_sap_adr~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
    AND zdsync_sap_ean~zakenpartner EQ '0028342284'
   INTO TABLE @DATA(lt_bg_2e).

DATA(lv_lines_2e) = lines( lt_bg_2e ).

IF lv_lines_2e GE 1.
ELSE.
ENDIF.


" query EAN met INNER JOIN ADR - MET - veld ID
SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_ean AS zdsync_sap_ean
   INNER JOIN zdsync_sap_adr AS zdsync_sap_adr
     ON zdsync_sap_ean~aansluitobject EQ zdsync_sap_adr~aansluitobject
    AND zdsync_sap_ean~verbruiksplaats EQ zdsync_sap_adr~verbruiksplaats
   WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
     AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
    AND zdsync_sap_ean~zakenpartner EQ '0028342284'
   INTO TABLE @DATA(lt_bg_2f).

DATA(lv_lines_2f) = lines( lt_bg_2f ).

IF lv_lines_2f GE 1.
ELSE.
ENDIF.

*/**
* andere query parameters voor vergelijking en analyse
*/*

SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_adr AS zdsync_sap_adr
   RIGHT OUTER JOIN zdsync_sap_ean AS zdsync_sap_ean
     ON zdsync_sap_adr~id EQ zdsync_sap_ean~id
    AND zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
    AND zdsync_sap_adr~zakenpartner EQ '0028342284'
   INTO TABLE @DATA(lt_bg_3a).

DATA(lv_lines_3a) = lines( lt_bg_3a ).

IF lv_lines_3a GE 1.
ELSE.
ENDIF.

SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_ean AS zdsync_sap_ean
   RIGHT OUTER JOIN zdsync_sap_adr AS zdsync_sap_adr
     ON zdsync_sap_ean~id EQ zdsync_sap_adr~id
    AND zdsync_sap_ean~aansluitobject EQ zdsync_sap_adr~aansluitobject
    AND zdsync_sap_ean~verbruiksplaats EQ zdsync_sap_adr~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
    AND zdsync_sap_ean~zakenpartner EQ '0028342284'
   INTO TABLE @DATA(lt_bg_3b).

DATA(lv_lines_3b) = lines( lt_bg_3b ).

IF lv_lines_3b GE 1.
ELSE.
ENDIF.

SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_adr AS zdsync_sap_adr
   LEFT OUTER JOIN zdsync_sap_ean AS zdsync_sap_ean
     ON zdsync_sap_adr~id EQ zdsync_sap_ean~id
    AND zdsync_sap_adr~aansluitobject EQ zdsync_sap_ean~aansluitobject
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
    AND zdsync_sap_adr~zakenpartner EQ '0028342284'
   INTO TABLE @DATA(lt_bg_4a).

DATA(lv_lines_4a) = lines( lt_bg_4a ).

IF lv_lines_4a GE 1.
ELSE.
ENDIF.

SELECT zdsync_sap_adr~aansluitobject, zdsync_sap_adr~verbruiksplaats, zdsync_sap_adr~eigenaar,
        zdsync_sap_ean~status_aansluit,
        zdsync_sap_adr~id, zdsync_sap_adr~postcode, zdsync_sap_adr~huisnummer,
        zdsync_sap_adr~huisnummer_toev, zdsync_sap_adr~straat, zdsync_sap_adr~plaats,
        zdsync_sap_adr~bag_id, zdsync_sap_adr~pand_id, zdsync_sap_adr~ao_soort,
        zdsync_sap_adr~vp_soort, zdsync_sap_adr~locatiedetails, zdsync_sap_adr~data_oorsprong,
        zdsync_sap_adr~zakenpartner, zdsync_sap_adr~type, zdsync_sap_adr~actie
   FROM zdsync_sap_ean AS zdsync_sap_ean
   LEFT OUTER JOIN zdsync_sap_adr AS zdsync_sap_adr
     ON zdsync_sap_ean~id EQ zdsync_sap_adr~id
    AND zdsync_sap_ean~aansluitobject EQ zdsync_sap_adr~aansluitobject
    AND zdsync_sap_ean~verbruiksplaats EQ zdsync_sap_adr~verbruiksplaats
  WHERE zdsync_sap_ean~status_aansluit EQ 'BG'
    AND zdsync_sap_adr~actie EQ @( VALUE #( ) )
    AND zdsync_sap_ean~zakenpartner EQ '0028342284'
   INTO TABLE @DATA(lt_bg_4b).

DATA(lv_lines_4b) = lines( lt_bg_4b ).

IF lv_lines_4b GE 1.
ELSE.
ENDIF.
