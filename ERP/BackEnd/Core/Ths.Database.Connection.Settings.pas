unit Ths.Database.Connection.Settings;

interface

{$I Ths.inc}

uses
  Vcl.Forms, System.Types, System.SysUtils, System.IniFiles,
  System.Classes, System.StrUtils, Ths.Language.Cache;

type
  TConnSettings = class
  private
    FDBUserPassword : UnicodeString;
    FDBPortNo       : Integer;
    FDBUserName     : UnicodeString;
    FSQLServer      : UnicodeString;
    FDatabaseName   : UnicodeString;
    FAppName        : UnicodeString;
    FUserName       : UnicodeString;
    FUserPass       : UnicodeString;
    FTheme          : UnicodeString;
    FLanguage       : UnicodeString;
    function SettingsFilePath: string;
  public
    property SQLServer      : UnicodeString read FSQLServer      write FSQLServer;
    property DatabaseName   : UnicodeString read FDatabaseName   write FDatabaseName;
    property DBUserName     : UnicodeString read FDBUserName     write FDBUserName;
    property DBUserPassword : UnicodeString read FDBUserPassword write FDBUserPassword;
    property DBPortNo       : Integer       read FDBPortNo       write FDBPortNo;
    property AppName        : UnicodeString read FAppName        write FAppName;
    property UserName       : UnicodeString read FUserName       write FUserName;
    property UserPass       : UnicodeString read FUserPass       write FUserPass;
    property Theme          : UnicodeString read FTheme          write FTheme;
    property Language       : UnicodeString read FLanguage       write FLanguage;
    procedure ReadFromFile;
    procedure SaveToFile(AOnlyTheme: Boolean = False);
    procedure ReadSupportedLanguages(AList: TStrings);
    procedure SaveSupportedLanguages(const ALanguages: TArray<TLanguageInfo>);
  end;

implementation

uses
  Ths.Constants, Ths.Globals, LocalizationManager;

function TConnSettings.SettingsFilePath: string;
begin
  Result := GUygulamaAnaDizin + PATH_SETTINGS + '\GlobalSettings.ini';
end;

procedure TConnSettings.ReadFromFile;
var
  LIni: TMemIniFile;
begin
  LIni := TMemIniFile.Create(SettingsFilePath, TEncoding.UTF8);
  try
    FSQLServer      := LIni.ReadString ('ConnectionSettings', 'SQLServer',      '');
    FDatabaseName   := LIni.ReadString ('ConnectionSettings', 'DatabaseName',   '');
    FDBUserName     := LIni.ReadString ('ConnectionSettings', 'DBUserName',     '');
    FDBUserPassword := DecryptStr(LIni.ReadString('ConnectionSettings', 'DBUserPassword', ''), SECURE_KEY);
    FDBPortNo       := LIni.ReadInteger('ConnectionSettings', 'DBPortNo',       0);
    FUserName       := LIni.ReadString ('ConnectionSettings', 'UserName',       '');
    FUserPass       := DecryptStr(LIni.ReadString('ConnectionSettings', 'UserPass', ''), SECURE_KEY);
    FTheme          := LIni.ReadString ('ConnectionSettings', 'Theme',          '');
    FLanguage       := LIni.ReadString ('ConnectionSettings', 'Language',       'tr-TR');
  finally
    LIni.Free;
  end;
end;

procedure TConnSettings.SaveToFile(AOnlyTheme: Boolean);
var
  LIni: TMemIniFile;
begin
  LIni := TMemIniFile.Create(SettingsFilePath, TEncoding.UTF8);
  try
    LIni.WriteString('ConnectionSettings', 'Theme', FTheme);
    LIni.WriteString('ConnectionSettings', 'Language', FLanguage);

    if not AOnlyTheme then
    begin
      LIni.WriteString ('ConnectionSettings', 'SQLServer',      FSQLServer);
      LIni.WriteString ('ConnectionSettings', 'DatabaseName',   FDatabaseName);
      LIni.WriteString ('ConnectionSettings', 'DBUserName',     FDBUserName);
      LIni.WriteString ('ConnectionSettings', 'DBUserPassword', EncryptStr(FDBUserPassword, SECURE_KEY));
      LIni.WriteInteger('ConnectionSettings', 'DBPortNo',       FDBPortNo);
      LIni.WriteString ('ConnectionSettings', 'UserName',       FUserName);
      LIni.WriteString ('ConnectionSettings', 'UserPass',       EncryptStr(FUserPass, SECURE_KEY));
    end;

    LIni.UpdateFile;
  finally
    LIni.Free;
  end;
end;

procedure TConnSettings.ReadSupportedLanguages(AList: TStrings);
var
  LIni: TMemIniFile;
  LKeys: TStringList;
  LKey: string;
  LValue: string;
  LDisplayText: string;
begin
  if not Assigned(AList) then Exit;
  AList.Clear;

  if not FileExists(SettingsFilePath) then Exit;

  LIni := TMemIniFile.Create(SettingsFilePath, TEncoding.UTF8);
  LKeys := TStringList.Create;
  try
    LIni.ReadSection('SupportedLanguages', LKeys);
    for LKey in LKeys do
    begin
      // Must be supported on disk (localization JSON file exists)
      if not TLocalizationManager.LanguageFileExists(LKey) then
        Continue;

      LValue := LIni.ReadString('SupportedLanguages', LKey, '');
      if LValue <> '' then
        LDisplayText := Format('%s | %s', [LValue, LKey])
      else
        LDisplayText := LKey;
      AList.Add(LDisplayText);
    end;
  finally
    LKeys.Free;
    LIni.Free;
  end;
end;

procedure TConnSettings.SaveSupportedLanguages(const ALanguages: TArray<TLanguageInfo>);
var
  LIni: TMemIniFile;
  LLang: TLanguageInfo;
begin
  LIni := TMemIniFile.Create(SettingsFilePath, TEncoding.UTF8);
  try
    LIni.EraseSection('SupportedLanguages');

    for LLang in ALanguages do
    begin
      // Must be supported both in database AND on disk
      if (LLang.Locale <> '') and TLocalizationManager.LanguageFileExists(LLang.Locale) then
        LIni.WriteString('SupportedLanguages', LLang.Locale, LLang.NativeName);
    end;

    LIni.UpdateFile;
  finally
    LIni.Free;
  end;
end;

end.
