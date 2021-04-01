unit Ths.Erp.Database.Connection.Settings;

interface

{$I ThsERP.inc}

uses
  Vcl.Forms, System.Types, System.SysUtils, System.IniFiles, System.Classes, System.StrUtils;

type
  TLangs = class
  private
    FLang: string;
    FLangList: TStringList;
  public
    destructor Destroy; override;
    property Lang: UnicodeString read FLang write FLang;
    property LangList: TStringList read FLangList write FLangList;
    constructor Create;
    procedure ReadFromFile();
  end;

  TLoginText = class
  private
    FLang: string;
    FUser: string;
    FUserPass: string;
    FDBUser: string;
    FDBPass: string;
    FServer: string;
    FExample: string;
    FDBName: string;
    FDBPort: string;
    FSaveSettings: string;
    FThemeName: string;
  public
    property Lang: UnicodeString read FLang write FLang;
    property User: UnicodeString read FUser write FUser;
    property UserPass: UnicodeString read FUserPass write FUserPass;
    property DBUser: UnicodeString read FDBUser write FDBUser;
    property DBPass: UnicodeString read FDBPass write FDBPass;
    property Server: UnicodeString read FServer write FServer;
    property Example: UnicodeString read FExample write FExample;
    property DBName: UnicodeString read FDBName write FDBName;
    property DBPort: UnicodeString read FDBPort write FDBPort;
    property SaveSettings: UnicodeString read FSaveSettings write FSaveSettings;
    property ThemeName: UnicodeString read FThemeName write FThemeName;

    procedure ReadFromFile(pLang: string);
  end;

  TConnSettings = class
  private
    FLanguage: string;
    FDBUserPassword: UnicodeString;
    FDBPortNo: Integer;
    FDBUserName: UnicodeString;
    FSQLServer: UnicodeString;
    FDatabaseName: UnicodeString;
    FAppName: UnicodeString;
    FUserName: UnicodeString;
    FUserPass: UnicodeString;
    FTheme: UnicodeString;
  protected
  public
    property Language: UnicodeString read FLanguage write FLanguage;
    property SQLServer: UnicodeString read FSQLServer write FSQLServer;
    property DatabaseName: UnicodeString read FDatabaseName write FDatabaseName;
    property DBUserName: UnicodeString read FDBUserName write FDBUserName;
    property DBUserPassword: UnicodeString read FDBUserPassword write FDBUserPassword;
    property DBPortNo: Integer read FDBPortNo write FDBPortNo;
    property AppName: UnicodeString read FAppName write FAppName;
    property UserName: UnicodeString read FUserName write FUserName;
    property UserPass: UnicodeString read FUserPass write FUserPass;
    property Theme: UnicodeString read FTheme write FTheme;

    procedure ReadFromFile();
    procedure SaveToFile(AOnlyTheme: Boolean = False);
  end;

implementation

uses
    Ths.Erp.Constants
  , Ths.Erp.Globals
  ;

procedure TConnSettings.ReadFromFile();
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create(GUygulamaAnaDizin + PATH_SETTINGS + '\' + 'GlobalSettings.ini');
  try
    Self.FLanguage       := iniFile.ReadString('ConnectionSettings', 'Language', '');
    Self.FSQLServer      := iniFile.ReadString('ConnectionSettings', 'SQLServer', '');
    Self.FDatabaseName   := iniFile.ReadString('ConnectionSettings', 'DatabaseName', '');
    Self.FDBUserName     := iniFile.ReadString('ConnectionSettings', 'DBUserName', '');
    Self.FDBUserPassword := DecryptStr(iniFile.ReadString('ConnectionSettings', 'DBUserPassword', ''), 22222);
    Self.DBPortNo        := iniFile.ReadInteger('ConnectionSettings', 'DBPortNo', 0);
    Self.FUserName       := iniFile.ReadString('ConnectionSettings', 'UserName', '');
    Self.FUserPass       := DecryptStr(iniFile.ReadString('ConnectionSettings', 'UserPass', ''), 22222);
    Self.FTheme      := iniFile.ReadString('ConnectionSettings', 'Theme', '');
  finally
    iniFile.Free;
  end;
end;

procedure TConnSettings.SaveToFile(AOnlyTheme: Boolean);
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create(GUygulamaAnaDizin + 'Settings' + '\' + 'GlobalSettings.ini');
  try
    if AOnlyTheme then
    begin
      iniFile.WriteString('ConnectionSettings', 'Theme', Self.FTheme);
      Exit;
    end;
    iniFile.WriteString('ConnectionSettings', 'Language', Self.FLanguage);
    iniFile.WriteString('ConnectionSettings', 'SQLServer', Self.FSQLServer);
    iniFile.WriteString('ConnectionSettings', 'DatabaseName', Self.FDatabaseName);
    iniFile.WriteString('ConnectionSettings', 'DBUserName', Self.FDBUserName);
    iniFile.WriteString('ConnectionSettings', 'DBUserPassword', EncryptStr(FDBUserPassword, 22222));
    iniFile.WriteInteger('ConnectionSettings', 'DBPortNo', Self.FDBPortNo);
    iniFile.WriteString('ConnectionSettings', 'UserName', Self.FUserName);
    iniFile.WriteString('ConnectionSettings', 'UserPass', EncryptStr(FUserPass, 22222));
    iniFile.WriteString('ConnectionSettings', 'Theme', Self.FTheme);
  finally
    iniFile.Free;
  end;
end;

constructor TLangs.Create();
begin
  LangList := TStringList.Create;
end;

destructor TLangs.Destroy;
begin
  FLangList.Free;

  inherited;
end;

procedure TLangs.ReadFromFile;
var
  iniFile: TIniFile;
  vList: TStringDynArray;
  n1: Integer;
begin
  iniFile := TIniFile.Create(GUygulamaAnaDizin + PATH_SETTINGS + '\' + 'GlobalSettings.ini');
  try
    Self.FLang := iniFile.ReadString('Langs', 'Lang', '');
    vList := SplitString(FLang, ',');
    for n1 := 0 to Length(vList)-1 do
      LangList.Add(vList[n1]);
  finally
    iniFile.Free;
  end;
end;

procedure TLoginText.ReadFromFile(pLang: string);
var
  iniFile: TIniFile;
  vLangVal: string;
begin
  iniFile := TIniFile.Create(GUygulamaAnaDizin + PATH_SETTINGS + '\' + 'GlobalSettings.ini');
  try
    if pLang = '' then
      vLangVal := 'Türkçe TR'
    else
      vLangVal := pLang;
    Self.FLang         := iniFile.ReadString(vLangVal, 'Lang', '');
    Self.FUser         := iniFile.ReadString(vLangVal, 'User', '');
    Self.FUserPass     := iniFile.ReadString(vLangVal, 'UserPass', '');
    Self.FDBUser       := iniFile.ReadString(vLangVal, 'DBUser', '');
    Self.FDBPass       := iniFile.ReadString(vLangVal, 'DBPass', '');
    Self.FServer       := iniFile.ReadString(vLangVal, 'Server', '');
    Self.FExample      := iniFile.ReadString(vLangVal, 'Example', '');
    Self.FDBName       := iniFile.ReadString(vLangVal, 'DBName', '');
    Self.FDBPort       := iniFile.ReadString(vLangVal, 'DBPort', '');
    Self.FSaveSettings := iniFile.ReadString(vLangVal, 'SaveSettings', '');
    Self.FThemeName    := iniFile.ReadString(vLangVal, 'ThemeName', '');
  finally
    iniFile.Free;
  end;
end;

end.
