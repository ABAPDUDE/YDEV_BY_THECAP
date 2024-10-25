*&---------------------------------------------------------------------*
*& Report YMD_GIT0197
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0197.


TYPES: BEGIN OF ty_tab,
         field1 TYPE char10,
         field2 TYPE char10,
         field3 TYPE char2,
       END OF ty_tab.

TYPES: tty_tab TYPE HASHED TABLE OF ty_tab WITH UNIQUE KEY field1.

DATA lt_tab TYPE tty_tab.
DATA ls_tab TYPE ty_tab.

START-OF-SELECTION.

  ls_tab-field1 = '1212121212'.
  ls_tab-field2 = 'CASEID1234'.
  ls_tab-field3 = '99'.

  INSERT ls_tab INTO TABLE lt_tab.

  ls_tab-field1 = '3434343434'.
  ls_tab-field2 = 'CASEID1234'.
  ls_tab-field3 = '01'.

  INSERT ls_tab INTO TABLE lt_tab.

  LOOP AT lt_tab
   INTO DATA(ls_tabline)
   WHERE ( field3 NE '90' AND
           field3 NE '99' ).
    "do something
    IF ls_tabline IS NOT INITIAL.
    ENDIF.

  ENDLOOP.
