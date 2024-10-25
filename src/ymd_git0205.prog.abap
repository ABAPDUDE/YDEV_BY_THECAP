*&---------------------------------------------------------------------*
*& Report YMD_GIT0205
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0205.

TYPES: BEGIN OF ty_p5,
         ean         TYPE ext_ui,
         verbruik_t1 TYPE zverbruik_t1,
         verbruik_t2 TYPE zverbruik_t1,
       END OF ty_p5.

TYPES: BEGIN OF ty_sum,
         ean         TYPE ext_ui,
         verbruik_t1 TYPE zp5_totaal_verbruik,
         verbruik_t2 TYPE zp5_totaal_verbruik,
       END OF ty_sum.

TYPES tty_sum TYPE STANDARD TABLE OF ty_sum WITH NON-UNIQUE KEY ean.
TYPES tty_p5 TYPE STANDARD TABLE OF ty_p5 WITH NON-UNIQUE KEY ean.

*   DATA lt_p5  TYPE ztt_p5meetdata.
DATA lt_sum TYPE tty_sum.
DATA lt_p5  TYPE tty_p5.
DATA lt_meetdata TYPE tty_sum.
DATA ls_meetdata TYPE ty_sum.


START-OF-SELECTION.

  DATA iv_ean TYPE ext_ui VALUE '871685900014352113'.
  DATA iv_product TYPE sparte VALUE 'N'.

  SELECT ean verbruik_t1 verbruik_t2
    FROM zp5_meetdata
    INTO TABLE lt_p5
    WHERE ean EQ iv_ean
      AND product EQ iv_product
      AND status EQ '99'.

*  lt_meetdata[] = lt_p5[].
*  lt_meetdata = CORRESPONDING tty_p5( lt_p5 ).
*
*  LOOP AT lt_meetdata INTO DATA(ls_meetdata).
*
*    COLLECT ls_meetdata INTO lt_sum.
*
*  ENDLOOP.

  LOOP AT lt_p5
    INTO DATA(ls_p5).

    ls_meetdata-ean = ls_p5-ean.
    ls_meetdata-verbruik_t1 = ls_p5-verbruik_t1.
    ls_meetdata-verbruik_t2 = ls_p5-verbruik_t2.

    COLLECT ls_meetdata INTO lt_sum.

  ENDLOOP.

  IF 1 EQ 2.
  ENDIF.
