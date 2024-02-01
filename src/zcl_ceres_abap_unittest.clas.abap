class ZCL_CERES_ABAP_UNITTEST definition
  public
  final
  create public

  global friends ZCL_CERES_FACTORY .

public section.

  interfaces ZIF_CERES_MUTATIES .
  PROTECTED SECTION.

   CLASS-DATA mo_input TYPE REF TO zcl_ceres_input .

private section.

  data MC_TVARVC_DATE type RVARI_VNAM value 'ZCERES_LAATSTE_OPHAALDATUM' ##NO_TEXT.
  data MT_CERES_MUTATION type ZDT_POWER_GENERATING_UNIT_TAB1 .
  data MT_PROCESSING_DATES type DATUM_TAB .
  constants MC_LOG_OBJECT_CERES type BALOBJ_D value 'ZCERES' ##NO_TEXT.
  constants MC_LOG_SUBOBJECT_CERES type BALSUBOBJ value 'ZCERES_DOC' ##NO_TEXT.
  data MV_IS_RUNNING type ABAP_BOOL .

  methods DETERMINE_PROCESSING_DATES .
  methods DISPLAY_LOG .
  methods GET_MUTATIONS_FROM_CERES
    returning
      value(RETURNING) type SAP_BOOL
    raising
      CX_AI_SYSTEM_FAULT
      ZFAULT_CX_FMT_GENERIC_FAULT .
  methods SAVE_MUTATION_2_DDIC
    raising
      ZCX_CERES_MUTATIES .
  methods ACTIVATE_LOGGING .
  class-methods CREATE
    importing
      !IO_INPUT type ref to ZCL_CERES_INPUT
    returning
      value(RO_DATA) type ref to ZCL_CERES_MUTATIES .
  methods GET_CONTACT_FROM_CERES
    importing
      !IV_OBJECT_EANID type STRING optional
    returning
      value(RETURNING) type ZDT_CONTACT_INFO .
ENDCLASS.



CLASS ZCL_CERES_ABAP_UNITTEST IMPLEMENTATION.


  METHOD ACTIVATE_LOGGING.

    DATA lv_extnumber TYPE balnrext.
    DATA lv_object    TYPE balobj_d.
    DATA lv_subobject TYPE balsubobj.

    lv_extnumber = 'CERES API Interface voor Mutaties'.
    lv_object =  me->mc_log_object_ceres.
    lv_subobject = me->mc_log_subobject_ceres.

    DATA(ls_header) = VALUE bal_s_log( object    = lv_object
                                       subobject = lv_subobject
                                       extnumber = lv_extnumber
                                       aluser    = sy-uname
                                       aldate    = sy-datlo
                                       altime    = sy-timlo
 ).

    zcl_ceres_factory=>mo_msglog->create_log_with_header_data( is_header = ls_header ).

    DATA(ls_msg1) = VALUE bal_s_msg(
             msgty = 'I'
             msgid = 'ZCERES'
             msgno = '001'
             msgv1 = sy-datum
             msgv2 = sy-uzeit ).
    zcl_ceres_factory=>mo_msglog->add_msg_to_log(
      EXPORTING
            iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
            is_msg    = ls_msg1
*                  IMPORTING
*                    ev_handle =
    ).
  ENDMETHOD.


  METHOD CREATE.

    mo_input = io_input.

    ro_data = NEW zcl_ceres_mutaties( ).

  ENDMETHOD.


  METHOD DETERMINE_PROCESSING_DATES.

    DATA lv_dats_field TYPE dats.

    IF me->mo_input->ms_input-mutation_date IS NOT INITIAL.

      APPEND me->mo_input->ms_input-mutation_date TO me->mt_processing_dates.

    ELSE.

      SELECT SINGLE low
        FROM tvarvc
        INTO @DATA(lv_ceres_date)
        WHERE name EQ @me->mc_tvarvc_date.

      IF lv_ceres_date IS NOT INITIAL.

        MOVE lv_ceres_date TO lv_dats_field.
        DATA(lv_date) = lv_dats_field.
        lv_date = lv_date + 1.

        " job runs every day but in case it doesn't we collect the dates since last run
        WHILE lv_date LT sy-datum.
          APPEND lv_date TO me->mt_processing_dates.
          lv_date = lv_date + 1.
        ENDWHILE.

      ELSE.

        DATA(ls_msg1) = VALUE bal_s_msg(
                msgty = 'E'
                msgid = 'ZCERES'
                msgno = '002' ).
        zcl_ceres_factory=>mo_msglog->add_msg_to_log(
          EXPORTING
                iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
                is_msg    = ls_msg1
*                  IMPORTING
*                    ev_handle =
        ).

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD DISPLAY_LOG.

    IF me->mo_input->ms_input-show_logdata EQ abap_true.
      zcl_ceres_factory=>mo_msglog->display_msg( ).
    ELSE.
      " running in Background?
    ENDIF.

  ENDMETHOD.


  METHOD GET_CONTACT_FROM_CERES.

    DATA ls_output TYPE zmt_contact_info_req.
    DATA lr_ceres  TYPE REF TO zco_sios_get_power_generating.

    TRY.

        ls_output-mt_contact_info_req-identified_object_eanid = iv_object_eanid.

        lr_ceres->sios_get_contact_info_sync(
          EXPORTING
            output     = ls_output
          IMPORTING
            input      = DATA(ls_input)
        ).
      CATCH cx_ai_system_fault INTO DATA(lr_exception).
        DATA(ls_msg1) = VALUE bal_s_msg(
        msgty = 'E'
        msgid = 'ZCERES'
        msgno = '010'
        msgv1 = sy-datum
        msgv2 = sy-uzeit
        msgv3 = iv_object_eanid ).

        zcl_factory_dsync=>mo_msglog->add_msg_to_log(
          EXPORTING
                iv_create_log_handle = zcl_factory_dsync=>mo_msglog->mv_create_log_handle
                is_msg    = ls_msg1
*                  IMPORTING
*                    ev_handle =
        ).

