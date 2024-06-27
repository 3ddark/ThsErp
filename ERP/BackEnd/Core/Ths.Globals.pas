unit Ths.Globals;

interface

uses
  System.Classes, System.Types, System.Variants, System.SysUtils,
  System.StrUtils, System.DateUtils, System.Math, System.UITypes, System.IOUtils,
  System.Generics.Collections, System.RTTI, System.TypInfo, System.Hash,
  System.AnsiStrings, System.Net.HttpClientComponent, Xml.XMLIntf, Xml.XMLDoc,
  Winapi.Windows, Winapi.Messages, Winapi.IpTypes, Winapi.IpHlpApi,
  Winapi.TlHelp32, Winapi.PsAPI, Winapi.ShellAPI, Winapi.WinInet, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Dialogs, Vcl.Grids, Vcl.Graphics, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Data.DB, Vcl.DBGrids, Data.FmtBcd,
  IdGlobal, IdFTP, IdFTPCommon, IdAntiFreeze, IdHash, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Phys.PGDef, FireDAC.Comp.Client, FireDAC.Phys.PG,
  FireDAC.Comp.DataSet, Ths.Database, Ths.Constants, Ths.Utils.Logger,
  Ths.Helper.ThsList, Ths.Database.Table, Ths.Database.Table.SysKullanicilar,
  Ths.Database.Table.SysOndalikHaneler, Ths.Database.Table.SysUygulamaAyarlari,
  Ths.Database.Table.SysAylar, Ths.Database.Table.SysParaBirimleri,
  Ths.Database.Table.SysGridKolonlar,
  Ths.Database.Table.SysGridFiltrelerSiralamalar,
  Ths.Database.Table.SysGuiIcerikler, Ths.Database.Table.View.SysViewColumns;

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

  TMukellefTipi = (TCKN, VKN);

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
  TTotal = record
    Fiyat: Double;
    Miktar: Double;
    Tutar: Double;
    NetFiyat: Double;
    NetTutar: Double;
    IskontoTutar: Double;
    KDVTutar: Double;
    ToplamTutar: Double;
  end;

