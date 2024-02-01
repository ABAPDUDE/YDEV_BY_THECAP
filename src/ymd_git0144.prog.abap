*&---------------------------------------------------------------------*
*& Report YMD_044
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0144.

TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbak-vbeln,
         kunnr TYPE vbak-kunnr,
       END OF ty_vbak.
TYPES tty_vbak TYPE STANDARD TABLE OF ty_vbak.

TYPES: BEGIN OF ty_out,
         vbeln    TYPE vbak-vbeln,
         customer TYPE vbak-kunnr,
       END OF ty_out.
TYPES tty_out TYPE STANDARD TABLE OF ty_out.

DATA lt_vbak TYPE tty_vbak.
DATA lt_out TYPE tty_out.

SELECT * UP TO 2 ROWS
  FROM vbak
  INTO CORRESPONDING FIELDS OF TABLE lt_vbak.


lt_out[] = CORRESPONDING #( lt_vbak[] MAPPING customer = kunnr ).

IF 1 EQ 2.

ENDIF.
