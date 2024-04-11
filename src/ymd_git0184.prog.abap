*&---------------------------------------------------------------------*
*& Report YMD_GIT0184
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0184.

DATA: lv_number_of_logs LIKE sy-tabix.

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
TYPES tty_msg TYPE STANDARD TABLE OF ty_msg.

DATA lt_msg TYPE tty_msg.

" Message parameters
TYPES: BEGIN OF ty_msgpara,
         include TYPE balmp.
TYPES END OF ty_msgpara.
TYPES tty_msgpara TYPE STANDARD TABLE OF ty_msgpara.

DATA lt_msgpara TYPE tty_msgpara.


CALL FUNCTION 'APPL_LOG_READ_DB'
  EXPORTING
    object             = 'ZDWLOG'
    subobject          = ' '
    external_number    = '0001464655'
  IMPORTING
    number_of_logs     = lv_number_of_logs
  TABLES
    header_data        = lt_header
    header_parameters  = lt_headpara
    messages           = lt_msg
    message_parameters = lt_msgpara.

*/**
DATA: BEGIN OF p_header_data_tab OCCURS 0.
    INCLUDE STRUCTURE balhdr.
DATA: END OF p_header_data_tab.

DATA: BEGIN OF p_header_para_tab OCCURS 0.
    INCLUDE STRUCTURE balhdrp.
DATA: END OF p_header_para_tab.

DATA: BEGIN OF p_message_tab OCCURS 0.
    INCLUDE STRUCTURE balm.
DATA: END OF p_message_tab.

DATA: BEGIN OF p_message_para_tab OCCURS 0.
    INCLUDE STRUCTURE balmp.
DATA: END OF p_message_para_tab.


CALL FUNCTION 'APPL_LOG_READ_DB'
  EXPORTING
    object             = 'ZDWLOG'
    subobject          = ' '
    external_number    = '0001464655'
  IMPORTING
    number_of_logs     = lv_number_of_logs
  TABLES
    header_data        = p_header_data_tab
    header_parameters  = p_header_para_tab
    messages           = p_message_tab
    message_parameters = p_message_para_tab.

IF 1 EQ 2.
ENDIF.
