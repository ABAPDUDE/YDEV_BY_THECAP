*&---------------------------------------------------------------------*
*& Report YMD_00017
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0017.

DATA ts TYPE xsddatetime_z.
GET TIME STAMP FIELD ts.

CALL TRANSFORMATION id SOURCE ts = ts
                       RESULT XML DATA(xml).
cl_demo_output=>display_xml( xml ).

WRITE ts.
