*&---------------------------------------------------------------------*
*& Report YMD_029
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0109.

DATA ls_workload TYPE zst_isu_poc_workload.
CONSTANTS gco_vzcstatus_60 TYPE zde_vzc_status VALUE '60'.

SELECT *
  INTO TABLE @DATA(lt_workload_his)
  FROM ztvzc_workloadh
  WHERE status EQ @gco_vzcstatus_60.

READ TABLE lt_workload_his
INDEX 1
ASSIGNING FIELD-SYMBOL(<ls_workload>).

MOVE-CORRESPONDING <ls_workload> TO ls_workload .

IF 1 EQ 2.
ENDIF.
