*&---------------------------------------------------------------------*
*& Report ymd_git0209
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0209.

DATA input_main        TYPE zp5push_request_schema1.
DATA input_eosupply    TYPE zp5push_request_schema1.

DATA ls_5 TYPE zend_device_control3.           " structuur
DATA ls_4 TYPE zend_device_event2.             " structuur
DATA ls_3 TYPE zend_device_event_tab2.         " tabel
DATA ls_2 TYPE zmeter_reading_response_schem4. " structuur
DATA ls_1 TYPE zp5push_request_schema1.        " structuur

" vul de INPUT structuur van de RESPONSE proxy

*/**
* 2 regels: 1 voor VZC EOSUPPY en een voor CL willekeurig
ls_5-issuer_tracking_id = 'VZC-871687120054300150-20241010-132316'.

ls_4-m_rid = '871687120054300150'.
ls_4-response_to_control = ls_5.

APPEND ls_4 TO ls_3.

ls_5-issuer_tracking_id = 'CL-871685900000931643-20241023-085316'.

ls_4-m_rid = '871685900000931643'.
ls_4-response_to_control = ls_5.

APPEND ls_4 TO ls_3.

*/**

ls_2-end_device_event = ls_3[].
ls_1-meter_reading_response_schema = ls_2.

input_main = ls_1.
input_eosupply = ls_1.

DATA(go_data) = zcl_factory_vzcfac=>get( )->build_support_object( ).

LOOP AT input_main-meter_reading_response_schema-end_device_event
  ASSIGNING FIELD-SYMBOL(<fs_event>).

  IF go_data IS BOUND.
    DATA(lv_eosupply_response) = go_data->get_referentie_id( iv_tracking_id = <fs_event>-response_to_control-issuer_tracking_id ).
  ELSE.
    " geen object / klasse geinstantieerd
  ENDIF.

  IF lv_eosupply_response EQ abap_true.
    " deze response is op basis van een REQUEST van EAN berichttype EOSUPPLY
    " deze regel wordt verwijderd uit globale responses voor alle EANs
    DELETE TABLE input_main-meter_reading_response_schema-end_device_event FROM <fs_event>.
  ELSE.
    " deze response is niet op basis van een REQUEST van EAN berichttype EOSUPPLY
    " deze regel wordt verwijderd zodat uiteindelijk alleen EANs met bericht type EOSUPPLY overblijven
    DELETE TABLE input_eosupply-meter_reading_response_schema-end_device_event FROM <fs_event>.
  ENDIF.

ENDLOOP.


DATA(go_data_eosupply) = zcl_factory_vzcfac=>get( )->build_workload_object_eosupply( ).

IF go_data_eosupply IS BOUND.
  go_data_eosupply->response_verbruik( it_xml_response = input_eosupply ).
ELSE.
  " geen object / klasse geinstancieerd
ENDIF.
