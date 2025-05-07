CLASS ycl_test_super_01 DEFINITION
  PUBLIC
* FINAL   // final means no Sub Classes possible
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS update
      IMPORTING
        !is_ean            TYPE zstr_poc_ean
      RETURNING
        VALUE(rs_bapiret2) TYPE bapiret2
      EXCEPTIONS
        update_failed
        update_hist_failed .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_test_super_01 IMPLEMENTATION.

  METHOD update.

  ENDMETHOD.

ENDCLASS.
