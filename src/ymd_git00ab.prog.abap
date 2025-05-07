*&---------------------------------------------------------------------*
*& Report ymd_git00ab
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git00ab.

* Add a description for the parameter
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE lv_text.

PARAMETERS p_zp TYPE bu_partner DEFAULT '0028063155'.
SELECTION-SCREEN  COMMENT 50(60) text_001 FOR FIELD p_zp.

SELECTION-SCREEN END OF BLOCK blk1.

INITIALIZATION.

  lv_text = |Zoek alle objecten van deze eigenaar|.

  SELECT SINGLE name_org1, name_org2
  INTO @DATA(ls_zpname)
  FROM but000
  WHERE partner EQ @p_zp.

  text_001 = |{ ls_zpname-name_org1 } { ls_zpname-name_org2 }|.

START-OF-SELECTION.