type
  TLang = record
    StatusAccept: string;
    StatusAdd: string;
    StatusCancel: string;
    StatusDelete: string;
    StatusOpacity: string;
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

  function ReplaceToRealColOrTableName(const ATableName: string): string;
  function ReplaceRealColOrTableNameTo(const ATableName: string): string;
  function getFormCaptionByLang(pFormName, pDefaultVal: string): string;

  function CalculateTotalValues(AFiyat, AMiktar, AIskontoOrani, AKDVOrani: Double): TTotal;

  function ColumnFromIDCol(pRawTableColName, pRawTableName, pDataColName,
      pVirtualColName, pDataTableName: string; pIsIDReference: Boolean = True; pIsNumericVal: Boolean = False): string;
  function TranslateText(ADefault, ACode, ATip: string; ATable: string=''; ALang: string=''): string;

  function FormatedVariantVal(pType: TFieldType; pVal: Variant): Variant; overload;
  function FormatedVariantVal(pField: TFieldDB): Variant; overload;

  function GetTempFolder(): string;


  /// <summary>
  ///   Framework içinde kullanılan sabit dil içeriklieri için bilgilerin olduğu record.
  /// </summary>
  /// <remarks>
  ///   Burada framework içinde kullanılan ve tekrar eden dil database tablosundan
  ///   Çekilecek olan datalar için sabit bilgiler yazıldı.
  /// </remarks>
  function FrameworkLang: TLang;

  /// <summary>
  ///   Birden fazla sLineBreak eklemek için kullanılır.
  /// </summary>
  /// <remarks>
  ///   Birden fazla sLineBreak kullanılmak istenildiğinde bu fonksiyon yardımcı oluyor.
  ///  3 tane slinebreak yazmak yerine bu fonksiyonu kullanabilirsin.
  ///  slinebreak + slinebreak + slinebreak
  /// </remarks>
  /// <example>
  ///   AddLBs(3)
  /// </example>
  function AddLBs(pCount: Integer = 1): string;

  /// <summary>
  ///   Butonların başlıklarını özelleştirebildiğimiz Mesaj ekranı
  /// </summary>
  /// <remarks>
  ///   Buton başlıklarını özelleştirilebildiğimiz özel MesajDiaglog formu.
  ///  Mesaj, Başlık, Buton Yazıları gibi herşeyi istediğimiz şekilde yazabildiğimiz
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

  function TrimCustom(const S: string; const AChar: Char): string;
  function TrimLeftCustom(const S: string; const AChar: Char): string;
  function TrimRightCustom(const S: string; const AChar: Char): string;

  function IsNumeric(const S: string): Boolean;
  procedure TutarHesapla(const fiyat: double; const miktar: double; const iskontoOrani: double; const kdvOrani: double; out tutar: double; out netFiyat: double; out iskontoTutar: double; out kdvTutar: double; out toplamTutar: double; ondalikli_hane: integer);
  function SayiyiYaziyaCevir(Num: Double): string;
  function SayiyiYaziyaCevir2(tutar: double; tur: integer; tam_birim: string = 'TL'; ondalikli_birim: string = 'KRŞ'): string;
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
  ///  Belirtilen dosyayı ByteArray bilgi olarak geri dönderir
  ///  Dosya adı "C:\Test\asd.xml" gibi
  /// </summary>
  function FileToByteArray(const FileName: WideString): TArray<Byte>;

  /// <summary>
  ///  ByteArray bilgiyi verilen dosya adında kayıt eder.
  ///  Dosya adı "C:\Test\asd.xml" gibi
  /// </summary>
  procedure ByteArrayToFile(const ByteArray: TBytes; const FileName: string);

  /// <summary>
  ///   Dosya yolu ile birlikte verilen dosya adının disk boyutunu getirir. Bilgi Byte cinsinden gelir.
  ///   1MB için dönen değer 1000000 olarak gelir. 15KB için 15000 gibi
  /// </summary>
  {$IFDEF MSWINDOWS}
  function GetFileSize(pFileName: string): Int64;
  {$ENDIF MSWINDOWS}

  /// <summary>
  ///   Türkçe karakterlerde dahil olmak üzere verilen string bilgiyi büyük harfe çevirir. ı>I i>İ olur
  /// </summary>
  function UpperCaseTr(S: string): string;

  /// <summary>
  ///   Türkçe karakterlerde dahil olmak üzere verilen string bilgiyi küçük harfe çevirir. I>ı İ>i olur
  /// </summary>
  function LowerCaseTr(S: string): string;

  /// <summary>
  ///   Boolean bilgiyi string olarak döndürür. Boolean tip değeri True ise "TRUE" string döner False ise "FALSE" string döner
  /// </summary>
  function BoolToStr(ABool: Boolean; ABuyuk: Boolean = True): string;

  /// <summary>
  ///  işletim sistemi dpi bilgilerine göre girilen int degerin dpi ayarına göre hesaplanarak sonucunu getiriyor
  ///  Örn. Button.Widht := 100 ise ve işletim sistemi %150 kullanılıyorsa. Bu değerin 150 olması gerekiyor.
  ///  Normalde 96ppi ile proje geliştiriliyor. Fakat sistem %150 yapılınca 144ppi oluyor 144/96 = 1,5 oluyor.
  ///  Bu durumda 100 * 1,5 = 150 oluyor
  /// </summary>
  function scaleBySystemDPI(AVal: Integer): Integer;

  function CheckIntegerInArray(pArr: ArrayInteger; AKey: Integer): Boolean;
  function CheckStringInArray(pArr: TArray<string>; AKey: string): Boolean;
  function GetStrHashSHA512(Str: string): string;
  function GetFileHashSHA512(FileName: WideString): string;
  function GetStrFromHashSHA512(pString: WideString): string;

  /// <summary>
  ///   Verilen string bilgiyi girilen key ile şifreler
  /// </summary>
  /// <remarks>
  ///  <para>Kendi Anahtar değerimiz (0-65535 aralığındaki) ile bilgiyi şifrelemek için kullanılır.</para>
  ///  <para>Mesela kişisel verileri koruma kanunu gereği TC Kimlik No bilgisini şifreler.</para>
  ///  <para>Aşağıdaki örnek kod örnek olarak attığım TC Kimlik bilgisini şifreler</para>
  ///  <code lang="Delphi">EncryptStr('30850331144', 14257); //Sonuç: 040EF0D744DA01BA36DAE5</code>
  /// </remarks>
  function EncryptStr(const S, ASecureKey: string): string;

  /// <summary>
  ///   EncryptStr ile şifrelenen bilginin şifresini çözmek için Key ile birlikte şifreli bilgi girilir.
  ///   Gerçek bilgi geri döner
  /// </summary>
  /// <remarks>
  ///   <para>Kendi Anahtar değerimiz (0-65535 aralığıdaki) ile bilgiyi şifrelemek için kullanılır.</para>
  ///   <para>Mesela kişisel verileri koruma kanunu gereği şifrelenen TC Kimlik No bilgisini gerçek bilgiye çevirir.</para>
  ///   <para>Aşağıdaki örnek kod örnek olarak attığım şifrelenmiş TC Kimlik bilgisini gerçek bilgiye çevirir</para>
  ///   <code lang="Delphi">EncryptStr('040EF0D744DA01BA36DAE5', 14257); //Sonuç: 30850331144</code>
  /// </remarks>
  function DecryptStr(const S, ASecureKey: string): string;

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
  function GetDialogOpen(AFilter: string; Out AFileName: string; AInitialDir: string = ''): Boolean;
  function GetDialogDirectory(pInitialDir: string = ''): string;
  function GetDialogSave(pFileName, pFilter: string; pInitialDir: string = ''): string;
  function FTPDosyaAl(pSrcFile, pDesFile: TFileName; pFtp, pRemoteDir, pLogin, pPass: string): Boolean;

  /// <summary>
  ///   Get ProcessID By ProgramName (Include Path or Not Include)
  /// </summary>
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

  /// <summary>
  ///   Copy files with sub folder to dest folder
  /// </summary>
  /// <remarks>
  ///   Files Copy with SubFolder
  /// </remarks>
  procedure CopyFolder(ASrcPath, ADestPath: string);


  /// <summary>
  ///   Parametre girilen Tablo adı ve Tablodaki Column Name bilgisine göre
  ///  sys_lang_data tablosundan programın açılan dil ayarına göre column
  ///  bilgsini döndürüyor. Bu fonksiyon tek başına kullanılamaz.
  ///  Bu fonksiyon SQL SELECT kodları içinde kullanılır.
  ///  <param name="pBaseTableName">Database Table Name</param>
  ///  <param name="pBaseColName">Database Table Column Name</param>
  ///  <example>
  ///   <code lang="Delphi">getRawDataByLang(TableName, FBirim.FieldName)</code>
  ///   <code lang="Delphi">'SELECT ' + getRawDataByLang(TableName, FSourceGroup.FieldName) + ' FROM tbl_name'</code>
  ///  </example>
  /// </summary>
  function getRawDataByLang(pBaseTableName, pBaseColName: string): string;

  /// <summary>
  ///  İstenilen Query ye Parametre eklemek için kullanılıyor. Insert ve Update kodları içinde kullanılıyor.
  ///  <param name="AQuery">Zeos Query</param>
  ///  <param name="AField">FieldDB tipindeki Field</param>
  ///  <example>
  ///   <code lang="Delphi">NewParamForQuery(QryOfInsert, FBirim)</code>
  ///  </example>
  /// </summary>
  procedure NewParamForQuery(AQuery: TFDQuery; AField: TFieldDB);

  /// <summary>
  ///  Bu fonksiyon DBGrid üzerinde gösterilen sütunların genişlik değerini değiştirmek için kullanılır.
  ///  Yaptığı iş hızlıca <b>sys_grid_col_width</b> tablosundaki <b>column_width</b>
  ///  değerini hızlıca güncellemek için kullanılır. Açık DBGrid(output form)
  ///  ekranındaki sütun genişliğinin hızlıca görselden ayarlamak için bu fonksiyon yazildi.
  ///  <param name="pTableName">Database Table Name</param>
  ///  <param name="pColName">Database Table Column Name</param>
  ///  <param name="pColWidth">DBGrid Column Width</param>
  ///  <example>
  ///   <code lang="Delphi">UpdateColWidth(olcu_birimi, birim, 100)</code>
  ///  </example>
  /// </summary>
  function UpdateColWidth(ATableName: string; AGrid: TDBGrid): Boolean;

  function GetGridDefaultOrderFilter(AKey: string; AIsOrder: Boolean): string;
  function GetIsRequired(ATableName, AFieldName: string): Boolean;
  function GetMaxLength(ATableName, AFieldName: string): Integer;

  procedure FillColNameForColWidth(AComboBox: TComboBox; ATableName: string);
  procedure FillColNameForColSummary(AComboBox: TComboBox; ATableName: string);
  function GetDistinctColumnName(ATableName: string): TStringList;

  function ExistForm(AFormClassType: TClass): Boolean;

  function FormatMoney(AValue: Double): string;

  procedure SendMailWithMailClient(
     AMailClientAppPath: string;
     ATo: TArray<string>;
     ACC: TArray<string>;
     ABCC: TArray<string>;
     ASubject: string;
     ABodyText: string;
     AAttachedFiles: TArray<string>
  );

