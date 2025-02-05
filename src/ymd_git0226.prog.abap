*&---------------------------------------------------------------------*
*& Report ymd_git0226
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0226.

DATA gv_calendaryear  TYPE calendaryear.
DATA gv_currdate      TYPE sy-datum.
DATA gv_backmonths(3) TYPE n.
DATA gv_backdate      TYPE sy-datum.
DATA gs_vzccal        TYPE zp5_eosupply_kal.

CONSTANTS gco_year TYPE calendaryear VALUE '2025'.

SELECT-OPTIONS: so_date FOR gv_calendaryear NO-DISPLAY.

INITIALIZATION.

  so_date-low = '2025'.
  so_date-high = '2034'.
  so_date-option = 'BT'.
  so_date-sign = 'I'.
  APPEND so_date.

START-OF-SELECTION.

  SELECT *
  INTO TABLE @DATA(lt_calender)
  FROM scal_tt_date
  WHERE calendaryear IN @so_date.    " EQ @gco_year.

  SORT lt_calender BY calendardate ASCENDING.

  gv_backmonths = '1'.

  LOOP AT lt_calender
  INTO DATA(ls_calender).

    CLEAR gv_backdate.
    CLEAR gv_currdate.
    CLEAR gs_vzccal.

    IF ( ls_calender-calendardate(4) EQ '2028' OR
         ls_calender-calendardate(4) EQ '2032' OR
         ls_calender-calendardate(4) EQ '2036' OR
         ls_calender-calendardate(4) EQ '2040' OR
         ls_calender-calendardate(4) EQ '2044' OR
         ls_calender-calendardate(4) EQ '2048' OR
         ls_calender-calendardate(4) EQ '2052' OR
         ls_calender-calendardate(4) EQ '2056' OR
         ls_calender-calendardate(4) EQ '2060' OR
         ls_calender-calendardate(4) EQ '2064' OR
         ls_calender-calendardate(4) EQ '2068' ).

      DATA(lv_schrikkeljaar) = abap_true.

    ELSE.
      lv_schrikkeljaar = abap_false.
    ENDIF.

    gs_vzccal-datum = ls_calender-calendardate.

    gv_currdate = ls_calender-calendardate.

    CALL FUNCTION 'CCM_GO_BACK_MONTHS'
      EXPORTING
        currdate   = gv_currdate
        backmonths = gv_backmonths
      IMPORTING
        newdate    = gv_backdate.

    gs_vzccal-effectueringsdatum_1 = gv_backdate.
    gs_vzccal-start_factuur_tijdvak = gv_backdate.
    gs_vzccal-einde_factuur_tijdvak = ( ls_calender-calendardate - 1 ).
    gs_vzccal-aantal_dagen_tijdvak = ( gs_vzccal-einde_factuur_tijdvak - gs_vzccal-start_factuur_tijdvak ) + 1.

    IF ls_calender-calendardate+4 EQ '0228'.

      IF lv_schrikkeljaar EQ abap_false.

        gs_vzccal-effectueringsdatum_1 = gv_backdate.
        gs_vzccal-effectueringsdatum_2 = ( gv_backdate + 1 ).
        gs_vzccal-effectueringsdatum_3 = ( gv_backdate + 2 ).
        gs_vzccal-effectueringsdatum_4 = ( gv_backdate + 3 ).

        gs_vzccal-einddatum_vorige_1 = ( gv_backdate - 1 ).

      ELSE.
        gs_vzccal-einddatum_vorige_1 = ( gv_backdate - 1 ).
      ENDIF.

    ELSEIF ls_calender-calendardate+4 EQ '0229'.

      IF lv_schrikkeljaar EQ abap_true.

        gs_vzccal-effectueringsdatum_1 = gv_backdate.
        gs_vzccal-effectueringsdatum_2 = ( gv_backdate + 1 ).
        gs_vzccal-effectueringsdatum_3 = ( gv_backdate + 2 ).

        gs_vzccal-einddatum_vorige_1 = ( gv_backdate - 1 ).

      ENDIF.

    ELSEIF ls_calender-calendardate+4 EQ '0301'.

      IF  lv_schrikkeljaar EQ abap_false.
        gs_vzccal-einddatum_vorige_1 = ( gv_backdate - 1 ).
        gs_vzccal-einddatum_vorige_2 =  ( gv_backdate - 2 ).
        gs_vzccal-einddatum_vorige_3 =  ( gv_backdate - 3 ).
        gs_vzccal-einddatum_vorige_4 =  ( gv_backdate - 4 ).
      ELSEIF  lv_schrikkeljaar EQ abap_true.
        gs_vzccal-einddatum_vorige_1 = ( gv_backdate - 1 ).
        gs_vzccal-einddatum_vorige_2 =  ( gv_backdate - 2 ).
        gs_vzccal-einddatum_vorige_3 =  ( gv_backdate - 3 ).
      ELSE.
      ENDIF.

    ELSE.

      gs_vzccal-einddatum_vorige_1 = ( gv_backdate - 1 ).

    ENDIF.

*/**
*  maart heeft 2 of 3 dagen waar geen acties nodig zijn
*  afhankelijk van het wel/geen schrikkeljaar
*/*
    IF ( ls_calender-calendardate+4 EQ '0329' OR
         ls_calender-calendardate+4 EQ '0330' OR
         ls_calender-calendardate+4 EQ '0331' AND
         lv_schrikkeljaar EQ abap_false ).

      CLEAR gs_vzccal.
      gs_vzccal-datum = ls_calender-calendardate.

    ELSEIF ( ls_calender-calendardate+4 EQ '0330' OR
             ls_calender-calendardate+4 EQ '0331' AND
             lv_schrikkeljaar EQ abap_true ).

      CLEAR gs_vzccal.
      gs_vzccal-datum = ls_calender-calendardate.

    ELSE.
    ENDIF.

    CASE  ls_calender-calendardate+4.
      WHEN '0501'.
        gs_vzccal-effectueringsdatum_2 = ( gv_backdate - 1 ).
        gs_vzccal-einddatum_vorige_2 =  ( gv_backdate - 2 ).
      WHEN '0531'.
        CLEAR gs_vzccal.  " DO NOTHING!
        gs_vzccal-datum = ls_calender-calendardate.
      WHEN '0701'.
        gs_vzccal-effectueringsdatum_2 = ( gv_backdate - 1 ).
        gs_vzccal-einddatum_vorige_2 =  ( gv_backdate - 2 ).
      WHEN '0731'.
        CLEAR gs_vzccal.  " DO NOTHING!
        gs_vzccal-datum = ls_calender-calendardate.
      WHEN '1001'.
        gs_vzccal-effectueringsdatum_2 = ( gv_backdate - 1 ).
        gs_vzccal-einddatum_vorige_2 =  ( gv_backdate - 2 ).
      WHEN '1031'.
        CLEAR gs_vzccal.  " DO NOTHING!
        gs_vzccal-datum = ls_calender-calendardate.
      WHEN '1201'.
        gs_vzccal-effectueringsdatum_2 = ( gv_backdate - 1 ).
        gs_vzccal-einddatum_vorige_2 =  ( gv_backdate - 2 ).
      WHEN '1231'.
        CLEAR gs_vzccal.  " DO NOTHING!
        gs_vzccal-datum = ls_calender-calendardate.
      WHEN OTHERS.
    ENDCASE.

    MODIFY zp5_eosupply_kal FROM gs_vzccal.

    CLEAR lv_schrikkeljaar.
    CLEAR ls_calender.

  ENDLOOP.
