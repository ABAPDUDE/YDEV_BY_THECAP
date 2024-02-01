*&---------------------------------------------------------------------*
*& Report YMD_00011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0011.

TYPES: BEGIN OF ty_textcollection,
         typecode TYPE char5,
         text     TYPE string,
       END OF ty_textcollection.

TYPES tty_textcollection TYPE STANDARD TABLE OF ty_textcollection WITH DEFAULT KEY.

DATA gt_textcollection TYPE tty_textcollection.
DATA gs_textcollection TYPE ty_textcollection.

TYPES: BEGIN OF ty_json_cx,
         incidentid     TYPE char25,
         name           TYPE char255,
         prioritycode   TYPE char1,
         lifecyclecode  TYPE char2,
         zp             TYPE char50,
         causeid        TYPE char25,
         serviceid      TYPE char25,
         aanvraagnr     TYPE char40,
         textcollection TYPE tty_textcollection.
*         BEGIN OF textcollection,
*           typecode TYPE char5,
*           text     TYPE string,
*         END OF textcollection.
TYPES:        END OF ty_json_cx.

TYPES: tty_json_cx TYPE STANDARD TABLE OF ty_json_cx.

DATA ls_json TYPE ty_json_cx.

gs_textcollection-typecode = |10011|.
gs_textcollection-text = |Dit is een intern commentaar geschikt voor kleine significante updates |.
APPEND gs_textcollection TO gt_textcollection.

gs_textcollection-typecode = |10004|.
gs_textcollection-text = |Dit is een tekst voor het algemene omschrijving veld: Adres fysieke capaciteit, EAN enz.|.
APPEND gs_textcollection TO gt_textcollection.

ls_json-incidentid = |CA_0503|.
ls_json-name = |GV-A123|.
ls_json-prioritycode = |3| .
ls_json-lifecyclecode = |1|.
ls_json-zp = |1000023456|.
ls_json-causeid = |CA_0503_3|.
ls_json-serviceid = |CA_0500|.
ls_json-aanvraagnr = |CaseID:123456-EAN:12121212|.
ls_json-textcollection = gt_textcollection[].

" converteer data naar JSON
DATA(lv_json) = /ui2/cl_json=>serialize(
           data = ls_json
           compress = abap_true
           pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

REPLACE 'incidentid'     IN lv_json WITH 'IncidentServiceIssueCategoryID'.
REPLACE 'name'           IN lv_json WITH 'Name'.
REPLACE 'prioritycode'   IN lv_json WITH 'ServicePriorityCode'.
REPLACE 'lifecyclecode'  IN lv_json WITH 'ServiceRequestUserLifeCycleStatusCode'.
REPLACE 'zp'             IN lv_json WITH 'BuyerPartyID'.
REPLACE 'causeid'        IN lv_json WITH 'CauseServiceIssueCategoryID'.
REPLACE 'serviceid'      IN lv_json WITH 'ServiceIssueCategoryID'.
REPLACE 'aanvraagnr'     IN lv_json WITH 'Aanvraagnummer_KUT'.
REPLACE 'textcollection' IN lv_json WITH 'ServiceRequestTextCollection'.
REPLACE ALL OCCURRENCES OF 'typecode'       IN lv_json WITH 'TypeCode'.
REPLACE ALL OCCURRENCES OF 'text'           IN lv_json WITH 'Text'.

*WRITE: /5 lv_json.
CALL TRANSFORMATION id SOURCE itab = lv_json
                       RESULT XML DATA(xml).

cl_abap_browser=>show_xml( xml_xstring = xml ).

cl_demo_output=>display_json( lv_json ).

DATA lv_eventmesh_queue TYPE string.

IF lv_json IS INITIAL.
  " Uitval - zou niet voor mogen komen - eerder checken op data aanwezig voor C4 ticket
ELSE.

  DATA(lo_em) = NEW zcl_enterprise_messaging( iv_messaging_destination    = 'ENTERPRISE_MESSAGING_AH'
                                                iv_management_destination = 'ENTERPRISE_MESSAGING_AH_MNG'
                                                iv_token_destination      = 'EVENT_MESH_CX' ).

  " Bepaal de EventMesh Queue voor de huidige verwerking
  lv_eventmesh_queue = |alliander/cx/em1/CreateTicket|.

  lo_em->post_to_topic( iv_message = lv_json
                        iv_topic   = cl_nwbc_utility=>escape_url( lv_eventmesh_queue ) ).

  lo_em->close( ).

ENDIF.
