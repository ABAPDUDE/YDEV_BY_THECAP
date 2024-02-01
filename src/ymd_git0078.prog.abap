*&---------------------------------------------------------------------*
*& Report YMD_302
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0078.

SELECT carrid, connid, fldate, price
  FROM  sflight
  INTO TABLE @DATA(it_sflight)
  UP TO 5 ROWS.

" convert data to a json
DATA(gv_json_output) = /ui2/cl_json=>serialize(
           data = it_sflight
           compress = abap_true
           pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

" print this information:
cl_demo_output=>display( gv_json_output ).
