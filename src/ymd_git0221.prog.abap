*&---------------------------------------------------------------------*
*& Report ymd_git0221
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0221.

DATA tsl TYPE timestampl.

GET TIME STAMP FIELD DATA(ts).
GET TIME STAMP FIELD tsl.

cl_demo_output=>new(
  )->write( |{ ts  TIMESTAMP = ISO
                   TIMEZONE = 'UTC' }|
  )->write( |{ tsl TIMESTAMP = ISO
                   TIMEZONE = 'UTC' }|
  )->display( ).
