*&---------------------------------------------------------------------*
*& Report YMD_1001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YMD_GIT0063.

CLASS cx_demo DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

CLASS cls DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS meth RAISING cx_demo.
ENDCLASS.

CLASS cls IMPLEMENTATION.
  METHOD meth.
    ...
    RAISE EXCEPTION TYPE cx_demo.
    ...
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  TRY.
      cls=>meth( ).
    CATCH cx_demo.
      cl_demo_output=>display( 'Catching exception' ).
  ENDTRY.
