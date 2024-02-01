*&---------------------------------------------------------------------*
*& Report YMD_061
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0161.

*REPORT zbase64_encode_decode_v1.

DATA: lv_string TYPE string,        "Text
      lv_base64 TYPE string.        "Base64

SELECTION-SCREEN BEGIN OF BLOCK in1 WITH FRAME TITLE TEXT-t01.
PARAMETERS: p_input TYPE string OBLIGATORY LOWER CASE.
SELECTION-SCREEN END OF BLOCK in1.

SELECTION-SCREEN BEGIN OF BLOCK in2 WITH FRAME TITLE TEXT-t02.
PARAMETERS: p_encode RADIOBUTTON GROUP rb1 USER-COMMAND grb1 DEFAULT 'X',
            p_decode RADIOBUTTON GROUP rb1.
SELECTION-SCREEN END OF BLOCK in2.

CASE 'X'.
  WHEN p_encode.

*Encode String to Base64
    CALL METHOD cl_http_utility=>if_http_utility~encode_base64
      EXPORTING
        unencoded = p_input
      RECEIVING
        encoded   = lv_base64.

  WHEN p_decode.
*Decode Base64 String to String
    CALL METHOD cl_http_utility=>if_http_utility~decode_base64
      EXPORTING
        encoded = p_input
      RECEIVING
        decoded = lv_string.

ENDCASE.

*Write the converted string to Screen.
CASE 'X'.
  WHEN p_decode.
    WRITE lv_string.
  WHEN p_encode.
    WRITE lv_base64.
  WHEN OTHERS.
ENDCASE.
