*&---------------------------------------------------------------------*
*& Report YMD_069
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0170.

DATA(lv_zakenpartner) = '0010008234'.

SELECT *
  UP TO 10 ROWS
   INTO TABLE @DATA(lt_datatab)
   FROM zdsync_sap_ean
   WHERE zakenpartner EQ @lv_zakenpartner.
*     AND caseid NE '0000000000'.


DATA(lv_path) = '/interface/MFT/sap/DNW/DataSync/'.
DATA(lv_file) = |{ lv_zakenpartner }_{ sy-datum }_WOCOBULK_TEST_XML.dat|.   " TYPE rlgrap-filename

CONCATENATE lv_path lv_file INTO DATA(lv_filename).

CALL TRANSFORMATION id SOURCE zdsync_sap_ean = lt_datatab
                       RESULT XML DATA(xml).

" Open the file for output
OPEN DATASET lv_filename FOR OUTPUT IN BINARY MODE.

IF sy-subrc NE 0.
  MESSAGE 'Bestand kon niet worden weggeschreven naar de SAP Server' TYPE 'I' DISPLAY LIKE 'S'.
  EXIT.
ENDIF.

" Write line items to file
TRANSFER xml TO lv_filename.

" Close the file
CLOSE DATASET lv_filename.

CLEAR xml.
OPEN DATASET lv_filename FOR INPUT IN BINARY MODE.
READ DATASET lv_filename INTO xml.
CLOSE DATASET lv_filename.

TRY.
    CALL TRANSFORMATION id SOURCE XML xml
                         RESULT zdsync_sap_ean = lt_datatab.
ENDTRY.

cl_demo_output=>display( lt_datatab ).

 DELETE DATASET lv_filename.
