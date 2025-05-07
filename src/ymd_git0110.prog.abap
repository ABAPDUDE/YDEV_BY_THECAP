*&---------------------------------------------------------------------*
*& Report YMD_git0110
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0110.

DATA: lv_number_of_logs LIKE sy-tabix.

PARAMETERS p_extnr TYPE balnrext.

" Log header data
TYPES: BEGIN OF ty_header,
         include TYPE balhdr.
TYPES END OF ty_header.
TYPES tty_header TYPE STANDARD TABLE OF ty_header.

DATA lt_header TYPE tty_header.

" Log parameters
TYPES: BEGIN OF ty_headpara,
         include TYPE balhdrp.
TYPES END OF ty_headpara.
TYPES tty_headpara TYPE STANDARD TABLE OF ty_headpara.

DATA lt_headpara TYPE tty_headpara.

" Log messages
TYPES: BEGIN OF ty_msg,
         include TYPE balm.
TYPES END OF ty_msg.
TYPES tty_msg TYPE STANDARD TABLE OF ty_msg WITH NON-UNIQUE KEY include-lognumber.

DATA lt_msg TYPE tty_msg.

" Message parameters
TYPES: BEGIN OF ty_msgpara,
         include TYPE balmp.
TYPES END OF ty_msgpara.
TYPES tty_msgpara TYPE STANDARD TABLE OF ty_msgpara.

DATA lt_msgpara TYPE tty_msgpara.

CALL FUNCTION 'APPL_LOG_READ_DB'
  EXPORTING
    object             = ''
    subobject          = ''
    external_number    = p_extnr    "  iv_external_id
  IMPORTING
    number_of_logs     = lv_number_of_logs
  TABLES
    header_data        = lt_header
    header_parameters  = lt_headpara
    messages           = lt_msg
    message_parameters = lt_msgpara.

DATA go_alv               TYPE REF TO cl_salv_table.
DATA go_columns           TYPE REF TO cl_salv_columns_table.
DATA go_functions         TYPE REF TO cl_salv_functions_list.

SORT lt_msg BY include-lognumber DESCENDING.
READ TABLE lt_msg
INTO DATA(ls_msg)
INDEX 1.
DELETE lt_msg WHERE include-lognumber NE ls_msg-include-lognumber.
SORT lt_msg BY include-msgnumber ASCENDING.

TRY.
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = go_alv
      CHANGING
        t_table      = lt_msg ).
  CATCH cx_salv_msg INTO DATA(lr_message).
ENDTRY.

go_functions = go_alv->get_functions( ).
go_functions->set_all( ).
go_columns = go_alv->get_columns( ).
go_columns->set_optimize( ).
go_alv->display( ).
