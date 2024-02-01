*&---------------------------------------------------------------------*
*& Report YMD_058
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0158.


DATA lv_method_name1 TYPE string VALUE 'GV_EN_DE_REST'.
DATA lv_method_name2 TYPE string VALUE 'SEND_EN_DE_REST'.

IF lv_method_name1 CS |GV_|.
  WRITE: |herkenning GV_ gelukt!|.
ELSE.
  WRITE: |herkenning niet gelukt maar had wel gemoeten!|.
ENDIF.
SKIP 2.
IF lv_method_name2 CS |GV_|.
  WRITE: |herkenning maar dat zou helemaal niet moeten kunnen!|.
ELSE.
  WRITE: |geen herkenning dus gelukt!|.
ENDIF.
