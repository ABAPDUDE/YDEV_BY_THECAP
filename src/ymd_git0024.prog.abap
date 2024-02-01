*&---------------------------------------------------------------------*
*& Report YMD_0024
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0024.

DATA ls_flow_ddic TYPE zdsync_flow.
DATA lt_flow TYPE STANDARD TABLE OF zdsync_flow.

LOOP AT lt_flow
     INTO DATA(ls_flow).

  ls_flow_ddic = CORRESPONDING #( ls_flow ).
  ls_flow_ddic-resultaat_wegschrijven = abap_true.
  ls_flow_ddic-datum_wegschrijven_resultaat = sy-datum.
  ls_flow_ddic-tijd_wegschrijven_resultaat = sy-uzeit.

  MODIFY zdsync_flow FROM ls_flow_ddic.

*  me->execute_dsync( ).

  UPDATE  zdsync_flow
  SET sync_uitgevoerd = abap_true
      datum_sync = sy-datum
      tijd_sync = sy-uzeit
  WHERE zakenpartner EQ ls_flow-zakenpartner.

ENDLOOP.
