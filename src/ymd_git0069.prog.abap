REPORT ymd_git0069.
*/**
*
* DATA out TYPE REF TO if_demo_output.
* out = cl_demo_output=>new( ).
* out->display( text ).
*/*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS rb_1 RADIOBUTTON GROUP rb1 DEFAULT 'X'.
PARAMETERS rb_2 RADIOBUTTON GROUP rb1.
PARAMETERS rb_3 RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK b1.

DATA gv_partner TYPE bu_partner.
DATA go_out      TYPE REF TO if_demo_output.

START-OF-SELECTION.

  IF rb_1 EQ abap_true.
    gv_partner = '0111111111'.
  ELSEIF rb_2 EQ abap_true.
    gv_partner = '0011229499'.
  ELSEIF rb_3 EQ abap_true.
    gv_partner = '0025679870'.
  ENDIF.

  SELECT partner, xdele
     INTO TABLE @DATA(gt_verw_marker)
     FROM but000
     WHERE partner EQ @gv_partner.

  " Controleer of de hoofzakenpartner bestaat
  TRY.
      DATA(line) = gt_verw_marker[ partner = gv_partner ].
    CATCH cx_sy_itab_line_not_found INTO DATA(oref).
      DATA(gv_text) = oref->get_text( ).
  ENDTRY.

  go_out = cl_demo_output=>new( ).
  IF NOT gv_text IS INITIAL.
    gv_text = | { gv_text }: Hoofdzakenpartner { gv_partner } is niet gevonden! |.
  ELSE.
    "Controleer of de hoofzakenpartner een verwijdermarkering heeft
    DATA(exists) = xsdbool( line_exists( gt_verw_marker[ xdele  = 'X' ] ) ).

    IF line_exists( gt_verw_marker[ xdele  = 'X' ] ).
      gv_text = | Hoofdzakenpartner { gv_partner } heeft een verwijdermarkering! |.
    ELSE.
      gv_text = | Hoofdzakenpartner { gv_partner } is in orde! |.
    ENDIF.
  ENDIF.

  go_out->display( gv_text ).
