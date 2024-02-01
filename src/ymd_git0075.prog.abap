*&---------------------------------------------------------------------*
*& Report YMD_300
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0075.

PARAMETERS pa_url TYPE string DEFAULT 'https://help.sap.com/doc/95ffc07cb5064bc5aaedf3b3172c28b8/Cloud/en-US/enterprise_messaging_en_US.pdf'.

START-OF-SELECTION.


  DATA(lo_em) = NEW zcl_enterprise_messaging( iv_messaging_destination  = 'ENTERPRISE_MESSAGING_AH'
                                              iv_management_destination = 'ENTERPRISE_MESSAGING_AH_MNG'
                                              iv_token_destination      = 'EVENT_MESH_FLANDERIJN'  "'ENTERPRISE_MESSAGING_CF_TOKEN' ).
                                              ).

  lo_em->post_to_topic( iv_message = pa_url
                        iv_topic   = cl_nwbc_utility=>escape_url( |Alliander/Flanderijn/EM1/EP| ) ).

  lo_em->post_to_queue( iv_message = |Test 001 - post to queue|
                        iv_queue   = |/Alliander%2fFlanderijn%2fEM1%2fEP| ).

  lo_em->post_to_queue( iv_message = |Test 001 - post to queue|
                      iv_queue   = cl_nwbc_utility=>escape_url( |Alliander/Flanderijn/EM1/EP| ) ).
*

*
*
*  DATA(response) = lo_em->consume_queue( |default%2Falliander.uitvoerdersapp%2F1%2FOrderChanges| ).
*  WRITE:/ response.

*  COMMIT WORK.

  IF 1 = 2. ENDIF.