var
  /// <summary>
  ///  Application event log
  /// </summary>
  GLogger: TLogger;


  GDosyaUzantilari: TArray<string>;

  /// <summary>
  ///  Dialog pencereleri açıldığı zaman bazen ExtractFilePath(Application.ExeName) ile elde edilen Uygulama Path erişilemiyor.
  ///  Bir nedenle ExtractFilePath(Application.ExeName) path değişiyor. Nedeni birden fazla uygulama kopyası açılabiliyor.
  ///  Bu nedenle uygulama ilk açılışta Path bu değişkende tutluyor. Buradan kullanılacak.
  /// </summary>
  GUygulamaAnaDizin: string;

  /// <summary>
  ///  Database sınıfına ulaşılıyor. Bazı fonksiyonlar burada GetToday GetNow veya runCustomSQL gibi
  /// </summary>
  GDataBase: TDatabase;

  /// <summary>
  ///  Giriş yapan kullanıcı bilgilerine bu tablo bilgisinden ulaşıyor.
  ///  <example>
  ///   <code lang="Delphi">GSysKullanici.KullaniciAdi</code>
  ///  </example>
  /// </summary>
  GSysKullanici: TSysKullanici;

  /// <summary>
  ///  Virgüllü sayılarda hane sayısı değerlerine buradan ulaşılıyor. Bu ayara göre işlemler yapılacak.
  ///  <example>
  ///   <code lang="Delphi">GSysOndalikHane.SatisMiktar</code>
  ///  </example>
  /// </summary>
  GSysOndalikHane: TSysOndalikHane;

  /// <summary>
  ///  Uygulama ayarlarına bu tablo bilgisinden ulaşılıyor.
  ///  <example>
  ///   <code lang="Delphi">GSysUygulamaAyari.Unvan</code>
  ///  </example>
  /// </summary>
  GSysApplicationSetting: TSysUygulamaAyari;


  /// <summary>
  ///  Sistemde tanımlı olan para birimleri burada tutuluyor
  /// </summary>
  GParaBirimi: TSysParaBirimi;

  /// <summary>
  ///  Table sınıfındaki field özelliklerini almak için kullanılıyor.
  /// </summary>
  GSysTableInfo: TSysViewColumns;

  GGuiIcerik: TDictionary<string, TGuiIcerik>;

