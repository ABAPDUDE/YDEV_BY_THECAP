*&---------------------------------------------------------------------*
*& Report YMD_00006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0006.

DATA gr_x_obj TYPE isu01_connobj.


START-OF-SELECTION.

  gr_x_obj = ycl_export_import_memory=>import_adres_oud_nieuw( ).

  WRITE: /20 gr_x_obj-addr1_data_old-house_num1.
  WRITE: /20 gr_x_obj-addr1_data_new-house_num1.
