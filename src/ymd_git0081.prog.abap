*&---------------------------------------------------------------------*
*& Report YMD_210
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0081.

DATA character_tab TYPE STANDARD TABLE OF char1.
DATA alpha TYPE string VALUE 'ABCDEFGHIJKLM'.

CALL FUNCTION 'SWA_STRING_TO_TABLE'
  EXPORTING
    character_string = alpha
    line_size        = 1
  IMPORTING
    character_table  = character_tab
  EXCEPTIONS
    OTHERS           = 0.

DATA(lv_lines) = lines( character_tab ).