implementation

uses
  SynCommons, SynCrypto;

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
  Result := nil;
  RttiType := Context.GetType(Source.ClassType);

  //find a suitable constructor, though treat components specially
  IsComponent := (Source is TComponent);
  for Method in RttiType.GetMethods do
  begin
    if Method.IsConstructor then
    begin
      Params := Method.GetParameters;
      if Params = nil then
      begin
        Result := (Method.Invoke(Source.ClassType, []).AsType < T > );
        Break;
      end;
      if (Length(Params) = 1) and IsComponent and (Params[0].ParamType is TRttiInstanceType) and SameText(Method.Name, 'Create') then
      begin
        Result := (Method.Invoke(Source.ClassType, [TComponent(Source).Owner]).AsType < T > );
        Break;
      end;
    end;
  end;

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

function ReplaceToRealColOrTableName(const ATableName: string): string;
begin
  Result := StringReplace(ATableName, ' ', '_', [rfReplaceAll]);
  Result := System.SysUtils.LowerCase(Result);
end;

function ReplaceRealColOrTableNameTo(const ATableName: string): string;
var
  n1: Integer;
  vDump: string;
begin
  vDump := StringReplace(ATableName, '_', ' ', [rfReplaceAll]);

  if vDump = '' then
    Result := ''
  else
  begin
    Result := System.SysUtils.Uppercase(vDump[1]);
    for n1 := 2 to Length(vDump) do
    begin
      if vDump[n1-1] = ' ' then
        Result := Result + System.SysUtils.Uppercase(vDump[n1])
      else
        Result := Result + System.SysUtils.Lowercase(vDump[n1]);
    end;
  end;

end;

function getFormCaptionByLang(pFormName, pDefaultVal: string): string;
begin
  Result := TranslateText(pDefaultVal, pFormName, LngFormCaption);
end;

function CalculateTotalValues(AFiyat, AMiktar, AIskontoOrani, AKDVOrani: Double): TTotal;
begin
  Result.Fiyat := AFiyat;
  Result.Tutar := AFiyat * AMiktar;
  Result.NetFiyat := AFiyat * ((100-AIskontoOrani)/100);
  Result.NetTutar := Result.NetFiyat * AMiktar;
  Result.IskontoTutar := Result.Tutar - Result.NetTutar;
  Result.KDVTutar := Result.NetTutar * (AKDVOrani)/100;
  Result.ToplamTutar := Result.NetTutar + Result.KDVTutar;
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

//      //variant data uzunluğu > 10 olduğunda Datetime tipi olarak kabul et
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
  if (pType = Data.DB.ftFloat)
  or (pType = Data.DB.ftCurrency)
  or (pType = Data.DB.ftSingle)
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
      vSP.ExecProc;
      Result := vSP.ParamByName('result').AsString;

      Result :=
          'spget_lang_text' +
          '(' +
            '(SELECT raw' + pRawTableName + '.' + pRawTableColName + ' FROM ' + pRawTableName + ' as raw' + pRawTableName +
            ' WHERE raw' + pRawTableName + '.' + vRefColName + '=' + pDataTableName + '.' + pDataColName + ')' + ',' +
            QuotedStr(pRawTableName) + ',' +
            QuotedStr(pRawTableColName) + ', ' +
            pDataColName;
    finally
      vSP.Free;
    end;
  end;
end;

function TranslateText(ADefault, ACode, ATip: string; ATable: string; ALang: string): string;
var
  LItem: TGuiIcerik;
//  Query: TZQuery;
//  LFilter: string;
//  LGui: TSysLisanGuiIcerik;
begin
  Result := ADefault;
{
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
}
//  LItem :=
  if GGuiIcerik.TryGetValue(ACode, LItem) then
    Result := LItem.FDeger;

  if (ATip = LngMsgError) then
    Result := 'Hata Kodu = ' + ACode + AddLBs(2) + Result;
//  finally
//    LGui.Free;
//  end;
end;

function GetTempFolder: string;
begin
  Result := TPath.GetTempPath;
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
    Result.StatusOpacity := '190';

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

      //font değiştir
      vDlgButton.Font.Name := fontName;
      //custom caption ata
      vDlgButton.Caption := pCaptions[nCaption];
      //yazıya göre buton genişliğini ayarla
      vDlgButton.Width := Max(vMsgDlg.Canvas.TextWidth(vDlgButton.Caption) + (8 * 2), 75);

      LTotalBtnWidth :=  LTotalBtnWidth + vDlgButton.Width;

      //butonların arasında 8 boşluk bırak
      //soldan da 8 boşluk için +8 yapıyoruz
      if nCaption = 0 then
        widthTotal := 8;
      widthTotal := widthTotal + vDlgButton.Width + 12;
      Inc(nCaption);

      //butonların left pozisyonlarını ayarlamak için array içinde tutuyoruz
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
  BIRLER: array[0..9] of string = ('', 'BİR ', 'İKİ ', 'ÜÇ ', 'DÖRT ', 'BEŞ ', 'ALTI ', 'YEDİ ', 'SEKİZ ', 'DOKUZ ');
  ONLAR: array[0..9] of string = ('', 'ON ', 'YİRMİ ', 'OTUZ ', 'KIRK ', 'ELLİ ', 'ALTMIŞ ', 'YETMİŞ ', 'SEKSEN ', 'DOKSAN ');
  DIGER: array[0..5] of string = ('', 'BİN ', 'MİLYON ', 'MİLYAR ', 'TRİLYON ', 'KATRİLYON ');

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

