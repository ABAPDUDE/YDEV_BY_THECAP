*&---------------------------------------------------------------------*
*& Report YMD_104
*&----if.-----------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0072.

SELECT zisu_poc_owner~bp, but0id~type, but0id~idnumber
        INTO TABLE @DATA(lt_join)
        FROM zisu_poc_owner AS zisu_poc_owner
        INNER JOIN but0id AS but0id
        ON zisu_poc_owner~bp EQ but0id~partner
*           WHERE but0id~valid_date_to GE @sy-datum    " Niet onderhouden in tabel!!
*             AND but0id~valid_date_from GE @sy-datum  " Niet onderhouden in tabel!!
        WHERE zisu_poc_owner~valid_from LE @sy-datum
          AND zisu_poc_owner~valid_to GE @sy-datum
          AND but0id~type NE 'ZWWOCO'.

SORT lt_join BY bp.
DELETE ADJACENT DUPLICATES FROM lt_join COMPARING bp.

IF 1 EQ 2.
ENDIF.