*        WRITE / : |Ophalen Ceres klant data mislukt voor EAN: { iv_object_eanid }|.
        RETURN.
      CATCH zfault_cx_fmt_generic_fault.
        DATA(ls_msg2) = VALUE bal_s_msg(
        msgty = 'E'
        msgid = 'ZCERES'
        msgno = '010'
        msgv1 = sy-datum
        msgv2 = sy-uzeit
        msgv3 = iv_object_eanid ).

        zcl_factory_dsync=>mo_msglog->add_msg_to_log(
          EXPORTING
                iv_create_log_handle = zcl_factory_dsync=>mo_msglog->mv_create_log_handle
                is_msg    = ls_msg2
*                  IMPORTING
*                    ev_handle =
        ).
*        WRITE / : |Ophalen Ceres klant data mislukt voor EAN: { iv_object_eanid }|.
        RETURN.

    ENDTRY.

    IF ls_input-mt_contact_info_resp-framework_error_response-code IS NOT INITIAL.

      DATA(ls_error) = ls_input-mt_contact_info_resp-framework_error_response.
      WRITE / : |ERROR: { ls_error-message }: { ls_error-details }|.
      RETURN.

    ENDIF.

    returning = CORRESPONDING #( ls_input-mt_contact_info_resp ).

    IF  ls_input-mt_contact_info_resp-initials        IS INITIAL AND
        ls_input-mt_contact_info_resp-surname_prefix  IS INITIAL AND
        ls_input-mt_contact_info_resp-surname         IS INITIAL AND
        ls_input-mt_contact_info_resp-phone           IS INITIAL AND
        ls_input-mt_contact_info_resp-email           IS INITIAL.

      ls_input-mt_contact_info_resp-phone = '0600000000'.

    ENDIF.

  ENDMETHOD.


  METHOD GET_MUTATIONS_FROM_CERES.

    DATA ls_output TYPE zmt_filter1.
    DATA ls_input  TYPE zmt_power_generating_unit_typ2.
*   DATA lr_ceres  TYPE REF TO zco_sios_get_power_generating.

    LOOP AT me->mt_processing_dates ASSIGNING FIELD-SYMBOL(<fs_dats>).

      CLEAR ls_output.
      CLEAR ls_input.

      ls_output-mt_filter-mutation_date_time_period-start =
        |{ <fs_dats>(4) }-{ <fs_dats>+4(2) }-{ <fs_dats>+6(2) }T00:00:00.000Z|.
      ls_output-mt_filter-mutation_date_time_period-end =
        |{ <fs_dats>(4) }-{ <fs_dats>+4(2) }-{ <fs_dats>+6(2) }T23:59:59.999Z|.

      DATA(lr_ceres) = NEW zco_sios_get_power_generating1( ).

      TRY.

          lr_ceres->sios_get_power_generating_unit(
            EXPORTING
              output   = ls_output
            IMPORTING
              input    = ls_input ).

        CATCH cx_ai_system_fault.

          DATA(ls_msg1) = VALUE bal_s_msg(
          msgty = 'E'
          msgid = 'ZCERES'
          msgno = '003'
          msgv1 = <fs_dats>
          msgv2 = sy-uzeit ).

          zcl_ceres_factory=>mo_msglog->add_msg_to_log(
            EXPORTING
                  iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
                  is_msg    = ls_msg1
*                  IMPORTING
*                    ev_handle =
          ).
