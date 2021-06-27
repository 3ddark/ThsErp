unit Ths.Erp.Globals;

interface

uses
  NetGsm_SMS,  //NetGSM SMS SOAP Web service
  Ths.Erp.Database,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKullanici,
  Ths.Erp.Database.Table.SysLisan,
  Ths.Erp.Database.Table.SysOndalikHane,
  Ths.Erp.Database.Table.SysUygulamaAyari,
  Ths.Erp.Database.Table.SysUygulamaAyariDiger,
  Ths.Erp.Database.Table.SysGun,
  Ths.Erp.Database.Table.SysAy,
  Ths.Erp.Database.Table.SysParaBirimi,
  Ths.Erp.Database.Table.SysKaliteFormTipi,
  Ths.Erp.Database.Table.SysKaliteFormNo,
  Ths.Erp.Database.Table.SysGridKolon,
  Ths.Erp.Database.Table.SysGridFiltreSiralama,
  Ths.Erp.Database.Table.SysLisanDataIcerik,
  Ths.Erp.Database.Table.SysLisanGuiIcerik,
  Ths.Erp.Database.Table.View.SysViewColumns,

  System.Classes,
  System.Types,
  System.Variants,
  System.SysUtils,
  System.StrUtils,
  System.DateUtils,
  System.Math,
  System.UITypes,
  System.IOUtils,
  System.RTTI,
  System.TypInfo,
  System.Hash,
  System.AnsiStrings,
  System.Net.HttpClientComponent,
  Xml.XMLIntf,
  Xml.XMLDoc,

  Winapi.Windows,
  Winapi.Messages,
  Winapi.IpTypes,
  Winapi.IpHlpApi,
  Winapi.TlHelp32,
  Winapi.PsAPI,
  Winapi.ShellAPI,

  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Dialogs,
  Vcl.Grids,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,

  Data.DB,
  Vcl.DBGrids,
  Data.FmtBcd,

  //#######*****for Indy components*****#######
  IdFTP,
  IdFTPCommon,
  IdAntiFreeze,
  //#######*****for Indy components*****#######

  //for TFDStorecProc class
  FireDAC.Comp.Client,
  FireDAC.Stan.Param
  ;


type
  TEmployeeID = class
  public
    ID: Integer;
    Name: string;
    SurName: string;
    FullName: string;
  end;
  TEmployeeIDList = TArray<TEmployeeID>;

  TSysUserID = class
  public
    ID: Integer;
    UserName: string;
  end;
  TSysUserIDList = TArray<TSysUserID>;

//#######*****Use SMS Service Result*****#######
type
  TSmsServiceResult = record
    Success: Boolean;
    Msg: string;
    BulkID: string;
  end;
//#######*****Use SMS Service Result*****#######

type
  ArrayInteger = array of Integer;

  //use network card info. IP address and Mac adress
  TNetworkCardInfo = record
    IPAddress: string;
    MacAddress: string;
  end;
  TNetworkCardInfoList = TArray<TNetworkCardInfo>;  //network card info list

type
  TRoundToRange = -37..37;

type
  TObjectClone = record
    class function From<T: class>(Source: T): T; static;
  end;

type
  TTCMBDovizKuru = record
    Tarih: TDate;
    Kod: string;
    Aciklama: string;
    ForexBuying: Double;
    ForexSelling: Double;
    BanknoteBuying: Double;
    BanknoteSelling: Double;
  end;

type
  TTCMBDovizKuruList = TArray<TTCMBDovizKuru>;

