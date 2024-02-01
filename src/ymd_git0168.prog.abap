*&---------------------------------------------------------------------*
*& Report YMD_066
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0168.

DATA lv_xstring TYPE xstring.
FIELD-SYMBOLS: <fs_data> TYPE ANY TABLE.

DATA(lv_zakenpartner) = '0010008234'.

SELECT *
  UP TO 10 ROWS
   INTO TABLE @DATA(lt_datatab)
   FROM zdsync_sap_ean
   WHERE zakenpartner EQ @lv_zakenpartner.
*     AND caseid NE '0000000000'.


DATA(lv_path) = '/interface/MFT/sap/DNW/DataSync/'.
DATA(lv_file) = |{ lv_zakenpartner }_{ sy-datum }_WOCOBULK_EXCEL.xlsx|.   " TYPE rlgrap-filename

CONCATENATE lv_path lv_file INTO DATA(lv_filename).

GET REFERENCE OF lt_datatab INTO DATA(lo_data_ref).

ASSIGN lo_data_ref->* TO <fs_data>.

TRY.
    cl_salv_table=>factory(
      IMPORTING r_salv_table = DATA(lo_table)
      CHANGING  t_table      = <fs_data> ).

    DATA(lt_fcat) =
      cl_salv_controller_metadata=>get_lvc_fieldcatalog(
        r_columns      = lo_table->get_columns( )
        r_aggregations = lo_table->get_aggregations( ) ).

    DATA(lo_result) =
      cl_salv_ex_util=>factory_result_data_table(
        r_data         = lo_data_ref
        t_fieldcatalog = lt_fcat ).

    cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform(
      EXPORTING
        xml_type      = if_salv_bs_xml=>c_type_xlsx
        xml_version   = cl_salv_bs_a_xml_base=>get_version( )
        r_result_data = lo_result
        xml_flavour   = if_salv_bs_c_tt=>c_tt_xml_flavour_export
        gui_type      = if_salv_bs_xml=>c_gui_type_gui
      IMPORTING
        xml           = lv_xstring ).
  CATCH cx_root.
    CLEAR lv_xstring.
ENDTRY.

" Open the file for output
OPEN DATASET lv_filename FOR OUTPUT IN BINARY MODE.

IF sy-subrc NE 0.
  MESSAGE 'Bestand kon niet worden weggeschreven naar de SAP Server' TYPE 'I' DISPLAY LIKE 'S'.
  EXIT.
ENDIF.

" Write line items to file
TRANSFER lv_xstring TO lv_filename.

" Close the file
CLOSE DATASET lv_filename.