*          WRITE / : |Ophalen Ceres data mislukt: CX_AI_SYSTEM_FAULT: { <fs_dats> }|.
*          MESSAGE e208(00) WITH 'Error ophalen CERES data' .
          returning = abap_false.
          RETURN.

        CATCH zfault_cx_fmt_generic_fault.

          DATA(ls_msg2) = VALUE bal_s_msg(
          msgty = 'E'
          msgid = 'ZCERES'
          msgno = '004'
          msgv1 = <fs_dats>
          msgv2 = sy-uzeit ).

          zcl_ceres_factory=>mo_msglog->add_msg_to_log(
            EXPORTING
                  iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
                  is_msg    = ls_msg2
*                  IMPORTING
*                    ev_handle =
          ).

*          WRITE / : |Ophalen Ceres data mislukt: ZCOMMON_CX_FMT_GENERIC_FAULT { <fs_dats> }|.
*          MESSAGE e208(00) WITH 'Error ophalen CERES data' .
          returning = abap_false.
          RETURN.

      ENDTRY.

      IF ls_input-mt_power_generating_unit_type-error_response IS NOT INITIAL.

        DATA(ls_msg3) = VALUE bal_s_msg(
        msgty = 'E'
        msgid = 'ZCERES'
        msgno = '005'
        msgv1 = ls_input-mt_power_generating_unit_type-error_response-message
        msgv2 = sy-uzeit ).

        zcl_ceres_factory=>mo_msglog->add_msg_to_log(
          EXPORTING
                iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
                is_msg    = ls_msg3
*                  IMPORTING
*                    ev_handle =
        ).

*        WRITE / : |ERROR: { ls_input-mt_power_generating_unit_type-error_response-message }|.
*        MESSAGE e208(00) WITH 'Error ophalen CERES data' .
        returning = abap_false.
        RETURN.
      ENDIF.

      IF ls_input-mt_power_generating_unit_type-framework_error_response-code IS NOT INITIAL.

        DATA(ls_error) = ls_input-mt_power_generating_unit_type-framework_error_response.

        DATA(ls_msg4) = VALUE bal_s_msg(
        msgty = 'E'
        msgid = 'ZCERES'
        msgno = '006'
        msgv1 = ls_error-message
        msgv2 = ls_error-details ).

        zcl_ceres_factory=>mo_msglog->add_msg_to_log(
          EXPORTING
                iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
                is_msg    = ls_msg4
*                  IMPORTING
*                    ev_handle =
        ).
*        WRITE / : |ERROR: { ls_error-message }: { ls_error-details }|.
*        MESSAGE e208(00) WITH 'Error ophalen CERES data' .
        returning = abap_false.
        RETURN.
      ENDIF.

      APPEND LINES OF ls_input-mt_power_generating_unit_type-power_generating_unit_type_a
      TO me->mt_ceres_mutation.
      returning = abap_true.

      " Update TVARVC value
      IF me->mo_input->ms_input-mutation_date IS INITIAL.
        UPDATE tvarvc
          SET low = <fs_dats>
          WHERE name EQ me->mc_tvarvc_date.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD SAVE_MUTATION_2_DDIC.

    DATA lt_mutation TYPE TABLE OF zceres_mutaties.

    IF me->mo_input->ms_input-test_mode EQ abap_true.

      DATA(ls_msg1) = VALUE bal_s_msg(
              msgty = 'I'
              msgid = 'ZCERES'
              msgno = '007'
              ).
      zcl_ceres_factory=>mo_msglog->add_msg_to_log(
        EXPORTING
              iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
              is_msg    = ls_msg1
*                  IMPORTING
*                    ev_handle =
      ).
