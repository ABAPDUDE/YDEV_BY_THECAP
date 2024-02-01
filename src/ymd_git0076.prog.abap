*&---------------------------------------------------------------------*
*& Report YMD_305
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0076.

DATA lt_string TYPE TABLE OF string.

cl_gui_frontend_services=>gui_upload(
   EXPORTING
     filename                = 'C:\Users\al24361\OneDrive - Alliander NV\Documents\Liander Projecten\Flanderijn\Test-Data\Test-Data\networkoperatordossier-202.json'
      filetype                = 'ASC'
*    has_field_separator     = SPACE
*    header_length           = 0
*    read_by_line            = 'X'
*    dat_mode                = SPACE
*    codepage                = SPACE
*    ignore_cerr             = ABAP_TRUE
*    replacement             = '#'
*    virus_scan_profile      =
*  IMPORTING
*    filelength              =
*    header                  =
   CHANGING
     data_tab                = lt_string
   EXCEPTIONS
     file_open_error         = 1
     file_read_error         = 2
     no_batch                = 3
     gui_refuse_filetransfer = 4
     invalid_type            = 5
     no_authority            = 6
     unknown_error           = 7
     bad_data_format         = 8
     header_not_allowed      = 9
     separator_not_allowed   = 10
     header_too_long         = 11
     unknown_dp_error        = 12
     access_denied           = 13
     dp_out_of_memory        = 14
     disk_full               = 15
     dp_timeout              = 16
     not_supported_by_gui    = 17
     error_no_gui            = 18
     OTHERS                  = 19
        ).
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
