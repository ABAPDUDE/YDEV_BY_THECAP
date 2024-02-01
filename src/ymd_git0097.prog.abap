*&---------------------------------------------------------------------*
*& Report YMD_017
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0097.

DATA: lv_date    TYPE sy-datum,

      lv_msg(50) TYPE c.
lv_date = '20051301'.

CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
  EXPORTING
    date                      = lv_date
  EXCEPTIONS
    plausibility_check_failed = 1
    OTHERS                    = 2.


IF sy-subrc <> 0.

  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_msg.

  WRITE: lv_msg.

ENDIF.