type
  TLang = record
    StatusAccept: string;
    StatusAdd: string;
    StatusCancel: string;
    StatusDelete: string;
    ButtonAccept: string;
    ButtonAdd: string;
    ButtonCancel: string;
    ButtonClose: string;
    ButtonDelete: string;
    ButtonFilter: string;
    ButtonOK: string;
    ButtonUpdate: string;
    ButtonHelper: string;
    ErrorAccessRight: string;
    ErrorDatabaseConnection: string;
    ErrorLogin: string;
    ErrorDBOther: string;
    ErrorDBNoDataFound: string;
    ErrorDBTooManyRows: string;
    ErrorDBRecordLocked: string;
    ErrorDBUnique: string;
    ErrorDBForeignKeyDeleteUpdate: string;
    ErrorDBForeignKeyUnique: string;
    ErrorDBObjectNotExist: string;
    ErrorDBUserPasswordInvalid: string;
    ErrorDBUserPasswordExpired: string;
    ErrorDBUserPasswordWillExpire: string;
    ErrorDBCmdAborted: string;
    ErrorDBServerGone: string;
    ErrorDBServerOutput: string;
    ErrorDBArrExecMalFunc: string;
    ErrorDBInvalidParams: string;
    ErrorRecordDeleted: string;
    ErrorRecordDeletedMessage: string;
    ErrorRedInputsRequired: string;
    ErrorRequiredData: string;
    GeneralConfirmationLower: string;
    GeneralConfirmationUpper: string;
    GeneralNoUpper: string;
    GeneralNoLower: string;
    GeneralYesUpper: string;
    GeneralYesLower: string;
    GeneralRecordCount: string;
    GeneralPeriod: string;
    FilterFilterCriteriaTitle: string;
    FilterLike: string;
    FilterNotLike: string;
    FilterSelectFilterFields: string;
    FilterWithEnd: string;
    FilterWithStart: string;
    FilterKeyValue: string;
    MessageApplicationTerminate: string;
    MessageCloseWindow: string;
    MessageDeleteRecord: string;
    MessageKillProcess: string;
    MessageUnsupportedProcess: string;
    MessageUpdateRecord: string;
    MessageUpdateColumnWidth: string;
    MessageTitleOther: string;
    MessageTitleNoDataFound: string;
    MessageTitleDataAlreadyExists: string;
    MessageTitleInsertUpdate: string;
    MessageTitleUpdateDelete: string;
    MessageTitleObjectNotFound: string;
    MessageTitleError: string;
    MessageTitleUyari: string;
    MessageOtomatikDovizKuru: string;

    PopupAddLangDataContent: string;
    PopupAddLangGuiContent: string;
    PopupAddUseMultiLangData: string;
    PopupCopyRecord: string;
    PopupExportExcel: string;
    PopupExportExcelAll: string;
    PopupFilter: string;
    PopupFilterExclude: string;
    PopupFilterRemove: string;
    PopupPreview: string;
    PopupPrint: string;
    PopupRemoveSort: string;

    WarningActiveTransaction: string;
    WarningLockedRecord: string;
    WarningOpenWindow: string;
    WarningChagenEncryptCode: string;
  end;

  function GetKaliteFormNo(ATabloAdi: string; AKaliteFormTipi: TQualityFormType): string;
  function setUserPassword(pOldPass, pNewPass: string; pUserID: Integer): Boolean;
  function getEmployeeIDList: TEmployeeIDList;
  function getSysUserIDList: TSysUserIDList;

  function getSetChHesapTipiID(pHesapTipi: THesapTipi): Integer;

  function Login(pUserName,pPassword: string): Integer;
  function ReplaceToRealColOrTableName(const pTableName: string): string;
  function ReplaceRealColOrTableNameTo(const pTableName: string): string;
  function getFormCaptionByLang(pFormName, pDefaultVal: string): string;

  function getCryptedData(pVal: string): string;

  function ColumnFromIDCol(pRawTableColName, pRawTableName, pDataColName,
      pVirtualColName, pDataTableName: string; pIsIDReference: Boolean = True; pIsNumericVal: Boolean = False): string;
  function TranslateText(ADefault, ACode, ATip: string; ATable: string=''; ALang: string=''): string;

  function FormatedVariantVal(pType: TFieldType; pVal: Variant): Variant; overload;
  function FormatedVariantVal(pField: TFieldDB): Variant; overload;

  function GetTempFolder(): string;

  function TCMB_DovizKurlari: TTCMBDovizKuruList;


  /// <summary>
  ///   Framework içinde kullanýlan sabit dil içeriklieri için bilgilerin olduðu record.
  /// </summary>
  /// <remarks>
  ///   Burada framework içinde kullanýlan ve tekrar eden dil database tablosundan
  ///   çekilecek olan datalar için sabit bilgiler yazýldý.
  /// </remarks>
  /// <example>
  ///   Yeni Kayýt Ekle Buton baþlýðý için ButtonAdd
  /// </example>
  /// <seealso href="http://www.aaa.xxx/test">
  ///   Link verilmedi. Buradan Uður Parlayan hocama selamlar
  /// </seealso>
  function FrameworkLang: TLang;

  /// <summary>
  ///   Birden fazla sLineBreak eklemek için kullanýlýr.
  /// </summary>
  /// <remarks>
  ///   Birden fazla sLineBreak kullanýlmak istenildiðinde bu fonksiyon yardýmcý oluyor.
  ///  3 tane slinebreak yazmak yerine bu fonksiyonu kullanabilirsin.
  ///  slinebreak + slinebreak + slinebreak
  /// </remarks>
  /// <example>
  ///   AddLBs(3)
  /// </example>
  function AddLBs(pCount: Integer = 1): string;

  /// <summary>
  ///   Butonlarýn baþlýklarýný özelleþtirebildiðimiz Mesaj ekraný
  /// </summary>
  /// <remarks>
  ///   Buton baþlýklarýný özelleþtirilebildiðimiz özel MesajDiaglog formu.
  ///  Mesaj, Baþlýk, Buton Yazýlarý gibi herþeyi istediðimiz þekilde yazabildiðimiz
  ///  özel Mesaj formu
  /// </remarks>
  /// <example>
  ///   CustomMsgDlg('Are you sure you want to update record?', mtConfirmation, mbYesNo, ['Yes', 'No'], mbNo, 'Confirmation') = mrYes
  /// </example>
  function CustomMsgDlg(const pMsg: string; pDlgType: TMsgDlgType;
      pButtons: TMsgDlgButtons; pCaptions: array of string;
      pDefaultButton: TMsgDlgBtn;
      pCustomTitle: string = ''; pFontName: string = ''): Integer;

  function ReplaceMessages(Source: string; Old, New: array of string; IsIgnoreCase: Boolean = False): string;

  function EnDeCrypt(const Value: string): string;

  function CheckString(const pStr: string): Boolean;

  /// <summary>
  ///  Send SMS via web service on SMS Service Providers
  ///  SMS Servis saðlayýcý üzerinde SMS gönderme rutini
  /// </summary>
  function SendSmsViaService(AMsg: WideString; AReceiverNos: Array_Of_string): TSmsServiceResult;


  function TrimCustom(const S: string; const AChar: Char): string;
  function TrimLeftCustom(const S: string; const AChar: Char): string;
  function TrimRightCustom(const S: string; const AChar: Char): string;

  function IsNumeric(const S: string): Boolean;
  procedure TutarHesapla(const fiyat: double; const miktar: double; const iskontoOrani: double; const kdvOrani: double; out tutar: double; out netFiyat: double; out iskontoTutar: double; out kdvTutar: double; out toplamTutar: double; ondalikli_hane: integer);
  function SayiyiYaziyaCevir(Num: Double): string;
  function SayiyiYaziyaCevir2(tutar: double; tur: integer; tam_birim: string = 'TL'; ondalikli_birim: string = 'KRÞ'): string;
  function VirguldenSonraHaneSayisi(deger: double; hanesayisi: integer): string;
  function GetMACAddress: TNetworkCardInfoList;
  function CountNumOfCharacter(s: string; delimeter: string): integer;
  function FloatKeyControl2(Sender: TObject; Key: Char): Char;
  function GetSimdikiTarih(date_now: TDate): TStringList;
  function LastPos(const SubStr: string; const strData: string): Integer;
  function isAltDown(): Boolean;
  function isCtrlDown(): Boolean;
  function isShiftDown(): Boolean;
  function GetMikroRaporTarihFormat(tarih: TDateTime): string;
  function CLen(S: string; N: integer): string;
  function RSet(S: string; N: integer): string;
  function LSet(ST: string): string;

  /// <summary>
  ///  Belirtilen dosyayý ByteArray bilgi olarak geri dönderir
  ///  Dosya adý "C:\Test\asd.xml" gibi
  /// </summary>
  function FileToByteArray(const FileName: WideString): TArray<Byte>;

  /// <summary>
  ///  ByteArray bilgiyi verilen dosya adýnda kayýt eder.
  ///  Dosya adý "C:\Test\asd.xml" gibi
  /// </summary>
  procedure ByteArrayToFile(const ByteArray: TBytes; const FileName: string);

  /// <summary>
  ///   Dosya yolu ile birlikte verilen dosya adýnýn disk boyutunu getirir. Bilgi Byte cinsinden gelir.
  ///   1MB için dönen deðer 1000000 olarak gelir. 15KB için 15000 gibi
  /// </summary>
  {$IFDEF MSWINDOWS}
  function GetFileSize(pFileName: string): Int64;
  {$ENDIF MSWINDOWS}

  /// <summary>
  ///   Türkçe karakterlerde dahil olmak üzere verilen string bilgiyi büyük harfe çevirir. ý>I i>Ý olur
  /// </summary>
  function UpperCaseTr(S: string): string;

  /// <summary>
  ///   Türkçe karakterlerde dahil olmak üzere verilen string bilgiyi küçük harfe çevirir. I>ý Ý>i olur
  /// </summary>
  function LowerCaseTr(S: string): string;

  /// <summary>
  ///   Boolean bilgiyi string olarak döndürür. Boolean tip deðeri True ise "TRUE" string döner False ise "FALSE" string döner
  /// </summary>
  function BoolToStr(ABool: Boolean; ABuyuk: Boolean = True): string;

  /// <summary>
  ///  iþletim sistemi dpi bilgilerine göre girilen int degerin dpi ayarýna göre hesaplanarak sonucunu getiriyor
  ///  Örn. Button.Widht := 100 ise ve iþletim sistemi %150 kullanýlýyorsa. Bu deðerin 150 olmasý gerekiyor.
  ///  Normalde 96ppi ile proje geliþtiriliyor. Fakat sistem %150 yapýlýnca 144ppi oluyor 144/96 = 1,5 oluyor.
  ///  Bu durumda 100 * 1,5 = 150 oluyor
  /// </summary>
  function scaleBySystemDPI(AVal: Integer): Integer;

  function CheckIntegerInArray(pArr: ArrayInteger; pKey: Integer): Boolean;
  function CheckStringInArray(pArr: TArray<string>; pKey: string): Boolean;
  function GetStrHashSHA512(Str: string): string;
  function GetFileHashSHA512(FileName: WideString): string;
  function GetStrFromHashSHA512(pString: WideString): string;

  /// <summary>
  ///   Verilen string bilgiyi girilen key ile þifreler
  /// </summary>
  /// <remarks>
  ///  <para>Kendi Anahtar deðerimiz (0-65535 aralýðýndaki) ile bilgiyi þifrelemek için kullanýlýr.</para>
  ///  <para>Mesela kiþisel verileri koruma kanunu gereði TC Kimlik No bilgisini þifreler.</para>
  ///  <para>Aþaðýdaki örnek kod örnek olarak attýðým TC Kimlik bilgisini þifreler</para>
  ///  <code lang="Delphi">EncryptStr('30850331144', 14257); //Sonuç: 040EF0D744DA01BA36DAE5</code>
  /// </remarks>
  function EncryptStr(const S: WideString; Key: Word): string;

  /// <summary>
  ///   EncryptStr ile þifrelenen bilginin þifresini çözmek için Key ile birlikte þifreli bilgi girilir.
  ///   Gerçek bilgi geri döner
  /// </summary>
  /// <remarks>
  ///   <para>Kendi Anahtar deðerimiz (0-65535 aralýðýndaki) ile bilgiyi þifrelemek için kullanýlýr.</para>
  ///   <para>Mesela kiþisel verileri koruma kanunu gereði þifrelenen TC Kimlik No bilgisini gerçek bilgiye çevirir.</para>
  ///   <para>Aþaðýdaki örnek kod örnek olarak attýðým þifrelenmiþ TC Kimlik bilgisini gerçek bilgiye çevirir</para>
  ///   <code lang="Delphi">EncryptStr('040EF0D744DA01BA36DAE5', 14257); //Sonuç: 30850331144</code>
  /// </remarks>
  function DecryptStr(const S: string; Key: Word): string;

  /// <summary>
  ///
  /// </summary>
  function FirstCaseUpper(const vStr: string): string;

  /// <summary>
  ///  Variant To Integer data convert
  /// </summary>
  function VarToInt(const pVal: Variant): Integer;

  /// <summary>
  ///  Variant To Integer data convert
  /// </summary>
  function VarToInt64(const pVal: Variant): Int64;

  /// <summary>
  ///  Variant To string data convert
  /// </summary>
  function VarToStr(const pVal: Variant): string;

  function PermissionTypeAsString(APermissionType: TPermissionType): string;


  function GetDialogColor(pColor: TColor): TColor;
  function GetDialogOpen(pFilter: string; pInitialDir: string = ''): string;
  function GetDialogDirectory(pInitialDir: string = ''): string;
  function GetDialogSave(pFileName, pFilter: string; pInitialDir: string = ''): string;
  function FTPDosyaAl(pSrcFile, pDesFile: TFileName; pFtp, pRemoteDir, pLogin, pPass: string): Boolean;

  /// <summary>
  ///   Get ProcessID By ProgramName (Include Path or Not Include)
  /// </summary>
  /// <remarks>
  ///   Burada framework içinde kullanýlan ve tekrar eden dil database tablosundan
  ///   çekilecek olan datalar için sabit bilgiler yazýldý.
  /// </remarks>
  /// <example>
  ///   Yeni Kayýt Ekle Buton baþlýðý için ButtonAdd
  /// </example>
  /// <seealso href="http://www.aaa.xxx/test">
  ///   Link verilmedi. Buradan Uður Parlayan hocama selamlar
  /// </seealso>
  function GetPIDByProgramName(const APName: string): THandle;

  // Get Window Handle By ProgramName (Include Path or Not Include)
  function GetHWndByProgramName(const APName: string): THandle;

  // Get Window Handle By ProcessID
  function GetHWndByPID(const hPID: THandle): THandle;

  // Get ProcessID By Window Handle
  function GetPIDByHWnd(const hWnd: THandle): THandle;

  // Get Process Handle By Window Handle
  function GetProcessHndByHWnd(const hWnd: THandle): THandle;

  // Get Process Handle By Process ID
  function GetProcessHndByPID(const hAPID: THandle): THandle;
  function GetPathFromPID(const PID: cardinal): string;
  function getApplicationPath(const hnwd: HWND): string;

  procedure freeInGroupBox(pGroup: TGroupBox);

  procedure CreateExceptionByLang(pMsg, pCode: string; AName: string = '');


  /// <summary>
  ///   Copy files with sub folder to dest folder
  /// </summary>
  /// <remarks>
  ///   Files Copy with SubFolder
  /// </remarks>
  procedure CopyFolder(ASrcPath, ADestPath: string);


  /// <summary>
  ///   Parametre girilen Tablo adý ve Tablodaki Column Name bilgisine göre
  ///  sys_lang_data tablosundan programýn açýlan dil ayarýna göre column
  ///  bilgsini döndürüyor. Bu fonksiyon tek baþýna kullanýlamaz.
  ///  Bu fonksiyon SQL SELECT kodlarý içinde kullanýlýr.
  ///  <param name="pBaseTableName">Database Table Name</param>
  ///  <param name="pBaseColName">Database Table Column Name</param>
  ///  <example>
  ///   <code lang="Delphi">getRawDataByLang(TableName, FBirim.FieldName)</code>
  ///   <code lang="Delphi">'SELECT ' + getRawDataByLang(TableName, FSourceGroup.FieldName) + ' FROM tbl_name'</code>
  ///  </example>
  /// </summary>
  function getRawDataByLang(pBaseTableName, pBaseColName: string): string;

  /// <summary>
  ///  Ýstenilen Query ye Parametre eklemek için kullanýlýyor. Insert ve Update kodlarý içinde kullanýlýyor.
  ///  <param name="pQuery">FireDac Query</param>
  ///  <param name="pField">FieldDB tipindeki Field</param>
  ///  <example>
  ///   <code lang="Delphi">NewParamForQuery(QueryOfInsert, FBirim)</code>
  ///  </example>
  /// </summary>
  procedure NewParamForQuery(pQuery: TFDQuery; pField: TFieldDB);

  /// <summary>
  ///  Bu fonksiyon DBGrid üzerinde gösterilen sütunlarýn geniþlik deðerini deðiþtirmek için kullanýlýr.
  ///  Yaptýðý iþ hýzlýca <b>sys_grid_col_width</b> tablosundaki <b>column_width</b>
  ///  deðerini hýzlýca güncellemek için kullanýlýr. Açýk DBGrid(output form)
  ///  ekranýndaki sütun geniþliðinin hýzlýca görselden ayarlamak için bu fonksiyon yazildi.
  ///  <param name="pTableName">Database Table Name</param>
  ///  <param name="pColName">Database Table Column Name</param>
  ///  <param name="pColWidth">DBGrid Column Width</param>
  ///  <example>
  ///   <code lang="Delphi">UpdateColWidth(olcu_birimi, birim, 100)</code>
  ///  </example>
  /// </summary>
  function UpdateColWidth(ATableName: string; AGrid: TDBGrid): Boolean;

  function GetGridDefaultOrderFilter(pKey: string; pIsOrder: Boolean): string;
  function GetIsRequired(pTableName, pFieldName: string): Boolean;
  function GetMaxLength(pTableName, pFieldName: string): Integer;

  procedure FillColNameForColWidth(pComboBox: TComboBox; pTableName: string);
  procedure FillColNameForColSummary(pComboBox: TComboBox; pTableName: string);
  function GetDistinctColumnName(pTableName: string): TStringList;

  procedure getStokResim(AID: Integer; ATableName, AImageFieldName: string; AImage: Timage);
  function ExistForm(AFormClassType: TClass): Boolean;

  function FormatMoney(AValue: Double): string;
  function DoDatabaseBackup(): string;
var
  GDosyaUzantilari: TArray<string>;

  /// <summary>
  ///  Dialog pencereleri açýldýðý zaman bazen ExtractFilePath(Application.ExeName) ile elde edilen Uygulama Path eriþilemiyor.
  ///  Bir nedenle ExtractFilePath(Application.ExeName) path deðiþiyor. Nedeni birden fazla uygulama kopyasý açýlabiliyor.
  ///  Bu nedenle uygulama ilk açýlýþta Path bu deðiþkende tutluyor. Buradan kullanýlacak.
  /// </summary>
  GUygulamaAnaDizin: string;

  /// <summary>
  ///  Database sýnýfýna ulaþýlýyor. Bazý fonksiyonlar burada GetToday GetNow veya runCustomSQL gibi
  /// </summary>
  GDataBase: TDatabase;

  /// <summary>
  ///  Giriþ yapan kullanýcý bilgilerine bu tablo bilgisinden ulaþalýyor.
  ///  <example>
  ///   <code lang="Delphi">GSysKullanici.KullaniciAdi</code>
  ///  </example>
  /// </summary>
  GSysKullanici: TSysKullanici;

  /// <summary>
  ///  Virgüllü sayýlarda hane sayýsý deðerlerine buradan ulaþýlýyor. Bu ayara göre iþlemler yapýlacak.
  ///  <example>
  ///   <code lang="Delphi">GSysOndalikHane.SatisMiktar</code>
  ///  </example>
  /// </summary>
  GSysOndalikHane: TSysOndalikHane;

  /// <summary>
  ///  Uygulama ayarlarýna bu tablo bilgisinden ulaþýlýyor.
  ///  <example>
  ///   <code lang="Delphi">GSysUygulamaAyari.Unvan</code>
  ///  </example>
  /// </summary>
  GSysUygulamaAyari: TSysUygulamaAyari;

  /// <summary>
  ///  Uygulamanýn özel ayarlarýna bu tablo bilgisinden ulaþýlýyor.
  ///  <example>
  ///   <code lang="Delphi">GSysUygulamaAyariDiger.xxx</code>
  ///  </example>
  /// </summary>
  GSysUygulamaAyariDiger: TSysUygulamaAyariDiger;

  /// <summary>
  ///  Uygulama açýlýrken hangi dil ile açýþmýþsa o dilin bilgileri alýnýyor.
  ///  <example>
  ///   <code lang="Delphi">GSysLisan.Langeuage</code>
  ///  </example>
  /// </summary>
  GSysLisan: TSysLisan;

  /// <summary>
  ///  Gün isimlerini farklý dillerde alabilmek için tanýmlandý
  /// </summary>
  GSysGun: TSysGun;

  /// <summary>
  ///  Ay isimlerini farklý dillerde alabilmek için tanýmlandý
  /// </summary>
  GSysAy: TSysAy;

  /// <summary>
  ///  Sistemde tanýmlý olan para birimleri burada tutuluyor
  /// </summary>
  GParaBirimi: TSysParaBirimi;

  /// <summary>
  ///  Table sýnýfýndaki field özelliklerini almak için kullanýlýyor.
  /// </summary>
  GSysTableInfo: TSysViewColumns;