function SayiyiYaziyaCevir2(tutar: double; tur: integer; tam_birim: string = 'TL'; ondalikli_birim: string = 'KRŞ'): string;
const
  b1: array[1..9] of string = ('BİR', 'İKİ', 'ÜÇ', 'DÖRT', 'BEŞ', 'ALTI', 'YEDİ', 'SEKİZ', 'DOKUZ');
  b2: array[1..9] of string = ('ON', 'YİRMİ', 'OTUZ', 'KIRK', 'ELLİ', 'ALTMIŞ', 'YETMİŞ', 'SEKSEN', 'DOKSAN');
  b3: array[1..6] of string = ('KATRİLYON', 'TRİLYON', 'MİLYAR', 'MİLYON', 'BİN', '');
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
  tutart := stringofchar('0', (18 - (length(System.SysUtils.trim(tutart))))) + tutart;
  tutark := tutark + stringofchar('0', (2 - (length(System.SysUtils.trim(tutark)))));

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

    if Length(System.SysUtils.Trim(sn[l])) <> 0 then
      sn[l] := sn[l] + b3[l];
  end;

  if sn[5] = 'BİRBİN' then
    sn[5] := 'BİN';

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
    TPermissionType.ptRead: Result := 'OKUMA';
    TPermissionType.ptAddRecord: Result := 'KAYIT EKLEME';
    TPermissionType.ptUpdate: Result := 'GÜNCELLEME';
    TPermissionType.ptDelete: Result := 'KAYIT SİLME';
    TPermissionType.ptSpecial: Result := 'ÖZEL HAK';
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

function GetDialogOpen(AFilter: string; Out AFileName: string; AInitialDir: string = ''): Boolean;
var
  LOpenDialog: TOpenDialog;
begin
  Result := False;

  LOpenDialog := TOpenDialog.Create(nil);
  try
    if AInitialDir = '' then
      LOpenDialog.InitialDir := '%USERPROFILE%\desktop';
    LOpenDialog.Filter := AFilter;
    if LOpenDialog.Execute(Application.Handle) then
    begin
      Result := True;
      AFileName := LOpenDialog.FileName;
    end;
  finally
    LOpenDialog.Free;
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
  LFiles: TArray<string>;
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
function CheckIntegerInArray(pArr: ArrayInteger; AKey: Integer): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 0 to Length(pArr) - 1 do
  begin
    if AKey = pArr[n1] then
      Result := True;
    Exit;
  end;
end;

function CheckStringInArray(pArr: TArray<string>; AKey: string): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 0 to Length(pArr) - 1 do
  begin
    if AKey = pArr[n1] then
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
    Key := #0; //sadece sayı ve virgülle backspace kabul et
  end
  else if (Key = FormatSettings.DecimalSeparator) and (Pos(Key, TStringGrid(Sender).Cells[TStringGrid(Sender).Col, TStringGrid(Sender).Row]) > 0) then
  begin
    Key := #0; //ikinci virgülü alma
  end
  else if (Key = FormatSettings.DecimalSeparator) and (Length(TStringGrid(Sender).Cells[TStringGrid(Sender).Col, TStringGrid(Sender).Row]) = 0) then
  begin
    Key := #0; //, ile başlatma
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
    Count := System.FileSize(F);
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
  Result := AnsiUpperCase(StringReplace(StringReplace(S, 'ı', 'I', [rfReplaceAll]), 'i', 'İ', [rfReplaceAll]));
end;

function LowerCaseTr(S: string): string;
begin
  Result := AnsiLowerCase(StringReplace(StringReplace(S, 'I', 'ı', [rfReplaceAll]), 'İ', 'i', [rfReplaceAll]));
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
  HashSHA: System.Hash.THashSHA2;
begin
  HashSHA := System.Hash.THashSHA2.Create;
  HashSHA.GetHashString(Str);
  Result := HashSHA.GetHashString(Str, System.Hash.SHA512);
end;

function GetFileHashSHA512(FileName: WideString): string;
var
  HashSHA: THashSHA2;
  Stream: TStream;
  Readed: Integer;
  Buffer: PByte;
  BufLen: Integer;
begin
  HashSHA := THashSHA2.Create(System.Hash.SHA512);
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
  HashSHA := THashSHA2.Create(System.Hash.SHA512);
  HashSHA.Update(pString);
  Result := HashSHA.GetHashString(pString);
end;

function EncryptStr(const S, ASecureKey: string): string;
var
  LData: RawByteString;
  LPass: RawByteString;
  LEncrptedData: RawByteString;
begin
  try
    LData := StringToUTF8(S);
    LPass := StringToUTF8(ASecureKey);
    LEncrptedData := BinToBase64(AESSHA256(LData, LPass, True));
    Result := UTF8ToString(LEncrptedData);
  except
    Result := '';
  end;
end;

function DecryptStr(const S, ASecureKey: string): string;
var
  LData: RawByteString;
  LPass: RawByteString;
  LEncrptedData: RawByteString;
