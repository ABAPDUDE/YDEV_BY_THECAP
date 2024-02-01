*&---------------------------------------------------------------------*
*& Report YMD_005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0085.

*/**
*ieuwe methode "OPHALEN_STATUS_CRM" (input CASEID)Het ophalen van de status van de CASE uit CRM
* kan met behulp van een bestaande RFC. Deze RFC wordt ook gebruikt in programma
* ZU_DW_FACTURATIE_CONTROLE, dus de noodzakelijke functionaliteiten/routines
* kunnen we hieruit kopiëren.Kopieer routine GET_CRM_ACTIVITIES
* hierbij hoeven we alleen te zorgen dat de globale tabel "gt_crm_case[]"
* met de CASEID wordt gevuld. Let op dat het CASEID in CRM altijd bestaat uit 10 karakters.
* Het CASEID uit ISU moeten we dus aanvullen met voorloopnullen
* Het resultaat is dat de globale tabel "GT_CRM_ACTIVITY" is gevuld
* (of niet indien de case niet in CRM kan worden gevonden)
*
* Kopieer routine GET_CRM_STATUSSES Als GT_CRM_ACTIVITY is gevuld,
* dan kunnen we deze code ook direct aanroepen. Het resultaat is dat de globale tabel "GT_CRM_STATUS" is gevuld
* (of niet indien de case niet in CRM kan worden gevonden
*/*

*/**
* Indien 1 van de statussen in deze tabel gelijk is aan onderstaande statussen,
* dan mag er geen scenariowissel worden uitgevoerd:
* (p.s. graag de omschrijving van de status als opmerking toevoegen in de code)-E0006 -
* Niet meer contractloos-E0011 - Inhuizing met terugkoppeling-E0012 - Gereed voor deurwaarder-E0013
* - In beheer bij deurwaarder-E0014 - Retour van Deurwaarder
* Wanneer er dus geen scenariowissel mag worden uitgevoerd, zullen we er ook voor moeten zorgen
* dat de betreffende CASE en EAN's bij de volgende run van het programma "ZISU_POC_BATCHPROCESS"
* niet opnieuw wordt opgepakt. Dit zouden we kunnen doen door bijvoorbeeld
* de ZISU_POC_EAN-DATUM_GEWIJZIGD aan te passen, maar eigenlijk denk ik dat het ook wel handig is
* als we weten welke EAN's allemaal niet van scenario zijn gewisseld omdat de status in CRM dat
* niet toeliet. In dat geval zouden we wellicht beter een nieuwe STATUS en STATUS_REDEN in het
* leven kunnen roepen, bijvoorbeeld:
* STATUS = 30STATUS_REDEN = SN - Segmentwissel niet mogelijk ivm status CRMIndien voor een EAN
* is bepaald dat deze geen scenariowissel mag ondergaan, dan alle EAN's (<>49) met
* dezelfde CASEID aanpassen naar STATUS = 30 en STATUS_REDEN = SN

TYPES: BEGIN OF ty_crm_case,
         caseid TYPE zde_cl_caseid,
       END OF ty_crm_case.
TYPES: BEGIN OF ty_crm_activity,   "crmd_activity_h
         caseid TYPE zde_cl_caseid,
         guid   TYPE sysuuid_c,
       END OF ty_crm_activity.
TYPES: BEGIN OF ty_crm_status,     "crm_jcds
         objnr    TYPE sysuuid_c,
         stat(5)  TYPE c,
         chgnr(3) TYPE n,
         udate    TYPE sydatum,
         utime    TYPE syuzeit,
         inact(1) TYPE c,
       END OF ty_crm_status.

TYPES: BEGIN OF ty_excel,
         caseid(20)      TYPE c,
         dossiernr(20)   TYPE c,
         regelnr(4)      TYPE n,
         akkoord(10)     TYPE c,
         afkeurreden(80) TYPE c,
       END OF ty_excel.

TYPES: BEGIN OF ty_excel_out,
         caseid(20)      TYPE c,
         dossiernr(20)   TYPE c,
         akkoord(10)     TYPE c,
         afkeurreden(80) TYPE c,
       END OF ty_excel_out.

TYPES: BEGIN OF ty_afkeur_reden,
         msgno     TYPE zde_cl_fact_msgno,
         tekst(80) TYPE c,
       END OF ty_afkeur_reden.

TYPES tty_crm_status   TYPE TABLE OF ty_crm_status.
TYPES tty_crm_case     TYPE TABLE OF ty_crm_case.
TYPES tty_crm_activity TYPE TABLE OF ty_crm_activity.
TYPES tty_excel        TYPE TABLE OF ty_excel.
TYPES tty_excel_out    TYPE TABLE OF ty_excel_out.
TYPES tty_afkeur_reden TYPE TABLE OF ty_afkeur_reden.


DATA gt_crm_case     TYPE tty_crm_case.
DATA gt_rfc_option   TYPE TABLE OF rfc_db_opt.
DATA gt_rfc_field    TYPE TABLE OF rfc_db_fld.
DATA gt_rfc_data     TYPE TABLE OF tab512.
DATA gt_crm_activity TYPE tty_crm_activity.
DATA gt_crm_status   TYPE tty_crm_status.
DATA gt_excel        TYPE tty_excel.
DATA gt_excel_out    TYPE tty_excel_out.
DATA gt_afkeur_reden TYPE tty_afkeur_reden.
DATA gt_poc_factuur  TYPE STANDARD TABLE OF zisu_poc_factuur.


DATA gs_rfc_option   TYPE rfc_db_opt.
DATA gs_rfc_field    TYPE rfc_db_fld.
DATA gs_crm_case     TYPE ty_crm_case.
DATA gs_rfc_data     TYPE tab512.
DATA gs_crm_activity TYPE ty_crm_activity.
DATA gs_crm_status   TYPE ty_crm_status.
DATA gs_afkeur_reden TYPE ty_afkeur_reden.


DATA gv_rfc_tabname     TYPE dd02l-tabname.
DATA gv_maxkeys_per_rfc TYPE i.
DATA gv_rfc_destination TYPE rfcdest.
DATA gv_rfc_error       TYPE xfeld.
DATA gv_major_error     TYPE xfeld.
DATA gv_case_cnt        TYPE i.
DATA gv_error_cnt       TYPE i.

*/--
PARAMETERS p_caseid TYPE zde_cl_caseid.