implementation

class function TObjectClone.From<T>(Source: T): T;
var
  Context: TRttiContext;
  IsComponent, LookOutForNameProp: Boolean;
  RttiType: TRttiType;
  Method: TRttiMethod;
  MinVisibility: TMemberVisibility;
  Params: TArray<TRttiParameter>;
  Prop: TRttiProperty;
  SourceAsPointer, ResultAsPointer: Pointer;
begin
  RttiType := Context.GetType(Source.ClassType);

  //find a suitable constructor, though treat components specially
  IsComponent := (Source is TComponent);
  for Method in RttiType.GetMethods do
    if Method.IsConstructor then
    begin
      Params := Method.GetParameters;
      if Params = nil then
        Break;
      if (Length(Params) = 1) and IsComponent and (Params[0].ParamType is TRttiInstanceType) and SameText(Method.Name, 'Create') then
        Break;
    end;

  Result := nil;
  if Params = nil then
    Result := (Method.Invoke(Source.ClassType, []).AsType < T > )
  else
    Result := (Method.Invoke(Source.ClassType, [TComponent(Source).Owner]).AsType < T > );

  try
    //many VCL control properties require the Parent property to be set first
    if Source is TControl then
      TControl(Result).Parent := TControl(Source).Parent;
    //loop through the props, copying values across for ones that are read/write
    Move(Source, SourceAsPointer, SizeOf(Pointer));
    Move(Result, ResultAsPointer, SizeOf(Pointer));
    LookOutForNameProp := IsComponent and (TComponent(Source).Owner <> nil);
    if IsComponent then
      MinVisibility := mvPublished //an alternative is to build an exception list
    else
      MinVisibility := mvPublic;
    for Prop in RttiType.GetProperties do
      if (Prop.Visibility >= MinVisibility) and Prop.IsReadable and Prop.IsWritable then
        if LookOutForNameProp and (Prop.Name = 'Name') and (Prop.PropertyType is TRttiStringType) then
          LookOutForNameProp := False
        else
          Prop.SetValue(ResultAsPointer, Prop.GetValue(SourceAsPointer));
  except
    Result.Free;
    raise;
  end;
end;

function GetKaliteFormNo(ATabloAdi: string; AKaliteFormTipi: TQualityFormType): string;
var
  LFormNo: TSysQualityFormNumber;
begin
  Result := '';
  if GDataBase.Connection.Connected then
  begin
    LFormNo := TSysQualityFormNumber.Create(GDataBase);
    try
      LFormNo.SelectToList(
        ' AND ' + LFormNo.TabloAdi.FieldName + '=' + QuotedStr(ATabloAdi) +
        ' AND ' + LFormNo.FormTipiID.FieldName + '=' + IntToStr(Ord(AKaliteFormTipi)), False, False);

      if LFormNo.List.Count = 1 then
        Result := VarToStr(FormatedVariantVal(LFormNo.FormNo));
    finally
      LFormNo.Free;
    end;
  end;
end;

function setUserPassword(pOldPass, pNewPass: string; pUserID: Integer): Boolean;
var
  LSP: TFDStoredProc;
begin
  Result := False;
  LSP := GDataBase.NewStoredProcedure;
  try
    LSP.ResourceOptions.DirectExecute := False;
    LSP.StoredProcName := 'spset_user_password';
    LSP.Prepare;
    LSP.ParamByName('oldpass').Text := pOldPass;
    LSP.ParamByName('newpass').Text := pNewPass;
    LSP.ParamByName('userid').AsInteger := pUserID;
    LSP.ExecProc;
    if not LSP.ParamByName('result').IsNull then
      Result := LSP.ParamByName('result').AsBoolean;
  finally
    LSP.Free;
  end;
end;

function getEmployeeIDList: TEmployeeIdList;
var
  LSP: TFDStoredProc;
begin
  LSP := GDataBase.NewStoredProcedure;
  try
    LSP.ResourceOptions.DirectExecute := False;
    LSP.StoredProcName := 'spget_emp_card_id_list';
    LSP.Prepare;
    LSP.Open;
    LSP.First;

    SetLength(Result, LSP.RecordCount);
    while not LSP.Eof do
    begin
      Result[LSP.RecNo-1] := TEmployeeID.Create;
      if not LSP.FieldByName('id').IsNull then
        Result[LSP.RecNo-1].ID := LSP.FieldByName('id').AsInteger;
      if not LSP.FieldByName('emp_name').IsNull then
        Result[LSP.RecNo-1].Name := LSP.FieldByName('emp_name').AsString;
      if not LSP.FieldByName('emp_surname').IsNull then
        Result[LSP.RecNo-1].SurName := LSP.FieldByName('emp_surname').AsString;
      if not LSP.FieldByName('emp_full_name').IsNull then
        Result[LSP.RecNo-1].FullName := LSP.FieldByName('emp_full_name').AsString;

      LSP.Next;
    end;
  finally
    LSP.Free;
  end;
end;

function getSysUserIDList: TSysUserIDList;
var
  LSP: TFDStoredProc;
begin
  LSP := GDataBase.NewStoredProcedure;
  try
    LSP.ResourceOptions.DirectExecute := False;
    LSP.StoredProcName := 'spget_sys_user_id_list';
    LSP.Prepare;
    LSP.Open;
    LSP.First;

    SetLength(Result, LSP.RecordCount);
    while not LSP.Eof do
    begin
      Result[LSP.RecNo-1] := TSysUserID.Create;
      if not LSP.FieldByName('id').IsNull then
        Result[LSP.RecNo-1].ID := LSP.FieldByName('id').AsInteger;
      if not LSP.FieldByName('user_name').IsNull then
        Result[LSP.RecNo-1].UserName := LSP.FieldByName('user_name').AsString;

      LSP.Next;
    end;
  finally
    LSP.Free;
  end;
end;

function getSetChHesapTipiID(pHesapTipi: THesapTipi): Integer;
var
  LSP: TFDStoredProc;
begin
  Result := 0;
  LSP := GDataBase.NewStoredProcedure;
  try
    LSP.ResourceOptions.DirectExecute := False;
    LSP.StoredProcName := 'spget_set_ch_hesap_tipi_id';
    LSP.Prepare;
    LSP.ParamByName('phesap_tipi').Value := Ord(pHesapTipi);
    LSP.ExecProc;
    if not LSP.ParamByName('result').IsNull then
      Result := LSP.ParamByName('result').AsInteger;
  finally
    LSP.Free;
  end;
end;

function Login(pUserName, pPassword: string): Integer;
begin
  with GDataBase.NewQuery do
  try
    Close;
    SQL.Text := 'SELECT splogin(' + QuotedStr(pUserName) + ',' + QuotedStr(pPassword) + ',' + QuotedStr(APP_VERSION) + ',' + QuotedStr('') + ');';
    Open;
    Result := Fields.Fields[0].AsInteger;
    EmptyDataSet;
    Close;
  finally
    Free;
  end;
end;

function ReplaceToRealColOrTableName(const pTableName: string): string;
begin
  Result := StringReplace(pTableName, ' ', '_', [rfReplaceAll]);
  Result := LowerCase(Result);
end;

function ReplaceRealColOrTableNameTo(const pTableName: string): string;
var
  n1: Integer;
  vDump: string;
begin
  vDump := StringReplace(pTableName, '_', ' ', [rfReplaceAll]);

  if vDump = '' then
    Result := ''
  else
  begin
    Result := Uppercase(vDump[1]);
    for n1 := 2 to Length(vDump) do
    begin
      if vDump[n1-1] = ' ' then
        Result := Result + Uppercase(vDump[n1])
      else
        Result := Result + Lowercase(vDump[n1]);
    end;
  end;

end;

function getFormCaptionByLang(pFormName, pDefaultVal: string): string;
begin
  Result := TranslateText(pDefaultVal, pFormName, LngFormCaption);
end;

function getCryptedData(pVal: string): string;
var
  vQry: TFDQuery;
begin
  vQry := GDataBase.NewQuery();
  try
    vQry.Close;
    vQry.SQL.Clear;
    vQry.SQL.Text := 'SELECT spget_crypted_data(' + QuotedStr(pVal) + ')';
    vQry.Open();
    Result := vQry.FieldByName('spget_crypted_data').AsString;
    vQry.Close;
  finally
    vQry.Free;
  end;
end;

function FormatedVariantVal(pType: TFieldType; pVal: Variant): Variant;
var
  vValueInt: Integer;
  vValueDouble: Double;
  vValueBool: Boolean;
  vValueDateTime: TDateTime;
  vValueBCD: TBcd;
begin
  if (pType = ftString)
  or (pType = ftMemo)
  or (pType = ftWideString)
  or (pType = ftWideMemo)
  or (pType = ftWideString)
  then
    Result := IfThen(not VarIsNull(pVal), VarToStr(pVal), '')
  else
  if (pType = ftSmallint)
  or (pType = ftShortint)
  or (pType = ftInteger)
  or (pType = ftLargeint)
  or (pType = ftWord)
  then
  begin
    if not VarIsNull(pVal) then
      Result := IfThen(TryStrToInt(pVal, vValueInt), VarToStr(pVal).ToInteger, 0)
    else
      Result := 0;
  end
  else if (pType = ftDate) then
  begin
    if not VarIsNull(pVal) then
    begin
      if TryStrToDateTime(VarToStr(pVal), vValueDateTime) then
        Result := vValueDateTime
      else
        Result := pVal;

//      //variant data uzunluðu > 10 olduðunda Datetime tipi olarak kabul et
//      if VarToStr(pVal).Length > 10 then
//      begin
//        TryStrToDate(VarToStr(pVal), vValueDateTime);
//        vDump := DateToStr(vValueDateTime);
//      end
//      else
//        vDump := VarToStr(pVal);
//
//      if TryStrToDate(vDump, vValueDateTime) then
//        Result := vValueDateTime
//      else
//        Result := 0;
    end
    else
      Result := 0;
  end
  else if (pType = ftDateTime) then
  begin
    if not VarIsNull(pVal) then
    begin
      if TryStrToDateTime(pVal, vValueDateTime) then
        Result := DateTimeToStr(VarToDateTime(pVal))
      else
        Result := 0;
    end
    else
      Result := 0;
  end
  else if (pType = ftTime) then
  begin
    if not VarIsNull(pVal) then
    begin
      if TryStrToTime(pVal, vValueDateTime) then
        Result := TimeToStr(VarToDateTime(pVal))
      else
        Result := 0;
    end
    else
      Result := 0;
  end
  else if (pType = ftTimeStamp) then
  begin
    if not VarIsNull(pVal) then
    begin
      if TryStrToDateTime(pVal, vValueDateTime) then
        Result := pVal//DateTimeToStr(VarToDateTime(pVal))
      else
        Result := 0;
    end
    else
      Result := 0;
  end
  else
  if (pType = ftFloat)
  or (pType = ftCurrency)
  or (pType = ftSingle)
  then
  begin
    if not VarIsNull(pVal) then
      Result := IfThen(TryStrToFloat(pVal, vValueDouble), VarToStr(pVal).ToDouble, 0.0)
    else
      Result := 0.0;
  end
  else
  if (pType = ftBCD)
  or (pType = ftFMTBcd)
  then
  begin
    if not VarIsNull(pVal) then
    begin
      if TryStrToBcd(pVal, vValueBCD) then
        Result := pVal
      else
        Result := 0.0;
    end
    else
      Result := 0.0;
  end
  else if (pType = ftBoolean) then
  begin
    if not VarIsNull(pVal) then
    begin
      if TryStrToBool(pVal, vValueBool) then
        Result := VarToStr(pVal).ToBoolean
      else
        Result := False;
    end
    else
      Result := False;
  end
  else if (pType = ftBlob) then
  begin
    Result := pVal
  end
  else if (pType = ftBytes) then
  begin
    Result := pVal
  end
  else
    Result := pVal;
end;

function FormatedVariantVal(pField: TFieldDB): Variant;
begin
  Result := FormatedVariantVal(pField.DataType, pField.Value);
end;

function ColumnFromIDCol(pRawTableColName, pRawTableName, pDataColName,
    pVirtualColName, pDataTableName: string; pIsIDReference: Boolean = True;
    pIsNumericVal: Boolean = False): string;
var
  vSP: TFDStoredProc;
  vRefColName: string;
