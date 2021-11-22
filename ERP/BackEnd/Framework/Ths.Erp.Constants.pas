unit Ths.Erp.Constants;

interface

{$I ThsERP.inc}

const
  APP_VERSION = '1.1.35';


  CKEY1 = 53761475;
  CKEY2 = 32618110;

  //Fast Report mm and cm define
  fr01cm = 3.77953;
  fr1cm  = 37.7953;
  //Fast Report mm and cm define


  EPSILON          = 0.00009;
  EPSILON_ISLEMLER = 0.009;//2 haneye bakılır

  PRX_LABEL = 'lbl';
  PRX_CHECKBOX = 'chk';
  PRX_EDIT = 'edt';
  PRX_MEMO = 'mmo';
  PRX_COMBOBOX = 'cbb';
  PRX_RADIOGROUP = 'rg';
  PRX_BUTTON = 'btn';
  PRX_TABSHEET = 'ts';

  PRX_SP_SELECT = 'sp_get_';
  PRX_SP_UPDATE = 'sp_set_';
  PRX_SP_INSERT = 'sp_add_';
  PRX_SP_DELETE = 'sp_del_';

  DefaultFontName = 'Tahoma';

  LngSystem = 'System';
  LngGeneral = 'General';

  LngButton = 'Button';
  LngDGridFieldCaption = 'DGrid.FieldCaption';
  LngSGridFieldCaption = 'SGrid.FieldCaption';
  LngLabelCaption = 'LabelCaption';
  LngFormCaption = 'FormCaption';
  LngMsgTitle = 'MsgTitle';
  LngMsgError = 'MsgError';
  LngMsgData = 'MsgData';
  LngMsgWarning = 'MsgWarning';
  LngMainTable = 'Main';
  LngFilter = 'Filter';
  LngPopup = 'Popup';
  LngStatus = 'Status';
  LngLogin = 'Login';
  LngTab = 'Tab';
  LngMenu = 'Menu';
  LngApplication = 'Application';
  LngPrintControlCaption = 'PrintControlCaption';

  LangTurkish = 'Türkçe TR';
  LangEnglish = 'English EN';
  LangFrench = 'French FR';

  ParaTL = 'TL';
  ParaUSD = 'USD';
  ParaEUR = 'EUR';

  IMG_ACCEPT = 0;
  IMG_ADD = 1;
  IMG_ADD_DATA = 2;
  IMG_APPLICATION = 3;
  IMG_ARCHIVE = 4;
  IMG_ATTACHMENT = 5;
  IMG_BACK = 6;
  IMG_CALCULATOR = 7;
  IMG_CALENDAR = 8;
  IMG_CHART = 9;
  IMG_CLOCK = 10;
  IMG_CLOSE = 11;
  IMG_COL_WIDTH = 12;
  IMG_COMMENT = 13;
  IMG_COMMUNITY_USERS = 14;
  IMG_COMPUTER = 15;
  IMG_COPY = 16;
  IMG_CUSTOMER = 17;
  IMG_DATABASE = 18;
  IMG_DOWN = 19;
  IMG_EXCEL_EXPORTS = 20;
  IMG_EXCEL_IMPORTS = 21;
  IMG_FAVORITE = 22;
  IMG_FILE_DOC = 23;
  IMG_FILE_PDF = 24;
  IMG_FILE_XLS = 25;
  IMG_FILTER = 26;
  IMG_FILTER_ADD = 27;
  IMG_FILTER_CLEAR = 28;
  IMG_FOLDER = 29;
  IMG_FORWARD_NEW_MAIL = 30;
  IMG_HELP = 31;
  IMG_HOME = 32;
  IMG_IMAGE = 33;
  IMG_INFO = 34;
  IMG_LANG = 35;
  IMG_LOCK = 36;
  IMG_MAIL = 37;
  IMG_MONEY = 38;
  IMG_MOVIE = 39;
  IMG_NEXT = 40;
  IMG_NOTE = 41;
  IMG_PAGE = 42;
  IMG_PAGE_SEARCH = 43;
  IMG_PAUSE = 44;
  IMG_PLAY = 45;
  IMG_PORT = 46;
  IMG_PREVIEW = 47;
  IMG_PRINT = 48;
  IMG_PROCESS = 49;
  IMG_RECORD = 50;
  IMG_REMOVE = 51;
  IMG_REPEAT = 52;
  IMG_RSS = 53;
  IMG_SEARCH = 54;
  IMG_SERVER = 55;
  IMG_STOCK = 56;
  IMG_STOCK_ADD = 57;
  IMG_STOCK_DELETE = 58;
  IMG_SUM = 59;
  IMG_UP = 60;
  IMG_USER_HE = 61;
  IMG_USER_PASSWORD = 62;
  IMG_USER_SHE = 63;
  IMG_USERS = 64;
  IMG_WARNING = 65;
  IMG_PERIOD = 66;
  IMG_QUALITY = 67;
  IMG_EXCHANGE_RATE = 68;
  IMG_BANK = 69;
  IMG_BANK_BRANCH = 70;
  IMG_CITY = 71;
  IMG_COUNTRY = 72;
  IMG_STOCK_ROOM = 73;
  IMG_MEASURE_UNIT = 74;
  IMG_DURATION_FINANCE = 75;
  IMG_SETTINGS = 76;
  IMG_SORT_ASC = 77;
  IMG_SORT_DESC = 78;
  IMG_FILTER_BACK = 79;
  IMG_SORT_REMOVE = 80;
  IMG_ACCESS = 81;
  IMG_NO_ACCESS = 82;
  IMG_NETWORK_CARD = 83;
  IMG_TEAM = 84;
  IMG_DAY = 85;
  IMG_ROBOT = 86;
  IMG_APPROVAL = 87;
  IMG_OFFER = 88;
  IMG_BILL = 89;
  IMG_QRCODE = 90;
  IMG_PHONE = 91;
  IMG_TECH_SUPPORT = 92;
  IMG_HAND_SHAKE = 93;

  FILE_EXT_XLS = 'xls';
  FILE_EXT_XLSX = 'xlsx';
  FILE_EXT_DOC = 'doc';
  FILE_EXT_DOCX = 'docx';
  FILE_EXT_ODT = 'odt';
  FILE_EXT_ODS = 'ods';
  FILE_EXT_PDF = 'pdf';
  FILE_EXT_XML = 'xml';
  FILE_EXT_PNG = 'png';
  FILE_EXT_JPG = 'jpg';
  FILE_EXT_BMP = 'bmp';
  FILE_EXT_FR3 = 'fr3';
  FILE_EXT_EXE = 'exe';
  FILE_EXT_BAK = 'bak';
  FILE_EXT_TXT = 'txt';
  FILE_EXT_DXF = 'dxf';
  FILE_EXT_DWG = 'dwg';

  FILE_FILTER_XLS = 'Excel File|*.' + FILE_EXT_XLS;
  FILE_FILTER_XLSX = 'Excel File|*.' + FILE_EXT_XLSX;
  FILE_FILTER_DOC = 'MS Word File|*.' + FILE_EXT_DOC;
  FILE_FILTER_DOCX = 'MS Word File|*.' + FILE_EXT_DOCX;
  FILE_FILTER_ODT = 'OpenO Word File|*.' + FILE_EXT_ODT;
  FILE_FILTER_ODS = 'OpenO Excel File|*.' + FILE_EXT_ODS;
  FILE_FILTER_PDF = 'PDF Document File|*.' + FILE_EXT_PDF;
  FILE_FILTER_XML = 'XML Document File|*.' + FILE_EXT_XML;
  FILE_FILTER_PNG = 'PNG Image File|*.' + FILE_EXT_PNG;
  FILE_FILTER_JPG = 'JPG Image File|*.' + FILE_EXT_JPG;
  FILE_FILTER_BMP = 'BMP Image File|*.' + FILE_EXT_BMP;
  FILE_FILTER_FR3 = 'Report File|*.' + FILE_EXT_FR3;
  FILE_FILTER_EXE = 'Application File|*.' + FILE_EXT_EXE;
  FILE_FILTER_BAK = 'Backup File|*.' + FILE_EXT_BAK;
  FILE_FILTER_TXT = 'Text File|*.' + FILE_EXT_TXT;
  FILE_FILTER_DXF = 'Cad File|*.' + FILE_EXT_DXF;
  FILE_FILTER_DWG = 'Cad File|*.' + FILE_EXT_DWG;

  FILE_FILTER_IMAGE = 'Image File *.(' + FILE_EXT_PNG + ',' + FILE_EXT_JPG + ',' + FILE_EXT_BMP + ')|' +
                                  '*.' + FILE_EXT_PNG+';*.' + FILE_EXT_JPG+';*.' + FILE_EXT_BMP;

  PATH_SETTINGS = 'Settings';
  PATH_PRINT_FORMS = '';

  STATUS_SQL_SERVER   = 0;
  STATUS_DATE         = 1;
  STATUS_USERNAME     = 2;
  STATUS_KEY_F4       = 3;
  STATUS_KEY_F5       = 4;
  STATUS_KEY_F6       = 5;
  STATUS_KEY_F7       = 6;
  STATUS_KEY_F11      = 7;

  QRY_PAR_CH = ':';
  ACC_DELIM = '-';
  SQL_LJOIN = 'LEFT JOIN ';
  SQL_RJOIN = 'RIGHT JOIN ';
  SQL_ON = ' ON ';


  MODULE_SISTEM_AYAR = '1';         //Sistem Ayarları Hakkı
  MODULE_SISTEM_DIGER = '2';        //Sistem Bölge, Ondalık, Ölçü, Para Birimi, ... Hakkı
  MODULE_SISTEM: TArray<string> = [MODULE_SISTEM_AYAR, MODULE_SISTEM_DIGER];

  MODULE_CH_AYAR = '1030';          //Cari Hesap Kartı Ayar
  MODULE_CH_KAYIT = '1031';         //Cari Hesap Kartı Kayıt
  MODULE_CH: TArray<string> = [MODULE_CH_AYAR, MODULE_CH_KAYIT];

  MODULE_MHS_AYAR = '3000';          //Muhasebe Ayar
  MODULE_MHS_DOVIZ_KURU = '3001';         //Muhasebe Doviz Kuru Kayıt
  MODULE_MHS: TArray<string> = [MODULE_MHS_AYAR, MODULE_MHS_DOVIZ_KURU];

  MODULE_STK_AYAR = '1040';         //Stok Kartı Ayar
  MODULE_STK_KAYIT = '1041';        //Stok Kartı Kayıt
  MODULE_STK: TArray<string> = [MODULE_STK_AYAR, MODULE_STK_KAYIT];

  MODULE_TSIF_AYAR = '357000';        //Teklif Sipariş İrsaliye Fatura Ayar
  MODULE_SAT_TEK_KAYIT = '357101';    //Satış Teklif Kayıt
  MODULE_SAT_SIP_KAYIT = '357201';    //Satış Teklif Kayıt
  MODULE_SAT_TEK_RAPOR = '357109';    //Satış Sipariş Rapor
  MODULE_SAT_SIP_RAPOR = '357209';    //Satış Sipariş Rapor
  MODULE_TSIF: TArray<string> = [MODULE_TSIF_AYAR,
                                 MODULE_SAT_TEK_KAYIT,
                                 MODULE_SAT_SIP_KAYIT,
                                 MODULE_SAT_TEK_RAPOR,
                                 MODULE_SAT_SIP_RAPOR];


  MODULE_RCT_RECETE_AYAR = '1060';         //Reçete Ayar
  MODULE_RCT_RECETE_KAYIT = '1061';        //Reçete Kayıt
  MODULE_RCT: TArray<string> = [MODULE_RCT_RECETE_AYAR,
                                MODULE_RCT_RECETE_KAYIT];


  MODULE_PRS_AYAR = '1020';         //Personel Kartı Ayar
  MODULE_PRS_KAYIT = '1021';        //Personel Kartı Kayıt

  MODULE_PERSONEL: TArray<string> = [MODULE_PRS_AYAR, MODULE_PRS_KAYIT];

  MODULE_UTD_AYAR = '7410';         //Üretim Teknik Döküman Ayar
  MODULE_UTD_DOKUMAN = '7411';      //Üretim Teknik Döküman Kayıt
  MODULE_BBK_AYAR = '6520';         //Bilgi Bankası Ayar
  MODULE_BBK_KAYIT = '6521';        //Bilgi Bankası Kayıt
  MODULE_ARC_AYAR = '8000';         //Araç Takip Ayar
  MODULE_ARC_KAYIT = '8001';        //Araç Takip Kayıt

  MODULE_GENEL: TArray<string> = [MODULE_UTD_AYAR,
                                  MODULE_UTD_DOKUMAN,
                                  MODULE_BBK_AYAR,
                                  MODULE_BBK_KAYIT,
                                  MODULE_ARC_AYAR,
                                  MODULE_ARC_KAYIT];

implementation

end.
