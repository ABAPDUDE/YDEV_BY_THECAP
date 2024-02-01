*&---------------------------------------------------------------------*
*& Report YMD_084
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0135.

DATA lv_value TYPE char3.
DATA lv_value_1 TYPE char3 VALUE '123'.


lv_value = lv_value_1.

" wanneer je OR gebruikt dan is de vergelijking 'waar' wanneer een van de vergelijkignen voldoet.
" in dit geval is '123' ongelijk aan '345' en dan voldoet de vergelijking al
IF ( lv_value NE |456|
  OR lv_value NE |123| ).

  WRITE /5 | OR -> d1t werkt niet | .

ELSE.
ENDIF.

IF ( lv_value NE |456|
  AND lv_value NE |123| ).
ELSE.

  WRITE /5 | AND -> dit werkt | .

ENDIF.
