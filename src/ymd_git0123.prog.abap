*&---------------------------------------------------------------------*
*& Report YMD_043
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0123.


SELECT *
  INTO TABLE @DATA(lt_flight)
  FROM sflight.

LOOP AT lt_flight
  INTO DATA(ls_flight).

  DATA(lv_index) = sy-tabix.

  IF lv_index EQ 1.
    DATA(lv_seats) = 0.
  ENDIF.

  DATA(lv_sum_per_3) = lv_seats + ls_flight-seatsocc.
  lv_seats = lv_sum_per_3.

  IF lv_index EQ 3.
*    EXIT.
  ENDIF.

ENDLOOP.
