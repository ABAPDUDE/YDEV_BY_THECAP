*&---------------------------------------------------------------------*
*& Report YMD_GIT00035
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0179.

TYPES: BEGIN OF lty_items,
         qty TYPE string,
         soh TYPE string,
         ean TYPE string,
         soi TYPE string,
         cat TYPE string,
       END OF lty_items.

TYPES: BEGIN OF lty_head,
         name TYPE string,
       END OF lty_head.

TYPES: BEGIN OF lty_out,
         head  TYPE lty_head,
         items TYPE STANDARD TABLE OF lty_items WITH DEFAULT KEY,
       END OF lty_out.

DATA: lv_xml TYPE string,
      lt_xml TYPE STANDARD TABLE OF string,
      ls_out TYPE lty_out.

PARAMETERS p_file TYPE string LOWER CASE DEFAULT 'C:\Users\AL24361\OneDrive - Alliander NV\Desktop\ST_testbestand_001.xml'.

"Load xml file
cl_gui_frontend_services=>gui_upload(
  EXPORTING
    filename = p_file
    filetype = 'ASC'
  CHANGING
    data_tab = lt_xml
  EXCEPTIONS
    OTHERS   = 19 ).

lv_xml = concat_lines_of( lt_xml ).

cl_abap_browser=>show_xml( EXPORTING xml_string = lv_xml
                                       modal      = 'X' ).

CALL TRANSFORMATION ysd_xslt_001
  SOURCE XML lv_xml
  RESULT file = ls_out.
cl_demo_output=>new( )->write_data( ls_out-head
                     )->write_data( ls_out-items )->display( ).