PERFORM init_acties.
PERFORM get_crm_activities.
PERFORM get_crm_statusses.

*/**
FORM init_acties.

  DATA: lt_dd07v TYPE STANDARD TABLE OF dd07v,
        ls_dd07v TYPE dd07v.

  CLEAR: gv_major_error,
         gv_rfc_error,
         gv_case_cnt,
         gv_error_cnt.

  CLEAR: gt_excel[],
         gt_excel_out[],
         gt_poc_factuur[],
         gt_afkeur_reden[].

* Bepaal rfc destination (overgenomen uit zi_mv45afzz_save_document)
  SELECT SINGLE rfcdest
     INTO gv_rfc_destination
     FROM zrfc_destination
    WHERE rfc_gebruik EQ 'AANSL'
      AND sysid_doel  EQ 'CRM'.

  IF sy-subrc NE 0.
    WRITE: / 'Aanroep van CRM kan niet worden bepaald'.
    gv_major_error = abap_true.
    RETURN.
  ENDIF.

* Ophalen van mogelijke afkeurredenen met omschrijving
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = 'ZDO_CL_FACT_MSGNO'
      text            = 'X'
      fill_dd07l_tab  = ' '
    TABLES
      values_tab      = lt_dd07v
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.

  IF sy-subrc NE 0.
    WRITE: / 'Ophalen van afkeurredenen is mislukt'.
    gv_major_error = abap_true.
    RETURN.
  ENDIF.

  LOOP AT lt_dd07v INTO ls_dd07v.
    gs_afkeur_reden-msgno = ls_dd07v-domvalue_l.
    gs_afkeur_reden-tekst = ls_dd07v-ddtext.
    APPEND gs_afkeur_reden TO gt_afkeur_reden.
  ENDLOOP.

  SORT gt_afkeur_reden.

  gv_maxkeys_per_rfc = 50.

ENDFORM.      "init_acties

FORM get_crm_activities.

  DATA: lv_category(3) TYPE c,
        lv_cnt         TYPE i.

  gs_crm_case-caseid = p_caseid.
  APPEND gs_crm_case TO gt_crm_case.

  CHECK gt_crm_case[] IS NOT INITIAL.

  CLEAR: gs_rfc_option,
         gt_rfc_option[],
         gt_rfc_field[],
         gt_rfc_data[].

  gv_rfc_tabname = 'CRMD_ACTIVITY_H'.

  lv_category    = 'Z51'.

  gs_rfc_field-fieldname = 'GUID'.
  APPEND gs_rfc_field TO gt_rfc_field.
  gs_rfc_field-fieldname = 'ZZFLD000035'.
  APPEND gs_rfc_field TO gt_rfc_field.

  LOOP AT gt_crm_case INTO gs_crm_case.

    IF lv_cnt GE gv_maxkeys_per_rfc.
      READ TABLE gt_rfc_option INDEX lv_cnt ASSIGNING FIELD-SYMBOL(<fs_rfc_option>).
      <fs_rfc_option>-text = <fs_rfc_option>-text && ' )'.
      CONCATENATE 'AND CATEGORY = ''' lv_category '''' INTO gs_rfc_option-text.
      APPEND gs_rfc_option TO gt_rfc_option.

      PERFORM execute_rfc TABLES gt_rfc_option
                                 gt_rfc_field
                                 gt_rfc_data
                           USING gv_rfc_destination
                                 gv_rfc_tabname.

      IF gv_rfc_error IS NOT INITIAL.
        EXIT.
      ENDIF.

      LOOP AT gt_rfc_data INTO gs_rfc_data.
        gs_crm_activity-caseid = gs_rfc_data+32(10).
        gs_crm_activity-guid   = gs_rfc_data(32).
        APPEND gs_crm_activity TO gt_crm_activity.
      ENDLOOP.

      CLEAR: lv_cnt,
             gs_rfc_option,
             gt_rfc_option[],
             gt_rfc_data[].
    ENDIF.

    IF gs_rfc_option-text IS INITIAL.
      CONCATENATE '( ZZFLD000035 = ''' gs_crm_case-caseid '''' INTO gs_rfc_option-text.
    ELSE.
      CONCATENATE 'OR ZZFLD000035 = ''' gs_crm_case-caseid '''' INTO gs_rfc_option-text.
    ENDIF.

    APPEND gs_rfc_option TO gt_rfc_option.
    ADD 1 TO lv_cnt.
  ENDLOOP.

  CHECK gv_major_error IS INITIAL.

* Laatste set gegevens ophalen
  READ TABLE gt_rfc_option INDEX lv_cnt ASSIGNING <fs_rfc_option>.
  <fs_rfc_option>-text = <fs_rfc_option>-text && ' )'.
  CONCATENATE 'AND CATEGORY = ''' lv_category '''' INTO gs_rfc_option-text.
  APPEND gs_rfc_option TO gt_rfc_option.

  PERFORM execute_rfc TABLES gt_rfc_option
                             gt_rfc_field
                             gt_rfc_data
                       USING gv_rfc_destination
                             gv_rfc_tabname.

  CHECK gv_rfc_error IS INITIAL.

  LOOP AT gt_rfc_data INTO gs_rfc_data.
    gs_crm_activity-caseid = gs_rfc_data+32(10).
    gs_crm_activity-guid   = gs_rfc_data(32).
    APPEND gs_crm_activity TO gt_crm_activity.
  ENDLOOP.

  SORT gt_crm_activity.
ENDFORM.



FORM get_crm_statusses.
  CHECK gt_crm_activity[] IS NOT INITIAL.

  DATA: lv_cnt           TYPE i.

  CHECK gt_crm_activity[] IS NOT INITIAL.

  CLEAR: gs_rfc_option,
         gt_rfc_option[],
         gt_rfc_field[],
         gt_rfc_data[].

  gv_rfc_tabname = 'CRM_JCDS'.

  gs_rfc_field-fieldname = 'OBJNR'.
  APPEND gs_rfc_field TO gt_rfc_field.
  gs_rfc_field-fieldname = 'STAT'.
  APPEND gs_rfc_field TO gt_rfc_field.
  gs_rfc_field-fieldname = 'CHGNR'.
  APPEND gs_rfc_field TO gt_rfc_field.
  gs_rfc_field-fieldname = 'UDATE'.
  APPEND gs_rfc_field TO gt_rfc_field.
  gs_rfc_field-fieldname = 'UTIME'.
  APPEND gs_rfc_field TO gt_rfc_field.
  gs_rfc_field-fieldname = 'INACT'.
  APPEND gs_rfc_field TO gt_rfc_field.

  LOOP AT gt_crm_activity INTO gs_crm_activity.

    IF lv_cnt GE gv_maxkeys_per_rfc.
      READ TABLE gt_rfc_option INDEX lv_cnt ASSIGNING FIELD-SYMBOL(<fs_rfc_option>).
      <fs_rfc_option>-text = <fs_rfc_option>-text && ' )'.
      gs_rfc_option-text = 'AND STAT LIKE ''E%'''.
      APPEND gs_rfc_option TO gt_rfc_option.

      PERFORM execute_rfc TABLES gt_rfc_option
                                 gt_rfc_field
                                 gt_rfc_data
                           USING gv_rfc_destination
                                 gv_rfc_tabname.

      IF gv_rfc_error IS NOT INITIAL.
        EXIT.
      ENDIF.

      LOOP AT gt_rfc_data INTO gs_rfc_data.
        gs_crm_status-objnr = gs_rfc_data(32).
        gs_crm_status-stat  = gs_rfc_data+32(5).
        gs_crm_status-chgnr = gs_rfc_data+37(3).
        gs_crm_status-udate = gs_rfc_data+40(8).
        gs_crm_status-utime = gs_rfc_data+48(6).
        gs_crm_status-inact = gs_rfc_data+54(1).
        APPEND gs_crm_status TO gt_crm_status.
      ENDLOOP.

      CLEAR: lv_cnt,
             gs_rfc_option,
             gt_rfc_option[],
             gt_rfc_data[].
    ENDIF.

    IF gs_rfc_option-text IS INITIAL.
      CONCATENATE '( OBJNR = ''' gs_crm_activity-guid '''' INTO gs_rfc_option-text.
    ELSE.
      CONCATENATE 'OR OBJNR = ''' gs_crm_activity-guid '''' INTO gs_rfc_option-text.
    ENDIF.

    APPEND gs_rfc_option TO gt_rfc_option.
    ADD 1 TO lv_cnt.
  ENDLOOP.

  CHECK gv_major_error IS INITIAL.

* Laatste set gegevens ophalen
  READ TABLE gt_rfc_option INDEX lv_cnt ASSIGNING <fs_rfc_option>.
  <fs_rfc_option>-text = <fs_rfc_option>-text && ' )'.
  gs_rfc_option-text = 'AND STAT LIKE ''E%'''.
  APPEND gs_rfc_option TO gt_rfc_option.

  PERFORM execute_rfc TABLES gt_rfc_option
                             gt_rfc_field
                             gt_rfc_data
                       USING gv_rfc_destination
                             gv_rfc_tabname.

  CHECK gv_rfc_error IS INITIAL.

  LOOP AT gt_rfc_data INTO gs_rfc_data.
    gs_crm_status-objnr = gs_rfc_data(32).
    gs_crm_status-stat  = gs_rfc_data+32(5).
    gs_crm_status-chgnr = gs_rfc_data+37(3).
    gs_crm_status-udate = gs_rfc_data+40(8).
    gs_crm_status-utime = gs_rfc_data+48(6).
    gs_crm_status-inact = gs_rfc_data+54(1).
    APPEND gs_crm_status TO gt_crm_status.
  ENDLOOP.

  SORT gt_crm_status BY objnr ASCENDING
                        udate DESCENDING
                        utime DESCENDING
                        chgnr ASCENDING.

ENDFORM.      "get_crm_statusses

FORM execute_rfc TABLES pt_option
                        pt_field
                        pt_data
                  USING p_dest
                        p_tabname.

  CLEAR: pt_data[].

  CALL FUNCTION 'ZRFC_READ_TABLE'
    DESTINATION p_dest
    EXPORTING
      query_table          = p_tabname
    TABLES
      options              = pt_option
      fields               = pt_field
      data                 = pt_data
    EXCEPTIONS
      table_not_available  = 1
      table_without_data   = 2
      option_not_valid     = 3
      field_not_valid      = 4
      not_authorized       = 5
      data_buffer_exceeded = 6
      OTHERS               = 7.

  IF sy-subrc NE 0.
    gv_rfc_error   = abap_true.
    gv_major_error = abap_true.
    WRITE: / 'Ophalen van', p_tabname, 'via ZRFC_READ_TABLE is mislukt met subrc:',
             sy-subrc.
    RETURN.
  ENDIF.

ENDFORM.      "execute_rfc