begin
  if pIsIDReference then
    vRefColName := 'id'
  else
    vRefColName := pRawTableColName;

  if pIsNumericVal then
    Result := '(SELECT raw' + pRawTableName + '.' + pRawTableColName + ' FROM ' + pRawTableName + ' as raw' + pRawTableName +
              ' WHERE raw' + pRawTableName + '.' + vRefColName + '=' + pDataTableName + '.' + pDataColName + ') as ' + pVirtualColName
  else
  begin
    vSP := GDataBase.NewStoredProcedure;
    try
      vSP.StoredProcName := 'spget_lang_text';
      vSP.Prepare;
      vSP.ParamByName('_default_value').Value := '';
      vSP.ParamByName('_table_name').Value := QuotedStr(pRawTableName);
      vSP.ParamByName('_column_name').Value := QuotedStr(pRawTableColName);
      vSP.ParamByName('_row_id').Value := IntToStr(0);
      vSP.ParamByName('_lang').Value := QuotedStr(GDataBase.ConnSetting.Language);
      vSP.ExecProc;
      Result := vSP.ParamByName('result').AsString;

      Result :=
          'spget_lang_text' +
          '(' +
            '(SELECT raw' + pRawTableName + '.' + pRawTableColName + ' FROM ' + pRawTableName + ' as raw' + pRawTableName +
            ' WHERE raw' + pRawTableName + '.' + vRefColName + '=' + pDataTableName + '.' + pDataColName + ')' + ',' +
            QuotedStr(pRawTableName) + ',' +
            QuotedStr(pRawTableColName) + ', ' +
            pDataColName + ', ' +
            QuotedStr(GDataBase.ConnSetting.Language) + ') as ' + pVirtualColName;
    finally
      vSP.Free;
    end;
  end;
end;

function TranslateText(ADefault, ACode, ATip: string; ATable: string; ALang: string): string;
var
  Query: TFDQuery;
  LFilter: string;
  LGui: TSysLisanGuiIcerik;
begin
  Result := ADefault;
  LGui := TSysLisanGuiIcerik.Create(GDataBase);
  try

    LFilter := LGui.Lisan.FieldName      + '=' + QRY_PAR_CH + LGui.Lisan.FieldName + ' AND ' +
               LGui.Kod.FieldName        + '=' + QRY_PAR_CH + LGui.Kod.FieldName   + ' AND ' +
               LGui.IcerikTipi.FieldName + '=' + QRY_PAR_CH + LGui.IcerikTipi.FieldName;

    if ATable <> '' then
      LFilter := LFilter + ' AND ' + LGui.TabloAdi.FieldName + '=' + QRY_PAR_CH + LGui.TabloAdi.FieldName;

    if GDataBase.Connection.Connected then
    begin
      Query := GDataBase.NewQuery;
      try
        with Query do
        begin
          Close;
          SQL.Text := 'SELECT ' + LGui.Deger.FieldName + ' FROM ' + LGui.TableName + ' WHERE 1=1 AND ' + LFilter;
          if ALang = '' then
            ParamByName(LGui.Lisan.FieldName).Value := GDataBase.ConnSetting.Language
          else
            ParamByName(LGui.Lisan.FieldName).Value := ALang;
          ParamByName(LGui.Kod.FieldName).Value := ACode;
          ParamByName(LGui.IcerikTipi.FieldName).Value := ATip;
          if ATable <> '' then
            ParamByName(LGui.TabloAdi.FieldName).Value := ATable;
          Open;

          if (Fields.Fields[0].IsNull) then
            Result := ADefault
          else
            Result := Fields.Fields[0].AsString;

          EmptyDataSet;
          Close;
        end;
      finally
        Query.Free;
      end;
    end;

    if (ATip = LngMsgError) then
      Result := 'Hata Kodu = ' + ACode + AddLBs(2) + Result;
  finally
    LGui.Free;
  end;
end;

function GetTempFolder: string;
begin
  Result := TPath.GetTempPath;
end;

function TCMB_DovizKurlari: TTCMBDovizKuruList;
var
  LClient: System.Net.HttpClientComponent.TNetHTTPClient;
  LXMLDocument: IXMLDocument;
  LXML: string;
  LNode: IXMLNode;
begin
  SetLength(Result, 0);
  //XML downloader with SSL/"https" support...
  LClient := TNetHTTPClient.Create(nil);
  try
    LXML := LClient.Get( 'https://www.tcmb.gov.tr/kurlar/today.xml' ).ContentAsString;

    LXMLDocument := TXMLDocument.Create(nil);
    LXMLDocument.ParseOptions := LXMLDocument.ParseOptions + [poPreserveWhiteSpace];
    LXMLDocument.LoadFromXML(LXML);

    LNode :=  LXMLDocument.DocumentElement.ChildNodes.FindNode('Currency');
    while LNode <> nil do
    begin
      SetLength(Result, Length(Result)+1);

      Result[Length(Result)-1].Tarih := GDataBase.DateDB;
      Result[Length(Result)-1].Kod := LNode.Attributes['Kod'];
      Result[Length(Result)-1].Aciklama := LNode.ChildNodes.Nodes['Isim'].Text;
      Result[Length(Result)-1].ForexBuying := StrToFloatDef(LNode.ChildNodes.Nodes['ForexBuying'].Text.Replace('.', ','), 0);
      Result[Length(Result)-1].ForexSelling := StrToFloatDef(LNode.ChildNodes.Nodes['ForexSelling'].Text.Replace('.', ','), 0);
      Result[Length(Result)-1].BanknoteBuying := StrToFloatDef(LNode.ChildNodes.Nodes['BanknoteBuying'].Text.Replace('.', ','), 0);
      Result[Length(Result)-1].BanknoteSelling := StrToFloatDef(LNode.ChildNodes.Nodes['BanknoteSelling'].Text.Replace('.', ','), 0);

      LNode := LNode.NextSibling; // ntTEXT
      LNode := LNode.NextSibling; // Currency
    end;
  finally
    LClient.Free;
  end;
end;

function FrameworkLang: TLang;
begin
  if Result.StatusAccept = '' then
  begin
    Result.GeneralConfirmationLower := '111';
    Result.GeneralConfirmationUpper := '112';
    Result.GeneralNoLower := '113';
    Result.GeneralNoUpper := '114';
    Result.GeneralPeriod := '115';
    Result.GeneralRecordCount := '116';
    Result.GeneralYesLower := '117';
    Result.GeneralYesUpper := '118';

    Result.StatusAccept := '119';
    Result.StatusAdd := '120';
    Result.StatusCancel := '121';
    Result.StatusDelete := '122';

    Result.ButtonAccept := '123';
    Result.ButtonAdd := '124';
    Result.ButtonCancel := '125';
    Result.ButtonClose := '126';
    Result.ButtonDelete := '127';
    Result.ButtonFilter := '128';
    Result.ButtonOK := '129';
    Result.ButtonUpdate := '130';
    Result.ButtonHelper := '188';

    Result.FilterFilterCriteriaTitle := '131';
    Result.FilterKeyValue := '132';
    Result.FilterLike := '133';
    Result.FilterNotLike := '134';
    Result.FilterSelectFilterFields := '135';
    Result.FilterWithEnd := '136';
    Result.FilterWithStart := '137';

    Result.ErrorAccessRight := '138';
    Result.ErrorDatabaseConnection := '139';
    Result.ErrorLogin := '140';
    Result.ErrorDBOther := '141';
    Result.ErrorDBNoDataFound := '142';
    Result.ErrorDBTooManyRows := '143';
    Result.ErrorDBRecordLocked := '144';
    Result.ErrorDBUnique := '145';
    Result.ErrorDBForeignKeyDeleteUpdate := '146';
    Result.ErrorDBForeignKeyUnique := '147';
    Result.ErrorDBObjectNotExist := '148';
    Result.ErrorDBCmdAborted := '149';
    Result.ErrorDBServerGone := '150';
    Result.ErrorDBInvalidParams := '151';
    Result.ErrorRecordDeleted := '152';
    Result.ErrorRecordDeletedMessage := '153';
    Result.ErrorRedInputsRequired := '154';
    Result.ErrorRequiredData := '155';

    Result.MessageApplicationTerminate := '156';
    Result.MessageCloseWindow := '157';
    Result.MessageDeleteRecord := '158';
    Result.MessageUnsupportedProcess := '159';
    Result.MessageUpdateRecord := '160';
    Result.MessageUpdateColumnWidth := '161';
    Result.MessageKillProcess := '166';
    Result.MessageOtomatikDovizKuru := '189';

    Result.WarningActiveTransaction := '162';
    Result.WarningLockedRecord := '163';
    Result.WarningOpenWindow := '164';
    Result.WarningChagenEncryptCode := '165';

    Result.MessageTitleOther := '1';
    Result.MessageTitleUyari := '2';
    Result.MessageTitleError := '3';
    Result.MessageTitleNoDataFound := '4';
    Result.MessageTitleDataAlreadyExists := '5';
    Result.MessageTitleInsertUpdate := '6';
    Result.MessageTitleUpdateDelete := '7';
    Result.MessageTitleObjectNotFound := '8';

    Result.PopupAddLangDataContent := '173';
    Result.PopupAddLangGuiContent := '174';
    Result.PopupAddUseMultiLangData := '175';
    Result.PopupCopyRecord := '176';
    Result.PopupExportExcel := '177';
    Result.PopupExportExcelAll := '178';
    Result.PopupFilter := '179';
    Result.PopupFilterExclude := '180';
    Result.PopupFilterRemove := '181';
    Result.PopupPreview := '182';
    Result.PopupPrint := '183';
    Result.PopupRemoveSort := '184';
  end;
end;

function AddLBs(pCount: Integer): string;
var
  n1: Integer;
begin
  Result := '';
  for n1 := 0 to pCount - 1 do
    Result := Result + sLineBreak;
end;

function CustomMsgDlg(const pMsg: string;
  pDlgType: TMsgDlgType; pButtons: TMsgDlgButtons;
  pCaptions: array of string; pDefaultButton: TMsgDlgBtn;
  pCustomTitle: string; pFontName: string): Integer;
var
  vMsgDlg: TForm;
  n1, nCaption, widthTotal, LTotalBtnWidth: Integer;
  vDlgButton: TButton;
  fontName: string;
  buttonNames: array of TButton;
begin
  vMsgDlg := CreateMessageDialog(pMsg, pDlgType, pButtons, pDefaultButton);
  if pFontName = '' then
    fontName := 'Tahoma'
  else
    fontName := pFontName;

  SetLength(buttonNames, 0);
  nCaption := 0;
  widthTotal := 0;
  LTotalBtnWidth := 0;

  vMsgDlg.Font.Name := fontName;
  vMsgDlg.Canvas.Font.Name := fontName;

  if pCustomTitle <> '' then
    vMsgDlg.Caption := pCustomTitle;

  for n1 := 0 to vMsgDlg.ComponentCount - 1 do
  begin
    if (vMsgDlg.Components[n1] is TButton) then
    begin
      vDlgButton := TButton(vMsgDlg.Components[n1]);
      if nCaption > High(pCaptions) then
        Break;

      //font deðiþtir
      vDlgButton.Font.Name := fontName;
      //custom caption ata
      vDlgButton.Caption := pCaptions[nCaption];
      //yazýya göre buton geniþliðini ayarla
      vDlgButton.Width := Max(vMsgDlg.Canvas.TextWidth(vDlgButton.Caption) + (8 * 2), 75);

      LTotalBtnWidth :=  LTotalBtnWidth + vDlgButton.Width;

      //butonlarýn arasýnda 8 boþluk býrak
      //soldan da 8 boþluk için +8 yapýyoruz
      if nCaption = 0 then
        widthTotal := 8;
      widthTotal := widthTotal + vDlgButton.Width + 12;
      Inc(nCaption);

      //butonlarýn left pozisyonlarýný ayarlamak için array içinde tutuyoruz
      SetLength(buttonNames, nCaption);
      buttonNames[nCaption-1] := vDlgButton;
    end;
  end;

  if widthTotal > vMsgDlg.Width then
    vMsgDlg.Width := widthTotal;

  for n1 := 0 to Length(buttonNames)-1 do
  begin
    if n1 = 0  then
      buttonNames[n1].Left := (vMsgDlg.Width - (LTotalBtnWidth + ((nCaption - 1) * 16))) div 2//widthTotal - buttonNames[n1].Width - posLeft - 8
    else
      buttonNames[n1].Left := buttonNames[n1-1].Left + buttonNames[n1-1].Width + 16;
  end;

  Result := vMsgDlg.ShowModal;
end;

function ReplaceMessages(Source: string; Old, New: array of string; IsIgnoreCase: Boolean = False): string;
var
  n1: Integer;
