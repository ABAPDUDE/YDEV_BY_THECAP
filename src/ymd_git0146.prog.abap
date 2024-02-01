*&---------------------------------------------------------------------*
*& Report YMD_046
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0146.

TYPES:
  BEGIN OF ty_ean,
    ext_ui TYPE ext_ui,
  END OF ty_ean .
TYPES:
  tty_ean TYPE SORTED TABLE OF ty_ean WITH NON-UNIQUE KEY ext_ui .

TYPES:
  BEGIN OF ty_productinstall,
    ext_ui           TYPE ext_ui,
    zz_ean_ldn       TYPE zz_ean_ldn,
    anlage           TYPE anlage,
    vstelle          TYPE vstelle,
    zzstatus_aansl   TYPE zchar_stat_aansl,
    sparte           TYPE sparte,
    zzusage_type     TYPE zusagetype,
    zzdoorlaatwaarde TYPE zdoorlaatwaarde,
    operand          TYPE e_operand,
  END OF ty_productinstall .
TYPES:
  tty_productinstall TYPE STANDARD TABLE OF ty_productinstall WITH NON-UNIQUE KEY ext_ui .

DATA mt_ean_product TYPE tty_ean.
DATA mt_ceres_mutation TYPE zdt_power_generating_unit_tab1 .
DATA ls_output TYPE zmt_filter.
DATA ls_input  TYPE zmt_power_generating_unit_typ2.

CONSTANTS mc_actief_tijd TYPE sy-uzeit VALUE '235959' ##NO_TEXT.
CONSTANTS mc_usagetype_gv TYPE zusagetype VALUE 'GV' ##NO_TEXT.
CONSTANTS mc_usagetype_kv TYPE zusagetype VALUE 'KV' ##NO_TEXT.
CONSTANTS mc_aansluitobj_isu TYPE fltyp VALUE 'A' ##NO_TEXT.
CONSTANTS mc_actief_datum TYPE sy-datum VALUE '99991231' ##NO_TEXT.
CONSTANTS mc_product_electra TYPE sparte VALUE 'N' ##NO_TEXT.
CONSTANTS mc_operand_03 TYPE e_operand VALUE '03-TEVRMGN' ##NO_TEXT.
CONSTANTS mc_operand_08 TYPE e_operand VALUE '08-TEBWJR' ##NO_TEXT.

ASSIGN '20220406'TO FIELD-SYMBOL(<fs_dats>).

ls_output-mt_filter-mutation_date_time_period-start =
  |{ <fs_dats>(4) }-{ <fs_dats>+4(2) }-{ <fs_dats>+6(2) }T00:00:00.000Z|.
ls_output-mt_filter-mutation_date_time_period-end =
  |{ <fs_dats>(4) }-{ <fs_dats>+4(2) }-{ <fs_dats>+6(2) }T23:59:59.999Z|.

DATA(lr_ceres) = NEW zco_sios_get_power_generating1( ).

TRY.
    lr_ceres->sios_get_power_generating_unit(
      EXPORTING
        output   = ls_output
      IMPORTING
        input    = ls_input ).
ENDTRY.

APPEND LINES OF ls_input-mt_power_generating_unit_type-power_generating_unit_type_a
   TO mt_ceres_mutation.

mt_ean_product[] = CORRESPONDING #( mt_ceres_mutation[] MAPPING ext_ui = identified_object_eanid ).
*   SORT mt_ean_product.
DELETE ADJACENT DUPLICATES FROM mt_ean_product.

DATA(lv_lines_ean) = lines( mt_ean_product ).
IF lv_lines_ean GE 0.

  SELECT euitrans~ext_ui, eanl~zz_ean_ldn, euiinstln~anlage, eanl~vstelle,
         eanl~zzstatus_aansl, eanl~sparte, eanl~zzusage_type,
         eanl~zzdoorlaatwaarde, ettifn~operand
        INTO TABLE @DATA(lt_join)
        FROM euitrans AS euitrans
        INNER JOIN euiinstln AS euiinstln
        ON euitrans~int_ui EQ euiinstln~int_ui
        INNER JOIN eanl AS eanl
        ON euiinstln~anlage EQ eanl~anlage
        INNER JOIN ettifn AS ettifn
        ON euiinstln~anlage EQ ettifn~anlage
        FOR ALL ENTRIES IN @mt_ean_product
        WHERE euitrans~ext_ui     EQ @mt_ean_product-ext_ui
          AND euitrans~dateto     EQ @mc_actief_datum
          AND euitrans~timeto     EQ @mc_actief_tijd
          AND euiinstln~dateto    EQ @mc_actief_datum
          AND euiinstln~timeto    EQ @mc_actief_tijd
          AND eanl~sparte         EQ @mc_product_electra
          AND eanl~zzusage_type   IN ( @mc_usagetype_kv, @mc_usagetype_gv )
          AND ettifn~operand      IN ( @mc_operand_03, @mc_operand_08 ).

ENDIF.

IF 1 EQ 2.
ELSE.
ENDIF.
