*&---------------------------------------------------------------------*
*& Report YMD_0020
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0032.

TYPES: BEGIN OF ty_zpnr,
         partner TYPE bu_partner,
       END OF ty_zpnr.

TYPES tty_zpnr TYPE STANDARD TABLE OF ty_zpnr WITH NON-UNIQUE KEY partner.

TYPES: BEGIN OF ty_zpname,
         partner TYPE bu_partner,
         name    TYPE bu_nameor1,
       END OF ty_zpname.

TYPES tty_zpname TYPE STANDARD TABLE OF ty_zpname WITH NON-UNIQUE KEY partner.

DATA lt_zpname TYPE tty_zpname.
DATA lt_zpnr TYPE tty_zpnr.

SELECT eigenaar, zakenpartner
    INTO TABLE @DATA(lt_sapnr)
    FROM zdsync_sap_adr.

SORT lt_sapnr BY eigenaar zakenpartner.

DELETE ADJACENT DUPLICATES FROM lt_sapnr COMPARING eigenaar zakenpartner.

LOOP AT lt_sapnr
   INTO DATA(ls_sapnr).

  lt_zpnr = VALUE #( BASE lt_zpnr ( partner = ls_sapnr-zakenpartner )
                                  (  partner = ls_sapnr-eigenaar ) ).

ENDLOOP.

DELETE lt_zpnr WHERE partner IS INITIAL.
SORT lt_zpnr BY partner.
DELETE ADJACENT DUPLICATES FROM lt_zpnr COMPARING partner.


SELECT partner name_org1
  INTO TABLE lt_zpname
  FROM but000
  FOR ALL ENTRIES IN lt_zpnr
  WHERE partner EQ lt_zpnr-partner.

  IF 1 EQ 2
    .
  ENDIF.
