*&---------------------------------------------------------------------*
*& Report YMD_0027
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0027.

CONSTANTS mco_verwijderen           TYPE zsoort_werk VALUE 'VW'.
CONSTANTS mco_verwijderen_hb        TYPE zsoort_werk VALUE 'VWH'.
CONSTANTS mco_verwijderen_wi        TYPE zsoort_werk VALUE 'VWWI'.
CONSTANTS mco_nieuweaansluiting     TYPE zsoort_werk VALUE 'NA'.
CONSTANTS mco_nieuweaansluiting_hb  TYPE zsoort_werk VALUE 'NAH'.
CONSTANTS mco_nieuweaansluiting_ose TYPE zsoort_werk VALUE 'NAOSE'.

CONSTANTS mco_ordertype_miaa        TYPE auart VALUE 'ZMI1'.
CONSTANTS mco_aansluitobj_isu       TYPE fltyp VALUE 'A'.

* DATA lra_soort_werk TYPE RANGE OF zsoort_werk.
TYPES:
  BEGIN OF ty_soortwerk,
    sign   TYPE ddsign,
    option TYPE ddoption,
    low    TYPE zsoort_werk,
    high   TYPE zsoort_werk,
  END OF ty_soortwerk .
TYPES: tty_soortwerk TYPE STANDARD TABLE OF ty_soortwerk.

DATA ra_soortwerk TYPE tty_soortwerk.

ra_soortwerk = VALUE #( BASE ra_soortwerk ( sign = 'I' option = 'EQ' low = mco_verwijderen )
                                          ( sign = 'I' option = 'EQ' low = mco_verwijderen_hb )
                                          ( sign = 'I' option = 'EQ' low = mco_verwijderen_wi )
                                          ( sign = 'I' option = 'EQ' low = mco_nieuweaansluiting )
                                          ( sign = 'I' option = 'EQ' low = mco_nieuweaansluiting_hb )
                                          ( sign = 'I' option = 'EQ' low = mco_nieuweaansluiting_ose )
                                           ).

SELECT zas_art_afleid~matnr, zas_art_afleid~begda, zas_art_afleid~endda,
       zas_art_afleid~soort_werk, zas_art_afleid~discipline, makt~maktx
  INTO TABLE @DATA(lt_soortwerk)
  FROM zas_art_afleid AS zas_art_afleid
  INNER JOIN makt AS makt
  ON makt~matnr = zas_art_afleid~matnr
  WHERE zas_art_afleid~soort_werk IN @ra_soortwerk
    AND ( zas_art_afleid~begda LE @sy-datum AND
          zas_art_afleid~endda GE @sy-datum ).

SORT lt_soortwerk BY soort_werk ASCENDING discipline ASCENDING.

DATA(lv_lines_sw) = lines( lt_soortwerk ).
IF lv_lines_sw GE 1.

  cl_demo_output=>display( lt_soortwerk ).

ENDIF.
*/**
* test select op VBAP met de geselecteerde materiaalnummers
* vaststellen hoeveel regels er in tabel VBAP zijn voor een bepaalde periode
*/*
SELECT vbeln, posnr, matnr
  FROM vbap
  INTO TABLE @DATA(lt_soitem)
      FOR ALL ENTRIES IN @lt_soortwerk
      WHERE matnr EQ @lt_soortwerk-matnr
        AND erdat GE '20230101'.

DATA(lv_lines_soitem) = lines( lt_soitem ).
IF lv_lines_soitem GE 1.

  cl_demo_output=>display( lt_soitem ).

ENDIF.
*/**
* test select join tabel vbap en tabel aufk
* vaststellen hoeveel regels er in tabel VBAP en AUFK zijn voor een bepaalde periode
*
*
* Resulting set for outer join
* The outer join basically creates the same resulting set as the inner join,
* with the difference that at least one line is created in the resulting set
* for every selected line on the left-hand side, even if no line on the right-hand side
* fulfils the join_cond condition.
* The columns on the right-hand side that do not fulfil the join_cond condition are filled with null values.
*/*
SELECT vbap~vbeln, vbap~posnr, vbap~matnr,
       aufk~aufnr, aufk~auart, aufk~zzvbeln, aufk~zzposnr
*         zviauf_afvc~tplnr
    FROM vbap AS vbap
    LEFT OUTER JOIN aufk AS aufk
    ON aufk~zzvbeln EQ vbap~vbeln
