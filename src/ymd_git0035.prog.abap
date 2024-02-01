*&---------------------------------------------------------------------*
*& Report YMD_00005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0035.

DATA gr_x_obj TYPE isu01_connobj.

gr_x_obj-addr1_data_new-house_num1 = '101'.
gr_x_obj-addr1_data_old-house_num1 = '99'.

START-OF-SELECTION.

  ycl_export_import_memory=>export_adres_oud_nieuw( gr_x_obj  ).
