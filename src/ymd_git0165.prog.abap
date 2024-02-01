*&---------------------------------------------------------------------*
*& Report YMD_065
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0165.

DATA gt_tab TYPE ztt_ean_dsync.
DATA lt_fieldcat TYPE slis_t_fieldcat_alv.
DATA ls_fieldcat LIKE LINE OF lt_fieldcat.

TYPES: BEGIN OF lty_field,
         field TYPE reptext,
       END OF lty_field.
DATA lt_fields TYPE TABLE OF lty_field.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS:
  pa_file TYPE rlgrap-filename OBLIGATORY DEFAULT 'C:\TEMP\test_password_excel_part2.xlsx'.
SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME         =
*     I_INTERNAL_TABNAME     =
      i_structure_name       = 'ZST_EAN_DSYNC'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT lt_fieldcat INTO ls_fieldcat.
    APPEND ls_fieldcat-reptext_ddic TO lt_fields.
  ENDLOOP.

  SELECT *
  FROM zdsync_sap_ean
    INTO CORRESPONDING FIELDS OF TABLE gt_tab
    WHERE zakenpartner EQ '0025011754'.

  CALL FUNCTION 'MS_EXCEL_OLE_STANDARD_DAT'
    EXPORTING
      file_name                 = pa_file
*     CREATE_PIVOT              = 0
      DATA_SHEET_NAME           = 'WOCO SAP/IS-U Alliander'
*     PIVOT_SHEET_NAME          = ' '
      password                  = 'woco22'
      password_option           = 1
    TABLES
*     PIVOT_FIELD_TAB           =
      data_tab                  = gt_tab
      fieldnames                = lt_fields
    EXCEPTIONS
      file_not_exist            = 1
      filename_expected         = 2
      communication_error       = 3
      ole_object_method_error   = 4
      ole_object_property_error = 5
      invalid_pivot_fields      = 6
      download_problem          = 7
      OTHERS                    = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
