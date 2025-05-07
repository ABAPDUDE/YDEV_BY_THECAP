*&---------------------------------------------------------------------*
*& Report ZRE_VERBRUIKSPLAATSEN_ZP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0233.


TYPES: BEGIN OF ty_devices,
         vstelle    TYPE vstelle,
         vbsart     TYPE vbsart,
         vbsarttext TYPE vbsarttext,
         haus       TYPE haus,
         anlage     TYPE anlage,
         ext_ui     TYPE ext_ui,
         equnr      TYPE equnr,
         post_code1 TYPE ad_pstcd1,
         house_num1 TYPE ad_hsnm1,
         house_num2 TYPE ad_hsnm2,
         street     TYPE ad_street,
         city1      TYPE ad_city1,
       END OF ty_devices.

TYPES tty_devices TYPE STANDARD TABLE OF ty_devices WITH NON-UNIQUE KEY vstelle.

DATA lt_devices TYPE tty_devices.

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

  DATA(lt_verbruiksplaatsen) = zcl_verbruiksplaats=>get_verbrplts_met_eigenaar(  p_zp ).

  SELECT evbs~vstelle, evbs~vbsart, te102t~vbsarttext, evbs~haus, eanl~anlage, euitrans~ext_ui, egerh~equnr,
  adrc~post_code1, adrc~house_num1, adrc~house_num2, adrc~street, adrc~city1   " , adrc~country, adrc~dont_use_s
  INTO CORRESPONDING FIELDS OF TABLE @lt_devices
  FROM evbs AS evbs
  INNER JOIN eanl AS eanl
  ON evbs~vstelle EQ eanl~vstelle
  INNER JOIN euiinstln AS euiinstln
  ON eanl~anlage EQ euiinstln~anlage
  INNER JOIN euitrans AS euitrans
  ON euiinstln~int_ui EQ euitrans~int_ui

  LEFT OUTER JOIN te102t AS te102t
  ON evbs~vbsart EQ te102t~vbsart
  LEFT OUTER JOIN eastl AS eastl
  ON eastl~anlage EQ eanl~anlage
  LEFT OUTER JOIN egerh AS egerh
  ON eastl~logiknr EQ egerh~logiknr
* INNER JOIN equi AS equi
* ON egerh~equnr EQ equi~equnr

  INNER JOIN iflot AS iflot
  ON evbs~haus EQ iflot~tplnr
  INNER JOIN iloa AS iloa
  ON iflot~iloan EQ iloa~iloan AND
        iflot~tplnr EQ iloa~tplnr
  INNER JOIN adrc AS adrc
  ON adrc~addrnumber EQ iloa~adrnr

  WHERE evbs~eigent EQ @p_zp.

  SORT lt_devices BY equnr DESCENDING.
  DATA(lv_lines_bezit) = lines( lt_devices ).

  DATA lo_alv          TYPE REF TO cl_salv_table.
  DATA lo_columns  TYPE REF TO cl_salv_columns_table.
  DATA lo_functions TYPE REF TO cl_salv_functions_list.
  DATA lo_display    TYPE REF TO cl_salv_display_settings.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = lt_devices ).
    CATCH cx_salv_msg INTO DATA(lr_message).
  ENDTRY.

  lo_functions = lo_alv->get_functions( ).
  lo_functions->set_all( ).
  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( ).
  lo_display = lo_alv->get_display_settings( ).
  lo_display->set_list_header( |Aantal bezittingen: { lv_lines_bezit } | ).

  lo_alv->display( ).
