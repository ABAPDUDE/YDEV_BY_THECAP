*&---------------------------------------------------------------------*
*& Report YMD_00008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0008.

* HTTP Client Abstraction
DATA  lo_client TYPE REF TO if_http_client.

START-OF-SELECTION.

* Creation of New IF_HTTP_Client Object
  cl_http_client=>create_by_url(
  EXPORTING
    url                = 'https://dev-api.alliander.com/odata/v1/c4ticket/ServiceRequestCollection' " URL
    proxy_host         = 'https://tst-api.alliander.com'                                            " Proxy
    proxy_service      = '3128'                                                                     " Port
    sap_username       = '28255'                                                                    " Username
    sap_client         = '001'                                     " Client
  IMPORTING
    client             = lo_client
  EXCEPTIONS
    argument_not_found = 1
    plugin_not_active  = 2
    internal_error     = 3
    ).

  IF sy-subrc IS NOT INITIAL.
* Handle errors
    LEAVE PROGRAM.
  ENDIF.

*Structure of HTTP Connection and Dispatch of Data
  lo_client->send( ).
  IF sy-subrc IS NOT INITIAL.
* Handle errors
  ENDIF.

*Receipt of HTTP Response
  lo_client->receive( ).
  IF sy-subrc IS NOT INITIAL.
* Handle errors
  ENDIF.
