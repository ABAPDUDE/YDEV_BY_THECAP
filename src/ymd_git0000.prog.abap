*&---------------------------------------------------------------------*
*& Report YMD_GIT0000
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0000.

*/**
* String Templates
*
* The purpose of a string template is to create a new character string out of literal texts
* and embedded expressions. It largely replaces the use of the WRITE TO statement,
* which will be explained later on.
*
* A string template is defined by using the | (pipe) symbol at the beginning and end of a template.
*/*

DATA character_string TYPE string.
DATA numeric_variable TYPE num.

character_string = |This is a literal text.|.

character_string = `This is a literal text.`.

character_string = |{ numeric_variable }|.

character_string = |This resulted in return code { sy-subrc }|.

character_string = |The length of text element 001 ({ TEXT-001 }) is { strlen( TEXT-001 ) }|.

DATA: amount_field   TYPE vbap-netwr VALUE '1234567.123',
      currency_field TYPE vbap-waerk.
character_string = |{ amount_field CURRENCY = currency_field  NUMBER = USER }|.
character_string = |{ amount_field COUNTRY = 'GB ' }|.

character_string = |{ TEXT-001 }|.

*/**
* Chaining Operator
*
* The Chaining Operator && can be used to create one character string out of multiple other strings
* and string templates. The use of the chaining operator largely replaces the CONCATENATE statement.
* In this example, a number text, a space, an existing character string and a new string template
* are concatenated into a new character string.

character_string  =  'Text literal'(002) && ` ` && character_string && |{ amount_field NUMBER = USER }|.

*/**
* Built-in functions
*
* SAP has added several new built-in functions for searching, comparing, and processing character strings.
* A few of these functions already existed before release WAS702, like for example, CHARLEN( ) or STRLEN( ).
* Other statements like FIND, REPLACE or TRANSLATE can now be replaced by built-in functions
* Also new functions have been added.
*
* Note that these built-in functions can be used as part of string templates or in operand positions.
* In the ABAP keyword documentation, the added value of these functions is described as followed:
*
* The string functions enable many string processing tasks to be done in operand positions
* where previously separate statements and auxiliary variables were required.



* A few examples of built-in functions are:

string_result = to_mixed( val = string_field sep = ` ` ).
string_result = reverse( string_field ).
distance_between_strings = distance( val1 = string_field val2 = string_result ).

* intrnal tot external
character_string = |Your Material Number is { pv_matnr ALPHA = IN }|.    " Adds leading zero's
character_string = |Your Material Number is { pv_matnr ALPHA = OUT }|.   " removes leading zero's
