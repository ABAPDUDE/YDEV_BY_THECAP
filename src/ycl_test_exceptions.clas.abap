class YCL_TEST_EXCEPTIONS definition
  public
  final
  create public .

public section.

  methods TEST_CATCH
    raising
      CX_SY_CONVERSION_NO_NUMBER .
  methods TEST_CATCH_INTO
    raising
      CX_SY_CONVERSION_NO_NUMBER .
  methods TEST_CATCH_SYSTEM_EXCEPTIONS .
protected section.
private section.
ENDCLASS.



CLASS YCL_TEST_EXCEPTIONS IMPLEMENTATION.


  METHOD test_catch.

    DATA ls_workload_e TYPE zst_isu_poc_workload.

    CONSTANTS mc_check_order_s18 TYPE char3 VALUE 'S18'.


    ls_workload_e-status = '18'.

    "Jira-1906 KH 22-01-2022: Status <> 18 toegevoegd omdat bij die status terecht geen order wordt aangemaakt
*    TRY.

    IF ls_workload_e-status NE mc_check_order_s18.

    ENDIF.

*      CATCH cx_sy_conversion_no_number.

*    ENDTRY.
  ENDMETHOD.


  METHOD test_catch_into.

    DATA ls_workload_e TYPE zst_isu_poc_workload.
    DATA error_ref TYPE REF TO cx_sy_conversion_no_number.
    DATA err_text TYPE string.
    CONSTANTS mc_check_order_s18 TYPE char3 VALUE 'S18'.


    ls_workload_e-status = '18'.

    "Jira-1906 KH 22-01-2022: Status <> 18 toegevoegd omdat bij die status terecht geen order wordt aangemaakt
    TRY.

        IF ls_workload_e-status NE mc_check_order_s18.

        ENDIF.

      CATCH cx_sy_conversion_no_number INTO error_ref.
        err_text = error_ref->get_text( ).
        WRITE err_text.
    ENDTRY.

  ENDMETHOD.


  METHOD test_catch_system_exceptions.

    DATA ls_workload_e TYPE zst_isu_poc_workload.

    CONSTANTS mc_check_order_s18 TYPE char3 VALUE 'S18'.

    ls_workload_e-status = '18'.

    "Jira-1906 KH 22-01-2022: Status <> 18 toegevoegd omdat bij die status terecht geen order wordt aangemaakt
*    TRY.
    CATCH SYSTEM-EXCEPTIONS convt_no_number = 7
       OTHERS = 10.

      IF ls_workload_e-status NE mc_check_order_s18.

      ENDIF.



      CASE sy-subrc.
        WHEN '7'.
        WHEN OTHERS.
      ENDCASE.

    ENDCATCH.

  ENDMETHOD.
ENDCLASS.
