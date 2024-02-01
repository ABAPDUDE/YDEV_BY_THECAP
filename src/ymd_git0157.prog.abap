*&---------------------------------------------------------------------*
*& Report YMD_057
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0157.

DATA lv_fysieke_status TYPE char3.
lv_fysieke_status = 'IBD'.

IF ( lv_fysieke_status NE 'IBD'
  AND lv_fysieke_status NE 'UBD' ).
  IF 1 EQ 2.
  ELSE.
  ENDIF.

ELSEIF ( lv_fysieke_status NE 'IBD'
  OR lv_fysieke_status NE 'UBD' ).
  " als de status ongelijk is aan "In Bedrijf" of "Uit Bedrijf" dan hoeft er geen case te worden aangemaakt              zcl_isu_poc_fw=>gv_close_message( ls_msg ).
  IF 1 EQ 2.
  ELSE.
  ENDIF.

ELSE.
  IF 1 EQ 2.
  ELSE.
  ENDIF.
ENDIF.
