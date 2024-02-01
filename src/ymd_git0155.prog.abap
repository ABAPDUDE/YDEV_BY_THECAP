*&---------------------------------------------------------------------*
*& Report YMD_055
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0155.

DATA lv_zaken_partner TYPE bu_partner.
CONSTANTS co_sapid_initial TYPE zdsync_id VALUE '0000000000'.
lv_zaken_partner = '0010008234'.

*DELETE FROM zdsync_sap_adr WHERE zakenpartner = @lv_zaken_partner
*                              AND id EQ @co_sapid_initial.

DELETE FROM zdsync_sap_adr WHERE id EQ @co_sapid_initial.

COMMIT WORK AND WAIT.
