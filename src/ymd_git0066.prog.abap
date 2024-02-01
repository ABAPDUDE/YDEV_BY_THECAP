*&---------------------------------------------------------------------*
*& Report YMD_1003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0066.

CLASS cx_demo DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

CLASS cls DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS meth RAISING RESUMABLE(cx_demo).
ENDCLASS.

CLASS cls IMPLEMENTATION.
  METHOD meth.
    ...
    RAISE RESUMABLE EXCEPTION TYPE cx_demo.
    cl_demo_output=>display( 'Resumed ...' ).
    ...
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  TRY.
      cls=>meth( ).
    CATCH BEFORE UNWIND cx_demo.
      RESUME.
  ENDTRY.
