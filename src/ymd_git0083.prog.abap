*&---------------------------------------------------------------------*
*& Report YMD_208
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0083.

TYPES:
  BEGIN OF ty_email,
    relnr    TYPE  bu_relnr,
    partner1 TYPE	bu_partner,
    partner2 TYPE	bu_partner,
    date_to  TYPE bu_datto,
    smtp_adr TYPE ad_smtpadr,
  END OF ty_email .
TYPES:
  tty_email TYPE SORTED TABLE OF ty_email WITH UNIQUE KEY relnr partner1 partner2 date_to .

DATA ls_email TYPE ty_email.

SELECT relnr, partner1, partner2, date_to, smtp_address
  INTO TABLE @DATA(lt_email_zp)
  FROM but051
  WHERE partner1 EQ '0010008234'  " @iv_zakenpartner
  AND date_to EQ '99991231'   " @me->MC_ACTIEF_DATUM
  AND reltyp EQ 'ZWOCOB'.   " @me->mc_woco_mailtype.

ls_email-date_to  = '99991231'.
ls_email-partner1 = '0010008234'.
ls_email-partner2 = '0000119266'.
ls_email-relnr    = '000000312463'.
ls_email-smtp_adr = 'DerDickeReutel@alliander.com'.

APPEND ls_email TO lt_email_zp.

DATA(lv_lines) = lines( lt_email_zp ).

IF lv_lines GE 1.

  DATA lv_string TYPE string.

  LOOP AT lt_email_zp
    INTO DATA(ls_email_zp).

    DATA(lv_index) = sy-tabix.

    IF lv_index = lv_lines.

      DATA(lv_string_email) = |{ lv_string }{ ls_email_zp-smtp_address }|.
      lv_string = lv_string_email.

    ELSE.

      lv_string_email = |{ lv_string }{ ls_email_zp-smtp_address }, |.
      lv_string = lv_string_email.
    ENDIF.

  ENDLOOP.

ENDIF.

WRITE: /5 lv_string_email.
WRITE: /5 lv_string.
