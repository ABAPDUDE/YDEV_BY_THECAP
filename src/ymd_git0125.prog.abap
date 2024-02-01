*&---------------------------------------------------------------------*
*& Report YMD_040
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0125.


SELECT *
  INTO TABLE @DATA(lt_flight)
  FROM sflight
  WHERE carrid EQ 'AA'
    AND connid EQ '0017'
    AND fldate EQ '20220102'.

cl_demo_output=>display( lt_flight ).

READ TABLE lt_flight
INTO DATA(ls_flight)
INDEX 1.

ls_flight-seatsocc = '315'.
ls_flight-paymentsum = '112500'.

MODIFY sflight FROM ls_flight.

IF sy-subrc EQ 0.
  COMMIT WORK AND WAIT.

  WRITE: /10 'bestaande regel gewijzigd'.

ELSE.
ENDIF.
