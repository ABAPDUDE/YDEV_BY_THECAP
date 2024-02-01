*&---------------------------------------------------------------------*
*& Report YMD_042
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0122.

SELECT *
  INTO TABLE @DATA(lt_status)
  FROM zisu_poc_status.

SELECT *
  INTO TABLE @DATA(lt_text)
  FROM zisu_poc_statust.

LOOP AT lt_text
  ASSIGNING FIELD-SYMBOL(<fs_text>).

  READ TABLE lt_status
  WITH KEY status = <fs_text>-status
  INTO DATA(ls_status).

  IF ls_status-omschrijving IS NOT INITIAL.
    <fs_text>-omschrijving = ls_status-omschrijving.
  ELSE.
    CONTINUE.
  ENDIF.

ENDLOOP.

MODIFY zisu_poc_statust FROM TABLE lt_text.
IF sy-subrc EQ 0.
  COMMIT WORK AND WAIT.
ELSE.
  WRITE: /5 'something went wrong!'.
ENDIF.
