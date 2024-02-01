*&---------------------------------------------------------------------*
*& Report YMD_024
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0104.

INCLUDE lclfmf3x.

DATA update TYPE c.

PERFORM cust_exit_post USING update.

*FUNCTION-POOL clfm MESSAGE-ID cl.
TABLES rmclf.

DATA:
  l_dynnr       LIKE sy-dynnr,
  l_ok_code     LIKE sy-ucomm,
  l_exit_active LIKE rmclf-kreuz.
DATA:
  lt_allkssk LIKE rmclkssk OCCURS 0 WITH HEADER LINE,
  lt_allausp LIKE rmclausp OCCURS 0 WITH HEADER LINE,
  lt_delcl   LIKE rmcldel  OCCURS 0 WITH HEADER LINE,
  lt_delob   LIKE rmcldob  OCCURS 0 WITH HEADER LINE.

DATA l_called TYPE c.
DATA g_exits_active(1) VALUE abap_true.
DATA in_update TYPE c.
DATA g_save_called(1).
DATA g_exit_upd(1).
DATA  g_appl(1).

CHECK NOT g_exits_active IS INITIAL. " internal debug flag

* Copy global CLFM tables to local tables that may be changed
* in customer exit.
* Consistency check after customer exit

*lt_allkssk[] = allkssk[].
*lt_allausp[] = allausp[].
*lt_delcl[]   = delcl[].
*lt_delob[]   = delob[].



IF in_update IS INITIAL.                                    "v 2241496
  l_called = g_save_called.
ELSE.
*   call exit in INSERT_CLASSIFICATION and similar routines
*   to ensure a final call
  l_called = g_exit_upd.
ENDIF.

IF in_update IS INITIAL OR NOT g_exit_upd IS INITIAL.       "^ 2241496

  CALL CUSTOMER-FUNCTION '002'
    EXPORTING
      i_rmclf   = rmclf
      i_appl    = g_appl
      i_called  = l_called                        "  2241496
    IMPORTING
      e_active  = l_exit_active
      e_ok_code = l_ok_code
      e_dynpro  = l_dynnr
    TABLES
      t_allkssk = lt_allkssk
      t_allausp = lt_allausp
      t_delcl   = lt_delcl
      t_delob   = lt_delob.
ENDIF.                                                      "v 2241496
