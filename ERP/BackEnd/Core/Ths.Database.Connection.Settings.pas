unit Ths.Database.Connection.Settings;

interface

{$I Ths.inc}

uses
  Vcl.Forms, System.Types, System.SysUtils, System.IniFiles, System.Classes, System.StrUtils;

type
  TConnSettings = class
  private
    FDBUserPassword: UnicodeString;
    FDBPortNo: Integer;
    FDBUserName: UnicodeString;
    FSQLServer: UnicodeString;
    FDatabaseName: UnicodeString;
    FAppName: UnicodeString;
    FUserName: UnicodeString;
    FUserPass: UnicodeString;
    FTheme: UnicodeString;
  public
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
  Ths.Constants, Ths.Globals;

procedure TConnSettings.ReadFromFile();
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create(GUygulamaAnaDizin + PATH_SETTINGS + '\' + 'GlobalSettings.ini');
  try
    Self.FSQLServer      := iniFile.ReadString('ConnectionSettings', 'SQLServer', '');
    Self.FDatabaseName   := iniFile.ReadString('ConnectionSettings', 'DatabaseName', '');
    Self.FDBUserName     := iniFile.ReadString('ConnectionSettings', 'DBUserName', '');
    Self.FDBUserPassword := DecryptStr(iniFile.ReadString('ConnectionSettings', 'DBUserPassword', ''), SECURE_KEY);
    Self.DBPortNo        := iniFile.ReadInteger('ConnectionSettings', 'DBPortNo', 0);
    Self.FUserName       := iniFile.ReadString('ConnectionSettings', 'UserName', '');
    Self.FUserPass       := DecryptStr(iniFile.ReadString('ConnectionSettings', 'UserPass', ''), SECURE_KEY);
    Self.FTheme          := iniFile.ReadString('ConnectionSettings', 'Theme', '');
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
    iniFile.WriteString('ConnectionSettings', 'SQLServer', Self.FSQLServer);
    iniFile.WriteString('ConnectionSettings', 'DatabaseName', Self.FDatabaseName);
    iniFile.WriteString('ConnectionSettings', 'DBUserName', Self.FDBUserName);
    iniFile.WriteString('ConnectionSettings', 'DBUserPassword', EncryptStr(FDBUserPassword, SECURE_KEY));
    iniFile.WriteInteger('ConnectionSettings', 'DBPortNo', Self.FDBPortNo);
    iniFile.WriteString('ConnectionSettings', 'UserName', Self.FUserName);
    iniFile.WriteString('ConnectionSettings', 'UserPass', EncryptStr(FUserPass, SECURE_KEY));
    iniFile.WriteString('ConnectionSettings', 'Theme', Self.FTheme);
  finally
    iniFile.Free;
  end;
end;

end.
