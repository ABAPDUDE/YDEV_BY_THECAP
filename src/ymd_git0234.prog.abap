*&---------------------------------------------------------------------*
*& Report YMD_GIT0234
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0234.

*/**
*  This BAPI creates a move-in document in the system
*  BAPI_ISUMOVEIN_CREATEFROMDATA
*
*  To fill the import parameters of this BAPI
*  ISU_MOVE_IN_BAPI_GET_DEFAULTS
*
*  toepassing voorbeeld in INCLUDE  - LEWEBIAC_MOVE_INF01
*
*  Function group ES60 -> FM ISU_REMOVAL_MOVEIN_CREATE
*
*
*/*
PARAMETERS p_vertrg TYPE vertrag.
PARAMETERS p_vbegin TYPE e_vbeginn DEFAULT '20250501'.
PARAMETERS p_paytyp TYPE char1 DEFAULT 'B'.
PARAMETERS p_vkont  TYPE vkont_kk DEFAULT '3008260124'.
PARAMETERS p_kklass TYPE ktoklasse DEFAULT 'ZM'.
PARAMETERS p_gpart  TYPE bu_partner DEFAULT '25111296'.
PARAMETERS p_midate TYPE dats DEFAULT '20250501'.
PARAMETERS p_anlage TYPE anlage DEFAULT '6502173869'.
PARAMETERS p_bukrs  TYPE bukrs DEFAULT '7000'.
PARAMETERS p_sparte TYPE sparte DEFAULT 'CE'.
PARAMETERS p_kofiz  TYPE e_kofiz DEFAULT '01'.
PARAMETERS p_gemfak TYPE e_gemfakt DEFAULT '2'.

" data declaration
DATA lv_gpart      TYPE bu_partner.
DATA lv_vkont      TYPE vkont_kk.
DATA lv_moveindate TYPE dats.
DATA lv_paytype    TYPE char1.


DATA ls_eiac_ser_move_in        TYPE eiac_ser_move_in.
DATA ls_eiac_move_in            TYPE eiac_move_in.
DATA lt_eiac_move_in            TYPE STANDARD TABLE OF eiac_move_in.
DATA ls_eiac_move_in1           TYPE eiac_move_in1.
DATA lt_eiac_move_in1           TYPE STANDARD TABLE OF eiac_move_in1.
DATA ls_moveincreatecontroldata TYPE bapiisumoveincr_c.

DATA lt_return TYPE bapiret2_tab.


DATA lt_address       TYPE iebapiisubpa.
DATA lt_addressx      TYPE iebapiisubpax.
DATA lt_bankdata      TYPE iebapiisubpb.
DATA lt_bankdatax     TYPE iebapiisubpbx.
DATA lt_ccarddata     TYPE iebapiisubpc.
DATA lt_ccarddatax    TYPE iebapiisubpcx.
DATA ls_contractdatax TYPE bapiisucontractx.
DATA lt_contractdata  TYPE cod_util_isucontract.
DATA ls_contractdata  TYPE bapiisucontract.
DATA lt_contractdatax TYPE cod_util_isucontractx.

DATA ls_moveincreateinputdata TYPE bapiisumoveincr_i.
DATA ls_partnerdata           TYPE bapiisubpd.
DATA ls_partnerdatax          TYPE bapiisubpdx.
DATA ls_contractaccountdata   TYPE bapiisuvkp.
DATA ls_contractaccountdatax  TYPE bapiisuvkpx.

DATA lv_moveindocnumber TYPE einzbeleg.
DATA lt_result          TYPE iebapieablu.

"  values for partner type
CONSTANTS lco_bu_type_person TYPE bu_type VALUE '1'.
CONSTANTS lco_bu_type_org    TYPE bu_type VALUE '2'.
CONSTANTS lco_bu_type_group  TYPE bu_type VALUE '3'.

"  Values relevant to creation Move In Document
lv_paytype = p_paytyp.
lv_vkont = p_vkont.
lv_gpart = p_gpart.
lv_moveindate = p_midate.

ls_contractdata-contract = p_vertrg.
ls_contractdata-installation = p_anlage.
ls_contractdata-comp_code = p_bukrs.
ls_contractdata-division = p_sparte.
ls_contractdata-contr_start = p_vbegin.
ls_contractdata-actdeterid = p_kofiz.
ls_contractdata-joint_invoice = p_gemfak.
APPEND ls_contractdata TO lt_contractdata.

ls_contractaccountdata-account_class = p_kklass.
ls_contractaccountdata-partner = lv_gpart.

