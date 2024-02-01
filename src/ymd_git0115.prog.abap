*&---------------------------------------------------------------------*
*& Report YMD_035
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0115.

" what this report does is remove the billing block from order
" Invoice is created later on by  report running in batch
" we can however check if billing block was removed
" check if ALL entries for sales order have status 49 - they should!

PARAMETERS pa_vbeln TYPE ztvzc_workload-vbeln.

DATA returning TYPE sap_bool.

SELECT vbeln
   INTO TABLE @DATA(lt_vbeln)
  FROM ztvzc_workload
  WHERE status EQ '49'.

LOOP AT lt_vbeln
  INTO DATA(ls_vbeln).

  SELECT *
    INTO TABLE @DATA(lt_workload)
    FROM ztvzc_workload
*   WHERE vbeln EQ @pa_vbeln
    WHERE vbeln EQ @ls_vbeln-vbeln
      AND status NE '49'.

  DATA(lv_lines) = lines( lt_workload ).
  IF lv_lines GT 0.
    returning = abap_false.
  ELSE.
    returning = abap_true.
  ENDIF.

ENDLOOP.
