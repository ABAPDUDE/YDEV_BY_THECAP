*&---------------------------------------------------------------------*
*& Report YMD_075
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0175.

DATA: lo_exception    TYPE REF TO cx_root.

DATA: lo_excel_writer         TYPE REF TO /bsar/if_xls_writer.

DATA: lo_excel         TYPE REF TO /bsar/cl_xls,
      lo_worksheet     TYPE REF TO /bsar/cl_xls_worksheet,
      column_dimension TYPE REF TO /bsar/cl_xls_wks_columndime.

DATA: ls_table_settings       TYPE /bsar/xls_s_table_settings.

DATA: lv_file                 TYPE xstring.

DATA: lv_error TYPE string.

DATA: lv_title TYPE /bsar/xls_sheet_title,
      lt_carr  TYPE TABLE OF scarr,
      row      TYPE /bsar/xls_cell_row VALUE 2,
      lo_range TYPE REF TO /bsar/cl_xls_range.
DATA: lo_data_validation  TYPE REF TO /bsar/cl_xls_data_validation.

CONSTANTS: gc_save_file_name TYPE string VALUE 'TEST-MIKE-001_ITAB.xlsx'.
INCLUDE /bsar/demo_xls_outputopt_incl.

START-OF-SELECTION.


  " Creates active sheet
  CREATE OBJECT lo_excel.

  " test data
  DATA(lv_zakenpartner) = '0010008234'.

  DATA(lv_path) = '/interface/MFT/sap/DNW/DataSync/'.
  DATA(lv_name) = |{ lv_zakenpartner }_{ sy-datum }_WOCOBULK_EXCEL.xlsx|.   " TYPE rlgrap-filename

  CONCATENATE lv_path lv_name INTO DATA(lv_filename).

  SELECT *
    UP TO 20 ROWS
     INTO TABLE @DATA(lt_datatab)
     FROM zdsync_sap_ean
     WHERE zakenpartner EQ @lv_zakenpartner
       AND caseid NE '0000000000'.


  lo_excel->/bsar/if_xls_book_prot~initialize( ).
  lo_excel->/bsar/if_xls_book_prot~protected        = /bsar/if_xls_book_prot=>c_protected.
  lo_excel->/bsar/if_xls_book_prot~workbookpassword = 'DAA7'."it is the encoded word "secret"
  lo_excel->/bsar/if_xls_book_prot~lockrevision  = /bsar/if_xls_book_prot=>c_locked.
  lo_excel->/bsar/if_xls_book_prot~lockstructure = /bsar/if_xls_book_prot=>c_locked.
  lo_excel->/bsar/if_xls_book_prot~lockwindows   = /bsar/if_xls_book_prot=>c_locked.

  " Get active sheet
  lo_worksheet = lo_excel->get_active_worksheet( ).

  lo_worksheet->/bsar/if_xls_sheet_prot~protected  = /bsar/if_xls_sheet_prot=>c_protected.
  lo_worksheet->/bsar/if_xls_sheet_prot~password   = 'DAA7'. "it is the encoded word "secret"
*  lo_worksheet->/BSAR/IF_XLS_SHEET_PROT~password   = /BSAR/CL_XLS_COMMON=>encrypt_password( p_pwd ).
  lo_worksheet->/bsar/if_xls_sheet_prot~sheet      = /bsar/if_xls_sheet_prot=>c_active.
  lo_worksheet->/bsar/if_xls_sheet_prot~objects    = /bsar/if_xls_sheet_prot=>c_active.
  lo_worksheet->/bsar/if_xls_sheet_prot~scenarios  = /bsar/if_xls_sheet_prot=>c_active.

  lo_worksheet->set_title( ip_title = 'Contractloos 1ste e-mail' ).

  ls_table_settings-table_style       = /bsar/cl_xls_table=>builtinstyle_medium2.
  ls_table_settings-show_row_stripes  = abap_true.
  ls_table_settings-nofilters         = abap_true.

  lo_worksheet->bind_table( ip_table          = lt_datatab
                            is_table_settings = ls_table_settings ).

  lo_worksheet->freeze_panes( ip_num_rows = 3 ). "freeze column headers when scrolling

  column_dimension = lo_worksheet->get_column_dimension( ip_column = 'E' ). "make date field a bit wider
  column_dimension->set_width( ip_width = 11 ).

  CREATE OBJECT lo_excel_writer TYPE /bsar/cl_xls_writer_2007.
  lv_file = lo_excel_writer->write_file( lo_excel ).

*** Create output
  lcl_output=>output( lo_excel ).

*
*  TRY.
*      OPEN DATASET lv_filename FOR OUTPUT IN BINARY MODE.
*      TRANSFER lv_file  TO lv_filename.
*      CLOSE DATASET lv_filename.
*    CATCH cx_root INTO lo_exception.
*      lv_error = lo_exception->get_text( ).
*      MESSAGE lv_error TYPE 'I'.
*  ENDTRY.
