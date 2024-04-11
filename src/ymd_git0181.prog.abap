*&---------------------------------------------------------------------*
*& Report YMD_GIT0181
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0181.

DATA: time_stamp TYPE timestamp,
      tz         TYPE ttzz-tzone.

tz = 'CET'.
time_stamp = 20030309033000.
CONVERT TIME STAMP time_stamp TIME ZONE tz
        INTO DATE DATA(dat) TIME DATA(tim)
        DAYLIGHT SAVING TIME DATA(dst).
cl_demo_output=>write( |{ dat DATE = ISO } {
                          tim TIME = ISO } { dst }| ).

DATA lv_timestamp TYPE timestamp.
GET TIME STAMP FIELD lv_timestamp.
CONVERT TIME STAMP lv_timestamp TIME ZONE tz
        INTO DATE dat TIME tim
        DAYLIGHT SAVING TIME dst.
CONCATENATE dat tim INTO DATA(lv_timestamp_local).

cl_demo_output=>write( lv_timestamp_local ).

time_stamp = 20030309043000.
CONVERT TIME STAMP time_stamp TIME ZONE tz
        INTO DATE dat TIME tim
        DAYLIGHT SAVING TIME dst.
cl_demo_output=>write( |{ dat DATE = ISO } {
                          tim TIME = ISO } { dst }| ).

cl_demo_output=>display( ).
