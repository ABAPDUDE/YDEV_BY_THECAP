*&---------------------------------------------------------------------*
*& Report YMD_101
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0067.

DATA gt_tab1 TYPE ztt_loadfile_dsync.

DATA(lr_01) = NEW ycl_test_oop_01( ).
DATA(lr_001) = NEW ycl_test_oop_001( ).

lr_001->check_values1( ).

gt_tab1[] = lr_001->mt_filedata1.

lr_01 ?= lr_001.

*lr_01->subclass_method_01( ).
