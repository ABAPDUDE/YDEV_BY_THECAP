*&---------------------------------------------------------------------*
*& Report YMD_GIT0192
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0192.

TYPES: BEGIN OF ty_msg_string,
         caseid      TYPE zde_cl_caseid,
         berichttype TYPE zem_berichttype,
         bericht     TYPE zem_json_bericht,
         response    TYPE zem_json_response,
         bevestiging TYPE zem_json_bevestiging,
       END OF ty_msg_string.

TYPES tty_msg_string TYPE STANDARD TABLE OF ty_msg_string.

DATA lt_alv_string TYPE tty_msg_string.

PARAMETERS p_caseid TYPE zde_cl_caseid DEFAULT '1477791'.

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

*LOOP AT lt_alv_string
*  INTO DATA(ls_string).
*
*  WRITE /5 ls_string-bericht.
*  SKIP 2.
*  WRITE /5 ls_string-response.
*  SKIP 2.
*  WRITE /5 ls_string-bevestiging.
*
*ENDLOOP.

DATA(out) = cl_demo_output=>new(
   )->begin_section( 'asJSON' ).
DATA(writer) = cl_sxml_string_writer=>create(
  type = if_sxml=>co_xt_json ).
CALL TRANSFORMATION id SOURCE itab = lt_alv_string
                       RESULT XML writer.
DATA(json) = writer->get_output( ).
out->write_json( json ).

"JSON-XML
out->next_section( 'asJSON-XML' ).
DATA(reader) = cl_sxml_string_reader=>create( json ).
DATA(xml_writer) = cl_sxml_string_writer=>create( ).
reader->next_node( ).
reader->skip_node( xml_writer ).
DATA(xml) = xml_writer->get_output( ).
out->write_xml( xml ).

*"asXML
*out->next_section( 'asXML' ).
*CALL TRANSFORMATION id SOURCE itab = lt_alv_string
*                       RESULT XML xml.
out->write_xml( xml )->display( ).
