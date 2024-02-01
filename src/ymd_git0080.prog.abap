*&---------------------------------------------------------------------*
*& Report YMD_211
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0080.

DATA gv_answer_verzoek TYPE c LENGTH 1.
DATA: BEGIN OF fm_table OCCURS 10.
    INCLUDE STRUCTURE spopli.
DATA: END   OF fm_table.

fm_table-varoption = 'Verzoek WEL versturen?'.
APPEND fm_table.
fm_table-varoption = 'Verzoek NIET versturen?'.
APPEND fm_table.
*    fm_table-varoption = 'SAP SEVRIVES '(003).
*    fm_table-selflag   = 'X'.
*    APPEND fm_table.

CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
  EXPORTING
*   CURSORLINE         = 1
    mark_flag          = 'X'
    mark_max           = 1
*   START_COL          = 0
*   START_ROW          = 0
    textline1          = | Het laatste verzoek is korter dan een half jaar geleden verstuurd |
*   textline2          = | Verzoek uitsturen? |
*   TEXTLINE3          = ' '
    titel              = | LET OP!|
*   DISPLAY_ONLY       = ' '
  IMPORTING
    answer             = gv_answer_verzoek
  TABLES
    t_spopli           = fm_table[]
  EXCEPTIONS
    not_enough_answers = 1
    too_much_answers   = 2
    too_much_marks     = 3
    OTHERS             = 4.

IF sy-subrc <> 0.
  " Implement suitable error handling here
ENDIF.

IF gv_answer_verzoek EQ '1'.
  " het proces loopt door en verzoek / email wordt verstuurd
ELSEIF gv_answer_verzoek EQ '2'.
*      DATA(lv_error_msg_2) = | Het laatste verzoek is korter dan een half jaar geleden verstuurd |.
*      MESSAGE lv_error_msg_2 TYPE 'W' DISPLAY LIKE 'E'.
  LEAVE LIST-PROCESSING.
ELSE.
ENDIF.
