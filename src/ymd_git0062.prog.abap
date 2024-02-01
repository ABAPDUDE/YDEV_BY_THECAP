*&---------------------------------------------------------------------*
*& Report YMD_307
*&---------------------------------------------------------------------*
REPORT ymd_git0062.


*/**
* Proof Of Concept : NetworkOperatorDossier data to JSON
*/*

DATA ls_email TYPE zst_nod_emailaddresses.
DATA lt_email TYPE ztt_nod_emailaddresses.
DATA ls_cell TYPE zst_nod_mobilephonenumber.
DATA lt_cell TYPE ztt_nod_mobilephonenumber.
DATA ls_lline TYPE zst_nod_phonenumbers.
DATA lt_lline TYPE ztt_nod_phonenumbers.


START-OF-SELECTION.


" fill the tables inside the main structure first!
ls_email-emailaddress = 'bert@sesamstraat. com'.
ls_cell-mobilephonenumber = '0031(0)6121212'.
ls_lline-phonenumber = '0031(0)245435431'.

APPEND ls_email TO lt_email.
APPEND ls_cell TO lt_cell.
APPEND ls_lline TO lt_lline.

ls_email-emailaddress = 'ernie@sesamstraat. com'.
ls_cell-mobilephonenumber = '0031(0)6565656'.
ls_lline-phonenumber = '0031(0)247567568'.

APPEND ls_email TO lt_email.
APPEND ls_cell TO lt_cell.
APPEND ls_lline TO lt_lline.

" fill the main structure
DATA(gs_nod) = VALUE zst_networkoperatordossier(
requestid = 'PI-CPI_ID00??'
lookupcode = 'conversie'
clientreference = 'klantnummer012933'

memos-description = 'dit is een voorbeeld memo: let op klant bezit wapens uit WOII'
memos-date = '01-10-2022'
statuteoflimitationsdate = '5 jaar'
expirationdate = '01-01-2023'
externalreference = 'EventMesh Flanderijn 03-10-2022'

customers-contact-emailaddresses = lt_email[]
customers-contact-mobilephonenumber = lt_cell[]
customers-contact-phonenumbers = lt_lline[]


customers-addresses-addresstype = 'home'
customers-addresses-isconfidential = ''
customers-addresses-postalcode = '4560 XT'
customers-addresses-streetname = 'Omroepstraat'
customers-addresses-housenumber = '123'
customers-addresses-housenumberaddition = 'gebouw AB'
customers-addresses-city = 'Hilversum'
customers-addresses-countrycode = 'NL'

customers-ispreferredperson = 'X'

customers-bankaccount-iban = 'ABNA1234'
customers-bankaccount-isfiatted = 'X'
customers-bankaccount-ispreferred = 'X'
customers-bankaccount-bankusage = 'checkingAccount'

).


" convert data to a json
DATA(gv_json_output) = /ui2/cl_json=>serialize(
           data = gs_nod
           compress = abap_true
           pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

" print this information:
cl_demo_output=>display_json( gv_json_output ).