*      WRITE / : |CERES Data is opgehaald, deze kan via SXMB_MONI worden bekeken|.
*      WRITE / : |Programma wordt nu gestopt...|.
      RETURN.
    ENDIF.

    DATA(lv_records) = 0.

    LOOP AT me->mt_ceres_mutation
      ASSIGNING FIELD-SYMBOL(<fs_unit>).

      IF <fs_unit>-metering_point_eanid IS NOT INITIAL. " Aangelegd/gemuteerd via CERES website

        APPEND INITIAL LINE TO lt_mutation ASSIGNING FIELD-SYMBOL(<fs_mutation>).

        <fs_mutation> = CORRESPONDING #( <fs_unit> ).

        <fs_mutation>-asset_in_use_date =
          |{ <fs_unit>-asset_in_use_date(4) }{ <fs_unit>-asset_in_use_date+5(2) }{ <fs_unit>-asset_in_use_date+8(2) }|.

        IF <fs_unit>-asset_out_of_use_date IS NOT INITIAL.
          <fs_mutation>-asset_out_of_use_date =
           |{ <fs_unit>-asset_out_of_use_date(4) }{ <fs_unit>-asset_out_of_use_date+5(2) }{ <fs_unit>-asset_out_of_use_date+8(2) }|.
        ENDIF.

        <fs_mutation>-isu_create_date = sy-datum.
        <fs_mutation>-isu_create_name = sy-uname.

        IF <fs_unit>-identified_object_eanid IS INITIAL.
          " EAN needed for contactdata
          CONTINUE.
        ENDIF.

        DATA(ls_contact) = me->get_contact_from_ceres( <fs_unit>-identified_object_eanid ).
        <fs_mutation>-initials       = ls_contact-initials.
        <fs_mutation>-surname_prefix = ls_contact-surname_prefix.
        <fs_mutation>-surname        = ls_contact-surname.
        <fs_mutation>-phone          = ls_contact-phone.
        <fs_mutation>-email          = ls_contact-email.

*        <fs_mutation>-mutated_at =
*        <fs_mutation>-registered_by_kvk =
*        <fs_mutation>-compliance_state =
*        <fs_mutation>-INITIAL_COMPLIANCE_DATE_TIME =
*        <fs_mutation>-segment    =

        lv_records = lv_records + 1.

      ENDIF.
    ENDLOOP.

    INSERT zceres_mutaties FROM TABLE lt_mutation.

    IF sy-subrc NE 0.

      DATA(ls_msg2) = VALUE bal_s_msg(
        msgty = 'I'
        msgid = 'ZCERES'
        msgno = '008'
        ).
      zcl_ceres_factory=>mo_msglog->add_msg_to_log(
        EXPORTING
          iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
          is_msg    = ls_msg2
*                  IMPORTING
*                    ev_handle =
      ).

      DATA: ls_t100_key TYPE scx_t100key.
      ls_t100_key-msgid = 'ZCERES'.
      ls_t100_key-msgno = '008'.

      RAISE RESUMABLE EXCEPTION TYPE zcx_ceres_mutaties
        EXPORTING
          textid = ls_t100_key
*         previous =
        .
    ENDIF.

    DATA(ls_msg3) = VALUE bal_s_msg(
       msgty = 'I'
       msgid = 'ZCERES'
       msgno = '009'
       msgv1  = sy-dbcnt
       ).
    zcl_ceres_factory=>mo_msglog->add_msg_to_log(
      EXPORTING
            iv_create_log_handle = zcl_ceres_factory=>mo_msglog->mv_create_log_handle
            is_msg    = ls_msg3
*                  IMPORTING
*                    ev_handle =
    ).
*    WRITE / : |Registraties weggeschreven naar database: { lines( lt_mutation ) }|.

    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD ZIF_CERES_MUTATIES~IS_RUNNING.
    rv_is = mv_is_running.
  ENDMETHOD.


  METHOD ZIF_CERES_MUTATIES~START_APP.

    me->activate_logging( ).
    me->determine_processing_dates( ).

    TRY.
        DATA(lv_ceres_if_succes) = me->get_mutations_from_ceres( ).

      CATCH BEFORE UNWIND zcx_ceres_mutaties INTO DATA(lo_exc).
*     MESSAGE lo_exc TYPE 'I'.
        RESUME.
    ENDTRY.

    IF lv_ceres_if_succes EQ abap_false.
      " do not continue processing - just show log
    ELSE.
      me->save_mutation_2_ddic( ).
    ENDIF.

    me->display_log( ).

  ENDMETHOD.
ENDCLASS.
