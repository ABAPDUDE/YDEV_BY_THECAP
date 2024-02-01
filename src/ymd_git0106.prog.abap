*&---------------------------------------------------------------------*
*& Report YMD_026
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0106.

DATA lv_material_nr TYPE matnr.
DATA lv_material_nr1 TYPE matnr.
DATA lv_material_nr2 TYPE matnr.

DATA lv_external_matnr TYPE swo_typeid.

lv_external_matnr = '128790-00001'.

lv_material_nr = CONV mara_matnr( lv_external_matnr ).

WRITE: /10 |lv_material_number = { lv_material_nr }|.

lv_material_nr1 = CONV #( lv_external_matnr ).

WRITE: /10 |lv_material_nr1 = { lv_material_nr1 }|.

lv_material_nr2 = lv_external_matnr.

WRITE: /10 |lv_material_nr2 = { lv_material_nr2 }|.
