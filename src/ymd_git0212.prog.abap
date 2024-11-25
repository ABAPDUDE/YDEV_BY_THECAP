*&---------------------------------------------------------------------*
*& Report YMD_GIT0212
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0212.

DATA lv_referentie TYPE zref_id VALUE 'VZC-871685900014173527-20241028-151130'.

SELECT *
    FROM zp5_meetdata_el
    WHERE workload_ready EQ @( VALUE #( ) )
     INTO TABLE @DATA(lt_el).


READ TABLE lt_el
   INTO DATA(ls_p5)
   WITH KEY referentie = lv_referentie.


ls_p5-caseid = '0023236565'.

UPDATE zp5_meetdata_el FROM ls_p5.
COMMIT WORK AND WAIT.
