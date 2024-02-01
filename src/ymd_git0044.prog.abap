*&---------------------------------------------------------------------*
*& Report YMD_0009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0044.

SELECT anlage, zzdoorlaatwaarde
  INTO TABLE @DATA(lt_dlw_txt)
  FROM eanl
 WHERE  zzdoorlaatwaarde LE '381'
   AND sparte EQ 'N'.

IF lines( lt_dlw_txt ) GE 1.

ENDIF.

SELECT anlage, zzdoorlaatwaarde
  INTO TABLE @DATA(lt_dlw_int)
  FROM eanl
 WHERE  zzdoorlaatwaarde LE 381
   AND sparte EQ 'N'.

IF lines( lt_dlw_int ) GE 1.

ENDIF.

*/****

SELECT anlage, zzdoorlaatwaarde
  INTO TABLE @DATA(lt_dlw_txt_empty)
  FROM eanl
 WHERE  zzdoorlaatwaarde LE '381'
  AND zzdoorlaatwaarde NE ' '
   AND sparte EQ 'N'.

IF lines( lt_dlw_txt_empty ) GE 1.

ENDIF.

SELECT anlage, zzdoorlaatwaarde
  INTO TABLE @DATA(lt_dlw_int_empty)
  FROM eanl
 WHERE  zzdoorlaatwaarde LE 381
  AND zzdoorlaatwaarde NE ' '
   AND sparte EQ 'N'.

IF lines( lt_dlw_int_empty ) GE 1.

ENDIF.
