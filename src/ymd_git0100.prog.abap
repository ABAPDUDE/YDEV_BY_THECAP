*&---------------------------------------------------------------------*
*& Report YMD_003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0100.


DATA gv_field1 TYPE c VALUE abap_true.
DATA gv_field2 TYPE c VALUE abap_false.

IF gv_field1 EQ abap_false.

  DATA(lv_equipmentnr) = '12345'.

ELSE.

  lv_equipmentnr = '67890'.

ENDIF.

WRITE:/5 lv_equipmentnr.


*/**
CONSTANTS gco_equipnr TYPE equi-equnr VALUE '5002077368'.

IF 1 = 2.

  DATA(lv_equipnr) =  '2'.
  DATA(lv_materialnr) = '1'.
  DATA(lv_sparte) = 'G'.

ELSE.

  SELECT SINGLE matnr, sernr, sparte
   FROM equi
   INTO @DATA(ls_equi)
   WHERE equnr EQ @gco_equipnr.

  lv_equipnr = ls_equi-sernr.
  lv_materialnr = ls_equi-matnr.
  lv_sparte = ls_equi-sparte.

ENDIF.

CHECK lv_equipmentnr IS NOT INITIAL.
CHECK lv_materialnr IS NOT INITIAL.

DATA(lv_smartmeter) = zcl_metertools=>is_meter_smart(
      i_equnr  = lv_equipnr
      i_matnr  = lv_materialnr
      i_sparte = lv_sparte ).
