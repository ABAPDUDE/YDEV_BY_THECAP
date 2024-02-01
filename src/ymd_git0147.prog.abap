*&---------------------------------------------------------------------*
*& Report YMD_047
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0147.

*CONCATENATE in SAP ABAP
*Below is the Code Concatenate in SAP ABAP the Old Way

DATA lv_variable1 TYPE char10.
DATA lv_variable2 TYPE char20.
DATA lv_concat_variable TYPE char30.

lv_variable1 = 'abcde'.
lv_variable2 = 'fghijk'.

CONCATENATE lv_variable1 lv_variable2 INTO lv_concat_variable.
WRITE: /5 lv_variable1 ,
          lv_variable2 ,
          lv_concat_variable.

*Result
*abcde
*fghijk
*abcdefghijk

*Variant 2 Adding Space
CONCATENATE lv_variable1 lv_variable2 INTO lv_concat_variable SEPARATED BY space.
*( or )
CONCATENATE lv_variable1 lv_variable2 INTO lv_concat_variable SEPARATED BY '  '.

WRITE: /5 lv_variable1 ,
          lv_variable2 ,
          lv_concat_variable.

*Result
*abcde
*fghijk
*abcde fghijk

*New concatenate syntax in sap ABAP 7.4
*In the new syntax, we can declare the variable INLINE. That means no explicit DATA declaration with type is required.
*The system will automatically convert the variable to the desired format based on the value on the go just like VB SCript or Front End Scripts.
*he above old code can now be written as

*variant 3

DATA(lv_variable1b) = 'abcde'.
DATA(lv_variable2b) = 'fghijk'.

DATA(lv_concat_variable1) =  |{ lv_variable1b }| & |{ lv_variable2b }| .

WRITE: /5 lv_variable1b,
          lv_variable2b,
          lv_concat_variable1.
*Result
*abcde
*fghijk
*abcdefghijk

*variant 3 With Space
DATA(lv_concat_variable2) =  |{ lv_variable1b }| && space && | { lv_variable2b  } |.
WRITE: /5 lv_variable1b,
          lv_variable2b,
          lv_concat_variable2.
*Result
*abcde
*fghijk
*abcde fghijk

*varient 4 - With Text Element
DATA(lv_errmsg) = lv_variable1b && space && | { TEXT-001 } |.

* variant 5 - with internal conversions

*Local variable declaration
DATA:lv_month TYPE char2, lv_day TYPE char2, lv_year TYPE char4.

DATA(lv_current_date) = '8/26/2021'.

SPLIT lv_current_date AT '/' INTO lv_month lv_day lv_year.

DATA(lv_concat_var) = |{ lv_year }| && |{ lv_month ALPHA = IN }| && |{ lv_day ALPHA = IN }|.

WRITE: /5 lv_current_date ,
          lv_concat_var.

*Result
*8/26/2021
*20212608

*Variant 6
*Example with Text element, space , importing variable (off set of first 2  characters only .We are considering

*Text elemtns 001 = he

DATA(lv_element) = 'LLLLL'.

*text elemtn 002 = '0'.

"DATA(lv_variable) = | { TEXT-001 } | && space && lv_element+lc_0(lc_level2) && space && | { TEXT-002 } |.

" WRITE: /5 lv_variable.

*Result = He ll o

*Real time Applications
*Example 1 -

* DATA(ls_key) = |{ lv_po }{ lv_linenumber }|.


*Example 2 Static Text with Variable

"DATA(lv_filename) = lv_filename.  "(this is dynamic and will change based ON user).

"DATA(lv_finalvalue) = |inline; filename="{ lv_filename }"|.

*Example 3 -
*Let us fetch Employee First name, last name, and Middle name from PA0002 based on PERNR.

DATA: lv_emp_name TYPE char80.
DATA lv_pernr TYPE char10.
CONSTANTS co_endoftime TYPE dats VALUE '31129999'.

SELECT SINGLE vorna,
              nach2,
              nachn
        FROM pa0002
        INTO @DATA(ls_pa0002)
        WHERE pernr EQ @lv_pernr
        AND endda EQ @co_endoftime.

DATA(emp_name) = |{ ls_pa0002-vorna }| & |{ ls_pa0002-nach2 }| & |{ ls_pa0002-nachn }|.
*SAP ABAP 7.4 concatenate separated by comma

DATA(emp_name2) = |{ ls_pa0002-vorna } & ',' & { ls_pa0002-nach2 } & ',' & { ls_pa0002-nachn }|.



*Example 4 - In this example, a variable lv_filename will be split '&' into two variables lv_filename and lv_line. Now these two variables along with some text elements(I will make a separate blog if you do not know text elements)into a final variable.

DATA lv_filename TYPE string.
DATA lv_line TYPE string.
lv_filename = 'demofile&001'.

SPLIT lv_filename AT '&' INTO lv_filename lv_line.

CONCATENATE TEXT-001 lv_line

            TEXT-002 lv_filename

            TEXT-003

INTO DATA(lv_final_url).

*New Syntax -

DATA(lv_final_ur2) = |{ TEXT-001 }{ lv_line }{ TEXT-002 }{ lv_filename }{ TEXT-003 }|.

*Try it yourself and comment below how did you like the new syntax for Concatenate.
*Let me know if I missed any variant, will add them in the Blog too


DATA(lv_title1) = |Contractloze Aansluitingen { sy-datum }_|.
DATA(lv_title2) = |Herinnering! Contractloze Aansluitingen { sy-datum }_|.

SKIP 2.
WRITE /5 lv_title1.
WRITE /5 lv_title2.
