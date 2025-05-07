*&---------------------------------------------------------------------*
*& Report ymd_git0229
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0229.

*/**
* apparaatlokaties zonder classificatie waar nu of
* ooit een meter heeft gehangen met soort discipline E/G
* en vervolgens deze apparaatlocaties voorzien van classificatie
*
* Apparaatlocatie = Functieplaats !  IFLOT-TPLNR
*
* De classificatie op de apparaatlocatie dient gevuld te worden voor de installaties waar deze leeg is
* Gaat alleen om KV -> E / DE / G / DG
* Classificatie moet gevuld worden met: “KV”; “ | ” Eigenaar van meter of app loc (0001, 0002, …);“ | ”
* Productidentificatie op apparaatlocatie.
*
* Ontbrekende Classificaties
* 0000000756 = EIGENAAR_METER_APP_LOC
* 0000000760 = KENMERK_GV_OF_KV
* 0000000761 = PRODUCT
*
* verwachting is 39k aan mutaties (31-12-2024);
* op de lijst staan apparaatlocaties/functieplaatsen
* 1 - apparaatlocaties/functieplaatsen zonder meter: altijd aanvulen met classificaties voor 'E'
* 2 - apparaatlocaties/functieplaatsen bepalen productgroep: aanvullen op bassis van productgroep
* 3 - apparaatlocaties/functieplaatsen die al zijn voorzien van de juiste classificaties
*
* Uitval inzichtelijk via ALV uitlijst einde programma
*
* DNW test apparaat locaties:
* 6500706101  t/m 6500706131
*/*


TYPES: BEGIN OF ty_anlage,
         anlage TYPE anlage,
       END OF ty_anlage.

TYPES tty_anlage TYPE STANDARD TABLE OF ty_anlage WITH NON-UNIQUE KEY anlage.

TYPES: BEGIN OF ty_tplnr,
         tplnr TYPE tplnr,
       END OF ty_tplnr.

TYPES tty_tplnr TYPE STANDARD TABLE OF ty_tplnr WITH NON-UNIQUE KEY tplnr.

CONSTANTS gco_delimiter_tab TYPE char1 VALUE ','.

DATA lv_tplnr TYPE tplnr.
DATA ls_funclocdata TYPE bapi_itob.
DATA ls_funclocdataupd TYPE bapi_itobx.
DATA ls_funclocspecdata TYPE bapi_itob_fl_only.
DATA ls_funclocspecdataupd TYPE bapi_itob_fl_onlyx.
DATA lt_return TYPE bapiret2_t.
DATA lt_return_total TYPE bapiret2_t.
DATA ls_data_general_exp TYPE  bapi_itob.
DATA ls_data_specific_exp TYPE bapi_itob_fl_only.
DATA ls_return TYPE bapiret2.
DATA lt_tplnr_dg TYPE tty_tplnr.
DATA gt_tplnr TYPE tty_tplnr.
DATA gt_anlage TYPE tty_anlage.

PARAMETERS p_file  TYPE localfile OBLIGATORY DEFAULT 'C:\Users\AL24361\OneDrive - Alliander NV\Documents\1 - Alliander WORK\testdata\app_loc_1_regel.csv'.
PARAMETERS p_tplnr TYPE tplnr.
PARAMETERS p_anlage TYPE anlage.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM u_selectfile CHANGING p_file.

