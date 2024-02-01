*&---------------------------------------------------------------------*
*& Report YMD_077
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0142.

PARAMETERS: p_file TYPE localfile DEFAULT 'C:\Users\al24361\OneDrive - Alliander NV\Documents\SAP\SAP GUI\TEST-MIKE-001_ITAB.xlsx'.
PARAMETERS: p_pword TYPE char8 DEFAULT '12345678'.

DATA: obj_ex_sheet TYPE ole2_object, obj_ex_app TYPE ole2_object.
DATA: obj_ex_wbook   TYPE ole2_object, obj_ex_wsheet1 TYPE ole2_object.

DATA: ole_books  TYPE ole2_object,
      ole_sheets TYPE ole2_object,
      errcode    LIKE sy-subrc.

*  start excel
CREATE OBJECT obj_ex_sheet 'EXCEL.SHEET'.
IF sy-subrc NE 0.
  errcode = sy-subrc.
  FREE OBJECT obj_ex_sheet.
  PERFORM error_handling_ms_excel USING p_file errcode.
ENDIF.

CALL METHOD OF obj_ex_sheet 'Application' = obj_ex_app.
IF sy-subrc NE 0.
  errcode = sy-subrc.
  FREE OBJECT obj_ex_app.
  FREE OBJECT obj_ex_sheet.
  PERFORM error_handling_ms_excel USING p_file errcode.
ENDIF.

*SET PROPERTY OF obj_ex_app 'Visible' = 1.
CALL METHOD OF obj_ex_app 'Workbooks' = ole_books.

*  open data file
CALL METHOD OF ole_books 'Open' = obj_ex_wbook
    EXPORTING #1  = p_file
              #2  = 0
              #3  = 0
              #4  = 0
              #5  = 0
              #6  = 0
              #7  = 0.

CALL METHOD OF obj_ex_wbook 'SaveAs'
  EXPORTING
    #1 = p_file           "filename
    #2 = 1                "fileFormat
    #3 = p_pword.        "password

FORM error_handling_ms_excel USING VALUE(filename) VALUE(subrc).
  CASE subrc.
    WHEN  0.
      EXIT.
    WHEN  1.
      PERFORM free_ole_objects.
      PERFORM delete_data_file USING filename.
      RAISE communication_error.
    WHEN  2.
      PERFORM free_ole_objects.
      PERFORM delete_data_file USING filename.
      RAISE ole_object_method_error.
    WHEN  3.
      PERFORM free_ole_objects.
      PERFORM delete_data_file USING filename.
      RAISE ole_object_property_error.
    WHEN  4.
      PERFORM free_ole_objects.
      PERFORM delete_data_file USING filename.
      RAISE ole_object_property_error.
  ENDCASE.
ENDFORM.

FORM delete_data_file USING VALUE(filename).

  DATA: fname TYPE string.
  DATA rc TYPE i.

  fname = filename.

* delete the file
  CALL METHOD cl_gui_frontend_services=>file_delete
    EXPORTING
      filename = fname
    CHANGING
      rc       = rc
    EXCEPTIONS
      OTHERS   = 0.

* flush to execute the deletion
  CALL METHOD cl_gui_cfw=>flush.

*  DATA: MY_SUBRC LIKE SY-SUBRC.
*
*  CALL FUNCTION 'WS_FILE_DELETE'
*       EXPORTING
*            FILE    = FILENAME
*       IMPORTING
*            RETURN  = MY_SUBRC
*       EXCEPTIONS
*            OTHERS  = 1.
*
*    IF SY-SUBRC <> 0 AND MY_SUBRC <> 0.
*    ENDIF.


ENDFORM.                    " DELETE_DAT_FILE

FORM free_ole_objects.
  FREE OBJECT  obj_ex_wbook.
  FREE OBJECT  obj_ex_wsheet1.
*  FREE OBJECT  obj_ex_wsheet2.
*  FREE OBJECT  obj_ex_cell.
*  FREE OBJECT  obj_ex_usedrange1.
*  FREE OBJECT  obj_ex_range.
*  FREE OBJECT  obj_ex_window1.
*  FREE OBJECT  obj_ex_window2.
*  FREE OBJECT  obj_ex_return.
*  FREE OBJECT  obj_ex_cell2.
*  FREE OBJECT  obj_ex_usedrange2.
*  FREE OBJECT  obj_ex_pivot_field.
*  FREE OBJECT  obj_ex_range2.
*  FREE OBJECT  obj_ex_wsheets.
*  FREE OBJECT  obj_ex_pivot.
  FREE OBJECT  obj_ex_app.
  FREE OBJECT  obj_ex_sheet.
*  FREE OBJECT  obj_ex_startcell.
ENDFORM.                    " FREE_OLE_OBJECTS
