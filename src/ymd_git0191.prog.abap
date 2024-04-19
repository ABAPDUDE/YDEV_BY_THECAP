*&---------------------------------------------------------------------*
*& Report ymd_git0191
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0191.

DATA ls_json TYPE zdt_bosveld_responses. "zst_responses_bosveld.
DATA lv_json TYPE string.

lv_json ='{ "Bosveld_Responses": { "message_id": "1464673_handoff_20240413150916", "http_status_code": "202", "http_status_code_txt": "Accepted", "additionele_txt": "[]" }}'.

/ui2/cl_json=>deserialize( EXPORTING
                  json = lv_json
                  pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                  CHANGING data = ls_json ).

SPLIT ls_json-bosveld_responses-message_id AT '_'
INTO DATA(lv_caseid) DATA(lv_queue) DATA(lv_datetime).

IF 1 EQ 2.
ENDIF.
