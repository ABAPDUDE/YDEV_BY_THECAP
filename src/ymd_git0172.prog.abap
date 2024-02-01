*&---------------------------------------------------------------------*
*& Report YMD_072
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0172.

DATA : lv_filename      TYPE string,
       lt_records       TYPE solix_tab,
       lv_headerxstring TYPE xstring,
       lv_filelength    TYPE i.

*lv_filename = p_file.
*
*CALL FUNCTION 'GUI_UPLOAD'
*  EXPORTING
*    filename                = lv_filename
*    filetype                = 'BIN'
*  IMPORTING
*    filelength              = lv_filelength
*    header                  = lv_headerxstring
*  TABLES
*    data_tab                = lt_records
*  EXCEPTIONS
*    file_open_error         = 1
*    file_read_error         = 2
*    no_batch                = 3
*    gui_refuse_filetransfer = 4
*    invalid_type            = 5
*    no_authority            = 6
*    unknown_error           = 7
*    bad_data_format         = 8
*    header_not_allowed      = 9
*    separator_not_allowed   = 10
*    header_too_long         = 11
*    unknown_dp_error        = 12
*    access_denied           = 13
*    dp_out_of_memory        = 14
*    disk_full               = 15
*    dp_timeout              = 16
*    OTHERS                  = 17.
