*&---------------------------------------------------------------------*
*& Report YMD_GIT0227
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0227.

PARAMETERS p_eff TYPE zde_effectueringdatum.

START-OF-SELECTION.

  DELETE FROM zisu_poc_ean
    WHERE effectueringsdatum GE p_eff.
  COMMIT WORK AND WAIT.

  DATA(lv_filterout) = |Er zijn { sy-dbcnt } regels verwijderd  uit tabel ZSU_POC_EAN met Eff-datum groter gelijk { p_eff }|.
  MESSAGE lv_filterout TYPE 'I'.
