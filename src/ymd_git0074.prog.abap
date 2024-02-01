*&---------------------------------------------------------------------*
*& Report YMD_304
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0074.

TYPES: BEGIN OF ty_final,
         name           TYPE string,
         model          TYPE string,
         manufacturer   TYPE string,
         starship_class TYPE string,
       END OF ty_final.

DATA: lv_code          TYPE i,
      lv_url           TYPE string,
      li_client        TYPE REF TO if_http_client,
      lt_errors        TYPE TABLE OF string,
      lv_error_message TYPE string,
      lv_json_data     TYPE string,
      lr_data          TYPE REF TO data,
      ls_final         TYPE ty_final,
      lt_final         TYPE TABLE OF ty_final.

FIELD-SYMBOLS:
  <data>        TYPE data,
  <results>     TYPE any,
  <structure>   TYPE any,
  <table>       TYPE ANY TABLE,
  <field>       TYPE any,
  <field_value> TYPE data.


*lv_url = 'https://swapi.dev/api/starships'.
lv_url = 'https://postman-echo.com/get'.

cl_http_client=>create_by_url(
  EXPORTING
    url           = lv_url
    ssl_id        = 'ANONYM'
  IMPORTING
    client        = li_client ).

li_client->send( ).
li_client->receive(
  EXCEPTIONS
    http_communication_failure = 1
    http_invalid_state         = 2
    http_processing_failed     = 3
    OTHERS                     = 4 ).
IF sy-subrc <> 0.
  WRITE: / 'Error Number', sy-subrc, /.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  li_client->get_last_error(
    IMPORTING
      message = lv_error_message ).
  SPLIT lv_error_message AT cl_abap_char_utilities=>newline INTO TABLE lt_errors.
  LOOP AT lt_errors INTO lv_error_message.
    WRITE: / lv_error_message.
  ENDLOOP.
  RETURN.
ENDIF.

li_client->response->get_status(
  IMPORTING
    code = lv_code ).
IF lv_code = 200.
  WRITE: / lv_url, ': OK', icon_checked AS ICON.
  WRITE: /.

  lv_json_data = li_client->response->get_cdata( ).

  CALL METHOD /ui2/cl_json=>deserialize
    EXPORTING
      json         = lv_json_data
      pretty_name  = /ui2/cl_json=>pretty_mode-camel_case
      assoc_arrays = abap_true
    CHANGING
      data         = lr_data.

  IF lr_data IS BOUND.
    ASSIGN lr_data->* TO <data>.
    ASSIGN COMPONENT `RESULTS` OF STRUCTURE <data> TO <results>.
    ASSIGN <results>->* TO <table>.

    LOOP AT <table> ASSIGNING <structure>.
      ASSIGN <structure>->* TO <data>.

      ASSIGN COMPONENT `NAME` OF STRUCTURE <data> TO <field>.
      IF <field> IS ASSIGNED.
        lr_data = <field>.
        ASSIGN lr_data->* TO <field_value>.
        ls_final-name = <field_value>.
      ENDIF.
      UNASSIGN: <field>, <field_value>.

      ASSIGN COMPONENT `MODEL` OF STRUCTURE <data> TO <field>.
      IF <field> IS ASSIGNED.
        lr_data = <field>.
        ASSIGN lr_data->* TO <field_value>.
        ls_final-model = <field_value>.
      ENDIF.
      UNASSIGN: <field>, <field_value>.

      ASSIGN COMPONENT `MANUFACTURER` OF STRUCTURE <data> TO <field>.
      IF <field> IS ASSIGNED.
        lr_data = <field>.
        ASSIGN lr_data->* TO <field_value>.
        ls_final-manufacturer = <field_value>.
      ENDIF.
      UNASSIGN: <field>, <field_value>.

      ASSIGN COMPONENT `STARSHIP_CLASS` OF STRUCTURE <data> TO <field>.
      IF <field> IS ASSIGNED.
        lr_data = <field>.
        ASSIGN lr_data->* TO <field_value>.
        ls_final-starship_class = <field_value>.
      ENDIF.
      UNASSIGN: <field>, <field_value>.

      APPEND ls_final TO lt_final.
      CLEAR ls_final.
    ENDLOOP.
  ENDIF.

  cl_demo_output=>write_data( lt_final ).
  cl_demo_output=>display( ).

ENDIF.
