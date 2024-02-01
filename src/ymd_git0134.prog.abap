*&---------------------------------------------------------------------*
*& Report YMD_085
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0134.

DATA: g_domain TYPE dd07l-domname.
DATA: gt_tab  TYPE TABLE OF dd07v,
      gwa_tab TYPE dd07v.

g_domain = 'PSTYP_EDI'.

CALL FUNCTION 'GET_DOMAIN_VALUES'
  EXPORTING
    domname         = g_domain
  TABLES
    values_tab      = gt_tab
  EXCEPTIONS
    no_values_found = 1
    OTHERS          = 2.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

WRITE:/ 'Domain',12 'Fix.Value',22 'Short Text'.
WRITE:/ sy-uline(43).

LOOP AT gt_tab INTO gwa_tab.
  WRITE:/ gwa_tab-domname,12 gwa_tab-domvalue_l,22 gwa_tab-ddtext.
  CLEAR: gwa_tab.
ENDLOOP.
