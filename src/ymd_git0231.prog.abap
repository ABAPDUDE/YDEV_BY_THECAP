*&---------------------------------------------------------------------*
*& Report ymd_git0231
*&---------------------------------------------------------------------*
REPORT ymd_git0231.

*/**
*
* vul tabel ZANLAGE_NETNR
*
* 0001        Liander
* 0002        Enduris
* 0003        Enexis
* 0004        Stedin
* 0005        Cogas
* 0006        Rendo
*/*


TYPES: BEGIN OF ty_fill,
         mandt         TYPE mandt,
         net           TYPE grid_id,
         classificatie TYPE atwrt,
         omschrijving  TYPE char10,
       END OF ty_fill.

TYPES tty_fill TYPE SORTED TABLE OF ty_fill WITH UNIQUE KEY net.

DATA(lt_fill) = VALUE tty_fill(
              ( mandt = '060' net = '871685900E' classificatie = '0001' omschrijving = 'LIANDER' )
              ( mandt = '060' net = '871687100E' classificatie = '0001' omschrijving = 'LIANDER' )
              ( mandt = '060' net = '871687100G' classificatie = '0001' omschrijving = 'LIANDER' )
              ( mandt = '060' net = '871690900E' classificatie = '0001' omschrijving = 'LIANDER' )
              ( mandt = '060' net = '871690200E' classificatie = '0002' omschrijving = 'ENDURIS' )
              ( mandt = '060' net = '871712775G' classificatie = '0002' omschrijving = 'ENDURIS' )
              ( mandt = '060' net = '871689700G' classificatie = '0003' omschrijving = 'ENEXIS' )
              ( mandt = '060' net = '871694800G' classificatie = '0003' omschrijving = 'ENEXIS' )
              ( mandt = '060' net = '871689200G' classificatie = '0004' omschrijving = 'STEDIN' )
              ( mandt = '060' net = '871691600G' classificatie = '0005' omschrijving = 'COGAS' )
              ( mandt = '060' net = '871691200E' classificatie = '0006' omschrijving = 'RENDO' )
              ( mandt = '060' net = '871691200G' classificatie = '0006' omschrijving = 'RENDO' )
                              ).
IF lt_fill[] IS NOT INITIAL.

  MODIFY zanlage_netnr FROM TABLE lt_fill.

ENDIF.
