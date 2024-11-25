*&---------------------------------------------------------------------*
*& Report YMD_GIT0055_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0055_01.

SELECT *
       FROM scarr
       INTO TABLE @DATA(carriers).

CALL TRANSFORMATION id SOURCE carriers = carriers
                       RESULT XML DATA(xml).

cl_demo_output=>begin_section( `Some Text` ).
cl_demo_output=>write_text( |blah blah blah \n| &&
                            |blah blah blah| ).
cl_demo_output=>next_section( `Some Data` ).
cl_demo_output=>begin_section( `Elementary Object` ).
cl_demo_output=>write_data( carriers[ 1 ]-carrid ).
cl_demo_output=>next_section( `Internal Table` ).
cl_demo_output=>write_data( carriers ).
cl_demo_output=>end_section( ).
cl_demo_output=>next_section( `XML` ).
cl_demo_output=>write_xml( xml ).
cl_demo_output=>display( ).
