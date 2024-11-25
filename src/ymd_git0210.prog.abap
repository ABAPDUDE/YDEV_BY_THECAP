*&---------------------------------------------------------------------*
*& Report ymd_git0210
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0210.

SELECT *
FROM zisu_poc_ean
INTO TABLE @DATA(lt_ean)
UP TO 5 ROWS
WHERE scenario EQ '02'.

READ TABLE lt_ean WITH KEY ean = '871685900014650707'
   ASSIGNING FIELD-SYMBOL(<ls_ean>).
<ls_ean>-einddatum = '20241025'.

IF 1 EQ 2.
ELSE.
ENDIF.
