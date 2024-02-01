*&---------------------------------------------------------------------*
*& Report YMD_012
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0092.

DATA gv_invoice_nr TYPE vbeln_vf VALUE '12334412'.
DATA gv_customer_nr TYPE kunnr VALUE '0000012555'.

gv_invoice_nr = |{ gv_invoice_nr ALPHA = IN }| .

gv_customer_nr = |{ gv_customer_nr ALPHA = OUT }| .

WRITE: /5 gv_invoice_nr,
       /5 gv_customer_nr.
