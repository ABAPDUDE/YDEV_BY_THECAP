*&---------------------------------------------------------------------*
*& Report YMD_082
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0137.

START-OF-SELECTION.

  TRY.
      zcl_sow_utilities=>convert_edsn_date_time( EXPORTING i_datumsap      = sy-datum
                                                 IMPORTING e_datumtijdedsn = DATA(lv_dattijd)
                                                           e_datumedsn     = DATA(lv_datum)                            ).
    CATCH zcx_sow_utilities.
      RETURN.
  ENDTRY.

  IF 1 EQ 2.

  ENDIF.
