*&---------------------------------------------------------------------*
*& Report YMD_030
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0124.

CONSTANTS gco_vzcstatus_05 TYPE zde_vzc_status VALUE '05'.
CONSTANTS gco_vzcstatus_09 TYPE zde_vzc_status VALUE '09'.
CONSTANTS gco_vzcstatus_10 TYPE zde_vzc_status VALUE '10'.
CONSTANTS gco_vzcstatus_11 TYPE zde_vzc_status VALUE '11'.
CONSTANTS gco_vzcstatus_12 TYPE zde_vzc_status VALUE '12'.
CONSTANTS gco_vzcstatus_15 TYPE zde_vzc_status VALUE '15'.
CONSTANTS gco_vzcstatus_16 TYPE zde_vzc_status VALUE '16'.
CONSTANTS gco_vzcstatus_17 TYPE zde_vzc_status VALUE '17'.
CONSTANTS gco_vzcstatus_18 TYPE zde_vzc_status VALUE '18'.
CONSTANTS gco_vzcstatus_20 TYPE zde_vzc_status VALUE '20'.
CONSTANTS gco_vzcstatus_27 TYPE zde_vzc_status VALUE '27'.
CONSTANTS gco_vzcstatus_30 TYPE zde_vzc_status VALUE '30'.
CONSTANTS gco_vzcstatus_35 TYPE zde_vzc_status VALUE '35'.
CONSTANTS gco_vzcstatus_60 TYPE zde_vzc_status VALUE '60'.
CONSTANTS gco_vzcstatus_81 TYPE zde_vzc_status VALUE '81'.

DATA ls_workload TYPE zst_isu_poc_workload.
DATA cs_workload TYPE zst_isu_poc_workload.
DATA gt_workload TYPE ztt_isu_poc_workload.

cs_workload-verbruik_e10 = 38.
cs_workload-verbruik_e11 = 23.

SELECT *
  INTO TABLE @DATA(lt_workload)
  FROM ztvzc_workload
  UP TO 10 ROWS
  WHERE status      NE @gco_vzcstatus_05
    AND status      NE @gco_vzcstatus_09
    AND status      NE @gco_vzcstatus_10
    AND status      NE @gco_vzcstatus_11
    AND status      NE @gco_vzcstatus_15
    AND status      NE @gco_vzcstatus_17
    AND status      NE @gco_vzcstatus_18
    AND status      NE @gco_vzcstatus_20
    AND status      NE @gco_vzcstatus_27.

DATA(lv_lines_workload) = lines( lt_workload ).
IF lv_lines_workload GE 1.
  " Er is/zijn dus 1 of meerdere record(s) gevonden dat/die NIET overschreven mag/mogen worden

  LOOP AT lt_workload
  ASSIGNING FIELD-SYMBOL(<fs_wl>)
    FROM  0 TO 1.
    IF <fs_wl> IS ASSIGNED.

*      DATA(v1) = |{ <fs_wl>-verbruik_e10 ALIGN = LEFT WIDTH = 20 PAD = '' }|.
*      DATA(v2) = |{ cs_workload-verbruik_e10 ALIGN = LEFT WIDTH = 20 PAD = '' }|.
*
*      WRITE <fs_wl>-verbruik_e10 TO <fs_wl>-verbruik_e10 LEFT-JUSTIFIED.

      CONDENSE <fs_wl>-verbruik_e10.
      CONDENSE <fs_wl>-verbruik_e11.
      CONDENSE cs_workload-verbruik_e10.
      CONDENSE cs_workload-verbruik_e11.

      IF ( <fs_wl>-verbruik_e10 NE cs_workload-verbruik_e10
      OR <fs_wl>-verbruik_e11 NE cs_workload-verbruik_e11 ).

        " verbruik is afwijkend, dus wel toevoegen met een "parkeerstatus"
        cs_workload-status = gco_vzcstatus_11.

      ENDIF.

    ENDIF.

  ENDLOOP.

  MOVE-CORRESPONDING lt_workload[] TO gt_workload.

  LOOP AT gt_workload
  INTO  ls_workload
    FROM 0 TO 1.

    IF ( ls_workload-verbruik_e10 NE cs_workload-verbruik_e10
     OR ls_workload-verbruik_e11 NE cs_workload-verbruik_e11 ).

      " verbruik is afwijkend, dus wel toevoegen met een "parkeerstatus"
      cs_workload-status = gco_vzcstatus_11.

    ENDIF.
  ENDLOOP.
ENDIF.
