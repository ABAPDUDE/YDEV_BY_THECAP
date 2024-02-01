*&---------------------------------------------------------------------*
*& Report YMD_074
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0174.

TYPES : BEGIN OF ty_tab1,
          plant      TYPE bapi2017_gm_item_create-plant,
          stge_loc   TYPE bapi2017_gm_item_create-stge_loc,
          material   TYPE bapi2017_gm_item_create-material,
          quantity   TYPE bapi2017_gm_item_create-quantity,
          base_uom   TYPE bapi2017_gm_item_create-base_uom,
          costcenter TYPE bapi2017_gm_item_create-costcenter,
        END OF ty_tab1.

DATA : t_dynpfields TYPE STANDARD TABLE OF dynpread.
DATA:  w_t_dynpfields TYPE dynpread.

DATA : it_tab TYPE STANDARD TABLE OF alsmex_tabline,
       wa_tab TYPE alsmex_tabline.
DATA : it_tab2 TYPE STANDARD TABLE OF ty_tab1,
       wa_tab2 TYPE ty_tab1.
DATA :BEGIN OF wa_srcdata,
        recno(5)         TYPE n, "record serial number
        plant            LIKE bapi2017_gm_item_create-plant,
        storage_location LIKE bapi2017_gm_item_create-stge_loc,
        material         LIKE bapi2017_gm_item_create-material,
        consumption_qty  LIKE bapi2017_gm_item_create-entry_qnt,
        base_uom         LIKE bapi2017_gm_item_create-entry_uom_iso,
        cost_center      LIKE bapi2017_gm_item_create-costcenter,
      END OF wa_srcdata.
DATA : gt_srcdata LIKE TABLE OF wa_srcdata.
DATA : BEGIN OF wa_errlog,
         recno    LIKE wa_srcdata-recno,
         msg_type LIKE bapiret2-type,
         message  LIKE bapiret2-message,
       END OF wa_errlog.
DATA : gt_errlog  LIKE TABLE OF wa_errlog,
       success_no LIKE wa_srcdata-recno.
DATA : gm_item    TYPE STANDARD TABLE OF bapi2017_gm_item_create,
       wa_gm_item TYPE bapi2017_gm_item_create.
DATA : goodsmvt_serialnumber    TYPE STANDARD TABLE OF bapi2017_gm_serialnumber,
       wa_goodsmvt_serialnumber TYPE bapi2017_gm_serialnumber.
DATA : gm_return    TYPE STANDARD TABLE OF bapiret2,
       wa_gm_return TYPE bapiret2.
DATA : gm_header  LIKE bapi2017_gm_head_01,
       gm_code    LIKE bapi2017_gm_code,
       gm_headret LIKE bapi2017_gm_head_ret,
       gm_retmtd  TYPE bapi2017_gm_head_ret-mat_doc,
       wa_return  LIKE bapiret2.
DATA: path LIKE dxfields-longpath,
      file TYPE rlgrap-filename.
DATA : l_repid LIKE d020s-prog,
       l_scrnr LIKE d020s-dnum.
DATA : appli_server.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
PARAMETER: file_nm TYPE localfile.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN SKIP.
PARAMETER : prest RADIOBUTTON GROUP r1,"default 'X'.
appli RADIOBUTTON GROUP r1.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  t1 = 'Details'.
  gm_code = '03'.
  prest = 'X'.
  l_repid = sy-repid.
  l_scrnr = 1000.
  w_t_dynpfields-fieldname = 'APPLI'.
  APPEND w_t_dynpfields TO t_dynpfields.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR file_nm.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = l_repid
      dynumb     = l_scrnr
*     translate_to_upper = ' '
*     REQUEST    = ' '
*     PERFORM_CONVERSION_EXITS = ' '
*     PERFORM_INPUT_CONVERSION = ' '
*     DETERMINE_LOOP_INDEX = ' '
    TABLES
      dynpfields = t_dynpfields
    EXCEPTIONS
*     INVALID_ABAPWORKAREA = 1
*     INVALID_DYNPROFIELD = 2
*     INVALID_DYNPRONAME = 3
*     INVALID_DYNPRONUMMER = 4
*     INVALID_REQUEST    = 5
*     NO_FIELDDESCRIPTION = 6
*     INVALID_PARAMETER  = 7
*     UNDEFIND_ERROR     = 8
*     DOUBLE_CONVERSION  = 9
*     STEPL_NOT_FOUND    = 10
      OTHERS     = 11.

  IF sy-subrc <> 0.
