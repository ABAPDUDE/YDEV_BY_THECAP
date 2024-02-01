*&---------------------------------------------------------------------*
*& Report YMD_306
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0073.

"Define the structure with the fields you are interested in:
TYPES:
  BEGIN OF ty_result,
    rebateno TYPE string,
    type     TYPE string,
  END OF ty_result,

  BEGIN OF ty_data,
    BEGIN OF d,
      results TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY,
    END OF d,
  END OF ty_data.

DATA: lt_data TYPE ty_data.

END-OF-SELECTION.
  "Messy hard-coded JSON string with some missing fields due to the 255 char limit
  DATA(lv_json_string) = `{"d":{"results":[{"RebateNo":"1234567890","Type":"ZZZZ","Status":"Z","SalesGroup":"Z","Owner":"JOHN SMITH","CustomerNo":"12345","CustomerName":"JOHN SMITH","CustomerVAT":"12345"}]}}`.

  "...and deserialize your JSON
  /ui2/cl_json=>deserialize(
    EXPORTING
       json             = lv_json_string
*       jsonx            =
       pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
*       assoc_arrays     =
*       assoc_arrays_opt =
*       name_mappings    =
*       conversion_exits =
    CHANGING
      data             = lt_data
  ).

  DATA go_out      TYPE REF TO if_demo_output.
  go_out = cl_demo_output=>new( ).
  go_out->display( lt_data-d-results ).
