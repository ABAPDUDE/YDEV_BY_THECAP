*&---------------------------------------------------------------------*
*& Report YMD_GIT0000_A
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0000_a.

DATA lv_string_sloop1 TYPE string.
DATA lv_string_sloop2 TYPE string.

DATA lv_ean TYPE ext_ui VALUE '763549957553'.
DATA lv_status TYPE char2 VALUE '2'.
DATA lv_status_ean_txt TYPE char40 VALUE 'Dit is een voorbeeld tekst van status'.
DATA lv_status_reden TYPE char2 VALUE '6'.
DATA  lv_statusreden_ean_txt TYPE char40 VALUE 'Dit is een voorbeeld tekst van StatusReden'.

lv_string_sloop1 =  |EAN { lv_ean }; Status: { lv_status }-{ lv_status_ean_txt } | &&
                     | Statusreden: { lv_status_reden }-{ lv_statusreden_ean_txt } | &&
                     |{ cl_abap_char_utilities=>cr_lf }| &&
                     |  Let op: Voor deze EAN bestaat een sloopaanvraag | &&
                     | { cl_abap_char_utilities=>cr_lf }|.

WRITE: /10 lv_string_sloop1.
