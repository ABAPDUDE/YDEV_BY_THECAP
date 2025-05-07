*&---------------------------------------------------------------------*
*& Report YMD_GIT0228
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0228.

DATA lv_name_text TYPE ad_namtext.
DATA(lv_usnam) = 'AL24361'.

SELECT SINGLE adrp~name_text INTO lv_name_text
  FROM usr21 JOIN adrp ON usr21~persnumber = adrp~persnumber AND
                          adrp~date_from   = '00010101'      AND
                          adrp~nation      = ''
  WHERE usr21~bname = lv_usnam.

IF 1 EQ 2.

ENDIF.
