*&---------------------------------------------------------------------*
*& Report YMD_022
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0102.

DATA lt_eastl TYPE isu07_ieastl.

LOOP AT lt_eastl ASSIGNING FIELD-SYMBOL(<eastl>)
   WHERE bis = '99991231'.                         " alleen actieve

  SELECT SINGLE equnr
   INTO @data(lv_equnr)
   FROM egerh
   WHERE logiknr = @<eastl>-logiknr
     AND bis     = '99991231'.

ENDLOOP.

IF <eastl> IS ASSIGNED.
  " Controleer of de installatie aanwezig is
  IF <eastl>-anlage IS NOT INITIAL.

    " Haal het product van de installatie op
    SELECT SINGLE sparte
      INTO @DATA(lv_sparte)
      FROM eanl
      WHERE anlage = @<eastl>-anlage.
  ELSE.
    WRITE: 'nothing selected'.
  ENDIF.
ELSE.
  WRITE: 'not assigned!'.
ENDIF.