START-OF-SELECTION.

  IF p_tplnr IS NOT INITIAL.

    SELECT  iflot~tplnr,
                  inob~cuobj,
                  ausp~atinn, ausp~atwrt
          FROM iflot AS iflot
          INNER JOIN inob AS inob
          ON iflot~tplnr EQ inob~objek
          INNER JOIN ausp AS ausp
          ON inob~cuobj EQ ausp~objek
          WHERE iflot~tplnr EQ @p_tplnr
          AND ( ausp~atinn NE '0000000756' OR
                    ausp~atinn NE '0000000760' OR
                    ausp~atinn NE '0000000761' )
          INTO TABLE @DATA(lt_class_check).

    SELECT  iflot~tplnr,
                   inob~cuobj,
                   ausp~atinn, ausp~atwrt,
                   eanl~anlage, eanl~sparte, eanl~vstelle
             FROM iflot AS iflot
             INNER JOIN inob AS inob
             ON iflot~tplnr EQ inob~objek
             INNER JOIN ausp AS ausp
             ON inob~cuobj EQ ausp~objek
             INNER JOIN eanl AS eanl
             ON  iflot~prems EQ eanl~vstelle
             WHERE iflot~tplnr EQ @p_tplnr
             AND ( ausp~atinn NE '0000000756' OR
                       ausp~atinn NE '0000000760' OR
                       ausp~atinn NE '0000000761' )
             INTO TABLE @DATA(lt_class_doublecheck).

  ELSE.

    DATA gv_raw_data TYPE truxs_t_text_data.

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = gco_delimiter_tab  " me->mc_delimiter_tab   " '|'
        i_line_header        = abap_false
        i_tab_raw_data       = gv_raw_data
        i_filename           = p_file                        " me->mr_input->ms_input-local_file_path
      TABLES
        i_tab_converted_data = gt_tplnr          " me->mt_data
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    IF gt_tplnr[] IS INITIAL.

      MESSAGE 'geen apparaatlocaties in bestand gevonden / bestand niet gevonden' TYPE 'S' DISPLAY LIKE 'I'.
      LEAVE LIST-PROCESSING.

    ELSE.

      SELECT  iflot~tplnr,
                     inob~cuobj,
                     ausp~atinn, ausp~atwrt
             FROM iflot AS iflot
             INNER JOIN inob AS inob
             ON iflot~tplnr EQ inob~objek
             INNER JOIN ausp AS ausp
             ON inob~cuobj EQ ausp~objek
             FOR ALL ENTRIES IN @gt_tplnr
             WHERE iflot~tplnr EQ @gt_tplnr-tplnr
             AND ( ausp~atinn NE '0000000756' OR
                       ausp~atinn NE '0000000760' OR
                       ausp~atinn NE '0000000761' )
            INTO TABLE @lt_class_check.

      SELECT  iflot~tplnr,
                         inob~cuobj,
                         ausp~atinn, ausp~atwrt,
                         eanl~anlage, eanl~sparte, eanl~vstelle
                 FROM iflot AS iflot
                 INNER JOIN inob AS inob
                 ON iflot~tplnr EQ inob~objek
                 INNER JOIN ausp AS ausp
                 ON inob~cuobj EQ ausp~objek
                 INNER JOIN eanl AS eanl
                 ON  iflot~prems EQ eanl~vstelle
                 FOR ALL ENTRIES IN @gt_tplnr
                 WHERE iflot~tplnr EQ @gt_tplnr-tplnr
                 AND ( ausp~atinn NE '0000000756' OR
                           ausp~atinn NE '0000000760' OR
                           ausp~atinn NE '0000000761' )
                INTO TABLE @lt_class_doublecheck.
    ENDIF.
  ENDIF.

  IF p_anlage IS NOT INITIAL.

    SELECT eanl~anlage, eanl~vstelle, eanl~sparte,
           iflot~tplnr,
           inob~cuobj,
           ausp~atinn, ausp~atwrt
         FROM eanl AS eanl
         INNER JOIN iflot AS iflot
         ON eanl~vstelle EQ iflot~prems
         INNER JOIN inob AS inob
         ON iflot~tplnr EQ inob~objek
         INNER JOIN ausp AS ausp
         ON inob~cuobj EQ ausp~objek
         WHERE eanl~anlage EQ @p_anlage
           AND ( eanl~sparte EQ 'E' OR
                 eanl~sparte EQ 'DE' OR
                 eanl~sparte EQ 'G' OR
                 eanl~sparte EQ 'DG' )
          AND eanl~zzusage_type EQ 'KV'
          AND ( ausp~atinn NE '0000000756' OR
                ausp~atinn NE'0000000760' OR
                ausp~atinn NE '0000000761' )
         INTO TABLE @DATA(lt_emptyclass_check).

  ELSE.