* message id sy-msgid type sy-msgty number sy-msgno
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.ENDIF.
    READ TABLE t_dynpfields INTO w_t_dynpfields INDEX 1.
    IF sy-subrc = 0.
      appli_server = w_t_dynpfields-fieldvalue.
    ENDIF.
    IF appli_server = ' '.
      CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
        EXPORTING
*      * PROGRAM_NAME = SYST-REPID
*         DYNPRO_NUMBER = SYST-DYNNR
*         FIELD_NAME    = ' 'STATIC = 'X'* MASK = ' 'CHANGING
          file_name     = file_nm
        EXCEPTIONS
          mask_too_long = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
      CALL FUNCTION 'F4_DXFILENAME_TOPRECURSION'
        EXPORTING
          i_location_flag = 'A'
          i_server        = ''
          i_path          = '/'
          filemask        = '.'
*         fileoperation   = 'R'
*importing
*         o_location_flag =
* O_SERVER =O_PATH = PATH* ABEND_FLAG =
        EXCEPTIONS
          rfc_error       = 1
          error_with_gui  = 2
          OTHERS          = 3.

      IF sy-subrc <> 0.
* message id sy-msgid type sy-msgty number sy-msgno
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.ENDIF.
        file_nm = path.
      ENDIF.
    ENDIF.
  ENDIF.
*------------------------------------------
*start-of-selection
*--------------------------------------------START-OF-SELECTION.
  IF appli = 'X'.
    PERFORM application_server.
  ELSE.
    PERFORM presentation_server.
  ENDIF.

*  PERFORM posting_data.
*&---------------------------------------------------------------------*
*& Form presentation_server
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM presentation_server .

  REFRESH it_tab2[].
  CLEAR wa_tab2.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = file_nm
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '10'
      i_end_row               = '35'
    TABLES
      intern                  = it_tab
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT it_tab INTO wa_tab.
    CASE wa_tab-col.
      WHEN '001'.
        wa_tab2-plant = wa_tab-value.
      WHEN '002'.
        wa_tab2-stge_loc = wa_tab-value.
      WHEN '003'.
        wa_tab2-material = wa_tab-value.
      WHEN '004'.
        wa_tab2-quantity = wa_tab-value.
      WHEN '005'.
        wa_tab2-base_uom = wa_tab-value.
      WHEN '006'.
        wa_tab2-costcenter = wa_tab-value.
    ENDCASE.
    AT END OF row.
      APPEND wa_tab2 TO it_tab2.
      CLEAR wa_tab2.
    ENDAT.
  ENDLOOP.

ENDFORM. " presentation_server
*&---------------------------------------------------------------------*
*& Form application_server
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM application_server .
  TYPE-POOLS: kcde.
  DATA : lt_intern TYPE kcde_cells OCCURS 0 WITH HEADER LINE.
*DATA : INTERN1 TYPE KCDE_INTERN.FILE = PATH.
  OPEN DATASET file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
**--- DISPLAY ERROR MESSAGES IF ANY.
  IF sy-subrc NE 0.
    MESSAGE e001(zsd_mes).
    EXIT.
* endif.
  ELSE.
    DO.
      READ DATASET file INTO wa_tab.
      APPEND wa_tab TO it_tab.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDDO.
    CLEAR wa_tab.
    LOOP AT it_tab INTO wa_tab.
      CASE wa_tab-col.
        WHEN '0001'.
          wa_tab2-plant = wa_tab-value.
        WHEN '0002'.
          wa_tab2-stge_loc = wa_tab-value.
        WHEN '0003'.
          wa_tab2-material = wa_tab-value.
        WHEN '0004'.
          wa_tab2-quantity = wa_tab-value.
        WHEN '0005'.
          wa_tab2-base_uom = wa_tab-value.
        WHEN '0006'.
          wa_tab2-costcenter = wa_tab-value.
      ENDCASE.
      AT END OF row.
        APPEND wa_tab2 TO it_tab2.
        CLEAR wa_tab2.
      ENDAT.
      CLEAR wa_tab.
    ENDLOOP.
  ENDIF.
  CLOSE DATASET file.
ENDFORM. " application_server
