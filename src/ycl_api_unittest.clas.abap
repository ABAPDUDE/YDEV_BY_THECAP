CLASS ycl_api_unittest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    DATA lv_ean TYPE ext_ui.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS YCL_API_UNITTEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TYPES: BEGIN OF ty_ean,
             ean TYPE ZEAN,
           END OF ty_ean.

    TYPES tty_ean TYPE SORTED TABLE OF ty_ean WITH UNIQUE KEY ean.

    DATA ls_ean TYPE ty_ean.
    DATA lt_ean TYPE tty_ean.


    ls_ean-ean = '871687140002167987'. " verwijder aanvraag (geeft dus true terug)
    APPEND ls_ean TO lt_ean.
    CLEAR ls_ean.
    ls_ean-ean = '871685900002059918'. " wel een aanvraag maar niet voor verwijderen van deze aansluiting (geeft dus false terug)
    INSERT ls_ean INTO TABLE lt_ean.
    CLEAR ls_ean.

    LOOP AT lt_ean
      INTO ls_ean.

      DATA(lo_sloop) = NEW zcl_api_mgmt_slooporder_valid(  ).
      DATA(lv_ean_wordt_gesloopt) = lo_sloop->get_slooporder_from_horizon( ls_ean-ean ).

      IF lv_ean_wordt_gesloopt EQ abap_true.
        " CL-proces moet onderbroken worden
      ELSE.
        " CL-proces kan doorgaan
      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
