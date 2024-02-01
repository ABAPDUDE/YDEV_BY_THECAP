*&---------------------------------------------------------------------*
*& Report YMD_00007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0007.

*/**
* The Difference between a GET method and the Post Method for Odata
* is the X-CSRF token handling.
* Since the HTTP POST method is a modifying call,
* an X-CSRF Token has to be passed for security purposes.
* once the X-CSRF Token is fetched the REST object and the HTTP Client are refreshed.
* use the same object instantiation for both the GET and POST methods.
*
*/*


DATA l_query  TYPE string.
DATA l_body   TYPE string.
DATA l_token  TYPE string.
DATA l_result TYPE string.

DATA lo_http_client TYPE REF TO if_http_client.

CONSTANTS c_rfchana TYPE rfcdest VALUE 'ZC4C_WS_QUOTES'.                                     " RFC Destination
CONSTANTS c_query   TYPE string  VALUE '/sap/byd/odata/v1/c4codataapi/SalesQuoteCollection'. " Entity name
