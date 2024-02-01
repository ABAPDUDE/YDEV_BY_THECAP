*&---------------------------------------------------------------------*
*& Report YMD_GIT0003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0003.


PARAMETERS pa_ean TYPE ext_ui DEFAULT '871687119500494086'.

DATA(lv_verbruiksplaats) = zcl_verbruiksplaats=>get_verbruiksplaats_met_ean( iv_ext_ui = pa_ean ).

DATA(lt_adres) = zcl_adres=>get_adres_met_verbruiksplaats( iv_vstelle = lv_verbruiksplaats ).

DATA lo_alv               TYPE REF TO cl_salv_table.
DATA lo_columns           TYPE REF TO cl_salv_columns_table.
DATA lo_functions         TYPE REF TO cl_salv_functions_list.

TRY.
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = lt_adres ).
  CATCH cx_salv_msg INTO DATA(lr_message).
ENDTRY.

lo_functions = lo_alv->get_functions( ).
lo_functions->set_all( ).
lo_columns = lo_alv->get_columns( ).
lo_columns->set_optimize( ).
lo_alv->display( ).
