*&---------------------------------------------------------------------*
*& Report YMD_019
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0099.

TYPES : BEGIN OF ty_ettifn,
          anlage  LIKE  ettifn-anlage,
          operand LIKE  ettifn-operand,
          ab      LIKE  ettifn-ab,
          bis     LIKE  ettifn-bis,
          wert1   LIKE  ettifn-wert1,
          inactiv TYPE sap_bool,
        END   OF ty_ettifn.

*Datum geldige installaties.
PARAMETERS : pa_dat TYPE v_eanl-ab OBLIGATORY DEFAULT '20210525'.

SELECT anlage,
       operand,
       ab,
       bis,
       wert1,
       inaktiv
       INTO TABLE @DATA(tb_ettifn)
       FROM ettifn
*       FOR ALL ENTRIES IN tb_v_eanl
       WHERE anlage     = '6000026989'
       AND   ab        <= @pa_dat
       AND   bis       >= @pa_dat
       AND   inaktiv    = ' '.

IF tb_ettifn[] IS NOT INITIAL.

ENDIF.

CLEAR tb_ettifn[].

SELECT anlage
       operand
       ab
       bis
       wert1
       inaktiv
       INTO TABLE tb_ettifn
       FROM ettifn
*       FOR ALL ENTRIES IN tb_v_eanl
       WHERE anlage     = '6000026989'
       AND   ab        <= pa_dat
       AND   bis       >= pa_dat.

IF tb_ettifn[] IS NOT INITIAL.

ENDIF.
