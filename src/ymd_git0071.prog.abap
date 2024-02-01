*&---------------------------------------------------------------------*
*& Report YMD_103
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0071.

SELECT *
   UP TO 25 ROWS
   INTO TABLE @DATA(lt_ean_data)
   FROM zdsync_sap_ean
   WHERE zakenpartner EQ '0010008234'
     AND caseid IS NULL.

IF 1 EQ 2.
ENDIF.
