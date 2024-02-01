*&---------------------------------------------------------------------*
*& Report YMD_105
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0070.

" example partner exists en XDELE equals ' ' ( abap_false)
DATA lv_partner2 TYPE bu_partner VALUE '0025679870'.

"Controleer of de hoofzakenpartner bestaat en geen verwijdermarkering heeft
SELECT xdele
   INTO TABLE @data(lt_verw_marker)
   FROM but000
   WHERE partner EQ @lv_partner2.

DATA(exists) = xsdbool( line_exists( lt_verw_marker[ xdele  = 'X' ] ) ).

IF line_exists( lt_verw_marker[ xdele  = 'X' ] ).

  DATA(cv_returning) = abap_true.  " '1'.

ELSE.

  cv_returning = abap_false.  " '2'

ENDIF.


" example partner exists en XDELE equals 'X' ( abap_true)
DATA lv_partner3 TYPE bu_partner VALUE '0011229499'.

CLEAR lt_verw_marker[].

"Controleer of de hoofzakenpartner bestaat en geen verwijdermarkering heeft
SELECT xdele
   INTO TABLE @lt_verw_marker
   FROM but000
   WHERE partner EQ @lv_partner3.

exists = xsdbool( line_exists( lt_verw_marker[ xdele  = 'X' ] ) ).

IF line_exists( lt_verw_marker[ xdele  = 'X' ] ).

  cv_returning = abap_true.  " '1'.

ELSE.

  cv_returning = abap_false.  " '2'.

ENDIF.


*   CASE gv_resultaat.
*      WHEN 1.
*        WRITE: / gv_teller_bestand,'Hoofdzakenpartner', gs_import-zakenpartner, 'heeft een verwijdermarkering'.
*        ADD 1 TO gv_teller_fout.
*        CONTINUE.
*      WHEN 2.
*        WRITE: / gv_teller_bestand,'Hoofdzakenpartner', gs_import-zakenpartner, 'is niet gevonden'.
*        ADD 1 TO gv_teller_fout.
*        CONTINUE.
*      WHEN OTHERS.
*    ENDCASE.