begin
  try
    LData := Base64ToBin(StringToUTF8(S));
    LPass := StringToUTF8(ASecureKey);
    LEncrptedData := AESSHA256(LData, LPass, False);
    Result := UTF8ToString(LEncrptedData);
  except
    Result := '';
  end;
end;

function FTPDosyaAl(pSrcFile, pDesFile: TFileName; pFtp, pRemoteDir, pLogin, pPass: string): Boolean;
var
  vFtp: TIdFTP;
  vIDAntiFreeze: TIDAntiFreeze;
begin
  //uses IdFTP, IdFTPCommon, IdAntiFreeze

  vFtp := TIdFTP.Create(nil);
  vIDAntiFreeze := TIDAntiFreeze.Create(nil); // büyük dosyalar inerken donma olmasın
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
    //free edilme olayı test edilmedi
    vFtp.Free;
    vIDAntiFreeze.Free;
  end;

//kullanım örnek
{
  //başarı ile ftp alırsa
  if TSpecialFunctions.FTPDosyaAl('vsd.jpg', 'c:\vsd.jpg', 'ftp.domain.com', 'public_html/uploads/', 'fpt_url@domain.com', 'P@ssw0rd123!') then
  begin
    //dosya başarılı bir şekilde indikten sonra yapılacak olan işlemler
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
      if (System.SysUtils.UpperCase(System.SysUtils.StrPas(APath)) = System.SysUtils.UpperCase(APName)) or (System.SysUtils.UpperCase(StrPas(ProcessEntry32.szExeFile)) = System.SysUtils.UpperCase(APName)) then
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

procedure NewParamForQuery(AQuery: TFDQuery; AField: TFieldDB);
begin
  AQuery.Params.ParamByName(AField.FieldName).DataType := AField.DataType;
  AQuery.Params.ParamByName(AField.FieldName).Value := FormatedVariantVal(AField);

  if AField.DataType = ftBytes then
  begin

  end;

  if AField.IsNullable then
  begin
    if (AField.DataType = ftString)
    or (AField.DataType = ftMemo)
    or (AField.DataType = ftWideString)
    or (AField.DataType = ftWideMemo)
    or (AField.DataType = ftWord)
    then
    begin
      if AQuery.Params.ParamByName(AField.FieldName).Value = '' then
        AQuery.Params.ParamByName(AField.FieldName).Value := Null
    end
    else
    if (AField.DataType = ftSmallint)
    or (AField.DataType = ftShortint)
    or (AField.DataType = ftInteger)
    or (AField.DataType = ftLargeint)
    or (AField.DataType = ftByte)
    then
    begin
      if AQuery.Params.ParamByName(AField.FieldName).AsInteger = 0 then
        AQuery.Params.ParamByName(AField.FieldName).Value := Null
    end
    else if (AField.DataType = ftDate) then
    begin
      if AQuery.Params.ParamByName(AField.FieldName).AsDate = 0 then
        AQuery.Params.ParamByName(AField.FieldName).Value := Null
    end
    else if (AField.DataType = ftDateTime) then
    begin
      if AQuery.Params.ParamByName(AField.FieldName).AsDateTime = 0 then
        AQuery.Params.ParamByName(AField.FieldName).Value := Null
    end
    else
    if (AField.DataType = ftTime)
    or (AField.DataType = ftTimeStamp)
    then
    begin
      if AQuery.Params.ParamByName(AField.FieldName).AsTime = 0 then
        AQuery.Params.ParamByName(AField.FieldName).Value := Null;
    end
    else
    if (AField.DataType = Data.DB.ftFloat)
    or (AField.DataType = Data.DB.ftCurrency)
    or (AField.DataType = Data.DB.ftSingle)
    or (AField.DataType = Data.DB.ftBCD)
    or (AField.DataType = Data.DB.ftFMTBcd)
    then
    begin
      if AQuery.Params.ParamByName(AField.FieldName).Value = 0 then
        AQuery.Params.ParamByName(AField.FieldName).Value := Null;
    end
    else if (AField.DataType = ftBlob) then
    begin
      if AQuery.Params.ParamByName(AField.FieldName).Value = 0 then
        AQuery.Params.ParamByName(AField.FieldName).Value := Null;
    end;


    if AQuery.Params.ParamByName(AField.FieldName).Value = Null then
      AQuery.Params.ParamByName(AField.FieldName).DataType := AField.DataType;
  end;
end;

function UpdateColWidth(ATableName: string; AGrid: TDBGrid): Boolean;
var
  LColWidth: TSysGridKolon;
  n1, n2, nNo: Integer;
begin
  Result := True;
  LColWidth := TSysGridKolon.Create(GDataBase);
  LColWidth.Database.Connection.StartTransaction;
  try
    try
      LColWidth.Clear;
      LColWidth.SelectToList(' AND ' + LColWidth.TabloAdi.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(ATableName)), False, False);

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
            TSysGridKolon(LColWidth.List[n2]).KolonGenislik.Value := AGrid.Columns[n1].Width;
            TSysGridKolon(LColWidth.List[n2]).SiraNo.Value := nNo+1;
            TSysGridKolon(LColWidth.List[n2]).Update(False);
            Inc(nNo);
            Break;
          end;
    except
      Result := False;
      if LColWidth.Database.Connection.InTransaction then
        LColWidth.Database.Connection.Rollback;
    end;
  finally
    if LColWidth.Database.Connection.InTransaction then
      LColWidth.Database.Connection.Commit;
    LColWidth.Free;
  end;
