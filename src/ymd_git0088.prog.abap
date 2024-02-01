*&---------------------------------------------------------------------*
*& Report YMD_008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0088.

*&---------------------------------------------------------------------*
*& Report  RSXMB_SUPPORT_RESTART
*&
*&---------------------------------------------------------------------*
*& Restart of messages for support
*& not allowed for productive systems because of duplicated messages
*&---------------------------------------------------------------------*
*REPORT  rsxmb_support_restart.
TABLES sxmspmast.                                           "#EC NEEDED
TABLES sxmspmast2.                                          "#EC NEEDED

DATA l_imo TYPE REF TO if_xms_message.                      "#EC NEEDED
DATA l_newguid TYPE sxmsguid.
DATA pid          TYPE sxmspidext.

PARAMETERS pguid TYPE sxmsguid OBLIGATORY.

START-OF-SELECTION.
* authority check
  PERFORM authority_check.

* load old message from database
  IF pguid IS INITIAL.
    MESSAGE e029(xms_adm).
  ENDIF.

  PERFORM read_message_from_persist
       USING pguid l_imo.
  IF l_imo IS INITIAL.
    MESSAGE e030(xms_adm).
  ENDIF.

* check if support is requested
*/**
* commented by Mike
*  PERFORM support_restart
*     USING l_imo.
*/*

* create new message from template
  PERFORM create_and_start_new_message
     USING l_imo l_newguid.

* show new message in XI monitor
  PERFORM find_new_message
     USING l_imo l_newguid.

*&--------------------------------------------------------------------*
*&      Form  support_restart
*&--------------------------------------------------------------------*
FORM support_restart
   USING l_imo TYPE REF TO if_xms_message.

  DATA l_xmb            TYPE REF TO if_xms_message_xmb.
  DATA l_dummy_plsrv_id TYPE sxmspsid.
  DATA l_ex_plsrv       TYPE REF TO cx_xms_system_error.    "#EC NEEDED
  DATA troubleshoot_ref TYPE REF TO cl_xms_troubleshoot.

  l_xmb ?= l_imo.
  l_dummy_plsrv_id = 'DUMMY'.
  CREATE OBJECT troubleshoot_ref.
  TRY.
      CALL METHOD troubleshoot_ref->if_xms_plsrv~enter_plsrv
        EXPORTING
          im_pipeline_service_id = l_dummy_plsrv_id
        CHANGING
          ch_message             = l_xmb.

    CATCH cx_xms_system_error INTO l_ex_plsrv.
      EXIT.
  ENDTRY.
  IF NOT l_imo->debug CP 'SUPPORT_RESTART_MESSAGE'.
    MESSAGE e129(xms_adm).
  ENDIF.

ENDFORM.                    "support_restart
*&--------------------------------------------------------------------*
*&      Form  read_mesage_from_persist
*&--------------------------------------------------------------------*
FORM read_message_from_persist
   USING l_guid TYPE sxmsguid
         l_imo  TYPE REF TO if_xms_message.

  DATA l_xms_main     TYPE REF TO cl_xms_main.
  DATA l_system_error TYPE REF TO cx_xms_system_error.      "#EC NEEDED
  DATA l_error_text   TYPE string.                          "#EC NEEDED
  DATA l_ro           TYPE REF TO cl_xms_run_time_env.
  DATA l_eo_ref       TYPE sxmseoref.
  DATA l_cguid        TYPE char32.

  l_xms_main = cl_xms_main=>create_xmb( ).
  CLEAR l_imo.
  PERFORM get_pid USING l_guid pid.
* reinstantiate the message-object
  TRY.
      CALL METHOD l_xms_main->read_message_from_persist
        EXPORTING
          im_message_guid = l_guid
          im_version      = '000'
          im_pipeline_id  = pid
        IMPORTING
          ex_message      = l_imo.
    CATCH cx_xms_system_error INTO l_system_error.
      l_error_text = l_system_error->get_text( ).
      MESSAGE s100(xms_adm) WITH l_error_text.
  ENDTRY.

  IF l_imo IS INITIAL.
    EXIT.
  ENDIF.
  CALL METHOD cl_xms_main=>get_message_properties
    EXPORTING
      im_message      = l_imo
    IMPORTING
      ex_run_time_env = l_ro.

  l_ro->set_user_name( sy-uname ).
  l_eo_ref-id = 'RESTART'.
  l_cguid = l_guid.
  CONCATENATE  sy-uname ':' l_cguid INTO l_eo_ref-val.
  l_ro->set_eo_ref_inbound( l_eo_ref ).
ENDFORM.                    "read_message_from_persist
*&--------------------------------------------------------------------*
*&      Form  get_pid
*&--------------------------------------------------------------------*
FORM get_pid
   USING l_guid TYPE sxmsguid
         l_pid  TYPE sxmspidext.

  SELECT SINGLE * FROM sxmspmast                            "#EC *
    WHERE msgguid = l_guid.
  IF sy-subrc = 0.
    l_pid = sxmspmast-pid.
  ELSE.
    SELECT SINGLE * FROM sxmspmast2                         "#EC *
      WHERE msgguid = l_guid.
    IF sy-subrc = 0.
      l_pid = sxmspmast2-pid.
    ELSE.
      CLEAR l_pid.
    ENDIF.
  ENDIF.

ENDFORM.                    "get_pid
*&--------------------------------------------------------------------*
*&      Form  create_and_start_new_message
*&--------------------------------------------------------------------*
FORM create_and_start_new_message
     USING l_imo     TYPE REF TO if_xms_message
           l_newguid TYPE sxmsguid.

  DATA l_xmb          TYPE REF TO if_xms_message_xmb.
  DATA l_timestamp    TYPE timestamp.
  DATA l_hlo          TYPE REF TO cl_xms_msghdr30_hoplist.
  DATA l_hlo_count    TYPE i.
  DATA l_execute_flag TYPE sxmsflag.
  DATA l_system_error TYPE REF TO cx_xms_system_error.
  DATA l_error_text   TYPE string.
  DATA l_engine        TYPE REF TO if_xms_engine.
  DATA l_im_adapter_id TYPE sxmspstype.

  l_xmb ?= l_imo.