*  DATA gv_raw_data TYPE truxs_t_text_data.

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = gco_delimiter_tab  " me->mc_delimiter_tab   " '|'
        i_line_header        = abap_false
        i_tab_raw_data       = gv_raw_data
        i_filename           = p_file                        " me->mr_input->ms_input-local_file_path
      TABLES
        i_tab_converted_data = gt_anlage          " me->mt_data
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    IF gt_anlage[] IS INITIAL.

      MESSAGE 'geen apparaatlocaties in bestand gevonden / bestand niet gevonden' TYPE 'S' DISPLAY LIKE 'I'.
      LEAVE LIST-PROCESSING.

    ELSE.

      SELECT eanl~anlage, eanl~vstelle, eanl~sparte,
               iflot~tplnr,
               inob~cuobj,
               ausp~atinn, ausp~atwrt
             FROM eanl AS eanl
             INNER JOIN iflot AS iflot
             ON eanl~vstelle EQ iflot~prems
             INNER JOIN inob AS inob
             ON iflot~tplnr EQ inob~objek
             INNER JOIN ausp AS ausp
             ON inob~cuobj EQ ausp~objek
             FOR ALL ENTRIES IN @gt_anlage
             WHERE eanl~anlage EQ @gt_anlage-anlage
               AND ( eanl~sparte EQ 'E' OR
                     eanl~sparte EQ 'DE' OR
                     eanl~sparte EQ 'G' OR
                     eanl~sparte EQ 'DG' )
              AND eanl~zzusage_type EQ 'KV'
              AND ( ausp~atinn NE '0000000756' OR
                    ausp~atinn NE'0000000760' OR
                    ausp~atinn NE '0000000761' )
             INTO TABLE @lt_emptyclass_check.

    ENDIF.
  ENDIF.

*/**
*  check ANLAGE exists
*/*

  IF lines( lt_class_doublecheck ) GE '1'.

    SELECT anlage
    INTO TABLE @DATA(lt_anlage_doublecheck)
    FROM eanl
    FOR ALL ENTRIES IN @lt_class_doublecheck
    WHERE anlage EQ @lt_class_doublecheck-anlage.

    LOOP AT lt_class_doublecheck
    INTO DATA(ls_anlage_dc).

      READ TABLE  lt_anlage_doublecheck WITH KEY anlage = ls_anlage_dc-anlage INTO DATA(ls_anlage_dcheck).

      IF sy-subrc EQ '0'.
        " ANLAGE bestaat!
      ELSE.
        " ANLAGE bestaat NIET!
        ls_return-message = | ANLAGE/Installatie { ls_anlage_dc-anlage } bestaat niet!|.
        APPEND ls_return TO lt_return_total.

      ENDIF.

    ENDLOOP.

  ENDIF.

  IF lines( gt_anlage ) GE '1'.

    SELECT anlage
    INTO TABLE @DATA(lt_anlage_check)
    FROM eanl
    FOR ALL ENTRIES IN @gt_anlage
    WHERE anlage EQ @gt_anlage-anlage.

    LOOP AT gt_anlage
    INTO DATA(ls_anlage).

      READ TABLE  lt_anlage_check WITH KEY anlage = ls_anlage-anlage INTO DATA(ls_anlage_check).

      IF sy-subrc EQ '0'.
        " ANLAGE bestaat!
      ELSE.
        " ANLAGE bestaat NIET!
        ls_return-message = | ANLAGE/Installatie { ls_anlage-anlage } bestaat niet!|.
        APPEND ls_return TO lt_return_total.

      ENDIF.

    ENDLOOP.

  ENDIF.

*  IF lines( gt_anlage ) EQ 1.
*    READ TABLE gt_anlage INTO DATA(ls_anlage) INDEX 1.
*    p_anlage = ls_anlage-anlage.
*  ENDIF.

