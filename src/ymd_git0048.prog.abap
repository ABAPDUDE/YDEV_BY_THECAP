*&---------------------------------------------------------------------*
*& Report YMD_0003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ymd_git0048.

DATA: lr_proxy          TYPE REF TO  zcarcl_siia_notify_metering_po,
      ls_input          TYPE         zcarmt_notify_metering_point_u,
      ls_message        TYPE         zcardt_notify_metering_pointup,
      ls_updatemutation TYPE         zcardt_zcar_updatemutation,
      lt_dails          TYPE         zcardt_zcar_dials_tab_tab,
      ls_dails          LIKE LINE OF lt_dails,
      lv_guid           TYPE guid_32.

SELECTION-SCREEN BEGIN OF BLOCK cts WITH FRAME TITLE TEXT-001.
PARAMETERS:
  "pa_0001 TYPE zcardt_notify_metering_pointup-messageid DEFAULT lv_guid,
  pa_0005 TYPE zcardt_notify_metering_pointup-ean_id DEFAULT '871687149100109196',
  pa_0053 TYPE zcardt_zcar_updatemutation-externalreference DEFAULT '0903LevEssentBulk02Liander',
  pa_0054 TYPE zcardt_zcar_updatemutation-mutationreason DEFAULT 'CONNACT',
  pa_0055 TYPE zcardt_zcar_updatemutation-mutationdateandtime DEFAULT '2016-09-03T12:24:15',
  pa_0056 TYPE zcardt_zcar_updatemutation-organisation  DEFAULT '8716871000002',
  pa_0057 TYPE zcardt_zcar_updatemutation-transactionid DEFAULT '4819543',
  pa_0058 TYPE zcardt_zcar_updatemutation-username DEFAULT 'BGehner'.
SELECTION-SCREEN END OF BLOCK cts.
SELECTION-SCREEN BEGIN OF BLOCK cts2 WITH FRAME TITLE TEXT-002.
PARAMETERS:
  pa_0002 TYPE zcardt_notify_metering_pointup-creationtimestamp DEFAULT '2016-09-03T12:25:06.625+02:00',
  pa_0003 TYPE zcardt_notify_metering_pointup-startdate DEFAULT '2016-09-03',
  pa_0004 TYPE zcardt_notify_metering_pointup-enddate DEFAULT '',

  pa_0006 TYPE zcardt_notify_metering_pointup-distributor DEFAULT '8716871000002',
  pa_0007 TYPE zcardt_notify_metering_pointup-supplier DEFAULT '8714252007299',
  pa_0008 TYPE zcardt_notify_metering_pointup-oldsupplier DEFAULT '',
  pa_0009 TYPE zcardt_notify_metering_pointup-meteringresponsible DEFAULT '',
  pa_0010 TYPE zcardt_notify_metering_pointup-balanceresponsibleparty DEFAULT '8717953107909',
  pa_0011 TYPE zcardt_notify_metering_pointup-gridarea DEFAULT '871718518003012565',
  pa_0012 TYPE zcardt_notify_metering_pointup-surname DEFAULT 'Sector2016027',
  pa_0013 TYPE zcardt_notify_metering_pointup-postcode DEFAULT '1000AA',
  pa_0014 TYPE zcardt_notify_metering_pointup-buildingnr DEFAULT '211',
  pa_0015 TYPE zcardt_notify_metering_pointup-ext_buildingnr DEFAULT '',
  pa_0016 TYPE zcardt_notify_metering_pointup-streetname DEFAULT 'Teststraat',
  pa_0017 TYPE zcardt_notify_metering_pointup-cityname DEFAULT 'Teststad',
  pa_0018 TYPE zcardt_notify_metering_pointup-countrycode DEFAULT 'NL',
  pa_0019 TYPE zcardt_notify_metering_pointup-latitude DEFAULT '',
  pa_0020 TYPE zcardt_notify_metering_pointup-longitude DEFAULT '',
  pa_0021 TYPE zcardt_notify_metering_pointup-locationdescription DEFAULT '',
  pa_0022 TYPE zcardt_notify_metering_pointup-producttype DEFAULT 'GAS',
  pa_0023 TYPE zcardt_notify_metering_pointup-market_segment DEFAULT 'KVB',
  pa_0024 TYPE zcardt_notify_metering_pointup-energyflowdirection DEFAULT 'LVR',
  pa_0025 TYPE zcardt_notify_metering_pointup-supplystatus DEFAULT 'ACT',
  pa_0026 TYPE zcardt_notify_metering_pointup-physicalstatus DEFAULT 'IBD',
  pa_0027 TYPE zcardt_notify_metering_pointup-disconnectionreason DEFAULT '',
  pa_0028 TYPE zcardt_notify_metering_pointup-disconnectionmethod DEFAULT '',
  pa_0029 TYPE zcardt_notify_metering_pointup-meteringmethod DEFAULT 'JRL',
  pa_0030 TYPE zcardt_notify_metering_pointup-connectiontype DEFAULT 'NRM',
  pa_0031 TYPE zcardt_notify_metering_pointup-subtype DEFAULT 'GWN',
  pa_0032 TYPE zcardt_notify_metering_pointup-contractedcapacity DEFAULT '',
  pa_0033 TYPE zcardt_notify_metering_pointup-physicalcapacity DEFAULT 'G4',
  pa_0034 TYPE zcardt_notify_metering_pointup-captarcode DEFAULT '8742020202119',
  pa_0035 TYPE zcardt_notify_metering_pointup-determinationcaptarcode DEFAULT 'FIX',
  pa_0036 TYPE zcardt_notify_metering_pointup-profilecategory DEFAULT 'G1A',
  "pa_0037 TYPE zcardt_notify_metering_pointup-residential DEFAULT '',                     "SR2020
  "pa_0038 TYPE zcardt_notify_metering_pointup-complexdetermination DEFAULT '',            "SR2020
  pa_0039 TYPE zcardt_notify_metering_pointup-allocationmethod DEFAULT 'PRF',
  pa_0040 TYPE zcardt_notify_metering_pointup-invoicemonth DEFAULT '',
  pa_0041 TYPE zcardt_notify_metering_pointup-content DEFAULT '',
  pa_0042 TYPE zcardt_notify_metering_pointup-meterid DEFAULT '9120167680V',
  pa_0043 TYPE zcardt_notify_metering_pointup-metertype DEFAULT 'CVN',
  pa_0044 TYPE zcardt_notify_metering_pointup-meter_ntaversion DEFAULT '',
  pa_0045 TYPE zcardt_notify_metering_pointup-nrofregisters DEFAULT '',
  pa_0046 TYPE zcardt_notify_metering_pointup-appliance DEFAULT '',
  pa_0047 TYPE zcardt_notify_metering_pointup-maxconsumption DEFAULT '',
  pa_0048 TYPE zcardt_notify_metering_pointup-administrativestatus DEFAULT '',
  pa_0049 TYPE zcardt_notify_metering_pointup-temperatureresolution DEFAULT '',
  pa_0050 TYPE zcardt_notify_metering_pointup-articlesub DEFAULT ''.
