*&---------------------------------------------------------------------*
*& Report ymd_git0189
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0189.

FIELD-SYMBOLS <fs_msg> TYPE any.
FIELD-SYMBOLS <fs_msg1> TYPE zst_responses_bosveld.
FIELD-SYMBOLS <fs_msg_t> TYPE any.

DATA lv_json TYPE string.
DATA ls_resp0 TYPE zst_responses_bosveld_deep.
DATA ls_resp1 TYPE zdt_bosveld_responses.
DATA ls_resp2 TYPE zdt_bosveld_responses_bosveld.
DATA ls_resp3 TYPE zst_responses_bosveld.

lv_json ='{ "Bosveld_Responses": { "message_id": "1464673_handoff_20240413150916", "http_status_code": "202", "http_status_code_txt": "Accepted", "additionele_txt": "[]" }}'.

DATA: lo_tab TYPE REF TO data.

" lo_tab = zif_dw_eventmesh~convert_json_2_ddic( iv_json = lv_json ).
DATA lo_json TYPE REF TO data.
DATA lt_tab1 TYPE STANDARD TABLE OF zdt_bosveld_responses.
DATA ls_resp TYPE zst_responses_bosveld.
FIELD-SYMBOLS: <fs_tabnam> TYPE STANDARD TABLE.

/ui2/cl_json=>deserialize( EXPORTING
                 json = lv_json
                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                 CHANGING data = lo_tab ).

ASSIGN lo_tab->* TO FIELD-SYMBOL(<fs_tab>).
ASSIGN COMPONENT 'BOSVELD_RESPONSES' OF STRUCTURE <fs_tab> TO FIELD-SYMBOL(<fs_resp1>).
ASSIGN COMPONENT 'BOSVELD_RESPONSES' OF STRUCTURE <fs_tab> TO FIELD-SYMBOL(<fs_resp2>).

ls_resp = CORRESPONDING #( <fs_resp1> ).

APPEND INITIAL LINE TO lt_tab1 ASSIGNING <fs_resp2>.

*/ui2/cl_json=>deserialize( EXPORTING
*                  json = lv_json
*                  pretty_name = /ui2/cl_json=>pretty_mode-camel_case
*                  CHANGING data = lo_tab ).
*

*ASSIGN lo_tab->* TO FIELD-SYMBOL(<fs_tab>).
*ASSIGN COMPONENT 'BOSVELD_RESPONSES' OF STRUCTURE <fs_tab> TO FIELD-SYMBOL(<fs_resp>). " structuur met 4 velden
*
*
*ASSIGN <fs_resp>->* TO <fs_msg>.
*ASSIGN COMPONENT 'MESSAGE_ID' OF STRUCTURE <fs_msg> TO FIELD-SYMBOL(<fs_msgid>).
*
*ls_resp0 = CORRESPONDING #( <fs_tab> ).
*ls_resp0 = CORRESPONDING #( <fs_tab> ).
*ls_resp1 = CORRESPONDING #( <fs_msg> ).
*ls_resp1 = CORRESPONDING #( <fs_tab> ).
*ls_resp2 = CORRESPONDING #( <fs_msg> ).

*clear <fs_msg>-message_id.

*ASSIGN <fs_resp>->* TO <fs_msg_t> CASTING TYPE c.

*ASSIGN <fs_resp>->* TO <fs_msg1>.

IF 1 EQ 2.
ENDIF.
