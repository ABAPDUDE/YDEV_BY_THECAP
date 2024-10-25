*&---------------------------------------------------------------------*
*& Report YMD_GIT0203
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0203.

DATA: BEGIN OF seats,
        carrid   TYPE sflight-carrid,
        connid   TYPE sflight-connid,
        seatsocc TYPE sflight-seatsocc,
      END OF seats.

DATA seats_tab LIKE HASHED TABLE OF seats
               WITH UNIQUE KEY carrid connid.

SELECT carrid, connid, seatsocc
       FROM sflight
       INTO @seats
       WHERE carrid EQ 'AA'.

  COLLECT seats INTO seats_tab.

ENDSELECT.

IF 1 EQ 2.
ENDIF.