*  IF p_anlage IS NOT INITIAL.
*
*    SELECT eanl~anlage, eanl~vstelle,
*              iflot~tplnr,
*              inob~cuobj,
*              ausp~atinn, ausp~atwrt
*       FROM eanl AS eanl
*       INNER JOIN iflot AS iflot
*       ON eanl~vstelle EQ iflot~prems
*       INNER JOIN inob AS inob
*       ON iflot~tplnr EQ inob~objek
*       INNER JOIN ausp AS ausp
*       ON inob~cuobj EQ ausp~objek
*       WHERE eanl~anlage EQ @p_anlage
*         AND ( eanl~sparte EQ 'E' OR
*               eanl~sparte EQ 'DE' OR
*               eanl~sparte EQ 'G' OR
*               eanl~sparte EQ 'DG' )
*        AND eanl~zzusage_type EQ 'KV'
*        AND ( ausp~atinn EQ '0000000756' OR
*              ausp~atinn EQ '0000000760' OR
*              ausp~atinn EQ '0000000761' )
**       AND ( ausp~atwrt EQ 'E' OR
**             ausp~atwrt EQ 'DE' )
**       AND ausp~atwrt EQ @( VALUE #( ) )
*       INTO TABLE @DATA(lt_emptyclass_parameter).
*
*  ELSE.
*
*    SELECT eanl~anlage, eanl~vstelle,
*           iflot~tplnr,
*           inob~cuobj,
*           ausp~atinn, ausp~atwrt
*    FROM eanl AS eanl
*    INNER JOIN iflot AS iflot
*    ON eanl~vstelle EQ iflot~prems
*    INNER JOIN inob AS inob
*    ON iflot~tplnr EQ inob~objek
*    INNER JOIN ausp AS ausp
*    ON inob~cuobj EQ ausp~objek
*    WHERE (  eanl~sparte EQ 'E' OR
*             eanl~sparte EQ 'DE' OR
*             eanl~sparte EQ 'G' OR
*             eanl~sparte EQ 'DG' )
*      AND eanl~zzusage_type EQ 'KV'
*      AND ( ausp~atinn EQ '0000000756' OR
*            ausp~atinn EQ '0000000760' OR
*            ausp~atinn EQ '0000000761' )
**   AND ausp~atwrt EQ @( VALUE #( ) )
*    INTO TABLE @DATA(lt_fullclass).
*
*  ENDIF.

*/**
*  onderstaande code speelt een rol
*  wanneer 'G' en 'DG' niet mogen worden meegenomen
*/*

*    SORT lt_emptyclass BY atwrt DESCENDING.
*
*    LOOP AT lt_emptyclass
*    INTO DATA(ls_emptyclass)
*    WHERE ( atwrt EQ 'DG' OR
*            atwrt EQ 'G' ).
*
**      DATA(lv_index) = sy-tabix.
**      DELETE lt_emptyclass INDEX lv_index.
**      DELETE lt_emptyclass WHERE tplnr EQ ls_emptyclass-tplnr.
*
*      APPEND ls_emptyclass-tplnr TO lt_tplnr_dg.
*
*    ENDLOOP.
*
*    SORT lt_tplnr_dg.
*    DELETE ADJACENT DUPLICATES FROM lt_tplnr_dg COMPARING tplnr.
*
*    LOOP AT lt_emptyclass
*    INTO ls_emptyclass.
*
*      DATA(lv_index) = sy-tabix.
*
*      READ TABLE lt_tplnr_dg TRANSPORTING NO FIELDS
*           BINARY SEARCH
*           WITH KEY tplnr = ls_emptyclass-tplnr.
*
*      IF sy-subrc EQ 0.
*        " regel niet akkoord: 'DG'
*        DELETE lt_emptyclass INDEX lv_index.
*      ELSE.
*        " regel akkoord: 'E' of 'DE'
*      ENDIF.
*
*    ENDLOOP.
*
*    SORT lt_emptyclass BY tplnr.

*  IF p_anlage IS NOT INITIAL.
*
*    SELECT eanl~anlage, eanl~vstelle, eanl~sparte,
*           iflot~tplnr,
*           inob~cuobj,
*           ausp~atinn, ausp~atwrt
*         FROM eanl AS eanl
*         INNER JOIN iflot AS iflot
*         ON eanl~vstelle EQ iflot~prems
*         INNER JOIN inob AS inob
*         ON iflot~tplnr EQ inob~objek
*         INNER JOIN ausp AS ausp
*         ON inob~cuobj EQ ausp~objek
*         WHERE eanl~anlage EQ @p_anlage
*           AND ( eanl~sparte EQ 'E' OR
*                 eanl~sparte EQ 'DE' OR
*                 eanl~sparte EQ 'G' OR
*                 eanl~sparte EQ 'DG' )
*          AND eanl~zzusage_type EQ 'KV'
*          AND ( ausp~atinn NE '0000000756' OR
*                ausp~atinn NE'0000000760' OR
*                ausp~atinn NE '0000000761' )
*         INTO TABLE @DATA(lt_emptyclass_check).
*
*  ELSE.
*
*    SELECT eanl~anlage, eanl~vstelle, eanl~sparte,
*           iflot~tplnr,
*           inob~cuobj,
*           ausp~atinn, ausp~atwrt
*     FROM eanl AS eanl
*     INNER JOIN iflot AS iflot
*     ON eanl~vstelle EQ iflot~prems
*     INNER JOIN inob AS inob
*     ON iflot~tplnr EQ inob~objek
*     INNER JOIN ausp AS ausp
*     ON inob~cuobj EQ ausp~objek
*     WHERE (  eanl~sparte EQ 'E' OR
*              eanl~sparte EQ 'DE' OR
*              eanl~sparte EQ 'G' OR
*              eanl~sparte EQ 'DG' )
*     AND eanl~zzusage_type EQ 'KV'
*     AND ( ausp~atinn NE '0000000756' AND
*           ausp~atinn NE '0000000760' AND
*           ausp~atinn NE '0000000761' )
*     INTO TABLE @lt_emptyclass_check.
*
*  ENDIF.

*/**
* verwerk alle apparaatlocaties zonder classificatie
* 0000000756 = EIGENAAR_METER_APP_LOC       /  KLART: 002 - EQUI
* 0000000760 = KENMERK_GV_OF_KV                  /   KLART: 003 - IFLOT
* 0000000761 = PRODUCT                                      /  KLART: 003 - IFLOT
*/*
* data lv_object_table type tabelle.

  CONSTANTS co_classtype_002   TYPE klassenart   VALUE '002'.
  CONSTANTS co_classtype_003   TYPE klassenart   VALUE '003'.

  DATA lt_allocnum  TYPE tt_bapi1003_alloc_values_num.
  DATA ls_allocnum  TYPE bapi1003_alloc_values_num.
  DATA lt_allocchar TYPE tt_bapi1003_alloc_values_char.
  DATA ls_allocchar TYPE bapi1003_alloc_values_char.
  DATA lt_alloccurr TYPE tt_bapi1003_alloc_values_curr. "bapi1003_alloc_values_curr

  SORT lt_emptyclass_check BY tplnr.
  DELETE ADJACENT DUPLICATES FROM lt_emptyclass_check COMPARING tplnr.

  IF lines( lt_emptyclass_check ) GE '1'.

    SELECT euiinstln~int_ui, euiinstln~anlage, euigrid~grid_id
    INTO TABLE @DATA(lt_intmid)
    FROM euiinstln AS euiinstln
    INNER JOIN euigrid AS euigrid
    ON euiinstln~int_ui EQ euigrid~int_ui
    FOR ALL ENTRIES IN @lt_emptyclass_check
    WHERE anlage EQ @lt_emptyclass_check-anlage.

    SELECT *
    INTO TABLE @DATA(lt_net)
    FROM zanlage_netnr.

  ENDIF.

  IF lines( lt_class_doublecheck ) GE '1'.

    SELECT euiinstln~int_ui, euiinstln~anlage, euigrid~grid_id
    INTO TABLE @lt_intmid
    FROM euiinstln AS euiinstln
    INNER JOIN euigrid AS euigrid
    ON euiinstln~int_ui EQ euigrid~int_ui
    FOR ALL ENTRIES IN @lt_class_doublecheck
    WHERE anlage EQ @lt_class_doublecheck-anlage.

    SELECT *
    INTO TABLE @lt_net
    FROM zanlage_netnr.

  ENDIF.
  TYPES: BEGIN OF ty_newclass,
           tplnr  TYPE tplnr,
           anlage TYPE anlage,
           sparte TYPE sparte,
           cuobj  TYPE objnum,      " cuobj,
           atinn  TYPE klasse_d,        " atinn,
         END OF ty_newclass.

  TYPES tty_newclass TYPE STANDARD TABLE OF ty_newclass WITH NON-UNIQUE KEY tplnr anlage sparte.

  DATA lt_newclass TYPE tty_newclass.

  LOOP AT lt_emptyclass_check
    INTO DATA(ls_empchk).

    DATA(ls_newclass) = VALUE ty_newclass(
                   tplnr = ls_empchk-tplnr
                    anlage = ls_empchk-anlage
                    sparte = ls_empchk-sparte
                    cuobj = ls_empchk-cuobj
                    atinn = '0000000756'                    "  'EIGENAAR_METER_APP_LOC'
                  ).

    APPEND ls_newclass TO lt_newclass.
    CLEAR ls_newclass.

    ls_newclass = VALUE ty_newclass(
                    tplnr = ls_empchk-tplnr
                     anlage = ls_empchk-anlage
                     sparte = ls_empchk-sparte
                     cuobj = ls_empchk-cuobj
                     atinn =  '0000000760'                  " 'KENMERK_GV_OF_KV'
                   ).

    APPEND ls_newclass TO lt_newclass.
    CLEAR ls_newclass.

    ls_newclass = VALUE ty_newclass(
                tplnr = ls_empchk-tplnr
                 anlage = ls_empchk-anlage
                 sparte = ls_empchk-sparte
                 cuobj = ls_empchk-cuobj
                 atinn = '0000000761'                      " 'PRODUCT'
               ).

    APPEND ls_newclass TO lt_newclass.
    CLEAR ls_newclass.

  ENDLOOP.

  DATA lv_class_type TYPE  klassenart.
  DATA lv_object_table TYPE tabelle .

  LOOP AT lt_newclass
  INTO DATA(ls_new).

    CLEAR lt_return[].
    CLEAR lt_allocchar[].
    CLEAR lt_alloccurr[].
    CLEAR lt_allocnum[].

    IF ls_new-tplnr IS NOT INITIAL.

      " check the classification values before creating the functional location

*      CALL FUNCTION 'CHAR_VALUE_CHECK2'
*        EXPORTING
**         atinn                  =
**         atnam                  =
*          new_value              =
**         flag_no_dialog         =
**         line_number            =
**       IMPORTING
**         atwrt                  =
**         atflv                  =
**         wrtkz                  =
*        exceptions
*          characteristic_unknown = 1
*          conversion_error       = 2
*          popup_escape           = 3
*          others                 = 4.
*      IF sy-subrc <> 0.
**      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.

      READ TABLE lt_intmid
      INTO DATA(ls_intmid)
      WITH KEY anlage = ls_new-anlage.

      IF ls_intmid-grid_id IS NOT INITIAL.

        READ TABLE lt_net
        INTO DATA(ls_net)
        WITH KEY  net = ls_intmid-grid_id.

        DATA(lv_gridid_classification) = ls_net-classificatie.

      ENDIF.

      CASE ls_new-atinn.
        WHEN '0000000756'.                                                       " 'EIGENAAR_METER_APP_LOC'.

          lv_class_type = '002'.
          lv_object_table = 'EQUI'.

          ls_allocchar-charact = '0000000756'.                             " 'EIGENAAR_METER_APP_LOC'.
          ls_allocchar-value_neutral = lv_gridid_classification.
          APPEND ls_allocchar TO lt_allocchar.
          CLEAR ls_allocchar.

        WHEN '0000000760'.                                                      "  'KENMERK_GV_OF_KV'.

          lv_class_type = '003'.
          lv_object_table = 'IFLOT'.

          ls_allocchar-charact = '0000000760'.                            " 'KENMERK_GV_OF_KV'.
          ls_allocchar-value_neutral = 'KV'.
          APPEND ls_allocchar TO lt_allocchar.
          CLEAR ls_allocchar.

        WHEN '0000000761'.                                                      "  'PRODUCT'.

          lv_class_type = '003'.
          lv_object_table = 'IFLOT'.

          ls_allocchar-charact = '0000000761'.                            "  'PRODUCT'.
          ls_allocchar-value_neutral = ls_new-sparte.
          APPEND ls_allocchar TO lt_allocchar.
          CLEAR ls_allocchar.

        WHEN OTHERS.
      ENDCASE.

      CALL FUNCTION 'BAPI_OBJCL_CREATE'
        EXPORTING
          objectkeynew    = ls_new-cuobj
          objecttablenew  = lv_object_table
          classnumnew     = ls_new-atinn
          classtypenew    = lv_class_type
*         status          = '1'
*         standardclass   =
*         changenumber    =
          keydate         = sy-datum
*         no_default_values = SPACE
*         objectkeynew_long =
*  IMPORTING
*         classif_status  =
        TABLES
          allocvaluesnum  = lt_allocnum
          allocvalueschar = lt_allocchar
          allocvaluescurr = lt_alloccurr
          return          = lt_return.

      APPEND LINES OF lt_return TO lt_return_total.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'
*      IMPORTING
*         return =     " Terugmeldingen
        .

      CLEAR lv_class_type.
      CLEAR lv_object_table.
      CLEAR lv_gridid_classification.
      CLEAR ls_new.
      CLEAR lt_return[].

    ENDIF.
  ENDLOOP.

  IF 1 EQ 2.
  ENDIF.

  DATA lo_alv          TYPE REF TO cl_salv_table.
  DATA lo_columns  TYPE REF TO cl_salv_columns_table.
  DATA lo_functions TYPE REF TO cl_salv_functions_list.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = lt_return_total ).
    CATCH cx_salv_msg INTO DATA(lr_message).
  ENDTRY.

  lo_functions = lo_alv->get_functions( ).
  lo_functions->set_all( ).
  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( ).
  lo_alv->display( ).


FORM u_selectfile CHANGING c_file TYPE localfile.

  DATA :
    lv_subrc  LIKE sy-subrc,
    lt_it_tab TYPE filetable.

  " Display File Open Dialog control/screen
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title     = 'Select Source File'
      default_filename = '*'
      multiselection   = ' '
    CHANGING
      file_table       = lt_it_tab
      rc               = lv_subrc.

  " Write path on input area
  LOOP AT lt_it_tab INTO c_file.
  ENDLOOP.

ENDFORM.


*DATA lv_objectkey  TYPE objnum.
*DATA lv_classnew   TYPE klasse_d.
*DATA lt_return     TYPE bapiret2_tab.
*
*DATA lt_char_old     TYPE TABLE OF bapi1003_alloc_values_char.
*DATA lt_curr_new     TYPE TABLE OF bapi1003_alloc_values_curr.
*DATA ls_char_new     TYPE bapi1003_alloc_values_char.
*
*START-OF-SELECTION.
*
*  lv_objectkey = '000000005008590361'.
*
*  DO 1 TIMES.
*    IF sy-tabix = 1.
*      lv_classnew = 'KENMERK_METER_KV'.
*    ELSE.
*      lv_classnew = 'ISU_INFOSTROOM'.
*    ENDIF.


*    ls_char_new-charact = 'FACTURATIE_RELEVANT'.
*    ls_char_new-value_neutral = 'Ja'.
*    APPEND ls_char_new TO lt_char_old.
*    ls_char_new-charact =  'GEFACTUREERD'.
*    ls_char_new-value_neutral = 'Nee'.
*    APPEND ls_char_new TO lt_char_old.
*
*
*    CALL FUNCTION 'BAPI_OBJCL_CREATE'
*      EXPORTING
*        objectkeynew            = lv_objectkey
*        objecttablenew          = 'EQUI'
*        classnumnew             = lv_classnew
*        classtypenew            = '002'
**                    STATUS                  = '1'
**                    STANDARDCLASS           =
**                    CHANGENUMBER            =
**                    KEYDATE                 = SY-DATUM
**                    NO_DEFAULT_VALUES       = ' '
**                  IMPORTING
**                    CLASSIF_STATUS          =
*      TABLES
**                    ALLOCVALUESNUM          =
*                    allocvalueschar         = lt_char_old
**                    ALLOCVALUESCURR         =
*        return                  = lt_return.

*  ENDIF.
