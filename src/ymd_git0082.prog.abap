*&---------------------------------------------------------------------*
*& Report YMD_209
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0082.

TYPES:
  BEGIN OF ty_email,
    relnr     TYPE  bu_relnr,
    partner1  TYPE  bu_partner,
    partner2  TYPE  bu_partner,
    date_to   TYPE bu_datto,
    smtp_addr TYPE ad_smtpadr,
  END OF ty_email .
TYPES:
  tty_email TYPE SORTED TABLE OF ty_email WITH UNIQUE KEY relnr partner1 partner2 date_to .

DATA lt_original_emailtab TYPE tty_email.

DATA gv_zakenpartner_1 TYPE bu_partner VALUE '0025086704'.

SELECT but051~relnr, but051~partner1, but051~partner2,
      but051~date_to, adr6~addrnumber, adr6~consnumber,
      adr6~smtp_addr, adr6~valid_from
   INTO TABLE @DATA(lt_email_zp_1)
   FROM but051 AS but051
  INNER JOIN but020 AS but020
  ON but051~partner2 EQ but020~partner
  INNER JOIN adr6 AS adr6
  ON but020~addrnumber EQ adr6~addrnumber
   WHERE but051~partner1 EQ @gv_zakenpartner_1
   AND but051~date_to EQ '99991231'
   AND but051~reltyp EQ 'ZWOCOB'
  ORDER BY valid_from DESCENDING.
*   AND ( adr6~valid_from LE @sy-datum
*       OR adr6~valid_from NE ' ' ).

IF 1 EQ 2.
ELSE.
ENDIF.

DATA gv_zakenpartner_2 TYPE bu_partner VALUE '0020092375'.
SELECT but051~relnr, but051~partner1, but051~partner2,
      but051~date_to, adr6~addrnumber, adr6~valid_from,
      adr6~consnumber, adr6~smtp_addr
   INTO TABLE @DATA(lt_email_zp_2)
   FROM but051 AS but051
  INNER JOIN but020 AS but020
  ON but051~partner2 EQ but020~partner
  INNER JOIN adr6 AS adr6
  ON but020~addrnumber EQ adr6~addrnumber
   WHERE but051~partner1 EQ @gv_zakenpartner_2
   AND but051~date_to EQ '99991231'
   AND but051~reltyp EQ 'ZWOCOB'
    ORDER BY valid_from DESCENDING.

SORT lt_email_zp_2 BY addrnumber valid_from DESCENDING.

DELETE ADJACENT DUPLICATES FROM lt_email_zp_2 COMPARING addrnumber.

lt_original_emailtab = CORRESPONDING #( lt_email_zp_2 ).

*   AND ( adr6~valid_from LE @sy-datum
*       OR adr6~valid_from NE ' ' ).

IF 1 EQ 2.
ELSE.
ENDIF.

*
*SELECT but051~relnr, but051~partner1, but051~partner2, but051~date_to, adr6~smtp_addr
*   INTO TABLE @DATA(lt_email_zp)
*   FROM but051 AS but051
*  INNER JOIN but020 AS but020
*  ON but051~partner2 EQ but020~partner
*  INNER JOIN adr6 AS adr6
*  ON but020~addrnumber EQ adr6~addrnumber
*   WHERE but051~partner1 EQ @gv_zakenpartner
*   AND but051~date_to EQ '99991231'
*   AND but051~reltyp EQ 'ZWOCOB'
*   AND adr6~valid_from LE @sy-datum
*   AND ( adr6~valid_to eq ' '
*         OR adr6~valid_to GE @sy-datum ).

*SELECT but051~relnr, but051~partner1, but051~partner2, but051~date_to,adr6~smtp_addr
*   INTO TABLE @DATA(lt_email_zp)
*   FROM but051 AS but051
*  INNER JOIN but020 AS but020
*  ON but051~partner2 EQ but020~partner
*  INNER JOIN adr6 AS adr6
*  ON but020~addrnumber EQ adr6~addrnumber
*   WHERE but051~partner1 EQ @me->mv_zakenpartner
*   AND but051~date_to EQ @me->mc_actief_datum
*   AND but051~reltyp EQ @me->mc_woco_mailtype
*   AND adr6~date_from LE @sy-datum
*   AND adr6~valid_to GE @sy-datum.
