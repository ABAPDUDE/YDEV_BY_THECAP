*&---------------------------------------------------------------------*
*& Report YMD_303
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0077.

TYPES: BEGIN OF str_sflight_input,
         carrid TYPE s_carr_id,
         connid TYPE s_conn_id,
         fldate TYPE s_date,
         price  TYPE s_price,
       END OF str_sflight_input.

DATA gt_itab TYPE STANDARD TABLE OF str_sflight_input.
DATA gv_fpath TYPE string.  " TXT FILE PATH MUST BE STRING FOR FM COMPATIBILITY
DATA gt_import TYPE STANDARD TABLE OF string.
DATA gv_json TYPE string.
DATA gv_head TYPE xstring.

PARAMETERS p_file TYPE zlocalfile
   DEFAULT 'C:\Users\al24361\OneDrive - Alliander NV\Documents\Liander Projecten\Flanderijn\Test-Data\Test-Data\networkoperatordossier-202.json'.

START-OF-SELECTION.

  gv_fpath = p_file.

*  CL_GUI_FRONTEND_SERVICES
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename            = gv_fpath
      has_field_separator = 'x'
    IMPORTING
      header              = gv_head
    TABLES
      data_tab            = gt_import.

  IF sy-subrc <> 0.
    WRITE: / 'Het bestand kon niet worden ingelezen'.
  ENDIF.

  " Convert JSON to Internal table
  /ui2/cl_json=>deserialize( EXPORTING
                  json = gv_json
                  pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                  CHANGING data = gt_itab ).

  IF 1 EQ 2.

  ENDIF.
