*&---------------------------------------------------------------------*
*& Report YMD_073
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT YMD_GIT0173.


SELECT *
     FROM scarr
     INTO TABLE @DATA(itab).
CALL TRANSFORMATION id SOURCE scarr = itab
                      RESULT XML DATA(xml).

DATA(dset) = 'scarr.dat'.
OPEN DATASET dset FOR OUTPUT IN BINARY MODE.
TRANSFER xml TO dset.
CLOSE DATASET dset.

...

CLEAR xml.
OPEN DATASET dset FOR INPUT IN BINARY MODE.
READ DATASET dset INTO xml.
CLOSE DATASET dset.

CALL TRANSFORMATION id SOURCE XML xml
                       RESULT scarr = itab.
cl_demo_output=>display( itab ).

DELETE DATASET dset.
