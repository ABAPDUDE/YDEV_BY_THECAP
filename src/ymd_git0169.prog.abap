*&---------------------------------------------------------------------*
*& Report YMD_069
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0169.

DATA(lv_zakenpartner) = '0010008234'.

SELECT *
  UP TO 10 ROWS
   INTO TABLE @DATA(lt_datatab)
   FROM zdsync_sap_ean
   WHERE zakenpartner EQ @lv_zakenpartner.
*     AND caseid NE '0000000000'.

DATA(lv_path) = '/interface/MFT/sap/DNW/DataSync/'.
DATA(lv_file) = |{ lv_zakenpartner }_{ sy-datum }_WOCOBULK_TEST_TEXT.txt|.   " TYPE rlgrap-filename

CONCATENATE lv_path lv_file INTO DATA(lv_filename).

" Open the file for output
OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

IF sy-subrc NE 0.
  MESSAGE 'Bestand kon niet worden weggeschreven naar de SAP Server' TYPE 'I' DISPLAY LIKE 'S'.
  EXIT.
ENDIF.

" Write line items to file
LOOP AT lt_datatab
  INTO DATA(ls_data).

  TRANSFER ls_data TO lv_filename.

ENDLOOP.

" Close the file
CLOSE DATASET lv_filename.


CLEAR lt_datatab[].

DATA lv_string TYPE string.

OPEN DATASET lv_filename FOR INPUT IN TEXT MODE ENCODING DEFAULT.
DO.
  READ DATASET lv_filename INTO ls_data.
  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    APPEND ls_data TO lt_datatab.
    CLEAR ls_data.
  ENDIF.
ENDDO.

CLOSE DATASET lv_filename.

cl_demo_output=>display( lt_datatab ).

DELETE DATASET lv_filename.
