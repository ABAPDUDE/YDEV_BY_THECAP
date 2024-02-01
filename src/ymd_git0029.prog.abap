*&---------------------------------------------------------------------*
*& Report YMD_0021
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0029.

DATA lv_name1 TYPE char40.
DATA lv_kadname TYPE char40.

lv_name1 = 'sinnige'.
lv_kadname = 'woonstichting stek'.

IF strlen( lv_kadname ) GE 5                     " Naam Kadaster is langer of gelijk aan 5
   AND strlen( lv_name1 ) GE 5                          " Naam vorige factuurontvanger is langer of gelijk aan 5
   AND ( lv_kadname CP |*{ lv_name1 }*| OR   " Naam Kadaster komt voor in naam factuurontvanger
         lv_name1 CP |*{ lv_kadname }*|      " Naam factuurontvanger komt voor in naam Kadaster
       ).

  DATA(lv_cp1) = abap_true.

ELSE.

  lv_cp1 = abap_false.

ENDIF.

lv_name1 = 'de stek'.
lv_kadname = 'woonstichting stek'.

IF strlen( lv_kadname ) GE 5                     " Naam Kadaster is langer of gelijk aan 5
   AND strlen( lv_name1 ) GE 5                          " Naam vorige factuurontvanger is langer of gelijk aan 5
   AND ( lv_kadname CP |*{ lv_name1 }*| OR   " Naam Kadaster komt voor in naam factuurontvanger
         lv_name1 CP |*{ lv_kadname }*|      " Naam factuurontvanger komt voor in naam Kadaster
       ).

  DATA(lv_cp2) = abap_true.

ELSE.

  lv_cp2 = abap_false.

ENDIF.

lv_name1 = 'steck'.
lv_kadname = 'woonstichting steck'.

IF strlen( lv_kadname ) GE 5            " Naam Kadaster is langer of gelijk aan 5
   AND strlen( lv_name1 ) GE 5          " Naam vorige factuurontvanger is langer of gelijk aan 5
   AND ( lv_kadname CP lv_name1  OR     " Naam Kadaster komt voor in naam factuurontvanger
         lv_name1 CP lv_kadname         " Naam factuurontvanger komt voor in naam Kadaster
       ).

  DATA(lv_cp3) = abap_true.

ELSE.

  lv_cp3 = abap_false.

ENDIF.
