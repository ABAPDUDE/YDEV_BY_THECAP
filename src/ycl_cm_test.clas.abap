class YCL_CM_TEST definition
  public
  final
  create public .

public section.

  methods CREATE_CM_INSTALLATION
    importing
      !IS_INPUT type YST_INPUT_CM_PRODUCTS
    exporting
      !EV_SUCCESS type BOOLEAN
      !EV_ERROR_MESSAGE type STRING .
  methods CONSTRUCTOR
    importing
      !IV_START_DATE type DATS optional
      !IV_END_DATE type DATS optional .
protected section.
private section.

  data GV_END_DATE type DATS .
  data GV_START_DATE type DATS .
ENDCLASS.



CLASS YCL_CM_TEST IMPLEMENTATION.


  method CONSTRUCTOR.

    gv_start_date = iv_start_date.
    gv_end_date = iv_end_date.

  endmethod.


  METHOD create_cm_installation.

*/**
*
* Foutmelding vanuit de master data generator, controleer de applicatielog
*
*/*

    CONSTANTS lc_prodid_installation TYPE epd_prodid VALUE 'ZGG_CM1'.
    CONSTANTS lc_cm_anlage TYPE epd_value VALUE 'IN_ANLAGE'.
    CONSTANTS lc_cm_sparte TYPE epd_value VALUE 'IN_SPARTE'.
    CONSTANTS lc_cm_vstelle TYPE epd_value VALUE 'IN_VSTELLE'.
    CONSTANTS lc_cm_aklasse TYPE epd_value VALUE 'IN_AKLASSE'.
    CONSTANTS lc_cm_ableinh TYPE epd_value VALUE 'IN_ABLEINH'.
    CONSTANTS lc_cm_tariftyp TYPE epd_value VALUE 'IN_TARIFTYP'.
    CONSTANTS lc_cm_ean_odn TYPE epd_value VALUE 'IN_EAN_ODN'.
    CONSTANTS lc_cm_ean_ldn TYPE epd_value VALUE 'IN_EAN_LDN'.
    CONSTANTS lc_cm_status_aansl TYPE epd_value VALUE 'IN_STATUS_AANSL'.
    CONSTANTS lc_cm_ean TYPE epd_value VALUE 'IN_EXT_UI'.
    CONSTANTS lc_cm_datefrom TYPE epd_value VALUE 'IN_DATEFROM'.
    CONSTANTS lc_cm_ab TYPE epd_value VALUE 'IN_AB'.
*    CONSTANTS lc_cm_vertrag TYPE epd_value VALUE 'IN_VERTRAG'.
*    CONSTANTS lc_cm_bukrs TYPE epd_value VALUE 'IN_BUKRS'.
*    CONSTANTS lc_cm_kofiz TYPE epd_value VALUE 'IN_KOFIZ'.
*    CONSTANTS lc_cm_vbeginn TYPE epd_value VALUE 'IN_VBEGINN'.
*    CONSTANTS lc_cm_gemfakt TYPE epd_value VALUE 'IN_GEMFAKT'.
    CONSTANTS lc_cm_vbez TYPE epd_value VALUE 'IN_VBEZ'.
    CONSTANTS lc_no_dialog TYPE e_dark VALUE 'X'.

    DATA lt_outtab    TYPE isu_prod_attr_disp_tab.
    DATA lt_container TYPE ccmcont_t.
    DATA lv_log       TYPE guid_32.
    DATA lt_new_keys  TYPE isu_prod_newobject_keys_tab.

    " lees installation velden van de MDG customizing: INSTALLATION template.
    CALL FUNCTION 'ISM_PRODUCT_READ_ATTRIBUTES'
      EXPORTING
        x_prodid        = lc_prodid_installation
      IMPORTING
        y_outtab        = lt_outtab
      EXCEPTIONS
        general_fault   = 1
        action_canceled = 2
        no_parameters   = 3
        OTHERS          = 4.

    " mogelijke data voor fout-afhandeling
    IF sy-subrc <> 0.
      ev_error_message = |Foutmelding vanuit de master data generator, controleer de applicatielog|.
      RETURN.
    ENDIF.

