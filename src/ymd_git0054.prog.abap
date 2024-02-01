*&---------------------------------------------------------------------*
*& Report YMD_405
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0054.

DATA go_out     TYPE REF TO if_demo_output.
DATA gv_partner TYPE bu_partner.
DATA gv_text TYPE string.

START-OF-SELECTION.

*  IF rb_1 EQ abap_true.
*    gv_partner = '0111111111'.
*  ELSEIF rb_2 EQ abap_true.
*    gv_partner = '0011229499'.
*  ELSEIF rb_3 EQ abap_true.
*    gv_partner = '0025679870'.
*  ENDIF.

*  SELECT partner, xdele
*     INTO TABLE @DATA(gt_verw_marker)
*     FROM but000
*     WHERE partner EQ @gv_partner.

  " Controleer of de hoofzakenpartner bestaat
*  TRY.
*      DATA(line) = gt_verw_marker[ partner = gv_partner ].
*    CATCH cx_sy_itab_line_not_found INTO DATA(oref).
*      DATA(gv_text) = oref->get_text( ).
*  ENDTRY.

  go_out = cl_demo_output=>new( ).

  "Controleer of de hoofzakenpartner een verwijdermarkering heeft
*  DATA(exists) = xsdbool( line_exists( gt_verw_marker[ xdele  = 'X' ] ) ).
*
*  IF line_exists( gt_verw_marker[ xdele  = 'X' ] ).
*    gv_text = | Hoofdzakenpartner { gv_partner } heeft een verwijdermarkering! |.
*  ELSE.
*    gv_text = | Hoofdzakenpartner { gv_partner } is in orde! |.
*  ENDIF.
*ENDIF.


  gv_text = | Hoofdzakenpartner { gv_partner } is in orde! |.

  go_out->display( gv_text ).
