*&---------------------------------------------------------------------*
*&  Include  zcm_products_test_sel
*&---------------------------------------------------------------------*

DATA gs_input TYPE yst_input_cm_products.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-000.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN SKIP 1.

" iNSTALLATION PARAMETERS
PARAMETERS p_anlage TYPE anlage.
PARAMETERS p_sparte TYPE sparte.
PARAMETERS p_vstell TYPE vstelle.
PARAMETERS p_aklass TYPE aklasse.
PARAMETERS p_tarift TYPE tariftyp.
PARAMETERS p_ablein TYPE ableinh.
PARAMETERS p_status TYPE zchar_stat_aansl.
PARAMETERS p_eanodn TYPE zz_ean_odn.
PARAMETERS p_eanldn TYPE zz_ean_ldn.
PARAMETERS p_eanid  TYPE ext_ui.
PARAMETERS p_datefr TYPE e_edmdatefrom.

SELECTION-SCREEN SKIP 1.
* SELECT-OPTIONS s_scen FOR gv_scenario.
SELECTION-SCREEN END OF BLOCK b02.

*SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-002.
*SELECTION-SCREEN SKIP 1.
*
*" CONTRACT PARAMETERS
*PARAMETERS p_vrtrag TYPE vertrag.
*PARAMETERS p_bukrs  TYPE bukrs.
*PARAMETERS p_vbez   TYPE e_vbez.
*PARAMETERS p_gemfak TYPE e_gemfakt.
*PARAMETERS p_kofiz  TYPE e_kofiz.
*PARAMETERS p_vbegin TYPE e_vbeginn.
*
*SELECTION-SCREEN SKIP 1.
** SELECT-OPTIONS s_scen FOR gv_scenario.
*SELECTION-SCREEN END OF BLOCK b03.

SELECTION-SCREEN SKIP 1.
* SELECT-OPTIONS s_scen FOR gv_scenario.
SELECTION-SCREEN END OF BLOCK b01.


*&---------------------------------------------------------------------*
*&  At Selection-screen
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

*/**
*  het is mogelijk om een Installatie nummer mee te geven
* wanneer er geen installatie nummer wordt meeggeven: nummerreeks gevolgd
*/*

*    DATA(lv_msg1) = |De installatie die wordt aangelegd krijgt een SAP intern nummerreeks-nummer!|.
*    MESSAGE lv_msg1 TYPE 'E' DISPLAY LIKE 'I'.
*
*    LEAVE LIST-PROCESSING.

*&---------------------------------------------------------------------*
*&  Initialization
*&-------------------
INITIALIZATION.

  IF ( sy-sysid = 'DNW'
*     AND sy-ucomm EQ 'ONLI'
*     AND p_test EQ abap_true
      ).
    p_aklass = 'N'.
    p_vstell = '4668'.
    p_sparte = 'CE'.
    p_tarift = 'CE-RDP'.
    p_ablein = 'RNBMND01'.
    p_status = 'IB'.
    p_eanodn = '871690910000009916'.
    p_eanldn = '871690910000009916'.
    p_eanid  = '871690910000009916'.
    p_datefr = sy-datum.
*    p_bukrs = '7000'.
*    p_vbez = |dit is een unit test door md|.
*    p_gemfak = '2'.
*    p_kofiz  = '01'.
*    p_vbegin = ( sy-datum + 1 ).

  ENDIF.
