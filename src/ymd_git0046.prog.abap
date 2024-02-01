*&---------------------------------------------------------------------*
*& Report YMD_0001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0046.

TYPES: BEGIN OF ty_mutation,
         ean_zisu            TYPE ext_ui,
         ean                 TYPE ext_ui,
         bericht_type        TYPE zde_cl_berichttype,
         effectueringsdatum  TYPE dats,
         datum               TYPE erdat,
         status              TYPE zde_cl_msg_status,
         marktsegment        TYPE zmarkt_segment,
         externalreference   TYPE string,
         mutationreason      TYPE string,
         mutationdateandtime TYPE string,
         organisation        TYPE string,
         transactionid       TYPE string,
         username            TYPE string,
         dextaskid           TYPE string,
         idocnr              TYPE string,
       END OF ty_mutation.

TYPES tty_mutation TYPE STANDARD TABLE OF ty_mutation.

DATA lt_mutation        TYPE tty_mutation.
DATA ls_mutation        TYPE ty_mutation.
DATA gv_ean             TYPE zisu_poc_ean-ean.

SELECT-OPTIONS s_ean FOR gv_ean.
*PARAMETERS p_ean TYPE ext_ui DEFAULT '871687120055012144'.

INITIALIZATION.

  s_ean-sign   = 'I'.
  s_ean-option = 'BT'.
  s_ean-low    = '871687120055012000'.
  s_ean-high   = '871687120055012144'.

  APPEND s_ean TO s_ean.

*DATA ls_message TYPE zisu_poc_message.
START-OF-SELECTION.

  DATA(lr_msg) = NEW zcl_isu_poc_message( ).

*SELECT SINGLE *
*  FROM zisu_poc_message
*  INTO @DATA(ls_message)
*  WHERE ean EQ @p_ean.

*SELECT SINGLE *
*  FROM zisu_poc_message
*  INTO @DATA(ls_message)
*  WHERE ean in @s_ean.

  SELECT *
    FROM zisu_poc_message
    INTO TABLE @DATA(lt_message)
    WHERE ean IN @s_ean.

  LOOP AT lt_message
    ASSIGNING FIELD-SYMBOL(<fs_msg>).

    IF <fs_msg>-xml IS ASSIGNED.

      CALL TRANSFORMATION id
      SOURCE XML <fs_msg>-xml
      RESULT model = lr_msg.

      DATA ls_xmldata TYPE zcarmt_notify_metering_point_u.
      ls_xmldata = lr_msg->get_bericht( ).

      DATA ls_data TYPE zcardt_notify_metering_pointup.
      ls_data =  ls_xmldata-mt_notify_metering_point_updat.

      IF 1 EQ 2.
      ENDIF.

      LOOP AT ls_data-updatemutation
        INTO DATA(ls_update).

        ls_mutation = CORRESPONDING #( ls_update ).
        ls_mutation-ean_zisu = <fs_msg>-ean.
        ls_mutation-ean = ls_data-ean_id.
        ls_mutation-bericht_type = <fs_msg>-berichttype.
        ls_mutation-effectueringsdatum = <fs_msg>-effectueringsdatum.
        ls_mutation-datum = <fs_msg>-datum.
        ls_mutation-status = <fs_msg>-status.
        ls_mutation-marktsegment = <fs_msg>-marktsegment.

        APPEND ls_mutation TO lt_mutation.
        CLEAR ls_mutation.

      ENDLOOP.

      CLEAR ls_data.
    ENDIF.

  ENDLOOP.

  SORT lt_mutation BY ean_zisu DESCENDING datum DESCENDING.

  DATA lo_alv               TYPE REF TO cl_salv_table.
  DATA lo_columns           TYPE REF TO cl_salv_columns_table.
  DATA lo_functions         TYPE REF TO cl_salv_functions_list.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = lt_mutation ).
    CATCH cx_salv_msg INTO DATA(lr_message).
  ENDTRY.

  lo_functions = lo_alv->get_functions( ).
  lo_functions->set_all( ).
  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( ).
  lo_alv->display( ).
