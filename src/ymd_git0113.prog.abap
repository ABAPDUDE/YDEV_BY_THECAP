*&---------------------------------------------------------------------*
*& Report YMD_033
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0113.

*SELECT-OPTIONS so_vbeln FOR lv_vbeln.
PARAMETERS pa_vbeln TYPE vbeln.

DATA ls_vbeln TYPE shp_vbeln_range.
DATA lt_vbeln TYPE shp_vbeln_range_t.


ls_vbeln-sign   = 'I'.
ls_vbeln-option = 'EQ'.
ls_vbeln-low    = pa_vbeln.
ls_vbeln-high   = ''.
APPEND ls_vbeln TO lt_vbeln.

SUBMIT zrp_vzc_auto_billing_batch
   WITH so_vbeln IN lt_vbeln
   AND RETURN.
