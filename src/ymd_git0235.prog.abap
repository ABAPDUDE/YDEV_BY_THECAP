*&---------------------------------------------------------------------*
*& Report zcm_products_test
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0235.

*/**
* dit is een test programma om het aanleggen van een installatie te bewerkstelligen
* hiervoor wordt gebruik gemaakt van SAP MDG
*/*

INCLUDE ycm_products_test_sel.
*INCLUDE zcm_products_test_sel.

START-OF-SELECTION.

  gs_input-anlage        = p_anlage.
  gs_input-sparte        = p_sparte.
  gs_input-vstelle       = p_vstell.
  gs_input-aklasse       = p_aklass.
  gs_input-ableinh       = p_ablein.
  gs_input-tariftyp      = p_tarift.
  gs_input-status_aansl  = p_status.
  gs_input-ean_odn       = p_eanodn.
  gs_input-ean_ldn       = p_eanldn.
  gs_input-ean_id                 = p_eanid.
  gs_input-date_from_ean          = p_datefr.
  gs_input-date_from_installation = p_datefr.
*  gs_input-vertrag       = p_vrtrag.
*  gs_input-bukrs         = p_bukrs.
*  gs_input-gemfact       = p_gemfak.
*  gs_input-kofiz         = p_kofiz.
*  gs_input-vbez          = p_vbez.
*  gs_input-vbeginn       = p_vbegin.

*  DATA(lo_input) = NEW zcl_cm_products_input( gs_input ).
  DATA(go_cm_product) = NEW ycl_cm_test( iv_start_date = sy-datum ).
  go_cm_product->create_cm_installation( is_input = gs_input ).