end;

function GetGridDefaultOrderFilter(AKey: string; AIsOrder: Boolean): string;
var
  LSysOrderFilter: TSysGridFiltreSiralama;
  vOrderFilter: string;
begin
  Result := '';
  LSysOrderFilter := TSysGridFiltreSiralama.Create(GDataBase);
  try
    if AIsOrder then
      vOrderFilter := ' AND ' + LSysOrderFilter.IsSiralama.QryName + '=True'
    else
      vOrderFilter := ' AND ' + LSysOrderFilter.IsSiralama.QryName + '=False';

    LSysOrderFilter.SelectToList(vOrderFilter + ' AND ' + LSysOrderFilter.TabloAdi.QryName + '=' + QuotedStr(AKey), False, False);
    if LSysOrderFilter.List.Count=1 then
      Result := TSysGridFiltreSiralama(LSysOrderFilter.List[0]).Icerik.Value;
  finally
    LSysOrderFilter.Free;
  end;

  if System.SysUtils.Trim(Result) <> '' then
    if not AIsOrder then
      Result := ' AND ' + Result;
end;

function GetIsRequired(ATableName, AFieldName: string): Boolean;
var
  LSysInputGui: TSysViewColumns;
begin
  Result := False;

  LSysInputGui := TSysViewColumns.Create(GDataBase);
  try
    LSysInputGui.SelectToList(' AND ' + LSysInputGui.TabloAdi.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(ATableName)) +
                              ' AND ' + LSysInputGui.ColumnName.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(AFieldName)), False, False);
    if LSysInputGui.List.Count=1 then
      Result := not TSysViewColumns(LSysInputGui.List[0]).IsNullable.Value;
  finally
    LSysInputGui.Free;
  end;
end;

function GetMaxLength(ATableName, AFieldName: string): Integer;
var
  LSysInputGui: TSysViewColumns;
begin
  Result := 0;

  LSysInputGui := TSysViewColumns.Create(GDataBase);
  try
    LSysInputGui.SelectToList(' AND ' + LSysInputGui.TabloAdi.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(ATableName)) +
                              ' AND ' + LSysInputGui.ColumnName.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(AFieldName)), False, False);
    if LSysInputGui.List.Count=1 then
      Result := TSysViewColumns(LSysInputGui.List[0]).CharacterMaximumLength.Value;
  finally
    LSysInputGui.Free;
  end;
end;

function GetDistinctColumnName(ATableName: string): TStringList;
var
  LCol: TSysViewColumns;
  LColWidth: TSysGridKolon;
  LQry: TFDQuery;
begin
  Result := TStringList.Create;

  LCol := TSysViewColumns.Create(GDataBase);
  LColWidth := TSysGridKolon.Create(GDataBase);
  LQry := GDataBase.NewQuery;
  try
    Result.BeginUpdate;
    LQry.Close;
    LQry.SQL.Text := 'SELECT DISTINCT ' + LCol.ColumnName.FieldName + ' FROM ' + LCol.TableName +
                ' LEFT JOIN ' + LColWidth.TableName + ' ON '
                              + LColWidth.TabloAdi.FieldName + '=' + LCol.TabloAdi.FieldName +
                      ' AND ' + LColWidth.KolonAdi.FieldName + '=' + LCol.ColumnName.FieldName +
                ' WHERE ' + LCol.TabloAdi.FieldName + '=' + QuotedStr(ATableName) +
                  ' AND ' + LColWidth.KolonAdi.FieldName + ' IS NULL ';
    LQry.Open;
    while NOT LQry.Eof do
    begin
      Result.Add( LQry.Fields.Fields[0].AsString );
      LQry.Next;
    end;
    LQry.EmptyDataSet;
    LQry.Close;
  finally
    LQry.Free;
    LCol.Free;
    LColWidth.Free;
    Result.EndUpdate;
  end;
end;

procedure FillColNameForColWidth(AComboBox: TComboBox; ATableName: string);
begin
  AComboBox.Clear;

  with GDataBase.NewQuery do
  try
    Close;
    SQL.Text := 'SELECT distinct v.column_name, ordinal_position FROM sys_view_columns v ' +
                'LEFT JOIN sys_grid_kolon a ON a.table_name=v.table_name and a.column_name = v.column_name ' +
                'WHERE v.table_name=' + QuotedStr(ATableName) + ' and a.column_name is null ' +
                'GROUP BY v.column_name, ordinal_position ' +
                'ORDER BY ordinal_position ASC ';
    Open;
    while NOT EOF do
    begin
      AComboBox.Items.Add( Fields.Fields[0].AsString );
      Next;
    end;
    EmptyDataSet;
    Close;
  finally
    Free;
  end;
end;

