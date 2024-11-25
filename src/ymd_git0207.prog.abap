*&---------------------------------------------------------------------*
*& Report YMD_GIT0207
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0207.

DATA : currdate      LIKE sy-datum,
       backmonths(3) TYPE n,
       newdate       LIKE sy-datum.

PARAMETERS p_date TYPE datum.

currdate = p_date.
backmonths = '1'.

CALL FUNCTION 'CCM_GO_BACK_MONTHS'
  EXPORTING
    currdate   = currdate
    backmonths = backmonths
  IMPORTING
    newdate    = newdate.

WRITE newdate.

IF 1 EQ 2.
ELSE.
ENDIF.
