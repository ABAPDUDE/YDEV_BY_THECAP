*&---------------------------------------------------------------------*
*& Report YMD_GIT0193
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0193.

TYPES: BEGIN OF ty_msg_string,
         caseid      TYPE zde_cl_caseid,
         berichttype TYPE zem_berichttype,
         bericht     TYPE zem_json_bericht,
         response    TYPE zem_json_response,
         bevestiging TYPE zem_json_bevestiging,
       END OF ty_msg_string.

TYPES tty_msg_string TYPE STANDARD TABLE OF ty_msg_string.

DATA lt_alv_string TYPE tty_msg_string.

PARAMETERS p_caseid TYPE zde_cl_caseid DEFAULT '1475901'.

SELECT caseid, berichttype, bericht, response, bevestiging
INTO TABLE @DATA(lt_msg)
FROM zem_berichten_dw
WHERE caseid EQ @p_caseid.

*/**
* display data in ALV table
*/*

lt_alv_string[] = lt_msg[].

*DATA lo_alv               TYPE REF TO cl_salv_table.
*DATA lo_columns           TYPE REF TO cl_salv_columns_table.
*DATA lo_functions         TYPE REF TO cl_salv_functions_list.
*
*TRY.
*    cl_salv_table=>factory(
*      IMPORTING
*        r_salv_table = lo_alv
*      CHANGING
*        t_table      = lt_alv_string ).
*  CATCH cx_salv_msg INTO DATA(lr_message).
*ENDTRY.
*
*lo_functions = lo_alv->get_functions( ).
*lo_functions->set_all( ).
*lo_columns = lo_alv->get_columns( ).
*lo_columns->set_optimize( ).
*lo_alv->display( ).

*DATA l_xml TYPE REF TO cl_xml_document .
*DATA xml_out TYPE string.
*
*CREATE OBJECT l_xml.
*
*LOOP AT lt_alv_string
* INTO DATA(ls_string).
*
*  CALL METHOD l_xml->parse_string
*    EXPORTING
*      stream = ls_string-bericht.   "   xml_out. " xml_out is the variable which is holding the xml string
*
*  CALL METHOD l_xml->display.
*
*ENDLOOP.
" alternate option: you can use a custom control and show the xml using cl_gui_html_viewer class


*DATA itab TYPE TABLE OF i WITH EMPTY KEY.

*itab = VALUE #( ( 1 ) ( 2 ) ( 3 ) ).

CALL TRANSFORMATION id SOURCE itab = lt_alv_string
                       RESULT XML DATA(xml).

cl_abap_browser=>show_xml( xml_xstring = xml
                           title = | CASEID: { p_caseid } |
                           size = 'XL'
                           ).
