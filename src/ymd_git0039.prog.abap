*&---------------------------------------------------------------------*
*& Report YMD_0014
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0039.

DATA lv_zp TYPE bu_partner.
CONSTANTS mc_via_zakenpartner TYPE zdata_oorsprong VALUE 'VIA-ZAKENPARTNER'.

lv_zp = '0025024494'.

TYPES:
  BEGIN OF ty_vpsoort,
    sign   TYPE ddsign,
    option TYPE ddoption,
    low    TYPE vbsart,
    high   TYPE vbsart,
  END OF ty_vpsoort.

TYPES tty_vpsoort TYPE STANDARD TABLE OF ty_vpsoort.

DATA ls_vpsoort TYPE ty_vpsoort.
DATA lt_vpsoort TYPE tty_vpsoort.

lt_vpsoort = VALUE #( BASE lt_vpsoort ( sign = 'I' option = 'EQ' low = 'WON' )
                                      ( sign = 'I' option = 'EQ' low = 'BEDR' )
                                      ( sign = 'I' option = 'EQ' low = 'CVZ' )
                                      ( sign = 'I' option = 'EQ' low = 'GAR' )
                                      ( sign = 'I' option = 'EQ' low = 'WINK' )
                                      ( sign = 'I' option = 'EQ' low = ' ' )
                                      ).


SELECT *
    FROM zdsync_sap_adr
    WHERE data_oorsprong EQ @mc_via_zakenpartner
      AND zakenpartner EQ @lv_zp                      " @me->mo_input->ms_input-zaken_partner
      AND eigenaar EQ @lv_zp                          " @me->mo_input->ms_input-zaken_partner
      AND ( bag_id <> @( VALUE #( ) ) OR
          ( postcode <> @( VALUE #( ) ) AND
            huisnummer <> @( VALUE #( ) ) ) )
      AND vp_soort IN @lt_vpsoort
    INTO TABLE @DATA(lt_nodril)
    UP TO 2500 ROWS.

IF lt_nodril[] IS NOT INITIAL.
  "test nbreakpoint

ENDIF.
