*&---------------------------------------------------------------------*
*& Report YMD_050
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0150.


*data gr_object type ZCL_DATA_VALUE_CONV_OBJECT.
*data gv_value_sap type Z_DATA_VAL_CONV_INT_VAL_TAB.
*
*DATA(go_data) = zcl_data_value_conv_object( X_APPLICATION = 'CERES'
*                                            X_DOMNAME = 'INSTAL_TYPE').
*  go_data->CONVERT_TO_INTERNAL( x_external =
*                                YT_VALUE =
DATA lv_value TYPE char100.
DATA lt_valuetab TYPE z_data_val_conv_int_val_tab.

TRY.

    DATA(lr_object) = NEW zcl_ceres_conversie(
        x_application = 'CERES'
        x_domname     = 'INSTAL_TYPE'
    ).

    lr_object->convert_to_internal(
      EXPORTING
        x_external                = 'B16'
      IMPORTING
        yt_value                  = lt_valuetab
        y_value                   = lv_value
    ).
*  CATCH zcx_data_conversion_error.    "
ENDTRY.

IF 1 EQ 2.
ELSE.
ENDIF.
