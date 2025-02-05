*&---------------------------------------------------------------------*
*& Report ymd_git0222
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0222.

DATA: lv_value TYPE c LENGTH 25.
"start of changes - Note 1956876
* Convert IV_DATE & IV_TIME to UTC time zone
DATA: lv_date TYPE datum,
      lv_time TYPE tims.


lv_date = sy-datum.
lv_time = sy-uzeit.

GET TIME STAMP FIELD DATA(ts).

SELECT SINGLE tzonesys
       FROM ttzcu
       INTO @DATA(tzone).

CONVERT TIME STAMP ts TIME ZONE tzone
 INTO DATE DATA(date) TIME DATA(time).

CALL METHOD cl_cfdi_utility_mx=>get_local_time  "to convert the date & time to UTC time zone
  EXPORTING
    iv_erdat    = date
    iv_erzet    = time
    iv_timezone = sy-zonlo
  IMPORTING
    ev_erdat    = date
    ev_erzet    = time.

"End of changes - Note 1956876
CALL METHOD cl_gdt_conversion=>date_time_outbound
  EXPORTING
    im_date     = lv_date "Note 1956876
    im_time     = lv_time "Note 1956876
    im_timezone = sy-zonlo
  IMPORTING
    ex_value    = lv_value.

DATA(lv_timestamp) = lv_value+0(19).

IF 1 EQ 2.

ENDIF.