*    AND aufk~zzposnr EQ vbap~posnr
*      INNER JOIN zviauf_afvc AS zviauf_afvc
*      ON zviauf_afvc~aufnr EQ aufk~aufnr
    FOR ALL ENTRIES IN @lt_soortwerk
    WHERE vbap~matnr EQ @lt_soortwerk-matnr
      AND vbap~erdat GE '20230101'
*        AND aufk~auart EQ @mco_ordertype_miaa
*        AND zviauf_afvc~tplnr NE @( VALUE #( ) )
    INTO TABLE @DATA(lt_sopos).

DATA(lv_lines_sopos) = lines( lt_sopos ).
IF lv_lines_sopos GE 1.

  cl_demo_output=>display( lt_sopos ).

*/**
* test select join tabel vbap en tabel aufk en view zviauf_afvc
* vaststellen hoeveel regels er in tabel VBAP en AUFK en zviauf_afvc zijn voor een bepaalde periode
* doel is om via het Servie Order nummer aan de bbijbehorende functieplaats te komen
*/*
  SELECT vbap~vbeln, vbap~posnr, vbap~matnr,
       aufk~aufnr, aufk~auart, aufk~zzvbeln, aufk~zzposnr,
       zviauf_afvc~tplnr
    FROM vbap AS vbap
    LEFT OUTER JOIN aufk AS aufk
    ON aufk~zzvbeln EQ vbap~vbeln
*    AND aufk~zzposnr EQ vbap~posnr
    LEFT OUTER JOIN zviauf_afvc AS zviauf_afvc
    ON zviauf_afvc~aufnr EQ aufk~aufnr
    FOR ALL ENTRIES IN @lt_soortwerk
    WHERE vbap~matnr EQ @lt_soortwerk-matnr
      AND vbap~erdat GE '20230101'
      AND aufk~auart EQ @mco_ordertype_miaa
      AND zviauf_afvc~tplnr NE @( VALUE #( ) )
    INTO TABLE @DATA(lt_sopos2).

  DATA(lv_lines_sopos2) = lines( lt_sopos2 ).
  IF lv_lines_sopos2 GE 1.

    cl_demo_output=>display( lt_sopos2 ).

*/**
* test select join tabel iflot en iloa en evbs en adrc
* vaststellen hoeveel regels er in zijn voor een bepaalde periode
* doel is om via het functieplaats bij de verbruiksplaats te komen
*/*
    SELECT iflot~tplnr, iflot~bagid_adresseerb_obj, iflot~bagid_pand, iflot~aosoort,
          iloa~iloan, iloa~adrnr,
          evbs~vstelle, evbs~haus, evbs~vbsart, evbs~eigent, evbs~lgzusatz,
          adrc~post_code1, adrc~house_num1, adrc~house_num2, adrc~street, adrc~city1
       INTO TABLE @DATA(lt_link)
       FROM iflot AS iflot
       INNER JOIN iloa AS iloa
       ON iflot~iloan EQ iloa~iloan AND
          iflot~tplnr EQ iloa~tplnr
       INNER JOIN evbs AS evbs
       ON evbs~haus EQ iflot~tplnr
       INNER JOIN adrc AS adrc
       ON adrc~addrnumber EQ iloa~adrnr
       FOR ALL ENTRIES IN @lt_sopos2
       WHERE iflot~tplnr EQ @lt_sopos2-tplnr
         AND iflot~fltyp EQ @mco_aansluitobj_isu.

    DATA(lv_lines_link) = lines( lt_link ).
    IF lv_lines_link GE 1.

      cl_demo_output=>display( lt_link ).

      SELECT zisu_poc_case~caseid, zisu_poc_case~verbruiksplaats, zisu_poc_ean~ean
        INTO TABLE @DATA(lt_graal)
        FROM zisu_poc_case AS zisu_poc_case
        INNER JOIN zisu_poc_ean AS zisu_poc_ean
        ON zisu_poc_ean~caseid EQ zisu_poc_case~caseid
        FOR ALL ENTRIES IN @lt_link
           WHERE zisu_poc_case~verbruiksplaats EQ @lt_link-vstelle.

      DATA(lv_lines_graal) = lines( lt_graal ).

      IF lv_lines_graal GE 1.

        cl_demo_output=>display( lt_graal ).

      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
