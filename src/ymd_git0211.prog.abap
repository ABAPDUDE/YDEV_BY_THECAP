*&---------------------------------------------------------------------*
*& Report YMD_GIT0211
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0211.

DATA lv_begindatum  TYPE begda.
DATA lv_einddatum   TYPE endda.
DATA lv_aantal_dagen TYPE zde_aantal_dagen.  "zde_aantaldagen_vzcfac.

lv_begindatum ='20240412'.
lv_einddatum ='20240416'.

lv_aantal_dagen = lv_einddatum - lv_begindatum.

WRITE: /5 'totaal aantal dagen :', 'van', lv_begindatum, 't/m', lv_einddatum, '= ', lv_aantal_dagen.

CLEAR lv_aantal_dagen.

CALL FUNCTION 'DAYS_BETWEEN_TWO_DATES'
  EXPORTING
    i_datum_bis             = lv_einddatum
    i_datum_von             = lv_begindatum
*   i_kz_excl_von           = ' '
    i_kz_incl_bis           = '1'
*   I_KZ_ULT_BIS            = ' '
*   I_KZ_ULT_VON            = ' '
*   I_STGMETH               = '0'
*   I_SZBMETH               = '1'
  IMPORTING
    e_tage                  = lv_aantal_dagen
  EXCEPTIONS
    days_method_not_defined = 1
    OTHERS                  = 2.

IF sy-subrc <> 0.
* Implement suitable error handling here
ELSE.

  WRITE: /5 'totaal aantal dagen met SAP standard FM :', 'van', lv_begindatum, 't/m', lv_einddatum, '= ', lv_aantal_dagen.

ENDIF.
