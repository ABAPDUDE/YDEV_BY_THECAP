*&---------------------------------------------------------------------*
*& Report YMD_301
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0079.

START-OF-SELECTION.


  DATA(lo_em) = NEW zcl_enterprise_messaging( iv_messaging_destination  = 'ENTERPRISE_MESSAGING_AH'
                                              iv_management_destination = 'ENTERPRISE_MESSAGING_AH_MNG'
                                              iv_token_destination      = 'EVENT_MESH_FLANDERIJN'  "'ENTERPRISE_MESSAGING_CF_TOKEN' ).
                                              ).


  DATA(response) = lo_em->consume_queue( cl_nwbc_utility=>escape_url( |Alliander/Flanderijn/EM1/NetworkOperatorDossier/Handmatig| ) ).
*  DATA(response) = lo_em->consume_queue(  '/Alliander%2fFlanderijn%2fEM1%2fEP' ).
  WRITE:/ response.
  IF 1 = 2. ENDIF.
