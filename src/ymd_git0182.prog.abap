*&---------------------------------------------------------------------*
*& Report ymd_git0182
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0182.

DATA: l_uuid_x16 TYPE sysuuid_x16.
DATA: system_uuid TYPE REF TO if_system_uuid.
DATA: oref        TYPE REF TO cx_uuid_error.


system_uuid = cl_uuid_factory=>create_system_uuid( ).


TRY.
    l_uuid_x16 = system_uuid->create_uuid_x16( ). " create uuid_x16


  CATCH cx_uuid_error INTO oref.                  " catch error
    DATA: s1 TYPE string.
    s1 = oref->get_text( ).
ENDTRY.
