*&---------------------------------------------------------------------*
*& Report YMD_00018
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0018.


DATA lv_start TYPE xsddatetime_z.
DATA lv_eind TYPE xsddatetime_z.

DATA lv_start1 TYPE C length 19.
DATA lv_eind1 TYPE C length 19.

DATA lv_startdatum TYPE dats VALUE '20240101'.
DATA lv_einddatum TYPE dats VALUE '20240131'.
DATA ls_output TYPE zp5request_schema.

lv_start = |{ lv_startdatum }000000|.
*GET TIME STAMP FIELD lv_start.
lv_eind = |{ lv_einddatum }235959|.
*GET TIME STAMP FIELD lv_eind.

WRITE lv_start TO lv_start1.
SKIP 1.
WRITE lv_eind TO lv_eind1 .

WRITE lv_start.
SKIP 1.
WRITE lv_eind.
