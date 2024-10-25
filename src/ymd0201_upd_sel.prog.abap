*&---------------------------------------------------------------------*
*&  Include           ZEIGENAAR_UPD_SEL
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_alv,
         vstelle TYPE vstelle,
         eigent  TYPE e_gpartner,
         result  TYPE char50,
       END OF ty_alv.

TYPES tty_alv TYPE STANDARD TABLE OF ty_alv WITH NON-UNIQUE KEY vstelle.

TYPES: BEGIN OF ty_excel,
         vstelle TYPE vstelle,
         eigent  TYPE e_gpartner,
       END OF ty_excel.

TYPES tty_excel TYPE STANDARD TABLE OF ty_excel WITH NON-UNIQUE KEY vstelle.

DATA  g_raw_data TYPE truxs_t_text_data.
DATA gt_excel_tab TYPE tty_excel.
DATA gt_alv TYPE tty_alv.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_file LIKE rlgrap-filename
DEFAULT 'C:\TEMP\10_lines_vstelle_eigent.xlsx' OBLIGATORY. " File Name
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM selectfile USING p_file.
