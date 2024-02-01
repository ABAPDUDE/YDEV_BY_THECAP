*&---------------------------------------------------------------------*
*& Report YMD_054
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0154.

DATA lv_partner TYPE bu_partner.

lv_partner = '0025011754'.

DELETE FROM zdsync_sap_adr WHERE eigenaar = @lv_partner.
COMMIT WORK AND WAIT.

IF 1 EQ 2.
ELSE.
ENDIF.
