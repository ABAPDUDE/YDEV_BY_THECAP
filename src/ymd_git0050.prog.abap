*&---------------------------------------------------------------------*
*& Report YMD_0010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0050.

*PROGRAM demo_dynpro_push_button.
*DATA: ok_code TYPE sy-ucomm,
*      save_ok LIKE ok_code,
*      output(8) TYPE c.
*CALL SCREEN 100.
*MODULE user_command_0100 INPUT.
*  save_ok = ok_code.
*  CLEAR ok_code.
*  CASE save_ok.
*    WHEN 'BUTTON_EXIT'.
*      LEAVE PROGRAM.
*    WHEN 'BUTTON_1'.
*      output = 'Button 1'(001).
*    WHEN 'BUTTON_2'.
*      output = 'Button 2'(002).
*    WHEN 'BUTTON_3'.
*      output = 'Button 3'(003).
*    WHEN 'BUTTON_4'.
*      output = 'Button 4'(004).
*    WHEN OTHERS.
*      output = save_ok.
*  ENDCASE.
*ENDMODULE.

TABLES sscrfields.
*--------------------------------------------------------------*
*Selection-Screen
*--------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: PUSHBUTTON /2(50) button1 USER-COMMAND but1.
SELECTION-SCREEN: COMMENT 55(65) TEXT-011.
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: PUSHBUTTON /2(50) button2 USER-COMMAND but2.
SELECTION-SCREEN: COMMENT 55(65) TEXT-012.
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: PUSHBUTTON /2(50) button3 USER-COMMAND but3.
SELECTION-SCREEN: COMMENT 55(65) TEXT-013.
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: PUSHBUTTON /2(50) button4 USER-COMMAND but4.
SELECTION-SCREEN: COMMENT 55(65) TEXT-014.
SELECTION-SCREEN: END OF BLOCK b01.

*--------------------------------------------------------------*
*At Selection-Screen
*--------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields.
    WHEN 'BUT1'.
* for TEST      MESSAGE 'Button 1 was clicked' TYPE 'I'.
      SUBMIT zre_clcockpit_caseid AND RETURN.
    WHEN 'BUT2'.
      MESSAGE 'Button 2 was clicked' TYPE 'I'.
    WHEN 'BUT3'.
      MESSAGE 'Button 3 was clicked' TYPE 'I'.
  ENDCASE.

*/**
* Hiding the default 'EXECUTE' button on top!
* Hiding the default 'SAVE' button on top!
*/*
AT SELECTION-SCREEN OUTPUT.
  PERFORM insert_into_excl(rsdbrunt) USING 'ONLI'.
  PERFORM insert_into_excl(rsdbrunt) USING 'SPOS'.

*--------------------------------------------------------------*
*Initialization
*--------------------------------------------------------------*
INITIALIZATION.
*  SET PF-STATUS 'MENU'.
*  button1 = 'CaseId: Directe acties'.
*  button2 = 'CaseID: Uitval bekijken'.
*  button3 = 'CaseID: Batch verwerking'.
*  button4 = 'CaseID: Standard logging'.


  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_select_detail
      text   = 'CaseId: Directe acties'
      info   = 'Click to Continue'
    IMPORTING
      result = button1
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_table_settings
      text   = 'CaseID: Uitval bekijken'
      info   = 'Click to Continue'
    IMPORTING
      result = button2
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_background_job
      text   = 'CaseID: Batch verwerking'
      info   = 'Click to Continue'
    IMPORTING
      result = button3
    EXCEPTIONS
      OTHERS = 0.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_zoom_in
      text   = 'CaseID: Standard logging'
      info   = 'Click to Continue'
    IMPORTING
      result = button4
    EXCEPTIONS
      OTHERS = 0.

START-OF-SELECTION.

  IF 1 EQ 2.
  ENDIF.
