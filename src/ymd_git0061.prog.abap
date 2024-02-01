*&---------------------------------------------------------------------*
*& Report YMD_308
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0061.

*PARAMETERS pa_url TYPE string DEFAULT 'https://help.sap.com/doc/95ffc07cb5064bc5aaedf3b3172c28b8/Cloud/en-US/enterprise_messaging_en_US.pdf'.

START-OF-SELECTION.

  DATA(lo_em) = NEW zcl_enterprise_messaging( iv_messaging_destination  = 'ENTERPRISE_MESSAGING_AH'
                                                 iv_management_destination = 'ENTERPRISE_MESSAGING_AH_MNG'
                                                 iv_token_destination      = 'EVENT_MESH_FLANDERIJN'  "'ENTERPRISE_MESSAGING_CF_TOKEN' ).
                                                 ).

  lo_em->post_to_topic( iv_message = |Testbericht: Aanmaken dossier bij Flanderijn|
                        iv_topic   = cl_nwbc_utility=>escape_url( |Alliander/Flanderijn/EM1/NOD/NetworkOperatorDossier| ) ).

  lo_em->post_to_topic( iv_message = |Testbericht: Reponse aanmaken dossier bij Flanderijn|
                        iv_topic   = cl_nwbc_utility=>escape_url( |Alliander/Flanderijn/EM1/NOD/NetworkOperatorDossierResponse| ) ).

*  lo_em->post_to_topic( iv_message = |test_2|
*                        iv_topic   = cl_nwbc_utility=>escape_url( |Alliander/Flanderijn/EM1/NOD| ) ).
*
*  lo_em->post_to_topic( iv_message = |test_3|
*                        iv_topic   = cl_nwbc_utility=>escape_url( |Alliander/Flanderijn/EM1/MD/SendDossier| ) ).
*
*  lo_em->post_to_topic( iv_message = |test_4|
*                        iv_topic   = cl_nwbc_utility=>escape_url( |Alliander/Flanderijn/EM1/MD| ) ).

  IF 1 = 2. ENDIF.