"pa_0051 TYPE zcardt_notify_metering_pointup-status DEFAULT '',
*pa_0052 TYPE zcardt_notify_metering_pointup-switchingtimestamp DEFAULT ''.
SELECTION-SCREEN END OF BLOCK cts2.

AT SELECTION-SCREEN.

START-OF-SELECTION.

  " Niet uitvoerbaar op het productiesysteem.
  ASSERT sy-sysid NE 'PNW'.

  " Mappen data
  ls_updatemutation-externalreference = pa_0053.
  ls_updatemutation-mutationreason =  pa_0054.
  ls_updatemutation-mutationdateandtime =  pa_0055.
  ls_updatemutation-organisation  =  pa_0056.
  ls_updatemutation-transactionid = pa_0057.
  ls_updatemutation-username = pa_0058.

  APPEND ls_updatemutation TO ls_message-updatemutation.
  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      ev_guid_32 = lv_guid.

  ls_message-messageid                = lv_guid.
  ls_message-creationtimestamp        = pa_0002.
  ls_message-startdate                = pa_0003.
  ls_message-enddate                  = pa_0004.
  ls_message-ean_id	                  = pa_0005.
  ls_message-distributor              = pa_0006.
  ls_message-supplier	                =	pa_0007.
  ls_message-oldsupplier              = pa_0008.
  ls_message-meteringresponsible      = pa_0009.
  ls_message-balanceresponsibleparty  = pa_0010.
  ls_message-gridarea	                =	pa_0011.
  ls_message-surname                  = pa_0012.
  ls_message-postcode	                =	pa_0013.
  ls_message-buildingnr	              =	pa_0014.
  ls_message-ext_buildingnr	          =	pa_0015.
  ls_message-streetname	              =	pa_0016.
  ls_message-cityname	                =	pa_0017.
  ls_message-countrycode              = pa_0018.
  ls_message-latitude	                =	pa_0019.
  ls_message-longitude                = pa_0020.
  ls_message-locationdescription      = pa_0021.
  ls_message-producttype              = pa_0022.
  ls_message-market_segment	          =	pa_0023.
  ls_message-energyflowdirection      = pa_0024.
  ls_message-supplystatus	            =	pa_0025.
  ls_message-physicalstatus	          =	pa_0026.
  ls_message-disconnectionreason      = pa_0027.
  ls_message-disconnectionmethod      = pa_0028.
  ls_message-meteringmethod	          =	pa_0029.
  ls_message-connectiontype	          =	pa_0030.
  ls_message-subtype                  = pa_0031.
  ls_message-contractedcapacity	      =	pa_0032.
  ls_message-physicalcapacity	        =	pa_0033.
  ls_message-captarcode	              =	pa_0034.
  ls_message-determinationcaptarcode  = pa_0035.
  ls_message-profilecategory          = pa_0036.
*  ls_message-residential              = pa_0037.               "SR2020
*  ls_message-complexdetermination      = pa_0038.              "SR2020
  ls_message-allocationmethod	        =	pa_0039.
  ls_message-invoicemonth             = pa_0040.
  ls_message-content                  = pa_0041.
  ls_message-meterid                  = pa_0042.
  ls_message-metertype                = pa_0043.
  ls_message-meter_ntaversion	        =	pa_0044.
  ls_message-nrofregisters            = pa_0045.
  ls_message-appliance                = pa_0046.
  ls_message-maxconsumption	          =	pa_0047.
  ls_message-administrativestatus	    =	pa_0048.
  ls_message-temperatureresolution    = pa_0049.
  ls_message-articlesub	              =	pa_0050.
*  ls_message-status                    = pa_0051.
*  ls_message-switchingtimestamp        = pa_0052.

  IF ls_message IS NOT INITIAL.
    ls_input-mt_notify_metering_point_updat = ls_message.
  ENDIF.

  " Proxy object creeren.
  CREATE OBJECT lr_proxy.

  IF ls_input IS NOT INITIAL.
    " Aanroepen inkomende berichtmethode.
    CALL METHOD lr_proxy->zcarii_siia_notify_metering_po~siia_notify_metering_point_upd
      EXPORTING
        input = ls_input.
  ENDIF.

  MESSAGE 'Bericht verzonden naar de webservice' TYPE 'S'.