begin
  Result := Source;
  if (Length(Old) > 0) and (Old[0] <> '') then
  begin
    for n1 := 0 to Length(Old) - 1 do
    begin
      if Old[n1] <> '' then
      begin
        if IsIgnoreCase then
          Result := StringReplace(Result, Old[n1], New[n1], [rfIgnoreCase])
        else
          Result := StringReplace(Result, Old[n1], New[n1], [rfReplaceAll]);
      end;
    end;
  end;

  Result := StringReplace(Result, '#br#', AddLBs, [rfReplaceAll]);
end;

function EnDeCrypt(const Value: string): string;
var
  CharIndex: integer;
begin
  Result := Value;
  for CharIndex := 1 to Length(Value) do
    Result[CharIndex] := chr(not (ord(Value[CharIndex])));
end;

function CheckString(const pStr: string): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 1 to Length(pStr) do
    if CharInSet(pStr[n1], ['0'..'9', 'a'..'z', 'A'..'Z', '_', '/', 'ö', 'Ö', 'ç', 'Ç', 'þ', 'Þ', 'ý', 'Ý', 'ð', 'Ð', 'ü', 'Ü']) then
      Exit(True);
end;

function SendSmsViaService(AMsg: WideString; AReceiverNos: Array_Of_string): TSmsServiceResult;
var
  LSmsService: smsnn;
begin
  //if TSingletonDB.GetInstance.ApplicationSettings.SmsServiceProvider.Value = 'NETGSM' then
  //þu anda sadece NETGSM hizmetini destekliyor
  LSmsService := Getsmsnn();

  Result.BulkID := LSmsService.smsGonder1NV2(
      GSysUygulamaAyari.SmsUser.Value,
      GSysUygulamaAyari.SmsPassword.Value,
      GSysUygulamaAyari.SmsTitle.Value,
      AMsg, AReceiverNos, '', '', '', '', 0
  );

  if Result.BulkID = '20' then
  begin
    Result.Success := False;
    Result.Msg :=
      'Mesaj metninde ki problemden dolayý gönderilemediðini veya standart maksimum mesaj karakter sayýsýný geçtiðini ifade eder. ' +
      '(Standart maksimum karakter sayýsý 917 dir. Eðer mesajýnýz türkçe karakter içeriyorsa Türkçe Karakter Hesaplama menüsunden karakter sayýlarýnýn hesaplanýþ þeklini görebilirsiniz.)';
  end
  else if Result.BulkID = '30' then
  begin
    Result.Success := False;
    Result.Msg :=
      'Geçersiz kullanýcý adý , þifre veya kullanýcýnýzýn API eriþim izninin olmadýðýný gösterir. ' +
      'Ayrýca eðer API eriþiminizde IP sýnýrlamasý yaptýysanýz ve sýnýrladýðýnýz ip dýþýnda gönderim saðlýyorsanýz 30 hata kodunu alýrsýnýz. ' +
      'API eriþim izninizi veya IP sýnýrlamanýzý , web arayüzden; sað üst köþede bulunan ayarlar> API iþlemleri menüsunden kontrol edebilirsiniz.';
  end
  else if Result.BulkID = '40' then
  begin
    Result.Success := False;
    Result.Msg := 'Mesaj baþlýðýnýzýn (gönderici adýnýzýn) sistemde tanýmlý olmadýðýný ifade eder. Gönderici adlarýnýzý API ile sorgulayarak kontrol edebilirsiniz.';
  end
  else if Result.BulkID = '50' then
  begin
    Result.Success := False;
    Result.Msg := 'Abone hesabýnýz ile ÝYS kontrollü gönderimler yapýlamamaktadýr.';
  end
  else if Result.BulkID = '51' then
  begin
    Result.Success := False;
    Result.Msg := 'Aboneliðinize tanýmlý ÝYS Marka bilgisi bulunamadýðýný ifade eder.';
  end
  else if Result.BulkID = '70' then
  begin
    Result.Success := False;
    Result.Msg := 'Hatalý sorgulama. Gönderdiðiniz parametrelerden birisi hatalý veya zorunlu alanlardan birinin eksik olduðunu ifade eder.';
  end
  else if Result.BulkID = '80' then
  begin
    Result.Success := False;
    Result.Msg := 'Gönderim sýnýr aþýmý';
  end
  else if Result.BulkID = '85' then
  begin
    Result.Success := False;
    Result.Msg := 'Mükerrer Gönderim sýnýr aþýmý. Ayný numaraya 1 dakika içerisinde 20 den fazla görev oluþturulamaz.';
  end
  else if (Result.BulkID = '100') or (Result.BulkID = '101') then
  begin
    Result.Success := False;
    Result.Msg := 'Sistem hatasý.';
  end
  else
  begin
    Result.Success := True;
    Result.Msg := 'Gönderim baþarýlý';
  end;
end;

function TrimCustom(const S: string; const AChar: Char): string;
var
  I, L: Integer;
begin
  L := S.Length - 1;
  I := 0;
  if (L > -1) and (S.Chars[I] > AChar) and (S.Chars[L] > AChar) then Exit(S);
  while (I <= L) and (S.Chars[I] <= AChar) do Inc(I);
  if I > L then Exit('');
  while S.Chars[L] <= AChar do Dec(L);
  Result := S.SubString(I, L - I + 1);
end;

function TrimLeftCustom(const S: string; const AChar: Char): string;
var
  I, L: Integer;
begin
  L := S.Length - 1;
  I := 0;
  while (I <= L) and (S[I] <= AChar) do Inc(I);
  if I > 0 then
    Result := S.SubString(I)
  else
    Result := S;
end;

function TrimRightCustom(const S: string; const AChar: Char): string;
var
  I: Integer;
begin
  I := S.Length - 1;
  if (I >= 0) and (S[I] > AChar) then Result := S
  else begin
    while (I >= 0) and (S.Chars[I] <= AChar) do Dec(I);
    Result := S.SubString(0, I + 1);
  end;
end;

function IsNumeric(const S: string): Boolean;
begin
  Result := True;
  try
    StrToInt(S);
  except
    Result := False;
  end;
end;

procedure TutarHesapla(const fiyat: double; const miktar: double; const iskontoOrani: double; const kdvOrani: double; out tutar: double; out netFiyat: double; out iskontoTutar: double; out kdvTutar: double; out toplamTutar: double; ondalikli_hane: integer);
begin
  tutar := miktar * fiyat;
  netFiyat := fiyat * (100.0 - iskontoOrani) / 100.0;
  iskontoTutar := (tutar * iskontoOrani) / 100.0;
  kdvTutar := (netFiyat * miktar * kdvOrani) / 100.0;
  toplamTutar := (netFiyat * miktar) + kdvTutar;
end;

function SayiyiYaziyaCevir(Num: Double): string;
const
  BIRLER: array[0..9] of string = ('', 'BÝR ', 'ÝKÝ ', 'ÜÇ ', 'DÖRT ', 'BEÞ ', 'ALTI ', 'YEDÝ ', 'SEKÝZ ', 'DOKUZ ');
  ONLAR: array[0..9] of string = ('', 'ON ', 'YÝRMÝ ', 'OTUZ ', 'KIRK ', 'ELLÝ ', 'ALTMIÞ ', 'YETMÝÞ ', 'SEKSEN ', 'DOKSAN ');
  DIGER: array[0..5] of string = ('', 'BÝN ', 'MÝLYON ', 'MÝLYAR ', 'TRÝLYON ', 'KATRÝLYON ');

  function SmallNum(Num: Int64): string;
  var
    S: string;
  begin
    Result := '';
    S := IntToStr(Num);
    if (Length(S) = 1) then
      S := '00' + S
    else
    begin
      if (Length(S) = 2) then
        S := '0' + S;
    end;
    if S[1] <> '0' then
    begin
      if S[1] <> '1' then
        Result := BIRLER[StrToInt(string(S[1]))] + 'YÜZ '
      else
        Result := 'YÜZ ';
    end;
    Result := Result + ONLAR[StrToInt(string(S[2]))];
    Result := Result + BIRLER[StrToInt(string(S[3]))];
  end;

var
  i, j, n, Nm: Int64;
  S, Sn: string;
begin
  S := FormatFloat('0', Num);
  Sn := '';
  if Num = 0 then
    Sn := 'SIFIR'
  else if Length(S) < 4 then
    Sn := SmallNum(Round(Num))
  else
  begin
    i := 1;
    j := Length(S) mod 3;
    if j = 0 then
    begin
      j := 3;
      n := Length(S) div 3 - 1;
    end
    else
      n := Length(S) div 3;

    while i < Length(S) do
    begin
      Nm := StrToInt(Copy(S, i, j));

      if (Nm = 1) and (n = 1) then
      begin
        Nm := 0;
        Sn := Sn + SmallNum(Nm) + Diger[n];
      end;

      if Nm <> 0 then
        Sn := Sn + SmallNum(Nm) + Diger[n];

      i := i + j;
      j := 3;
      n := n - 1;
    end;
  end;
  Result := Sn;
end;

function SayiyiYaziyaCevir2(tutar: double; tur: integer; tam_birim: string = 'TL'; ondalikli_birim: string = 'KRÞ'): string;
const
  b1: array[1..9] of string = ('BÝR', 'ÝKÝ', 'ÜÇ', 'DÖRT', 'BEÞ', 'ALTI', 'YEDÝ', 'SEKÝZ', 'DOKUZ');
  b2: array[1..9] of string = ('ON', 'YÝRMÝ', 'OTUZ', 'KIRK', 'ELLÝ', 'ALTMIÞ', 'YETMÝÞ', 'SEKSEN', 'DOKSAN');
  b3: array[1..6] of string = ('KATRÝLYON', 'TRÝLYON', 'MÝLYAR', 'MÝLYON', 'BÝN', '');
var
  gr: array[1..6] of string;
  sn: array[1..6] of string;
  bs: array[1..3] of integer;
  tutars, tutart, tutark, sonuct, sonuck: string;
  i, l: integer;
begin
  tutars := floattostr(tutar);
  if pos(',', tutars) = 0 then
    tutars := tutars + ',00';

  tutart := copy(tutars, 1, (pos(',', tutars) - 1));
  tutark := copy(tutars, (pos(',', tutars) + 1), 2);
  tutart := stringofchar('0', (18 - (length(trim(tutart))))) + tutart;
  tutark := tutark + stringofchar('0', (2 - (length(trim(tutark)))));

  for i := 1 to 6 do
    gr[i] := copy(tutart, 1 + (3 * (i - 1)), 3);

  for l := 1 to 6 do
  begin
    bs[1] := StrToInt(Copy(gr[l], 1, 1));
    if bs[1] <> 0 then
    begin
      if bs[1] <> 1 then
        sn[l] := sn[l] + b1[bs[1]] + 'YÜZ'
      else
        sn[l] := sn[l] + 'YÜZ';
    end;

    bs[2] := strtoint(copy(gr[l], 2, 1));

    if bs[2] <> 0 then
      sn[l] := sn[l] + b2[bs[2]];

    bs[3] := strtoint(copy(gr[l], 3, 1));

    if bs[3] <> 0 then
      sn[l] := sn[l] + b1[bs[3]];

    if Length(Trim(sn[l])) <> 0 then
      sn[l] := sn[l] + b3[l];
  end;

  if sn[5] = 'BÝRBÝN' then
    sn[5] := 'BÝN';

  for i := 1 to 6 do
    sonuct := sonuct + sn[i];

  if strtoint(copy(tutark, 1, 1)) <> 0 then
    sonuck := sonuck + b2[strtoint(copy(tutark, 1, 1))];

  if strtoint(copy(tutark, 2, 1)) <> 0 then
    sonuck := sonuck + b1[strtoint(copy(tutark, 2, 1))];

  if tur = 0 then
    result := sonuct + ' ' + tam_birim + ' / ' + sonuck + ' ' + ondalikli_birim;

  if tur = 1 then
    result := sonuct + ' ' + tam_birim;

  if tur = 2 then
    result := sonuck + ' ' + ondalikli_birim;
end;

function VarToInt(const pVal: Variant): Integer;
begin
  Result := StrToIntDef(VarToStr(pVal), 0);
end;

function VarToInt64(const pVal: Variant): Int64;
begin
  Result := StrToInt64Def(VarToStr(pVal), 0);
end;

function VarToStr(const pVal: Variant): string;
begin
  Result := System.Variants.VarToStr(pVal);
end;

function PermissionTypeAsString(APermissionType: TPermissionType): string;
begin
  case APermissionType of
    ptRead: Result := 'OKUMA';
    ptAddRecord: Result := 'KAYIT EKLEME';
    ptUpdate: Result := 'GÜNCELLEME';
    ptDelete: Result := 'KAYIT SÝLME';
    ptSpeacial: Result := 'ÖZEL HAK';
  end;
