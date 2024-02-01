*&---------------------------------------------------------------------*
*& Report YMD_0028
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0028.


SELECT caseid
  INTO  TABLE @DATA(lt_caseid)
    FROM zisu_poc_case
UP TO 3 ROWS.

DATA(ls_caseid) = lt_caseid[ 1 ].

IF ls_caseid IS NOT INITIAL.
  WRITE:/ ls_caseid-caseid.
ELSE.

ENDIF.


CLEAR lt_caseid[].


IF lt_caseid[] IS INITIAL.

ELSE.

  ls_caseid = lt_caseid[ 1 ].

  IF ls_caseid IS NOT INITIAL.
    WRITE:/ ls_caseid-caseid.
  ELSE.

  ENDIF.

ENDIF.

IF 1 EQ 2.
ENDIF.
