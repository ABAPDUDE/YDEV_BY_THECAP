*&---------------------------------------------------------------------*
*& Report ZEIGENAAR_UPD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0202.

*/**
* Deze applicatie is NIET bedoeld voor business user
* Tabel EVBS wordt bijgewerkt op basis van een excel met verberuiksplaats
* het programma zoekt de correcte verbruiksplaats en voert de wijziging uit
* Alleen het veld EIGENAAR wordt gewijzogd met de ZP uit de excel file
*/*

INCLUDE YMD0201_UPD_SEL.
INCLUDE YMD0201_UPD_FORM.

START-OF-SELECTION.

  PERFORM uploadexceldata.
  PERFORM updatefield.
  PERFORM displayupdatedata.