end;

function VirguldenSonraHaneSayisi(deger: double; hanesayisi: integer): string;
var
  strDeger: string;
begin
  if deger <> 0 then
  begin
    strDeger := FloatToStr(deger);
    if Pos(',', strDeger) > 0 then
      Result := LeftStr(strDeger, Pos(',', strDeger) + hanesayisi)
    else
      Result := strDeger;
  end
  else if deger = 0 then
  begin
    Result := '0';
  end;
end;

function GetDialogColor(pColor: TColor): TColor;
var
  vColorDialog: TColorDialog;
begin
  vColorDialog := TColorDialog.Create(nil);
  try
    vColorDialog.Color := pColor;
    vColorDialog.Execute(Application.Handle);
    Result := vColorDialog.Color;
  finally
    vColorDialog.Free;
  end;
end;

{$WARN SYMBOL_PLATFORM OFF}
function GetDialogDirectory(pInitialDir: string): string;
var
  OpenDialog: TFileOpenDialog;
begin

  OpenDialog := TFileOpenDialog.Create(nil);
  try
    if pInitialDir = '' then
      OpenDialog.DefaultFolder := '%USERPROFILE%\desktop'
    else
      OpenDialog.DefaultFolder := pInitialDir;

    OpenDialog.Title := 'Select Directory';
    OpenDialog.Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
    OpenDialog.OkButtonLabel := 'Select';

    if OpenDialog.Execute then
      Result := OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end
end;
{$WARN SYMBOL_PLATFORM ON}

function GetDialogOpen(pFilter: string; pInitialDir: string = ''): string;
var
  vOpenDialog: TOpenDialog;
begin
  vOpenDialog := TOpenDialog.Create(nil);
  try
    if pInitialDir = '' then
      vOpenDialog.InitialDir := '%USERPROFILE%\desktop';
    vOpenDialog.Filter := pFilter;
    vOpenDialog.Execute(Application.Handle);
    Result := vOpenDialog.FileName;
  finally
    vOpenDialog.Free;
  end;
end;

function GetDialogSave(pFileName, pFilter: string; pInitialDir: string = ''): string;
var
  LSaveDialog: TSaveDialog;
begin
  Result := '';
  LSaveDialog := TSaveDialog.Create(nil);
  with LSaveDialog do
  try
    Filter := pFilter;
    FileName := pFileName;
    DefaultExt := pFilter.PadRight(3);
    if pInitialDir = '' then
      InitialDir := '%USERPROFILE%\desktop'
    else
      InitialDir := pInitialDir;

    if not Execute(Application.Handle) then
      Exit;
    Result := FileName;
  finally
    Free;
  end;
end;

function GetMACAddress: TNetworkCardInfoList;
var
  NumInterfaces: Cardinal;
  AdapterInfo: array of TIpAdapterInfo;
  OutBufLen: ULONG;
  n1, I, N, LLen: Integer;
  LIP: string;
begin
  GetNumberOfInterfaces(NumInterfaces);
  SetLength(AdapterInfo, NumInterfaces);
  OutBufLen := NumInterfaces * SizeOf(TIpAdapterInfo);
  GetAdaptersInfo(@AdapterInfo[0], OutBufLen);

  SetLength(Result, 100);
  I := 0;
  for n1 := 0 to NumInterfaces - 1 do
  begin
    if  (AdapterInfo[n1].IpAddressList.IpAddress.S[0] <> '0')
    and (AdapterInfo[n1].IpAddressList.IpAddress.S[0] <> '')
    then
    begin
      LLen := Length(AdapterInfo[n1].IpAddressList.IpAddress.S);
      LIP := '';
      for n := 0 to LLen-1 do
        if Char(AdapterInfo[n1].IpAddressList.IpAddress.S[n]) <> '' then
          LIP := LIP + Char(AdapterInfo[n1].IpAddressList.IpAddress.S[n]);

      if (LeftStr(LIP, 8) <> '169.254.') and (LIP <> '') then
      begin
        SetLength(Result, I+1);
        Result[I].IPAddress := LIP;
        Result[I].MacAddress := Format('%.2x:%.2x:%.2x:%.2x:%.2x:%.2x',
                                          [AdapterInfo[n1].Address[0], AdapterInfo[n1].Address[1],
                                           AdapterInfo[n1].Address[2], AdapterInfo[n1].Address[3],
                                           AdapterInfo[n1].Address[4], AdapterInfo[n1].Address[5]]
                                      );
        Inc(I);
      end;
    end;
  end;
end;

procedure CopyFolder(ASrcPath, ADestPath: string);
var
  LFiles: TStringDynArray;
  LInFile, LOutFile, LFileName, LFolderName: string;
begin
  LFiles := TDirectory.GetFiles(ASrcPath, '*.*', TSearchOption.soAllDirectories);
  for LInFile in LFiles do
  begin
    LOutFile := TPath.Combine(ADestPath, TPath.GetFileName(LInFile));
    LOutFile := StringReplace(LInFile, ASrcPath, ADestPath, [rfReplaceAll]);

    LFileName := ExtractFileName(LOutFile);
    LFolderName := ExtractFilePath(LOutFile);

    if not DirectoryExists(LFolderName) then  //check folder
      ForceDirectories(LFolderName);  //create folder with subfolder

    TFile.Copy(LInFile, LOutFile, True);  //copy file
  end;
end;

function CountNumOfCharacter(s: string; delimeter: string): integer;
var
  i, nFind: integer;
  letter: string;
begin
  //count := 0;
  nFind := 0;
  for i := 1 to length(s) do
  begin
    letter := s[i];
    if letter = delimeter then
      nFind := nFind + 1;
  end;
  result := nFind;
end;

procedure CreateExceptionByLang(pMsg, pCode: string; AName: string = '');
begin
  raise Exception.Create(TranslateText(pMsg, pCode, LngMsgError, '') + ' ' + AName);
end;

function GetSimdikiTarih(date_now: TDate): TStringList;
var
  wGun, wAy, wYil: word;
begin
  Result := TStringList.Create;

  DecodeDate(date_now, wYil, wAy, wGun);

  Result.Add(IntToStr(wGun));
  Result.Add(IntToStr(wAy));
  Result.Add(IntToStr(wYil));
end;

function scaleBySystemDPI(AVal: Integer): Integer;
begin
  //Default DPI value 96ppi
  //Exmp. System %150 Increase(144ppi) 144/96=1,5(zoom) * 50 = 75
  Result := Trunc(AVal * (Screen.PixelsPerInch / 96));
end;

//todo ferhat
function CheckIntegerInArray(pArr: ArrayInteger; pKey: Integer): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 0 to Length(pArr) - 1 do
  begin
    if pKey = pArr[n1] then
      Result := True;
    Exit;
  end;
end;

function CheckStringInArray(pArr: TArray<string>; pKey: string): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 0 to Length(pArr) - 1 do
  begin
    if pKey = pArr[n1] then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure freeInGroupBox(pGroup: TGroupBox);
var
  n1: Integer;
begin
  for n1 := pGroup.ComponentCount-1 downto 0 do
    pGroup.Components[n1].Free;
end;

function CLen(S: string; N: INTEGER): string;
var
  X: integer;
begin
  X := LENGTH(S);
  if X < N then
    CLen := S + StringOfChar(' ', N - X)
  else
    CLen := COPY(S, 1, N);
end;

function RSet(S: string; N: integer): string;
var
  X: INTEGER;
begin
  X := LENGTH(S);
  if X < N then
    RSet := StringOfChar(' ', N - X) + S
  else
    RSet := COPY(S, 1, N);
end;

function FirstCaseUpper(const vStr: string): string;
var
  n1: Integer;
begin
  if vStr = '' then
    Result := ''
  else
  begin
    Result := UpperCaseTr(vStr[1]);
    for n1 := 2 to Length(vStr) do
    begin
      if vStr[n1 - 1] = ' ' then
        Result := Result + UpperCaseTr(vStr[n1])
      else
        Result := Result + LowerCaseTr(vStr[n1]);
    end;
  end;
end;

function LSet(st: string): string;
var
//  ch:char;
  bCon: boolean;
  i: integer;
begin
  i := 0;
  bCon := FALSE;
  repeat
    i := i + 1;
    if (i > Length(st)) or (Copy(st, i, 1) <> ' ') then
      bCon := TRUE;
  until bCon;
  Delete(st, 1, i - 1);
  LSet := st;
end;

function FloatKeyControl2(Sender: TObject; Key: Char): Char;
begin
  if not CharInSet(Key, [#8, '0'..'9', FormatSettings.DecimalSeparator]) then
  begin
    Key := #0; //sadece sayý ve virgülle backspace kabul et
  end
  else if (Key = FormatSettings.DecimalSeparator) and (Pos(Key, TStringGrid(Sender).Cells[TStringGrid(Sender).Col, TStringGrid(Sender).Row]) > 0) then
  begin
    Key := #0; //ikinci virgülü alma
  end
  else if (Key = FormatSettings.DecimalSeparator) and (Length(TStringGrid(Sender).Cells[TStringGrid(Sender).Col, TStringGrid(Sender).Row]) = 0) then
  begin
    Key := #0; //, ile baþlatma
  end;
  Result := Key;
end;

function LastPos(const SubStr: string; const strData: string): Integer;
begin
  Result := Pos(ReverseString(SubStr), ReverseString(strData));

  if (Result <> 0) then
    Result := ((Length(strData) - Length(SubStr)) + 1) - Result + 1;
end;

function isAltDown: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_MENU] and 128) <> 0);
end;

function isCtrlDown: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_CONTROL] and 128) <> 0);
end;

function isShiftDown: Boolean;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := ((State[VK_SHIFT] and 128) <> 0);
end;

function GetMikroRaporTarihFormat(tarih: TDateTime): string;
begin
  if tarih <> 0 then
    Result := StringReplace(DateToStr(tarih), '.', '', [rfReplaceAll])
  else
    Result := '';
end;

function FileToByteArray(const FileName: WideString): TArray<Byte>;
const
  BLOCK_SIZE = 1024;
var
  BytesRead, BytesToWrite, Count: integer;
  F: file of Byte;
  pTemp: Pointer;
begin
  AssignFile(F, FileName);
  Reset(F);
  try
    Count := FileSize(F);
    SetLength(Result, Count);
    pTemp := @Result[0];
    BytesRead := BLOCK_SIZE;
    while (BytesRead = BLOCK_SIZE) do
    begin
      BytesToWrite := Min(Count, BLOCK_SIZE);
      BlockRead(F, pTemp^, BytesToWrite, BytesRead);
      pTemp := Pointer(LongInt(pTemp) + BLOCK_SIZE);
      Count := Count - BytesRead;
    end;
  finally
    CloseFile(F);
  end;
end;

{$IFDEF MSWINDOWS}
function GetFileSize(pFileName: string): Int64;
var
  vSearchRec: TSearchRec;
begin
{$WARN SYMBOL_PLATFORM OFF}
  //SearchRec.Size property works, but only for files less than 2GB
  if FindFirst(pFileName, faAnyFile, vSearchRec) = 0 then
    Result := Int64(vSearchRec.FindData.nFileSizeHigh) shl Int64(32) + Int64(vSearchRec.FindData.nFileSizeLow)
  else
    Result := 0;
  System.Sysutils.FindClose(vSearchRec);
{$WARN SYMBOL_PLATFORM ON}
end;
{$ENDIF MSWINDOWS}

procedure ByteArrayToFile(const ByteArray: TBytes; const FileName: string);
var
  Count: Integer;
  F: file of Byte;
  pTemp: Pointer;
begin
  AssignFile(F, FileName);
  Rewrite(F);
  try
    Count := Length(ByteArray);
    pTemp := @ByteArray[0];
    BlockWrite(F, pTemp^, Count);
  finally
    CloseFile(F);
  end;
end;

function UpperCaseTr(S: string): string;
begin
  Result := AnsiUpperCase(StringReplace(StringReplace(S, 'ý', 'I', [rfReplaceAll]), 'i', 'Ý', [rfReplaceAll]));
end;

function LowerCaseTr(S: string): string;
begin
  Result := AnsiLowerCase(StringReplace(StringReplace(S, 'I', 'ý', [rfReplaceAll]), 'Ý', 'i', [rfReplaceAll]));
end;

function BoolToStr(ABool: Boolean; ABuyuk: Boolean): string;
begin
  if ABuyuk then
    Result := IfThen(ABool, 'TRUE', 'FALSE')
  else
    Result := IfThen(ABool, 'True', 'False');
end;

function GetStrHashSHA512(Str: string): string;
var
  HashSHA: THashSHA2;
