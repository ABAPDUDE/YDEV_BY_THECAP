*&---------------------------------------------------------------------*
*& Report YMD_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0036.

SELECT z1~aanv_code, z1~aanv_rvnr, z1~p_key_volgnr, z1~type, z2~aanv_dienst, z2~aanv_dienst_g, z1~specificatie, z1~ean_code
    FROM zaanvr_producten AS z1
    INNER JOIN zaanvragen AS z2
    ON z1~aanv_code EQ z2~aanv_code
    AND z1~aanv_rvnr EQ  z2~aanv_rvnr
    INTO TABLE @DATA(lt_zaanvr_producten1)
    WHERE z2~vbeln      EQ ''
      AND z1~dienstcode EQ 'VW'.

DELETE ADJACENT DUPLICATES FROM lt_zaanvr_producten1 COMPARING aanv_code.

SELECT z1~aanv_code, z1~aanv_rvnr, z1~p_key_volgnr, z1~type, z2~aanv_dienst, z2~aanv_dienst_g, z1~specificatie, z1~ean_code
    FROM zaanvr_producten AS z1
    INNER JOIN zaanvragen AS z2
    ON z1~aanv_code EQ z2~aanv_code
    AND z1~aanv_rvnr EQ  z2~aanv_rvnr
    INTO TABLE @DATA(lt_zaanvr_producten2)
    WHERE z2~vbeln         EQ ''
      AND z1~dienstcode EQ 'vw'
      AND z1~ean_code      NE ''.

* DELETE ADJACENT DUPLICATES FROM lt_zaanvr_producten2 COMPARING aanv_code.

SELECT z1~aanv_code, z1~aanv_rvnr, z1~p_key_volgnr, z1~type, z2~aanv_dienst, z2~aanv_dienst_g, z1~specificatie, z1~ean_code
    FROM zaanvr_producten AS z1
    INNER JOIN zaanvragen AS z2
    ON z1~aanv_code EQ z2~aanv_code
    AND z1~aanv_rvnr EQ  z2~aanv_rvnr
    INTO TABLE @DATA(lt_zaanvr_producten3)
    WHERE z1~type          EQ 2
      AND z2~vbeln         EQ ''
      AND z1~dienstcode EQ 'vw'.

DELETE ADJACENT DUPLICATES FROM lt_zaanvr_producten3 COMPARING aanv_code.

SELECT z1~aanv_code, z1~aanv_rvnr, z1~p_key_volgnr, z1~type, z2~aanv_dienst, z2~aanv_dienst_g, z1~specificatie, z1~ean_code
    FROM zaanvr_producten AS z1
    INNER JOIN zaanvragen AS z2
    ON z1~aanv_code EQ z2~aanv_code
*    AND z1~aanv_rvnr EQ  z2~aanv_rvnr
    INTO TABLE @DATA(lt_zaanvr_producten4)
    WHERE z1~type          EQ 2
      AND z2~vbeln         EQ ''
      AND z1~dienstcode EQ 'vw'.

DELETE ADJACENT DUPLICATES FROM lt_zaanvr_producten4 COMPARING aanv_code.

IF lt_zaanvr_producten2 IS NOT INITIAL.

  DATA: gr_table TYPE REF TO cl_salv_table.

  " Generate an instance of the ALV table object
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = gr_table
    CHANGING
      t_table      = lt_zaanvr_producten2.

*Display the ALV table.
  gr_table->display( ).
ENDIF.

SORT lt_zaanvr_producten2 BY aanv_code p_key_volgnr DESCENDING.
DELETE ADJACENT DUPLICATES FROM lt_zaanvr_producten2 COMPARING aanv_code.

IF lt_zaanvr_producten2 IS NOT INITIAL.

* DATA: gr_table TYPE REF TO cl_salv_table.

  " Generate an instance of the ALV table object
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = gr_table
    CHANGING
      t_table      = lt_zaanvr_producten2.

*Display the ALV table.
  gr_table->display( ).
ENDIF.
