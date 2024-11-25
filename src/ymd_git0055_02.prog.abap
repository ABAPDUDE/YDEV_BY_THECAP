*&---------------------------------------------------------------------*
*& Report YMD_GIT0055_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0055_02.

SELECT *
       FROM scarr
       INTO TABLE @DATA(carriers).

CALL TRANSFORMATION id SOURCE carriers = carriers
                       RESULT XML DATA(xml).

cl_demo_output=>new(
  )->begin_section( `Some Text`
  )->write_text( |blah blah blah \n| &&
                 |blah blah blah|
  )->next_section( `Some Data`
  )->begin_section( `Elementary Object`
  )->write_data( carriers[ 1 ]-carrid
  )->next_section( `Internal Table`
  )->write_data( carriers
  )->end_section(
  )->next_section( `XML`
  )->write_xml( xml
  )->display( ).