begin
  HashSHA := THashSHA2.Create;
  HashSHA.GetHashString(Str);
  Result := HashSHA.GetHashString(Str, SHA512);
end;

function GetFileHashSHA512(FileName: WideString): string;
var
  HashSHA: THashSHA2;
  Stream: TStream;
  Readed: Integer;
  Buffer: PByte;
  BufLen: Integer;
begin
  HashSHA := THashSHA2.Create(SHA512);
  BufLen := 16 * 1024;
  Buffer := AllocMem(BufLen);
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      while Stream.Position < Stream.Size do
      begin
        Readed := Stream.Read(Buffer^, BufLen);
        if Readed > 0 then
        begin
          HashSHA.update(Buffer^, Readed);
        end;
      end;
    finally
      Stream.Free;
    end;
  finally
    FreeMem(Buffer)
  end;
  Result := HashSHA.HashAsString;
end;

function GetStrFromHashSHA512(pString: WideString): string;
var
  HashSHA: THashSHA2;
begin
  HashSHA := THashSHA2.Create(SHA512);
  HashSHA.Update(pString);
  Result := HashSHA.GetHashString(pString);
end;

function EncryptStr(const S: WideString; Key: Word): string;
var
  n1: Integer;
  vRStr: RawByteString;
  vRStrB: TBytes absolute vRStr;
begin
  Result := '';
  vRStr := UTF8Encode(S);
  for n1 := 0 to Length(vRStr) - 1 do
  begin
    vRStrB[n1] := vRStrB[n1] xor (Key shr 8);
    Key := (vRStrB[n1] + Key) * CKEY1 + CKEY2;
  end;

  for n1 := 0 to Length(vRStr) - 1 do
    Result := Result + IntToHex(vRStrB[n1], 2);
end;

function DecryptStr(const S: string; Key: Word): string;
var
  n1, vTmpKey: Integer;
  vRStr: RawByteString;
  vRStrB: TBytes absolute vRStr;
  vTmpStr: string;
begin
  vTmpStr := UpperCase(S);
  SetLength(vRStr, Length(vTmpStr) div 2);
  n1 := 1;
  try
    while (n1 < Length(vTmpStr)) do
    begin
      vRStrB[n1 div 2] := StrToInt('$' + vTmpStr[n1] + vTmpStr[n1 + 1]);
      Inc(n1, 2);
    end;
  except
    Result := '';
    Exit;
  end;

  for n1 := 0 to Length(vRStr) - 1 do
  begin
    vTmpKey := vRStrB[n1];
    vRStrB[n1] := vRStrB[n1] xor (Key shr 8);
    Key := (vTmpKey + Key) * CKEY1 + CKEY2;
  end;

  Result := UTF8ToString(vRStr);
end;

function FTPDosyaAl(pSrcFile, pDesFile: TFileName; pFtp, pRemoteDir, pLogin, pPass: string): Boolean;
var
  vFtp: TIdFTP;
  vIDAntiFreeze: TIDAntiFreeze;
begin
  //uses IdFTP, IdFTPCommon, IdAntiFreeze

  vFtp := TIdFTP.Create(nil);
  vIDAntiFreeze := TIDAntiFreeze.Create(nil); // büyük dosyalar inerken donma olmasýn
  try
    Result := False;
    vFtp.Host := pFtp;
    vFtp.Username := pLogin;
    vFtp.Password := pPass;
    vFtp.Passive := True;
    vFtp.Connect;

    if vFtp.Connected then
    begin
      vFtp.ChangeDir(pRemoteDir);
      try
        vFtp.TransferType := ftBinary;
        vFtp.Get(pSrcFile, pDesFile, True);
      finally
        Result := True;
      end;
      vFtp.Disconnect;
    end;
  finally
    //free edilme olayý test edilmedi
    vFtp.Free;
    vIDAntiFreeze.Free;
  end;

//kullaným örnek
{
  //baþarý ile ftp alýrsa
  if TSpecialFunctions.FTPDosyaAl('vsd.jpg', 'c:\vsd.jpg', 'ftp.aybey.com', 'public_html/uploads/', 'u8264876@aybey.com', 'BmAe1993_') then
  begin
    //dosya baþaralý bir þekilde indikten sonra yapýlacak olan iþlemler
  end;
}
end;

function GetHWndByProgramName(const APName: string): THandle;
// Get Window Handle By ProgramName (Include Path or Not Include)
begin
  Result := GetHWndByPID(GetPIDByProgramName(APName));
end;

function GetProcessHndByHWnd(const hWnd: THandle): THandle;
// Get Process Handle By Window Handle
var
  PID: DWORD;
  AhProcess: THandle;
begin
  if hWnd <> 0 then
  begin
    GetWindowThreadProcessID(hWnd, @PID);
    AhProcess := OpenProcess(PROCESS_ALL_ACCESS, false, PID);
    Result := AhProcess;
    CloseHandle(AhProcess);
  end
  else
    Result := 0;
end;

function GetProcessHndByPID(const hAPID: THandle): THandle;
// Get Process Handle By Process ID
var
  AhProcess: THandle;
begin
  if hAPID <> 0 then
  begin
    AhProcess := OpenProcess(PROCESS_ALL_ACCESS, false, hAPID);
    Result := AhProcess;
    CloseHandle(AhProcess);
  end
  else
    Result := 0;
end;

function GetPIDByHWnd(const hWnd: THandle): THandle;
// Get Window Handle By ProcessID
var
  PID: DWORD;
begin
  if hWnd <> 0 then
  begin
    GetWindowThreadProcessID(hWnd, @PID);
    Result := PID;
  end
  else
    Result := 0;
end;

function GetHWndByPID(const hPID: THandle): THandle;
// Get Window Handle By ProcessID
type
  PEnumInfo = ^TEnumInfo;

  TEnumInfo = record
    ProcessID: DWORD;
    hWnd: THandle;
  end;

  function EnumWindowsProc(Wnd: DWORD; var EI: TEnumInfo): Bool; stdcall;
  var
    PID: DWORD;
  begin
    GetWindowThreadProcessID(Wnd, @PID);
    Result := (PID <> EI.ProcessID) or (not IsWindowVisible(Wnd)) or (not IsWindowEnabled(Wnd));
    if not Result then
      EI.HWND := Wnd; //break on return FALSE
  end;

  function FindMainWindow(PID: DWORD): DWORD;
  var
    EI: TEnumInfo;
  begin
    EI.ProcessID := PID;
    EI.HWND := 0;
    EnumWindows(@EnumWindowsProc, Integer(@EI));
    Result := EI.HWND;
  end;

begin
  if hPID <> 0 then
    Result := FindMainWindow(hPID)
  else
    Result := 0;
end;

function GetPIDByProgramName(const APName: string): THandle;
// Get ProcessID By ProgramName (Include Path or Not Include)
var
  isFound: boolean;
  AHandle, AhProcess: THandle;
  ProcessEntry32: TProcessEntry32;
  APath: array[0..MAX_PATH] of char;
begin
  Result := 0;
  AHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    ProcessEntry32.dwSize := Sizeof(ProcessEntry32);
    isFound := Process32First(AHandle, ProcessEntry32);
    while isFound do
    begin
      AhProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, ProcessEntry32.th32ProcessID);
      GetModuleFileName(AhProcess, @APath[0], sizeof(APath));
      //GetModuleFileNameEx(AhProcess, 0, @APath[0], sizeof(APath));
      if (UpperCase(StrPas(APath)) = UpperCase(APName)) or (UpperCase(StrPas(ProcessEntry32.szExeFile)) = UpperCase(APName)) then
      begin
        Result := ProcessEntry32.th32ProcessID;
        break;
      end;
      isFound := Process32Next(AHandle, ProcessEntry32);
      CloseHandle(AhProcess);
    end;
  finally
    CloseHandle(AHandle);
  end;
end;

function GetPathFromPID(const PID: cardinal): string;
var
  hProcess: THandle;
  path: array[0..MAX_PATH - 1] of char;
begin
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, PID);
  if hProcess <> 0 then
  try
    if GetModuleFileNameEx(hProcess, 0, path, MAX_PATH) = 0 then
      RaiseLastOSError;
    result := path;
  finally
    CloseHandle(hProcess)
  end
  else
    RaiseLastOSError;
end;

function getApplicationPath(const hnwd: HWND): string;
var
  PID: DWORD;
begin
  GetWindowThreadProcessID(hnwd, @PID);
  Result := GetPathFromPID(PID);
end;

function AppActivate(WindowHandle: hWnd): boolean; overload;
// Activate a window by its handle
begin
  try
    SendMessage(WindowHandle, WM_SYSCOMMAND, SC_HOTKEY, WindowHandle);
    SendMessage(WindowHandle, WM_SYSCOMMAND, SC_RESTORE, WindowHandle);
    result := SetForegroundWindow(WindowHandle);
  except
    on Exception do
      Result := false;
  end;
end;

function getRawDataByLang(pBaseTableName, pBaseColName: string): string;
begin
  if GDataBase.ConnSetting.Language <> GSysUygulamaAyari.UygulamaLisan.Value then
  begin
    Result :=
    'spget_lang_text(' + pBaseColName + ', ' + QuotedStr(pBaseTableName) + ', ' +
      QuotedStr(pBaseColName) + ', id, ' +
      QuotedStr(GDataBase.ConnSetting.Language) + ')::varchar as ' + pBaseColName;
  end
  else
    Result := pBaseTableName + '.' + pBaseColName;
                                                                                                           {
    '(SELECT ' +
    '  CASE WHEN ' +
		'    (SELECT b.val FROM sys_lang_data_content b ' +
        ' WHERE b.table_name=' + QuotedStr(pBaseTableName) +
          ' AND b.column_name=' + QuotedStr(pBaseColName) +
          ' AND b.lang=' + QuotedStr(TSingletonDB.GetInstance.DataBase.ConnSetting.Language) +
          ' AND b.row_id = ' + pBaseTableName + '.id) IS NULL THEN ' + pBaseTableName + '.' + pBaseColName +
		'  ELSE ' +
		'    (SELECT b.val FROM sys_lang_data_content b ' +
        ' WHERE b.table_name=' + QuotedStr(pBaseTableName) +
          ' AND b.column_name=' + QuotedStr(pBaseColName) +
          ' AND b.lang=' + QuotedStr(TSingletonDB.GetInstance.DataBase.ConnSetting.Language) +
          ' AND b.row_id = ' + pBaseTableName + '.id)' +
		'  END ' +
	  ')::varchar as ' + pBaseColName                                                                         }
end;

procedure NewParamForQuery(pQuery: TFDQuery; pField: TFieldDB);
begin
  pQuery.Params.ParamByName(pField.FieldName).DataType := pField.DataType;
  pQuery.Params.ParamByName(pField.FieldName).Value := FormatedVariantVal(pField);

  if pField.DataType = ftBytes then
  begin

  end;

  if pField.IsNullable then
  begin
    if (pField.DataType = ftString)
    or (pField.DataType = ftMemo)
    or (pField.DataType = ftWideString)
    or (pField.DataType = ftWideMemo)
    or (pField.DataType = ftWord)
    then
    begin
      if pQuery.Params.ParamByName(pField.FieldName).Value = '' then
        pQuery.Params.ParamByName(pField.FieldName).Value := Null
    end
    else
    if (pField.DataType = ftSmallint)
    or (pField.DataType = ftShortint)
    or (pField.DataType = ftInteger)
    or (pField.DataType = ftLargeint)
    or (pField.DataType = ftByte)
    then
    begin
      if pQuery.Params.ParamByName(pField.FieldName).AsInteger = 0 then
        pQuery.Params.ParamByName(pField.FieldName).Value := Null
    end
    else if (pField.DataType = ftDate) then
    begin
      if pQuery.Params.ParamByName(pField.FieldName).AsDate = 0 then
        pQuery.Params.ParamByName(pField.FieldName).Value := Null
    end
    else if (pField.DataType = ftDateTime) then
    begin
      if pQuery.Params.ParamByName(pField.FieldName).AsDateTime = 0 then
        pQuery.Params.ParamByName(pField.FieldName).Value := Null
    end
    else
    if (pField.DataType = ftTime)
    or (pField.DataType = ftTimeStamp)
    then
    begin
      if pQuery.Params.ParamByName(pField.FieldName).AsTime = 0 then
        pQuery.Params.ParamByName(pField.FieldName).Value := Null;
    end
    else
    if (pField.DataType = ftFloat)
    or (pField.DataType = ftCurrency)
    or (pField.DataType = ftSingle)
    or (pField.DataType = ftBCD)
    or (pField.DataType = ftFMTBcd)
    then
    begin
      if pQuery.Params.ParamByName(pField.FieldName).Value = 0 then
        pQuery.Params.ParamByName(pField.FieldName).Value := Null;
    end
    else if (pField.DataType = ftBlob) then
    begin
      if pQuery.Params.ParamByName(pField.FieldName).Value = 0 then
        pQuery.Params.ParamByName(pField.FieldName).Value := Null;
    end;


    if pQuery.Params.ParamByName(pField.FieldName).Value = Null then
      pQuery.Params.ParamByName(pField.FieldName).DataType := pField.DataType;
  end;
