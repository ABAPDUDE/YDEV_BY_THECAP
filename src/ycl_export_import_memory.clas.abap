class YCL_EXPORT_IMPORT_MEMORY definition
  public
  final
  create public .

public section.

  class-methods EXPORT_ADRES_OUD_NIEUW
    importing
      !IS_X_OBJ type ISU01_CONNOBJ .
  class-methods IMPORT_ADRES_OUD_NIEUW
    returning
      value(RETURNING) type ISU01_CONNOBJ .
  class-methods FREE_ADRES_OUD_NEW .
protected section.
private section.
ENDCLASS.



CLASS YCL_EXPORT_IMPORT_MEMORY IMPLEMENTATION.


  METHOD export_adres_oud_nieuw.

    EXPORT is_x_obj = is_x_obj TO MEMORY ID 'ZADR_WIJZ'.

  ENDMETHOD.


  METHOD free_adres_oud_new.

    FREE MEMORY ID 'ZADR_WIJZ'.

  ENDMETHOD.


  METHOD import_adres_oud_nieuw.

    IMPORT returning = returning FROM MEMORY ID 'ZADR_WIJZ'.

  ENDMETHOD.
ENDCLASS.
