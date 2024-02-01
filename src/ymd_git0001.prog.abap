*&---------------------------------------------------------------------*
*& Report YMD_00015
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0001.

DATA ls_sub TYPE zst_subsidie_kaart.
DATA lt_meterstanden TYPE ztt_meterstanden.
DATA ls_meterstand TYPE zst_meterstanden.
DATA lt_telwerkstanden TYPE ztt_meterstandsub.
DATA ls_telwerkstand TYPE zst_meterstandsub.

START-OF-SELECTION.

  " fill internal table lt_telwerkstanden

  ls_meterstand-meter = |E00032456|.
  ls_meterstand-meeteenheid = |kWh|.
  ls_meterstand-telwerkcode = |1.8.1|.
  ls_meterstand-meterstand = |00001111|.
  ls_meterstand-telwerk = |001|.

  APPEND ls_meterstand TO lt_meterstanden.

  ls_meterstand-meter = |E00032456|.
  ls_meterstand-meeteenheid = |kWh|.
  ls_meterstand-telwerkcode = |1.8.2|.
  ls_meterstand-meterstand = |00002222|.
  ls_meterstand-telwerk = |001|.

  APPEND ls_meterstand TO lt_meterstanden.

  ls_meterstand-meter = |E00032456|.
  ls_meterstand-meeteenheid = |kWh|.
  ls_meterstand-telwerkcode = |1.8.3|.
  ls_meterstand-meterstand = |0000333|.
  ls_meterstand-telwerk = |001|.

  APPEND ls_meterstand TO lt_meterstanden.

**/*
*
*/*

  " fill main structure
  ls_sub-ean = |13451234512345|.
  ls_sub-voornaam = |Mike|.
  ls_sub-achternaam = |Derksema|.
  ls_sub-emailadres = |michaelderksema@capgemini.com|.
  ls_sub-telefoon = |00310612121212|.
  ls_sub-bedrijfsnaam = |CAP|.
  ls_sub-meterstanden[] = lt_meterstanden[].

  " converteer data naar JSON
  DATA(lv_json) = /ui2/cl_json=>serialize(
             data = ls_sub
             compress = abap_true
             pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

  CALL TRANSFORMATION id SOURCE itab = lv_json
                         RESULT XML DATA(xml).

  cl_abap_browser=>show_xml( xml_xstring = xml ).

  cl_demo_output=>display_json( lv_json ).
