*&---------------------------------------------------------------------*
*& Report YMD_GIT0183
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0183.

DATA ls_logkeys TYPE bapialf.
DATA it_logdata TYPE TABLE OF bapialg.
DATA it_logkeys  TYPE TABLE OF bapialf.

" Construct the BAPI tabl
ls_logkeys-lognumber = '00000000000997445229' . " '0001464655'.  " ls_applog-appl_log.
APPEND ls_logkeys TO it_logkeys.

" Get the messages from application log
CALL FUNCTION 'BAPI_APPLICATIONLOG_GETDETAIL'
  EXPORTING
    language   = sy-langu
    textformat = 'ASC'
  TABLES
    logkeys    = it_logkeys
    logdata    = it_logdata.

IF 1 EQ 2.
ENDIF.
