*&---------------------------------------------------------------------*
*& Report YMD_00002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0021.

PARAMETERS pa_ean TYPE ext_ui.

DATA lt_p5data TYPE STANDARD TABLE OF zpilot_vzc_p5.

SELECT *
  INTO TABLE lt_p5data
  FROM zpilot_vzc_p5
  WHERE ean EQ pa_ean.

" converteer data naar JSON
DATA(lv_json) = /ui2/cl_json=>serialize(
           data = lt_p5data
           compress = abap_true
           pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

CALL TRANSFORMATION id SOURCE itab = lv_json
                       RESULT XML DATA(xml).

cl_abap_browser=>show_xml(
  EXPORTING
*      xml_string   =
     xml_xstring  = xml
*      title        =
*      size         = CL_ABAP_BROWSER=>MEDIUM
*      modal        = ABAP_TRUE
    printing     = abap_true
*      buttons      = NAVIGATE_OFF
*      format       = CL_ABAP_BROWSER=>LANDSCAPE
*      position     = CL_ABAP_BROWSER=>TOPLEFT
    context_menu = abap_true
*      container    =
*      check_xml    = ABAP_TRUE
*      dialog       = ABAP_TRUE
).
" ( xml_xstring = xml ).

cl_demo_output=>display_json( lv_json ).
