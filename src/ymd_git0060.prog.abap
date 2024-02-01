*&---------------------------------------------------------------------*
*& Report YMD_309
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0060.

DATA lv_queue TYPE string VALUE '12345abcde'.
DATA lv_msgid TYPE string VALUE 'messageID_001'.
DATA lv_uri_consume_queue1 TYPE string VALUE '/messagingrest/v1/queues/{queue}/messages/consumption'.
DATA lv_uri_consume_queue2 TYPE string VALUE '/messagingrest/v1/queues/{queue}/{msgid}/messages/acknowledgement'.

DATA(lv_uri) = replace( val = lv_uri_consume_queue1 sub = '{queue}' with = lv_queue ).

WRITE /10 lv_uri.


DATA(lv_uri2) = replace( val = lv_uri_consume_queue2 sub = '{queue}' with = lv_queue ).

WRITE /10 lv_uri2.

DATA(lv_uri3) = replace( val = lv_uri2 sub = '{msgid}' with = lv_msgid ).

WRITE /10 lv_uri3.
