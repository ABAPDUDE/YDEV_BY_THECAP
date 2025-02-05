*&---------------------------------------------------------------------*
*& Report ymd_git0218
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0218.

*&---------------------------------------------------------------------*
*&      Module  LOKET_DROPDOWN_BOX  OUTPUT
*&---------------------------------------------------------------------*
*       listbox vullen Loket
*----------------------------------------------------------------------*
MODULE loket_dropdown_box OUTPUT.

  PERFORM loket_dropdown_box.
ENDMODULE.

TABLES: zcarm_wo_2_crm_scr_fields,   " 'TABLES' Noodzakelijk voor een makkelijk data transfer van/naar schermen
        *zcarm_wo_2_crm_scr_fields.
DATA: go_carm_standen_wo_2_crm TYPE REF TO zcl_carm_standen_wo_2_crm.

DATA: gt_t_loket_vrm        TYPE vrm_values.

FORM loket_dropdown_box.
  IF gt_t_loket_vrm IS INITIAL.

* TO DO verplaats naar klasse ===============================
    SELECT * FROM zherkomst_loket
      INTO TABLE @DATA(lt_zherkomst_loket)
     WHERE herkomst EQ @zcarm_wo_2_crm_scr_fields-herkomst.
*     Vul Listbox met waarden. Zijn er maar een paar...
    LOOP AT lt_zherkomst_loket ASSIGNING FIELD-SYMBOL(<zherkomst_loket>).

      APPEND INITIAL LINE TO gt_t_loket_vrm REFERENCE INTO DATA(lrd_loket_vrm).
      lrd_loket_vrm->key    = <zherkomst_loket>-loket.
      SELECT SINGLE omsch FROM zloketten_crm INTO lrd_loket_vrm->text   "TO DO AANPASSEN NAAR NIEUWE ZCUST TABEL
        WHERE loket EQ <zherkomst_loket>-loket.
      IF sy-subrc IS NOT INITIAL.
        lrd_loket_vrm->text = '- geen omschrijving -'.        "#NO_TEXT
      ENDIF.
    ENDLOOP.
*   ========================================================================
  ENDIF.

* Set values in listbox
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'ZCARM_WO_2_CRM_SCR_FIELDS-LOKET'   " Afdeling
      values = gt_t_loket_vrm[].

ENDFORM.
