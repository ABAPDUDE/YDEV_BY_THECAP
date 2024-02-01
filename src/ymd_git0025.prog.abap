*&---------------------------------------------------------------------*
*& Report YMD_0025
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0025.

START-OF-SELECTION.

  SELECT *
    FROM zdsync_flow
    WHERE resultaat_wegschrijven EQ @( VALUE #( ) )  " WHERE resultaat_wegschrijven NE @abap_true.
    INTO TABLE @DATA(lt_flow).

  DATA(lv_lines) = lines( lt_flow ).

  IF lv_lines GE 1.

    LOOP AT lt_flow
      INTO DATA(ls_flow).

      READ TABLE lt_flow
        WITH KEY zakenpartner = ls_flow-zakenpartner
        INTO ls_flow.

      UPDATE zdsync_flow FROM @( VALUE #( BASE ls_flow resultaat_wegschrijven       = abap_true
                                                       datum_wegschrijven_resultaat = sy-datum
                                                       tijd_wegschrijven_resultaat  = sy-uzeit ) ).

    ENDLOOP.

  ELSE.
    " geen zakenpartner gevonde waarvan het synchronisatie resultaat moet worden bijgelezen.
  ENDIF.