end;

function UpdateColWidth(ATableName: string; AGrid: TDBGrid): Boolean;
var
  LColWidth: TSysGridKolon;
  n1, n2, nNo: Integer;
begin
  Result := True;
  LColWidth := TSysGridKolon.Create(GDataBase);
  LColWidth.QueryOfDS.Connection.StartTransaction;
  try
    try
      LColWidth.Clear;
      LColWidth.SelectToList(' AND ' + LColWidth.TableName + '.' + LColWidth.TabloAdi.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(ATableName)), False, False);

      for n1 := 0 to AGrid.Columns.Count - 1 do
        for n2 := 0 to LColWidth.List.Count-1 do
          if ReplaceRealColOrTableNameTo(AGrid.Columns[n1].FieldName) = TSysGridKolon(LColWidth.List[n2]).KolonAdi.Value then
          begin
            TSysGridKolon(LColWidth.List[n2]).SiraNo.Value := 99 + n1;
            TSysGridKolon(LColWidth.List[n2]).Update(False);
          end;

      nNo := 0;
      for n1 := 0 to AGrid.Columns.Count-1 do
        for n2 := 0 to LColWidth.List.Count-1 do
          if ReplaceRealColOrTableNameTo(AGrid.Columns[n1].FieldName) = TSysGridKolon(LColWidth.List[n2]).KolonAdi.Value then
          begin
            TSysGridKolon(LColWidth.List[n2]).Genislik.Value := AGrid.Columns[n1].Width;
            TSysGridKolon(LColWidth.List[n2]).SiraNo.Value := nNo+1;
            TSysGridKolon(LColWidth.List[n2]).Update(False);
            Inc(nNo);
            Break;
          end;
    except
      Result := False;
      LColWidth.QueryOfDS.Connection.Rollback;
    end;
  finally
    LColWidth.QueryOfDS.Connection.Commit;
    LColWidth.Free;
  end;
end;

function GetGridDefaultOrderFilter(pKey: string; pIsOrder: Boolean): string;
var
  vSysGridDefaultOrderFilter: TSysGridFiltreSiralama;
  vOrderFilter: string;
begin
  Result := '';
  vSysGridDefaultOrderFilter := TSysGridFiltreSiralama.Create(GDataBase);
  try
    if pIsOrder then
      vOrderFilter := ' AND ' + vSysGridDefaultOrderFilter.TableName + '.' + vSysGridDefaultOrderFilter.IsSiralama.FieldName + '=True'
    else
      vOrderFilter := ' AND ' + vSysGridDefaultOrderFilter.TableName + '.' + vSysGridDefaultOrderFilter.IsSiralama.FieldName + '=False';

    vSysGridDefaultOrderFilter.SelectToList(vOrderFilter + ' AND ' + vSysGridDefaultOrderFilter.TableName + '.' + vSysGridDefaultOrderFilter.TabloAdi.FieldName + '=' + QuotedStr(pKey), False, False);
    if vSysGridDefaultOrderFilter.List.Count=1 then
      Result := TSysGridFiltreSiralama(vSysGridDefaultOrderFilter.List[0]).Deger.Value;
  finally
    vSysGridDefaultOrderFilter.Free;
  end;

  if Trim(Result) <> '' then
    if not pIsOrder then
      Result := ' AND ' + Result;
end;

function GetIsRequired(pTableName, pFieldName: string): Boolean;
var
  vSysInputGui: TSysViewColumns;
begin
  Result := False;

  vSysInputGui := TSysViewColumns.Create(GDataBase);
  try
    vSysInputGui.SelectToList(' AND ' + vSysInputGui.TableName + '.' + vSysInputGui.TableName1.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(pTableName)) +
                              ' AND ' + vSysInputGui.TableName + '.' + vSysInputGui.ColumnName.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(pFieldName)), False, False);
    if vSysInputGui.List.Count=1 then
      Result := not TSysViewColumns(vSysInputGui.List[0]).IsNullable.Value;
  finally
    vSysInputGui.Free;
  end;
end;

function GetMaxLength(pTableName, pFieldName: string): Integer;
var
  vSysInputGui: TSysViewColumns;
begin
  Result := 0;

  vSysInputGui := TSysViewColumns.Create(GDataBase);
  try
    vSysInputGui.SelectToList(' AND ' + vSysInputGui.TableName + '.' + vSysInputGui.TableName1.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(pTableName)) +
                              ' AND ' + vSysInputGui.TableName + '.' + vSysInputGui.ColumnName.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(pFieldName)), False, False);
    if vSysInputGui.List.Count=1 then
      Result := TSysViewColumns(vSysInputGui.List[0]).CharacterMaximumLength.Value;
  finally
    vSysInputGui.Free;
  end;
end;

function GetDistinctColumnName(pTableName: string): TStringList;
var
  vColumns: TSysViewColumns;
  vColWidth: TSysGridKolon;
  qry: TFDQuery;
begin
  Result := TStringList.Create;

  vColumns := TSysViewColumns.Create(GDataBase);
  vColWidth := TSysGridKolon.Create(GDataBase);
  qry := GDataBase.NewQuery;
  try
    Result.BeginUpdate;
    qry.Close;
    qry.SQL.Text := 'SELECT DISTINCT ' + vColumns.ColumnName.FieldName + ' FROM ' + vColumns.TableName +
                ' LEFT JOIN ' + vColWidth.TableName + ' ON '
                              + vColWidth.TabloAdi.FieldName + '=' + vColumns.TableName1.FieldName +
                      ' AND ' + vColWidth.KolonAdi.FieldName + '=' + vColumns.ColumnName.FieldName +
                ' WHERE ' + vColumns.TableName1.FieldName + '=' + QuotedStr(pTableName) +
                  ' AND ' + vColWidth.KolonAdi.FieldName + ' IS NULL ';
    qry.Open;
    while NOT qry.Eof do
    begin
      Result.Add( qry.Fields.Fields[0].AsString );
      qry.Next;
    end;
    qry.EmptyDataSet;
    qry.Close;
  finally
    qry.Free;
    vColumns.Free;
    vColWidth.Free;
    Result.EndUpdate;
  end;
end;

procedure FillColNameForColWidth(pComboBox: TComboBox; pTableName: string);
begin
  pComboBox.Clear;

  with GDataBase.NewQuery do
  try
    Close;
    SQL.Text := 'SELECT distinct v.column_name, ordinal_position FROM sys_view_columns v ' +
                'LEFT JOIN sys_grid_kolon a ON a.table_name=v.table_name and a.column_name = v.column_name ' +
                'WHERE v.table_name=' + QuotedStr(pTableName) + ' and a.column_name is null ' +
                'GROUP BY v.column_name, ordinal_position ' +
                'ORDER BY ordinal_position ASC ';
    Open;
    while NOT EOF do
    begin
      pComboBox.Items.Add( Fields.Fields[0].AsString );
      Next;
    end;
    EmptyDataSet;
    Close;
  finally
    Free;
  end;
end;

procedure FillColNameForColSummary(pComboBox: TComboBox; pTableName: string);
begin
  pComboBox.Clear;

  with GDataBase.NewQuery do
  try
    Close;
    SQL.Text := 'SELECT distinct v.column_name, ordinal_position FROM sys_view_columns v ' +
                'LEFT JOIN sys_grid_kolon a ON a.tablo_adi=v.table_name and a.kolon_adi = v.column_name ' +
                'WHERE v.table_name=' + QuotedStr(pTableName) + ' and a.kolon_adi is null ' +
                'GROUP BY v.column_name, ordinal_position ' +
                'ORDER BY ordinal_position ASC ';
    Open;
    while NOT EOF do
    begin
      pComboBox.Items.Add( Fields.Fields[0].AsString );
      Next;
    end;
    EmptyDataSet;
    Close;
  finally
    Free;
  end;
end;

procedure getStokResim(AID: Integer; ATableName, AImageFieldName: string; AImage: Timage);
var
  LQry: TFDQuery;
begin
  AImage.Picture.Bitmap.Assign(nil);

  LQry := GDatabase.NewQuery();
  try
    LQry.SQL.Text := 'SELECT ' + AImageFieldName + ' FROM ' + ATableName + ' WHERE id=' + AID.ToString;
    LQry.Open;
    if LQry.Fields.Fields[0].IsBlob then
    begin
      if not LQry.Fields.Fields[0].IsNull then
        AImage.Picture.Bitmap.Assign( TBlobField(LQry.Fields.Fields[0]) );
    end;
  finally
    LQry.Free;
  end;
end;

function ExistForm(AFormClassType: TClass): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 0 to Screen.FormCount-1 do
  begin
    if AFormClassType = Screen.Forms[n1].ClassType then
    begin
      Result := True;
      Break;
    end;
  end;

  if Result then
  begin
    Screen.Forms[n1].Show;
    if Screen.Forms[n1].WindowState = TWindowState.wsMinimized then
      Screen.Forms[n1].WindowState := TWindowState.wsNormal;
  end
end;

function FormatMoney(AValue: Double): string;
begin
  Result := FormatFloat('0' +
                        FormatSettings.ThousandSeparator +
                        FormatSettings.DecimalSeparator +
                        StringOfChar('0', VarToInt(GSysOndalikHane.SatisFiyat.Value)), AValue);
end;

function DoDatabaseBackup: string;
var
  LParams: string;
begin
  ForceDirectories(GUygulamaAnaDizin + PathDelim + 'Tools\');
  ForceDirectories(GUygulamaAnaDizin + PathDelim + 'Backups\');

  if not FileExists(GUygulamaAnaDizin + 'Tools\yedekle.exe') then
    raise Exception.Create('Yedekleme programý bulunamadý. Lütfen Tools dizini altýndaki yedekleme uygulamasýný kontrol edin.');

  LParams :=
    '/c Tools\yedekle.exe' +
    ' -Fc postgresql://' +
    GDataBase.Connection.Params.UserName + ':' + GDataBase.Connection.Params.Password + '@' +
    GDataBase.ConnSetting.SQLServer + ':' + GDataBase.ConnSetting.DBPortNo.ToString + '/' +
    GDataBase.Connection.Params.Database + ' > Backups\' + FormatDateTime('YYYY_MM_DD_HH_MM_SS', Now) + '&&exit';

  ShellExecute(0, 'open', 'cmd', PWideChar(LParams), nil, SW_HIDE);
end;

initialization
  SetLength(GDosyaUzantilari, 17);
  GDosyaUzantilari[0] := FILE_FILTER_XLS;
  GDosyaUzantilari[1] := FILE_FILTER_XLSX;
  GDosyaUzantilari[2] := FILE_FILTER_DOC;
  GDosyaUzantilari[3] := FILE_FILTER_DOCX;
  GDosyaUzantilari[4] := FILE_FILTER_ODT;
  GDosyaUzantilari[5] := FILE_FILTER_ODS;
  GDosyaUzantilari[6] := FILE_FILTER_PDF;
  GDosyaUzantilari[7] := FILE_FILTER_XML;
  GDosyaUzantilari[8] := FILE_FILTER_PNG;
  GDosyaUzantilari[9] := FILE_FILTER_JPG;
  GDosyaUzantilari[10] := FILE_FILTER_BMP;
  GDosyaUzantilari[11] := FILE_FILTER_FR3;
  GDosyaUzantilari[12] := FILE_FILTER_EXE;
  GDosyaUzantilari[13] := FILE_FILTER_BAK;
  GDosyaUzantilari[14] := FILE_FILTER_TXT;
  GDosyaUzantilari[15] := FILE_FILTER_DXF;
  GDosyaUzantilari[16] := FILE_FILTER_DWG;


  GDataBase := TDatabase.Create;

finalization
  SetLength(GDosyaUzantilari, 0);
  GDataBase.Free;
  GSysKullanici.Free;
  GSysOndalikHane.Free;
  GSysUygulamaAyari.Free;
  GSysUygulamaAyariDiger.Free;
  GSysLisan.Free;
  GSysGun.Free;
  GSysAy.Free;
  GParaBirimi.Free;
  GSysTableInfo.Free;
end.