" Determination relevant Move In Data
IF ( lv_gpart IS INITIAL ).
  " create partner in move-in
  ls_moveincreatecontroldata-partnercreate = abap_true.
ELSE.
  ls_moveincreateinputdata-partner = lv_gpart.
*    l_partnerdatax = co_x.
ENDIF.

IF ( lv_vkont IS INITIAL ).
* create contract account in move-in
  ls_moveincreatecontroldata-contractaccountcreate = abap_true.
ELSE.
  ls_moveincreateinputdata-cont_acct = lv_vkont.
ENDIF.

"  testing purposes
ls_moveincreatecontroldata-testrun               = abap_true.
ls_moveincreatecontroldata-partnerstdaddradjust  = abap_true.
ls_moveincreatecontroldata-partnerstdaddradjustx = abap_true.

"  set move-in create data
ls_moveincreateinputdata-moveindate      = lv_moveindate.
ls_moveincreateinputdata-partner         = lv_gpart.
ls_moveincreateinputdata-partnercategory = lco_bu_type_org.
ls_moveincreateinputdata-cont_acct       = lv_vkont.

CLEAR lt_addressx[].
APPEND INITIAL LINE TO lt_addressx.

IF ( lv_paytype = 'B' ).
  CLEAR lt_bankdatax[].
  APPEND INITIAL LINE TO lt_bankdatax.
ELSE.
  CLEAR lt_ccarddatax[].
  APPEND INITIAL LINE TO  lt_ccarddatax.
ENDIF.

"  set contract data
LOOP AT lt_contractdata
INTO ls_contractdata.

  CLEAR ls_contractdatax.
  ls_contractdatax-installation = abap_true.
  APPEND ls_contractdatax TO lt_contractdatax.

ENDLOOP.

MOVE-CORRESPONDING ls_eiac_move_in  TO ls_partnerdata.
ls_partnerdatax = abap_true.
MOVE-CORRESPONDING lt_eiac_move_in1 TO lt_address.
* append lt_address.
IF ( lv_paytype = 'B' ).
  MOVE-CORRESPONDING lt_eiac_move_in TO lt_bankdata.
* APPEND lt_bankdata.
ELSE.
  MOVE-CORRESPONDING lt_eiac_move_in TO lt_ccarddata.
*  APPEND lt_ccarddata.
ENDIF.

CALL FUNCTION 'ISU_MOVE_IN_BAPI_GET_DEFAULTS'
  EXPORTING
    x_refmidoc              = ls_eiac_ser_move_in-refmidoc
    x_autbankidcr           = abap_true
    moveincreatecontroldata = ls_moveincreatecontroldata
  TABLES
    treturn                 = lt_return
    taddress                = lt_address
    taddressx               = lt_addressx
    tbankdata               = lt_bankdata
    tbankdatax              = lt_bankdatax
    tccarddata              = lt_ccarddata
    tccarddatax             = lt_ccarddatax
*   TCTRACLOCKDETAIL        =
    tcontractdata           = lt_contractdata
    tcontractdatax          = lt_contractdatax
*   EXTENSIONIN             =
  CHANGING
    moveincreateinputdata   = ls_moveincreateinputdata
    partnerdata             = ls_partnerdata
    contractaccountdata     = ls_contractaccountdata
*   CONTACTDATA             =
    partnerdatax            = ls_partnerdatax
    contractaccountdatax    = ls_contractaccountdatax
  EXCEPTIONS
    action_failed           = 1
    OTHERS                  = 2.

IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.


* if ( lv_paytype = 'B' ).
*    lt_bankdatax = abap_true.
*    append lt_bankdatax.
*  else.
*    lt_ccarddatax = abap_true.
*    append lt_ccarddatax.
*  endif.


CALL FUNCTION 'BAPI_ISUMOVEIN_CREATEFROMDATA'
  EXPORTING
    moveincreatecontroldata = ls_moveincreatecontroldata
    moveincreateinputdata   = ls_moveincreateinputdata
    partnerdata             = ls_partnerdata
    partnerdatax            = ls_partnerdatax
    contractaccountdata     = ls_contractaccountdata
    contractaccountdatax    = ls_contractaccountdatax
*   contactdata             =
  IMPORTING
    moveindocnumber         = lv_moveindocnumber
  TABLES
    treturn                 = lt_return
    taddress                = lt_address
    taddressx               = lt_addressx
    tbankdata               = lt_bankdata
    tbankdatax              = lt_bankdatax
    tccarddata              = lt_ccarddata
    tccarddatax             = lt_ccarddatax
    tcontractdata           = lt_contractdata
    tcontractdatax          = lt_contractdatax
    tmeterreadingresults    = lt_result
