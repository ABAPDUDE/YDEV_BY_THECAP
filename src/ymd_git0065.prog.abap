*&---------------------------------------------------------------------*
*& Report YMD_1002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0065.

CLASS cx_demo DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

START-OF-SELECTION.

  TRY.
      TRY.
          RAISE EXCEPTION TYPE cx_demo.
        CATCH cx_demo INTO DATA(exc).
          cl_demo_output=>write( 'Inner CATCH' ).
          RAISE EXCEPTION exc.
      ENDTRY.
    CATCH cx_demo.
      cl_demo_output=>write( 'Outer CATCH' ).
  ENDTRY.

  cl_demo_output=>display( ).