procedure FillColNameForColSummary(AComboBox: TComboBox; ATableName: string);
begin
  AComboBox.Clear;

  with GDataBase.NewQuery do
  try
    Close;
    SQL.Text := 'SELECT distinct v.column_name, ordinal_position FROM sys_view_columns v ' +
                'LEFT JOIN sys_grid_kolon a ON a.tablo_adi=v.table_name and a.kolon_adi = v.column_name ' +
                'WHERE v.table_name=' + QuotedStr(ATableName) + ' and a.kolon_adi is null ' +
                'GROUP BY v.column_name, ordinal_position ' +
                'ORDER BY ordinal_position ASC ';
    Open;
    while NOT EOF do
    begin
      AComboBox.Items.Add( Fields.Fields[0].AsString );
      Next;
    end;
    EmptyDataSet;
    Close;
  finally
    Free;
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
                        StringOfChar('0', VarToInt(GSysOndalikHane.Fiyat.Value)), AValue);
end;

procedure SendMailWithMailClient(
  AMailClientAppPath: string;
  ATo: TArray<string>;
  ACC: TArray<string>;
  ABCC: TArray<string>;
  ASubject: string;
  ABodyText: string;
  AAttachedFiles: TArray<string>
);
type
  TMailApp = (Outlook, Thunderbird);

var
  LParams: string;
  LTO, LCC, LBCC: string;
  LFiles: string;
  n1: Integer;
  LDelimeter: string;
  LMailApp: TMailApp;
begin
  if not FileExists(AMailClientAppPath) then
    raise Exception.Create('Uygulama dosya yolu hatalı.' + sLineBreak + AMailClientAppPath);

  for n1 := 0 to Length(AAttachedFiles)-1 do
    if not FileExists(AAttachedFiles[n1]) then
      raise Exception.Create('Dosya eki verilen "' + AAttachedFiles[n1] + '" konumda bulunamadı!');

  LDelimeter := '';
  LMailApp := TMailApp.Outlook;
  if System.SysUtils.LowerCase(ExtractFileName(AMailClientAppPath)) = System.SysUtils.LowerCase('outlook.exe') then
  begin
    LMailApp := TMailApp.Outlook;

    //outlook cli ile sadece tek ek eklenebiliyor
    if Length(AAttachedFiles) > 1 then
      raise Exception.Create('Outlook CLI ile sadece 1 tane ek dosya kabul ediyor. 20.12.2021');

    LDelimeter := ';'
  end
  else if System.SysUtils.LowerCase(ExtractFileName(AMailClientAppPath)) = System.SysUtils.LowerCase('thunderbird.exe') then
  begin
    LMailApp := TMailApp.Thunderbird;
    LDelimeter := ',';
  end;


  LTO := '';
  for n1 := 0 to Length(ATo)-1 do
    LTO := LTO + ATo[n1] + LDelimeter;
  if LTO <> '' then
    LTO := LeftStr(LTO, Length(LTO)-1);

  LCC := '';
  for n1 := 0 to Length(ACC)-1 do
    LCC := LCC + ACC[n1] + LDelimeter;
  if LCC <> '' then
    LCC := LeftStr(LCC, Length(LCC)-1);

  LBCC := '';
  for n1 := 0 to Length(ABCC)-1 do
    LBCC := LBCC + ABCC[n1] + LDelimeter;
  if LBCC <> '' then
    LBCC := LeftStr(LBCC, Length(LBCC)-1);


  if LMailApp = TMailApp.Outlook then
  begin
    LFiles := '';
    if Length(AAttachedFiles) > 0 then
      LFiles := AAttachedFiles[0];

    //OUTLOOK.EXE /m "john@doe.com;jane@doe.com&cc=baby@doe.com&&subject=Hi&body=Hello Body" /a "c:\temp\file.txx"
    LParams := Format(' /m "%s&cc=%s&bcc=%s&subject=%s&body=%s" /a "%s"', [LTO, LCC, LBCC, ASubject, ABodyText, LFiles]);
    ShellExecute(0, 'open', PWideChar(AMailClientAppPath), PWideChar(LParams), nil, SW_SHOWNORMAL)
  end
  else if LMailApp = TMailApp.Thunderbird then
  begin
    LFiles := '';
    for n1 := 0 to Length(AAttachedFiles)-1 do
      LFiles := LFiles + AAttachedFiles[n1] + LDelimeter;
    if LFiles <> '' then
      LFiles := LeftStr(LFiles, Length(LFiles)-1);

    //thunderbird.exe -compose "to='john@doe.com,jane@doe.com',cc='baby@doe.com',subject='Hi',body='Hello Body',attachment='C:\temp\1.doc,C:\temp\2.txt'"
    LParams := Format(' -compose "to=' + QuotedStr('%s') +
                                ',cc=' + QuotedStr('%s') +
                                ',bcc=' + QuotedStr('%s') +
                                ',subject=' + QuotedStr('%s') +
                                ',body=' + QuotedStr('%s') +
                                ',attachment=' + QuotedStr('%s') + '"', [LTO, LCC, LBCC, ASubject, ABodyText, LFiles]);
    ShellExecute(0, 'open', PWideChar(AMailClientAppPath), PWideChar(LParams), nil, SW_SHOWNORMAL)
  end;
end;

initialization
begin
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
end;

finalization
begin
  SetLength(GDosyaUzantilari, 0);
  GDataBase.Free;

  GSysKullanici.Free;
  GSysOndalikHane.Free;
  GSysApplicationSetting.Free;
  GParaBirimi.Free;
  GSysTableInfo.Free;
  GGuiIcerik.Free;
  GLogger.Free;
end;

end.
