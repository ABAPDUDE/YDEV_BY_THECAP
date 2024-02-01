*&---------------------------------------------------------------------*
*& Report YMD_016
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0096.

DATA gs_param TYPE zst_excel_upload.
DATA gt_input TYPE ztt_input_meterstanden.

PARAMETERS: p_file  TYPE localfile OBLIGATORY
DEFAULT 'C:\Users\al24361\OneDrive - Alliander NV\Documents\report_usage_data11 Test.xlsx'.

START-OF-SELECTION.

  gs_param-header_row_count      = '1'.
  gs_param-local_file_path       = p_file.
  gs_param-max_rows              = '2000'.

  DATA(lo_input) = NEW zcl_exl_2_abap_input( gs_param ).
  DATA(lo_app) = NEW zcl_exl_2_abap( lo_input ).
  gt_input[] = lo_app->start_app( ).

  DATA(lv_lines) = lines( gt_input ).
  IF lv_lines GT 0.

    " some data consistency checks
    LOOP AT gt_input
      ASSIGNING FIELD-SYMBOL(<fs_input>).

      IF <fs_input>-datum_sap IS INITIAL.
        WRITE / : |Datum { <fs_input>-datum } is ongeldig, format YYYY-MM-DD verwacht|.
        CONTINUE.
      ENDIF.
      IF <fs_input>-meter IS INITIAL.
        WRITE / : |Voor { <fs_input>-datum } ontbreekt de meter|.
        CONTINUE.
      ENDIF.
      IF <fs_input>-meterstand IS INITIAL OR
         <fs_input>-meterstand EQ 'NULL' .
        WRITE / : |Voor { <fs_input>-datum } ontbreekt de meterstand|.
        CONTINUE.
      ENDIF.
      IF <fs_input>-meterstand CO '1234567890'.
        WRITE / : |Voor { <fs_input>-datum } bestaat de meterstand voor meter { <fs_input>-meter } niet uit 0-9|.
        CONTINUE.
      ENDIF.

      IF <fs_input>-telwerk IS INITIAL.
        WRITE / : |Voor { <fs_input>-datum } ontbreekt de telwerkcode voor meter { <fs_input>-meter } |.
        CONTINUE.
      ENDIF.
      IF strlen( <fs_input>-telwerk ) LT 5.
        WRITE / : |Voor { <fs_input>-datum } voor meter { <fs_input>-meter } is telwerkcode { <fs_input>-telwerk } ongeldig |.
        CONTINUE.
      ENDIF.

    ENDLOOP.
  ENDIF.


*  PARAMETERS: p_file  TYPE localfile OBLIGATORY.
*  CONSTANTS: gc_delimiter   VALUE '|'.
*
*  DATA: lt_table      TYPE TABLE OF string.
*  lv_file = p_file.
*
*    CALL FUNCTION 'FAA_FILE_UPLOAD_EXCEL'
*    EXPORTING
*      i_filename           = lv_file
*      i_delimiter          = gc_delimiter
*    TABLES
*      et_filecontent       = lt_table
*    EXCEPTIONS
*      error_accessing_file = 1
*      OTHERS               = 2.
*
*  LOOP AT lt_table ASSIGNING FIELD-SYMBOL(<fs_table>).
*    SPLIT <fs_table> AT gc_delimiter
*   INTO  DATA(ls_input-datum)
*         DATA(ls_input-meter)
*         DATA(ls_input-telwerk)
*         DATA(ls_input-meterstand).
*    IF sy-tabix EQ 1 AND
*       ls_input-datum EQ 'Datum'.
*      CONTINUE.
*    ENDIF.
*  ENDLOOP.
