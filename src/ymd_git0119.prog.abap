*&---------------------------------------------------------------------*
*& Report YMD_039
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0119.


SELECT *
  INTO TABLE @DATA(lt_flight)
  FROM sflight
  WHERE carrid EQ 'AA'
    AND connid EQ '0017'
    AND fldate EQ '20200827'.

cl_demo_output=>display( lt_flight ).

READ TABLE lt_flight
INTO DATA(ls_flight)
INDEX 1.

ls_flight-fldate = '20220102'.

MODIFY sflight FROM ls_flight.

IF sy-subrc EQ 0.
  COMMIT WORK AND WAIT.

  WRITE: /10 'nieuwe regel toegevoegd'.

ELSE.
ENDIF.