* create Guid for the message-broker
  l_newguid = cl_xms_msg_util=>create_guid( ).
* set attributes of the message-header
  l_xmb->set_message_id( l_newguid ).
* set send date and time
  GET TIME STAMP FIELD l_timestamp.
  l_xmb->set_time_sent( l_timestamp ).

  CALL METHOD cl_xms_main=>get_message_properties
    EXPORTING
      im_message = l_imo
    IMPORTING
      ex_hoplist = l_hlo.

  IF NOT l_hlo IS INITIAL.
    DESCRIBE TABLE  l_hlo->hoplist LINES l_hlo_count.
    DELETE l_hlo->hoplist FROM l_hlo_count.
  ENDIF.

  IF pid = 'RECEIVER'.
    l_im_adapter_id = 'PLAINHTTP'.
  ENDIF.

  l_execute_flag  = '1'.
  TRY.
      l_engine = cl_xms_main=>create_engine( ).
      CALL METHOD l_engine->enter_engine
        EXPORTING
          im_execute_flag = l_execute_flag
          im_adapter_id   = l_im_adapter_id
        CHANGING
          ch_message      = l_xmb.

    CATCH cx_xms_system_error INTO l_system_error.
      l_error_text = l_system_error->get_text( ).
      MESSAGE e100(xms_adm) WITH l_error_text.
      CLEAR l_imo.
      EXIT.
  ENDTRY.
  COMMIT WORK.

ENDFORM.                    "create_and_start_new_message
*&--------------------------------------------------------------------*
*&      Form  find_new_message
*&--------------------------------------------------------------------*
FORM find_new_message
     USING l_imo     TYPE REF TO if_xms_message
           l_newguid TYPE sxmsguid.

  DATA l_xmb           TYPE REF TO if_xms_message_xmb.
  DATA l_message_class TYPE  sxmsmsgcl.
  DATA l_execute_flag  TYPE sxmsflag.                       "#EC NEEDED
  DATA l_error_code    TYPE string.
  DATA l_error_text    TYPE string.

  l_xmb ?= l_imo.
  l_message_class = l_xmb->get_message_class( ).

  IF   l_message_class =  if_xms_msghdr30_main=>co_msgclass_apperr
    OR l_message_class =  if_xms_msghdr30_main=>co_msgclass_syserr.
    l_error_text = l_xmb->get_error_text( ).
    MESSAGE e101(xms_adm) WITH l_error_code l_error_text.
    EXIT.
  ELSE.
    SELECT SINGLE * FROM sxmspmast                          "#EC *
      WHERE msgguid = l_newguid
           AND  pid = pid.
    IF sy-subrc <> 0.
      SELECT SINGLE * FROM sxmspmast2                       "#EC *
        WHERE msgguid = l_newguid
              AND pid = pid.
      IF sy-subrc <> 0.
        MESSAGE e030(xms_adm).
      ENDIF.
    ENDIF.
    PERFORM show_guid USING l_newguid.
  ENDIF.
ENDFORM.                    "find_new_message
*&--------------------------------------------------------------------*
*&      Form  show_guid
*&--------------------------------------------------------------------*
FORM show_guid
   USING l_guid TYPE idxsndpor-guid.

  DATA sel_s     TYPE rsparams.
  DATA sel_t     TYPE STANDARD TABLE OF rsparams.

* add message to selection-table
  sel_s-selname = 'MSGGUID'.
  sel_s-sign    = 'I'.
  sel_s-option  = 'EQ'.
  sel_s-low     =  l_guid.
  APPEND sel_s TO sel_t.

* add message to selection-table
  sel_s-selname = 'PIDACK'.
  sel_s-sign    = 'I'.
  sel_s-option  = 'EQ'.
  sel_s-low     =  'X'.
  APPEND sel_s TO sel_t.

  SUBMIT rsxmb_select_messages                           "#EC CI_SUBMIT
    WITH SELECTION-TABLE sel_t
    AND RETURN.

ENDFORM.                    "show_guid
*&--------------------------------------------------------------------*
*&      Form  authority_check
*&--------------------------------------------------------------------*
FORM authority_check.
  DATA: lv_allowed  TYPE sxmsflag.

* check authority "monitoring allowed ?"
  AUTHORITY-CHECK OBJECT 'S_XMB_AUTH'
    ID 'SXMBAREA' FIELD 'MESSAGE'
    ID 'ACTVT'    FIELD '03'.
  IF sy-subrc <> 0.
    AUTHORITY-CHECK OBJECT 'S_XMB_AUTH'
      ID 'SXMBAREA' FIELD 'MESSAGE'
      ID 'ACTVT'    FIELD '02'.
    IF sy-subrc <> 0.

      MESSAGE i082(xms_adm) DISPLAY LIKE 'E'.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.

* check authority "display of XML messages allowed ?"
  CALL FUNCTION 'SXMB_MONI_CHECK_AUTHORITY'
    EXPORTING
      im_activity      = '03'
    IMPORTING
      ex_authority     = lv_allowed
    EXCEPTIONS
      invalid_activity = 1
      OTHERS           = 2.

  IF ( sy-subrc <> 0 ) OR ( lv_allowed = cl_xms_main=>co_false ).
    MESSAGE i082(xms_adm) DISPLAY LIKE 'E'.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.                    "authority_check
