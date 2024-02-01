*&---------------------------------------------------------------------*
*& Report YMD_053
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0153.

DATA lv_max_operating_pvalue TYPE char16.
DATA lv_max_doorlaatwaarde TYPE int8.
DATA lv_kw TYPE int8.
DATA lv_new_doorlaatwaarde TYPE p DECIMALS 3.
DATA lv_conv_max_doorlaatwaarde TYPE p DECIMALS 3.

" show value as is currently
lv_max_operating_pvalue = '500.000'.
lv_max_doorlaatwaarde = 24150.
WRITE: /5 'doorlaatwaarde type int8', lv_max_doorlaatwaarde.

SKIP 2.
"show value when moved to type p decimals 3
lv_new_doorlaatwaarde =  lv_max_doorlaatwaarde.
WRITE: /5 'doorlaatwaarde type p decimals 3: ', lv_new_doorlaatwaarde.

SKIP 2.

"show value when int 8 is divided by 1000 - no decimals afterwards!! WRONG!!
lv_max_doorlaatwaarde = lv_max_doorlaatwaarde / 1000.
WRITE: /5 'doorlaatwaarde gedeeld door 1000 type int8',lv_max_doorlaatwaarde.

SKIP 2.

"show value when p decimals 3 is divided by 1000 - decimals afterwards!! Correct!!
lv_conv_max_doorlaatwaarde = lv_new_doorlaatwaarde / 1000.
WRITE: /5 'doorlaatwaarde gedeeld door 1000 type int8',lv_conv_max_doorlaatwaarde.

SKIP 2.

"show values when P decimals 3 compared to char16
IF lv_max_operating_pvalue > lv_conv_max_doorlaatwaarde.
  WRITE: /5 'lv_max_operating_pvalue is greater'.
ELSE.
  WRITE: /5 'lv_max_doorlaatwaarde is greater'.
ENDIF.
