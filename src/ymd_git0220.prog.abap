*&---------------------------------------------------------------------*
*& Report ymd_git0220
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0220.

" type UTCLONG available from 7.56
* DATA timestamp1 TYPE utclong.
* DATA timestamp2 TYPE utclong.
* DATA difference TYPE decfloat34.
* DATA date_user TYPE d.
* DATA time_user TYPE t.
*
* timestamp1 = utclong_current( ).
* out->write( |Current UTC time { timestamp1 }| ).
*
* timestamp2 = utclong_add( val = timestamp1 days = 7 ).
* out->write( |Added 7 days to current UTC time { timestamp2 }| ).
*
* difference = utclong_diff( high = timestamp2 low = timestamp1 ).
* out->write( |Difference between timestamps in seconds: { difference }| ).
*
* out->write( |Difference between timestamps in days: { difference / 3600 / 24 }| ).
*
* CONVERT UTCLONG utclong_current( )
*    INTO DATE date_user
*         TIME time_user
*         TIME ZONE cl_abap_context_info=>get_user_time_zone( ).
*
* out->write( |UTC timestamp split into date (type D) and time (type T )| ).
* out->write( |according to the user's time zone (cl_abap_context_info=>get_user_time_zone( ) ).| ).
* out->write( |{ date_user date = user }, { time_user time = user }| ).
