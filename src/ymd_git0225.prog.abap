*&---------------------------------------------------------------------*
*& Report YMD_GIT0225
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0225.

DATA :
  gs_icon TYPE icon,
  gt_icon TYPE TABLE OF icon.

SELECT * FROM icon INTO TABLE gt_icon.

LOOP AT gt_icon INTO gs_icon.

  WRITE :/
    gs_icon-name,
    33 '@',
    34 gs_icon-id+1(2),
    36 '@',
    40 gs_icon-id.

ENDLOOP.
