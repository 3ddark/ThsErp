unit Ths.Database.Connection.Settings;

interface

{$I Ths.inc}

uses
  Vcl.Forms, System.Types, System.SysUtils, System.IniFiles,
  System.Classes, System.StrUtils;

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
    procedure ReadFromFile;
    procedure SaveToFile(AOnlyTheme: Boolean = False);
  end;

implementation

uses
  Ths.Constants, Ths.Globals;

function TConnSettings.SettingsFilePath: string;
begin
  Result := GUygulamaAnaDizin + PATH_SETTINGS + '\GlobalSettings.ini';
end;

procedure TConnSettings.ReadFromFile;
var
  LIni: TIniFile;
begin
  LIni := TIniFile.Create(SettingsFilePath);
  try
    FSQLServer      := LIni.ReadString ('ConnectionSettings', 'SQLServer',      '');
    FDatabaseName   := LIni.ReadString ('ConnectionSettings', 'DatabaseName',   '');
    FDBUserName     := LIni.ReadString ('ConnectionSettings', 'DBUserName',     '');
    FDBUserPassword := DecryptStr(LIni.ReadString('ConnectionSettings', 'DBUserPassword', ''), SECURE_KEY);
    FDBPortNo       := LIni.ReadInteger('ConnectionSettings', 'DBPortNo',       0);
    FUserName       := LIni.ReadString ('ConnectionSettings', 'UserName',       '');
    FUserPass       := DecryptStr(LIni.ReadString('ConnectionSettings', 'UserPass', ''), SECURE_KEY);
    FTheme          := LIni.ReadString ('ConnectionSettings', 'Theme',          '');
  finally
    LIni.Free;
  end;
end;

procedure TConnSettings.SaveToFile(AOnlyTheme: Boolean);
var
  LIni: TIniFile;
begin
  LIni := TIniFile.Create(SettingsFilePath);
  try
    LIni.WriteString('ConnectionSettings', 'Theme', FTheme);

    if AOnlyTheme then Exit;

    LIni.WriteString ('ConnectionSettings', 'SQLServer',      FSQLServer);
    LIni.WriteString ('ConnectionSettings', 'DatabaseName',   FDatabaseName);
    LIni.WriteString ('ConnectionSettings', 'DBUserName',     FDBUserName);
    LIni.WriteString ('ConnectionSettings', 'DBUserPassword', EncryptStr(FDBUserPassword, SECURE_KEY));
    LIni.WriteInteger('ConnectionSettings', 'DBPortNo',       FDBPortNo);
    LIni.WriteString ('ConnectionSettings', 'UserName',       FUserName);
    LIni.WriteString ('ConnectionSettings', 'UserPass',       EncryptStr(FUserPass, SECURE_KEY));
  finally
    LIni.Free;
  end;
end;

end.
