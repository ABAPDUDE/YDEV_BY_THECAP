*&---------------------------------------------------------------------*
*& Report ymd_102
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0068.

DATA lv_field TYPE numc10.
lv_field = 'nietinfile'.

TYPES: BEGIN OF ty_zp,
         tplnr  TYPE tplnr,
         eigent TYPE e_gpartner,
       END OF ty_zp.
TYPES: tty_zp TYPE SORTED TABLE OF ty_zp WITH UNIQUE KEY tplnr eigent.

CONSTANTS mc_aansluitobj_isu TYPE fltyp VALUE 'A' ##NO_TEXT.

DATA lt_zp TYPE tty_zp.
DATA ls_zp TYPE ty_zp.

ls_zp-tplnr  = '8007319334'.
ls_zp-eigent = '0021448641'.
APPEND ls_zp TO lt_zp.

ls_zp-tplnr  = '8007319371'.
ls_zp-eigent = '0021448641'.
APPEND ls_zp TO lt_zp.

ls_zp-tplnr  = '8007330049'.
ls_zp-eigent = '0021448641'.
APPEND ls_zp TO lt_zp.

SELECT iflot~tplnr, iflot~bagid_adresseerb_obj, iflot~bagid_pand, iflot~aosoort, iflotx~pltxt,
          iloa~iloan, iloa~adrnr,
          evbs~vstelle, evbs~haus, evbs~vbsart, evbs~eigent,
          adrc~post_code1, adrc~house_num1, adrc~house_num2, adrc~street, adrc~city1
        INTO TABLE @DATA(lt_join)
        FROM adrc AS adrc
         INNER JOIN iloa AS iloa
        ON adrc~addrnumber EQ iloa~adrnr
        INNER JOIN evbs AS evbs
        ON evbs~haus EQ iloa~tplnr
        INNER JOIN iflot AS iflot
        ON iflot~iloan EQ iloa~iloan AND
           iflot~tplnr EQ iloa~tplnr
        INNER JOIN iflotx AS iflotx
        ON iflotx~tplnr EQ iflot~tplnr AND
           iflotx~spras EQ @sy-langu
*           FOR ALL ENTRIES IN @me->mt_data_nobagid
        FOR ALL ENTRIES IN @lt_zp
        WHERE evbs~eigent = @lt_zp-eigent
          AND iflot~fltyp EQ @mc_aansluitobj_isu.

SELECT iflot~tplnr, iflot~bagid_adresseerb_obj, iflot~bagid_pand, iflot~aosoort,
          iloa~iloan, iloa~adrnr,
          evbs~vstelle, evbs~haus, evbs~vbsart, evbs~eigent,
          adrc~post_code1, adrc~house_num1, adrc~house_num2, adrc~street, adrc~city1
        INTO TABLE @DATA(lt_join2)
       FROM iflot AS iflot
          INNER JOIN iloa AS iloa
          ON iflot~iloan EQ iloa~iloan AND
             iflot~tplnr EQ iloa~tplnr
          INNER JOIN evbs AS evbs
          ON evbs~haus EQ iflot~tplnr
          INNER JOIN adrc AS adrc
          ON adrc~addrnumber EQ iloa~adrnr
        FOR ALL ENTRIES IN @lt_zp
        WHERE evbs~eigent = @lt_zp-eigent
          AND iflot~fltyp EQ @mc_aansluitobj_isu.

SELECT iflot~tplnr, iflot~bagid_adresseerb_obj, iflot~bagid_pand, iflot~aosoort,
          iloa~iloan, iloa~adrnr,
          evbs~vstelle, evbs~haus, evbs~vbsart, evbs~eigent,
          adrc~post_code1, adrc~house_num1, adrc~house_num2, adrc~street, adrc~city1
        INTO TABLE @DATA(lt_join3)
       FROM evbs AS evbs
          INNER JOIN iflot AS iflot
          ON evbs~haus EQ iflot~tplnr
          INNER JOIN iloa AS iloa
          ON iflot~iloan EQ iloa~iloan AND
             iflot~tplnr EQ iloa~tplnr
          INNER JOIN adrc AS adrc
          ON adrc~addrnumber EQ iloa~adrnr
        FOR ALL ENTRIES IN @lt_zp
        WHERE evbs~eigent = @lt_zp-eigent
          AND iflot~fltyp EQ @mc_aansluitobj_isu.

* DELETE ADJACENT DUPLICATES FROM lt_join COMPARING ALL FIELDS.

LOOP AT lt_zp
     INTO ls_zp.

  READ TABLE lt_join
  WITH KEY tplnr = ls_zp-tplnr
  TRANSPORTING NO FIELDS.

  DATA(lv_index) = sy-tabix.

  IF sy-subrc EQ 0.
    DELETE lt_join INDEX lv_index.
  ELSE.
    " geen actie nodig
  ENDIF.

ENDLOOP.
" Simple display of retrieved data
* cl_demo_output=>display( lt_join ).

READ TABLE lt_join
WITH KEY tplnr = '8007319334'
INTO DATA(ls_join2).

READ TABLE lt_join
WITH KEY tplnr = '8007319371'
INTO DATA(ls_join3).

READ TABLE lt_join
WITH KEY tplnr = '8007330049'
INTO DATA(ls_join4).

DATA: gr_table TYPE REF TO cl_salv_table.

" Generate an instance of the ALV table object
CALL METHOD cl_salv_table=>factory
  IMPORTING
    r_salv_table = gr_table
  CHANGING
    t_table      = lt_join.

*Display the ALV table.
gr_table->display( ).
