*&---------------------------------------------------------------------*
*& Report ymd_git0232
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0232.

DATA lv_username TYPE uname.
DATA ls_user_logondata TYPE bapilogond.
DATA ls_user_password TYPE bapipwd.
DATA ls_user_adress TYPE bapiaddr3.
DATA lt_return TYPE bapiret2_t.

lv_username = |IRONMIKE|.

ls_user_logondata-gltgv = sy-datum.
ls_user_logondata-gltgb = '99991231'.
ls_user_logondata-ustyp = |A|.

ls_user_password-bapipwd = |uppercut|.

ls_user_adress-firstname = |Mike|.
ls_user_adress-lastname = |Tyson|.
ls_user_adress-e_mail = |mike.derksema@alliander.com|.

CALL FUNCTION 'BAPI_USER_CREATE1'
  EXPORTING
    username  = lv_username
*   name_in   =
    logondata = ls_user_logondata
    password  = ls_user_password
*   defaults  =
    address   = ls_user_adress
*   company   =
*   snc       =
*   ref_user  =
*   alias     =
*   ex_address              =
*   uclass    =
*   force_system_assignment =
*   self_register           = SPACE
*   tech_user =
*   lock_locally            = SPACE
*   generate_pwd            = SPACE
*   description             =
*              IMPORTING
*   generated_password      =
  TABLES
*   parameter =
    return    = lt_return
*   addtel    =
*   addfax    =
*   addttx    =
*   addtlx    =
*   addsmtp   =
*   addrml    =
*   addx400   =
*   addrfc    =
*   addprt    =
*   addssf    =
*   adduri    =
*   addpag    =
*   addcomrem =
*   groups    =
*   parameter1              =
*   extidhead =
*   extidpart =
  .

WRITE:/10 | SAP UserID: { lv_username }|.
WRITE:/10 | SAP Password: { ls_user_password-bapipwd }|.
SKIP 1.
WRITE:/10 | Return message(s)|.
LOOP AT lt_return INTO DATA(ls_return).
  WRITE:/10 | { ls_return-message }|.
  WRITE:/10 | Return message|.
ENDLOOP.