*   tctraclockdetail        =
*   extensionin             =
  .

IF ( lv_moveindocnumber IS INITIAL ).
  LOOP AT lt_return
  INTO DATA(ls_return).

  ENDLOOP.                           " at lt_return
ELSE.
  COMMIT WORK.
ENDIF.


*/**
*  onderstaande code kan los in een methode worden gezet
*/*

*    " data declaration
*    DATA lv_gpart      TYPE bu_partner.
*    DATA lv_vkont      TYPE vkont_kk.
*    DATA lv_moveindate TYPE dats.
*    DATA lv_paytype    TYPE char1.
*
*
*    DATA ls_eiac_ser_move_in        TYPE eiac_ser_move_in.
*    DATA ls_eiac_move_in            TYPE eiac_move_in.
*    DATA lt_eiac_move_in            TYPE STANDARD TABLE OF eiac_move_in.
*    DATA ls_eiac_move_in1           TYPE eiac_move_in1.
*    DATA lt_eiac_move_in1           TYPE STANDARD TABLE OF eiac_move_in1.
*    DATA ls_moveincreatecontroldata TYPE bapiisumoveincr_c.
*    DATA lt_return TYPE bapiret2_tab.
*
*    DATA lt_address       TYPE iebapiisubpa.
*    DATA lt_addressx      TYPE iebapiisubpax.
*    DATA lt_bankdata      TYPE iebapiisubpb.
*    DATA lt_bankdatax     TYPE iebapiisubpbx.
*    DATA lt_ccarddata     TYPE iebapiisubpc.
*    DATA lt_ccarddatax    TYPE iebapiisubpcx.
*    DATA ls_contractdatax TYPE bapiisucontractx.
*    DATA lt_contractdata  TYPE cod_util_isucontract.
*    DATA ls_contractdata  TYPE bapiisucontract.
*    DATA lt_contractdatax TYPE cod_util_isucontractx.
*
*    DATA ls_moveincreateinputdata TYPE bapiisumoveincr_i.
*    DATA ls_partnerdata           TYPE bapiisubpd.
*    DATA ls_partnerdatax          TYPE bapiisubpdx.
*    DATA ls_contractaccountdata   TYPE bapiisuvkp.
*    DATA ls_contractaccountdatax  TYPE bapiisuvkpx.
*
*    DATA lv_moveindocnumber TYPE einzbeleg.
*    DATA lt_result          TYPE iebapieablu.
*
*    "  values for partner type
*    CONSTANTS lco_bu_type_person TYPE bu_type VALUE '1'.
*    CONSTANTS lco_bu_type_org    TYPE bu_type VALUE '2'.
*    CONSTANTS lco_bu_type_group  TYPE bu_type VALUE '3'.
*
*    "  Values relevant to creation Move In Document
** lv_vkont = '3008260124'.
*    lv_paytype = 'B'.
*    lv_gpart = iv_bp.
*    lv_moveindate = sy-datum.
*
**ls_contractdata-contract = iv_vertrg.
*    ls_contractdata-installation = iv_anlage.
*    ls_contractdata-comp_code = '7000'.
*    ls_contractdata-division = 'CE'.
*    ls_contractdata-contr_start = sy-datum.
*    ls_contractdata-actdeterid = '01'.
*    ls_contractdata-joint_invoice = '2'.
*
*    APPEND ls_contractdata TO lt_contractdata.
*
*    " Determination relevant Move In Data
*    IF ( lv_gpart IS INITIAL ).
*      " create partner in move-in
*      ls_moveincreatecontroldata-partnercreate = abap_true.
*    ELSE.
*      ls_moveincreateinputdata-partner = lv_gpart.
**    l_partnerdatax = co_x.
*    ENDIF.
*
*    IF ( lv_vkont IS INITIAL ).
** create contract account in move-in
*      ls_moveincreatecontroldata-contractaccountcreate = abap_true.
*    ELSE.
*      ls_moveincreateinputdata-cont_acct = lv_vkont.
*    ENDIF.
*
*    "  testing purposes
*    ls_moveincreatecontroldata-testrun               = abap_true.
*    ls_moveincreatecontroldata-partnerstdaddradjust  = abap_true.
*    ls_moveincreatecontroldata-partnerstdaddradjustx = abap_true.
*
*    "  set move-in create data
*    ls_moveincreateinputdata-moveindate      = lv_moveindate.
*    ls_moveincreateinputdata-partner         = lv_gpart.
*    ls_moveincreateinputdata-partnercategory = lco_bu_type_org.
*    ls_moveincreateinputdata-cont_acct       = lv_vkont.
*
*    CLEAR lt_addressx[].
*    APPEND INITIAL LINE TO lt_addressx.
*
*    IF ( lv_paytype = 'B' ).
*      CLEAR lt_bankdatax[].
*      APPEND INITIAL LINE TO lt_bankdatax.
*    ELSE.
*      CLEAR lt_ccarddatax[].
*      APPEND INITIAL LINE TO  lt_ccarddatax.
*    ENDIF.
*
*    "  set contract data
*    LOOP AT lt_contractdata
*    INTO ls_contractdata.
*
*      CLEAR ls_contractdatax.
*      ls_contractdatax-installation = abap_true.
*      APPEND ls_contractdatax TO lt_contractdatax.
*
*    ENDLOOP.
*
*    MOVE-CORRESPONDING ls_eiac_move_in  TO ls_partnerdata.
*    ls_partnerdatax = abap_true.
*    MOVE-CORRESPONDING lt_eiac_move_in1 TO lt_address.
** append lt_address.
*    IF ( lv_paytype = 'B' ).
*      MOVE-CORRESPONDING lt_eiac_move_in TO lt_bankdata.
** APPEND lt_bankdata.
*    ELSE.
*      MOVE-CORRESPONDING lt_eiac_move_in TO lt_ccarddata.
**  APPEND lt_ccarddata.
*    ENDIF.
*
*
*    CALL FUNCTION 'ISU_MOVE_IN_BAPI_GET_DEFAULTS'
*      EXPORTING
*        x_refmidoc              = ls_eiac_ser_move_in-refmidoc
*        x_autbankidcr           = abap_true
*        moveincreatecontroldata = ls_moveincreatecontroldata
*      TABLES
*        treturn                 = lt_return
*        taddress                = lt_address
*        taddressx               = lt_addressx
*        tbankdata               = lt_bankdata
*        tbankdatax              = lt_bankdatax
*        tccarddata              = lt_ccarddata
*        tccarddatax             = lt_ccarddatax
**       TCTRACLOCKDETAIL        =
*        tcontractdata           = lt_contractdata
*        tcontractdatax          = lt_contractdatax
**       EXTENSIONIN             =
*      CHANGING
*        moveincreateinputdata   = ls_moveincreateinputdata
*        partnerdata             = ls_partnerdata
*        contractaccountdata     = ls_contractaccountdata
**       CONTACTDATA             =
*        partnerdatax            = ls_partnerdatax
*        contractaccountdatax    = ls_contractaccountdatax
*      EXCEPTIONS
*        action_failed           = 1
*        OTHERS                  = 2.
*
*    IF sy-subrc <> 0.
**   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.
*
*
** if ( lv_paytype = 'B' ).
**    lt_bankdatax = abap_true.
**    append lt_bankdatax.
**  else.
**    lt_ccarddatax = abap_true.
**    append lt_ccarddatax.
**  endif.
*
*
*    CALL FUNCTION 'BAPI_ISUMOVEIN_CREATEFROMDATA'
*      EXPORTING
*        moveincreatecontroldata = ls_moveincreatecontroldata
*        moveincreateinputdata   = ls_moveincreateinputdata
*        partnerdata             = ls_partnerdata
*        partnerdatax            = ls_partnerdatax
*        contractaccountdata     = ls_contractaccountdata
*        contractaccountdatax    = ls_contractaccountdatax
**       contactdata             =
*      IMPORTING
*        moveindocnumber         = lv_moveindocnumber
*      TABLES
*        treturn                 = lt_return
*        taddress                = lt_address
*        taddressx               = lt_addressx
*        tbankdata               = lt_bankdata
*        tbankdatax              = lt_bankdatax
*        tccarddata              = lt_ccarddata
*        tccarddatax             = lt_ccarddatax
*        tcontractdata           = lt_contractdata
*        tcontractdatax          = lt_contractdatax
*        tmeterreadingresults    = lt_result
**       tctraclockdetail        =
**       extensionin             =
*      .
*
*    IF ( lv_moveindocnumber IS INITIAL ).
*
*      LOOP AT lt_return
*      INTO DATA(ls_return).
*        ev_error_message = ls_return-message.
*      ENDLOOP.                           " at lt_return
*
*    ELSE.
*
*      COMMIT WORK.
*
*      ev_success = abap_true.
*      ev_movein_doc = lv_moveindocnumber.
*
*    ENDIF.
