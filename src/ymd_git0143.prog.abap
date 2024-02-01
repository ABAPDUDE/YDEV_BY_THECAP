*&---------------------------------------------------------------------*
*& Report YMD_076
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0143.

*/**
* Rich Heilman
*/*

INCLUDE ole2incl.

DATA: e_sheet TYPE ole2_object.
DATA: e_appl  TYPE ole2_object.
DATA: e_work  TYPE ole2_object.
DATA: e_cell  TYPE ole2_object.
DATA: e_wbooklist TYPE ole2_object.

DATA: field_value(30) TYPE c.

PARAMETERS: p_file TYPE localfile DEFAULT 'C:\Users\al24361\OneDrive - Alliander NV\Documents\SAP\SAP GUI\TEST-MIKE-003_ITAB.xls'.

START-OF-SELECTION.

* Start the application
  CREATE OBJECT e_appl 'EXCEL.APPLICATION'.
  SET PROPERTY OF e_appl 'VISIBLE' = 0.

* Open the file
  CALL METHOD OF e_appl 'WORKBOOKS' = e_wbooklist.
  GET PROPERTY OF e_wbooklist 'Application' = e_appl .
  SET PROPERTY OF e_appl 'SheetsInNewWorkbook' = 1 .
  CALL METHOD OF e_wbooklist 'Add' = e_work .
  GET PROPERTY OF e_appl 'ActiveSheet' = e_sheet .
  SET PROPERTY OF e_sheet 'Name' = 'Test' .

* Write data to the excel file
  DO 20 TIMES.

* Create the value
    field_value  = sy-index.
    SHIFT field_value LEFT DELETING LEADING space.
    CONCATENATE 'Cell' field_value INTO field_value SEPARATED BY space.

* Position to specific cell  in  Column 1
    CALL METHOD OF e_appl 'Cells' = e_cell
           EXPORTING
                #1 = sy-index
                #2 = 1.
* Set the value
    SET PROPERTY OF e_cell 'Value' = field_value .


* Position to specific cell  in  Column 2
    CALL METHOD OF e_appl 'Cells' = e_cell
           EXPORTING
                #1 = sy-index
                #2 = 2.
* Set the value
    SET PROPERTY OF e_cell 'Value' = field_value .


* Position to specific cell  in  Column 3
    CALL METHOD OF e_appl 'Cells' = e_cell
           EXPORTING
                #1 = sy-index
                #2 = 3.
* Set the value
    SET PROPERTY OF e_cell 'Value' = field_value .

  ENDDO.

** Close the file
  GET PROPERTY OF e_appl 'ActiveWorkbook' = e_work.
  CALL METHOD OF e_work 'SAVEAS'
    EXPORTING
      #1 = p_file
      #2 = 1           "" Don't ask me when closing
      #3 = 'rich'    "" Password
      #4 = 'rich'.     "" Reserved for Password</b>

  CALL METHOD OF e_work 'close'.

* Quit the file
  CALL METHOD OF e_appl 'QUIT'.

* Free them up
  FREE OBJECT e_cell.
  FREE OBJECT e_sheet.
  FREE OBJECT e_work.
  FREE OBJECT e_wbooklist.
  FREE OBJECT e_appl.
