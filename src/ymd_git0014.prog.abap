*&---------------------------------------------------------------------*
*& Report YMD_00014
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0014.

DATA ls_sap_structuur TYPE zst_em_ticketcreated_msg.

DATA(lo_em) = NEW zcl_enterprise_messaging( iv_messaging_destination  = 'ENTERPRISE_MESSAGING_AH'
                                            iv_management_destination = 'ENTERPRISE_MESSAGING_AH_MNG'
                                            iv_token_destination      = 'EVENT_MESH_CX' ).

DATA(lv_json_string) = lo_em->consume_queue( cl_nwbc_utility=>escape_url( |alliander/cx/em1/TicketCreated| ) ).

START-OF-SELECTION.

  " Convert JSON to SAP/ABAP structure
  /ui2/cl_json=>deserialize( EXPORTING json = lv_json_string
                                       pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                              CHANGING data = ls_sap_structuur ).

  IF 1 EQ 2.
  ENDIF.
