*&---------------------------------------------------------------------*
*& Report YMD_GIT0203
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0204.

DATA: BEGIN OF seats,
        carrid   TYPE sflight-carrid,
        connid   TYPE sflight-connid,
        seatsocc TYPE sflight-seatsocc,
      END OF seats.

DATA seats_tab LIKE HASHED TABLE OF seats
               WITH UNIQUE KEY carrid connid.

SELECT carrid, connid, seatsocc
  INTO TABLE @DATA(lt_seats)
       FROM sflight.


LOOP AT lt_seats
  INTO DATA(ls_seats).

  COLLECT ls_seats INTO seats_tab.

ENDLOOP.

IF 1 EQ 2.
ENDIF.
