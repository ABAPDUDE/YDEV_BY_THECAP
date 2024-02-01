*&---------------------------------------------------------------------*
*& Report YMD_041
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0121.

DATA lr_alv TYPE REF TO cl_salv_table.
DATA lr_columns TYPE REF TO cl_salv_columns_table.
DATA lr_column  TYPE REF TO cl_salv_column_table.


START-OF-SELECTION.

  SELECT factuurnummer, datum_gemaakt, tijd_gemaakt, klantnummer, herkomst
    INTO TABLE @DATA(lt_data)
    UP TO 10 ROWS
    FROM ztvzc_webform.


  " Generate an instance of the ALV table object
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lr_alv
    CHANGING
      t_table      = lt_data.

  " omzetten repid in een datatype dat de methodes slikken.
  DATA(lv_repid) = sy-repid.

  " Referentie ophalen naar de selectiesturing
  DATA(lr_sel) = lr_alv->get_selections( ).
  " Aanzetten sturingsparameter voor meervoudige selectie.
  lr_sel->set_selection_mode( if_salv_c_selection_mode=>multiple ).
* Create the event reciever
  " PF status zetten op ALV status + eigen knoppen.
  lr_alv->set_screen_status(
        report        = lv_repid
        pfstatus      = 'ZVZC'
        set_functions = lr_alv->c_functions_all ).

  TRY.
      lr_columns = lr_alv->get_columns( ).
      lr_column ?= lr_columns->get_column( 'HERKOMST' ).
      IF lr_column IS BOUND.
        DATA(lv_return) =  lr_column->get_ddic_domain( ).
       lr_column->set_long_text( value =  'dit is een test' ).
       lr_column->set_text_column( value = lv_return ).

        FREE lr_column.
      ENDIF.
    CATCH cx_salv_not_found ##NO_HANDLER.
      "Niet zo heel erg als de column niet gevonden of verborgen is.
  ENDTRY.

*Display the ALV table.
  lr_alv->display( ).