*/**
* lt_outab kan default-values bevatten vanuit aanroep FM
* Design-keuze: dit is momenteel niet het geval - geen default waarden vanuit Customizing
* onderstaande geneutraliseerde code kan eventueel default waarden wissen (om zeker te zijn)
* en dan begint het installatie aanmaken procs met alleen de input structuur waarden
*/*
*    LOOP AT lt_outtab INTO DATA(ls_outtab).
*      CLEAR ls_outtab-value.
*      MODIFY lt_outtab FROM ls_outtab INDEX sy-tabix.
*    ENDLOOP.
    DATA lv_date TYPE dats.
    lv_date = me->gv_start_date.
    CONCATENATE lv_date+6(2) lv_date+4(2) lv_date+0(4)
    INTO DATA(lv_date_mdg1).

    LOOP AT lt_outtab ASSIGNING FIELD-SYMBOL(<fs_output>).

      CASE <fs_output>-element.
        WHEN lc_cm_anlage.
          <fs_output>-value = is_input-anlage. " let op: wordt leeg meegegeven
        WHEN lc_cm_sparte.
          <fs_output>-value = is_input-sparte.
        WHEN lc_cm_vstelle.
          <fs_output>-value = is_input-vstelle.
        WHEN lc_cm_aklasse.
          <fs_output>-value = is_input-aklasse.
        WHEN lc_cm_ableinh.
          <fs_output>-value = is_input-ableinh.
        WHEN lc_cm_tariftyp.
          <fs_output>-value = is_input-tariftyp.
        WHEN lc_cm_ean_odn.
          <fs_output>-value = is_input-ean_odn.
        WHEN lc_cm_ean_ldn.
          <fs_output>-value = is_input-ean_ldn.
        WHEN lc_cm_status_aansl.
          <fs_output>-value = is_input-status_aansl.
        WHEN lc_cm_ean.
          <fs_output>-value = is_input-ean_id.
        WHEN lc_cm_datefrom.
          <fs_output>-value = lv_date_mdg1.
        WHEN lc_cm_ab.
          <fs_output>-value = lv_date_mdg1.
*        WHEN lc_cm_vertrag.
*          <fs_output>-value = is_input-vertrag.
*        WHEN lc_cm_bukrs.
*          <fs_output>-value = is_input-bukrs.
*        WHEN lc_cm_kofiz.
*          <fs_output>-value = is_input-kofiz.
*        WHEN lc_cm_vbeginn.
*          DATA lv_contract_date TYPE dats.
*          lv_contract_date = ( me->gv_start_date + 1 ).
*          CONCATENATE lv_contract_date+6(2) lv_contract_date+4(2) lv_contract_date+0(4)
*          INTO DATA(lv_date_mdg2).
*          <fs_output>-value = lv_date_mdg2.
*        WHEN lc_cm_gemfakt.
*          <fs_output>-value = is_input-gemfact.
*        WHEN lc_cm_vbez.
*          <fs_output>-value = is_input-vbez.

        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    " Edit MDG-template parameters.
    CALL FUNCTION 'ISM_PRODUCT_EDIT_PARAMETERS'
      EXPORTING
        x_no_dialog     = lc_no_dialog
        x_outtab        = lt_outtab
      IMPORTING
        y_container     = lt_container
      EXCEPTIONS
        general_fault   = 1
        action_canceled = 2
        no_parameters   = 3
        OTHERS          = 4.

    IF sy-subrc <> 0.
      ev_error_message = |Foutmelding vanuit de master data generator, controleer de applicatielog|.
      RETURN.
    ENDIF.

* Create installation fact.
    CALL FUNCTION 'ISU_PRODUCT_IMPLEMENT'
      EXPORTING
        x_prodid              = lc_prodid_installation
        x_container           = lt_container
      IMPORTING
        y_logid               = lv_log
      CHANGING
        xy_new_keys_tab       = lt_new_keys
      EXCEPTIONS
        general_fault         = 1
        input_error           = 2
        ambiguous_environment = 3
        OTHERS                = 4.

    IF sy-subrc = 0.

      COMMIT WORK AND WAIT.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

    ELSE.

      IF sy-subrc <> 0.
        ev_error_message = |Foutmelding vanuit de master data generator, controleer de applicatielog|.
        RETURN.
      ENDIF.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    ENDIF.


    IF sy-subrc EQ 0.
      ev_success = abap_true.  " installation created
    ELSE.
      ev_success = abap_false. " installation NOT created
    ENDIF.

  ENDMETHOD.
ENDCLASS.
