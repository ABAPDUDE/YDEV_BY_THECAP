*&---------------------------------------------------------------------*
*& Report YMD_0012
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0042.


*/**
* Class: ZCL_VZC_WEBFORM
* Method: CHECK_SALESORDER_1
* line 59
* Jira-1906 KH 22-01-2022: Status <> 18 toegevoegd omdat bij die status terecht geen order wordt aangemaakt
*/*

DATA(go_test) = NEW ycl_test_exceptions( ).

START-OF-SELECTION.

  TRY.

*      go_test->test_catch( ).
*    CATCH cx_sy_conversion_no_number.

     go_test->test_catch_system_exceptions( ).

*     go_test->test_catch_into( ).

  ENDTRY.

  IF 1 EQ 2.
  ENDIF.
