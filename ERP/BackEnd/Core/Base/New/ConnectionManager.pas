unit ConnectionManager;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  System.Diagnostics, System.DateUtils, System.IOUtils, Data.DB,
  FireDAC.Phys, FireDAC.Phys.Intf, FireDAC.Phys.PGDef, FireDAC.Phys.PG,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.Param, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.DatS, FireDAC.DApt, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Logger;

const
  ContextMain = 'MainDB';
  ContextThs = 'ThsDB';

type
  TConnectionManager = class
  private
    class var FInstance: TConnectionManager;
    class var FDriverLink: TFDPhysPgDriverLink;
    FConnections: TObjectDictionary<string, TFDConnection>;
    FConnectionAttempts: TDictionary<string, Integer>;
    FConnectionTimes: TDictionary<string, TDateTime>;
    FContextKeys: TDictionary<TFDConnection, string>;

    procedure LogConnectionInfo(const AContextKey: string; AConn: TFDConnection);
    procedure LogConnectionParams(const AContextKey, AHostName, ADatabase, AUser: string; APort: Integer);
    procedure SetupConnectionEvents(AConn: TFDConnection; const AContextKey: string);

    procedure OnConnectionAfterConnect(Sender: TObject);
    procedure OnConnectionBeforeDisconnect(Sender: TObject);
    procedure OnConnectionAfterDisconnect(Sender: TObject);
    procedure OnConnectionError(ASender, AInitiator: TObject; var AException: Exception);
    procedure OnConnectionLost(ASender: TObject);
    procedure OnConnectionRecover(ASender, AInitiator: TObject; AException: Exception; var AAction: TFDPhysConnectionRecoverAction);
    procedure OnConnectionRestored(ASender: TObject);

    function GetContextKey(AConn: TFDConnection): string;
  public
    class function Instance: TConnectionManager;
    constructor Create;
    destructor Destroy; override;

    procedure EnsureConnected(Conn: TFDConnection; const ContextKey: string);
    function GetConnectionPID(const AContextKey: string): Integer;
    function GetConnection(const AContextKey, AHostName, ADatabase, AUser, APassword: string; const APort: Integer = 5432): TFDConnection; overload;
    function GetConnection(const AContextKey: string): TFDConnection; overload;

    function IsConnected(const AContextKey: string): Boolean;
    function GetConnectionCount: Integer;
    procedure LogConnectionStatus;
    procedure CloseConnection(const AContextKey: string);
    procedure CloseAllConnections;
    function GetToday(): string;
  end;

implementation

constructor TConnectionManager.Create;
begin
  inherited;
  GLogger.Info('ConnectionManager oluşturuluyor...');

  FConnections := TObjectDictionary<string, TFDConnection>.Create([doOwnsValues]);
  FConnectionAttempts := TDictionary<string, Integer>.Create;
  FConnectionTimes := TDictionary<string, TDateTime>.Create;
  FContextKeys := TDictionary<TFDConnection, string>.Create;

  if FDriverLink = nil then
  begin
    try
      FDriverLink := TFDPhysPgDriverLink.Create(nil);
      FDriverLink.VendorLib := TPath.Combine(TPath.Combine(TPath.GetLibraryPath, 'lib'), 'libpq.dll');
      GLogger.InfoFmt('PostgreSQL driver yüklendi: %s', [FDriverLink.VendorLib]);
    except
      on E: Exception do
      begin
        GLogger.ErrorLog(E, 'PostgreSQL driver yüklenirken hata');
        raise;
      end;
    end;
  end;

  GLogger.Info('ConnectionManager başarıyla oluşturuldu');
end;

destructor TConnectionManager.Destroy;
//var
//  LKey: string;
//  LConn: TFDConnection;
begin
  try
    GLogger.Info('ConnectionManager kapatılıyor...');
    CloseAllConnections;

    FConnections.Free;
    FConnectionAttempts.Free;
    FConnectionTimes.Free;
    FContextKeys.Free;

    if FDriverLink <> nil then
    begin
      FDriverLink.Free;
      FDriverLink := nil;
    end;

    GLogger.Info('ConnectionManager başarıyla kapatıldı');
  except
    on E: Exception do
      GLogger.ErrorLog(E, 'ConnectionManager kapatılırken hata');
  end;

  inherited;
end;

function TConnectionManager.GetContextKey(AConn: TFDConnection): string;
begin
  if not FContextKeys.TryGetValue(AConn, Result) then
    Result := 'Unknown';
end;

function TConnectionManager.GetToday: string;
begin
  Result := FormatDateTime('dd.mm.yyyy', Now);
end;

procedure TConnectionManager.OnConnectionAfterConnect(Sender: TObject);
var
  LContextKey: string;
begin
  LContextKey := GetContextKey(Sender as TFDConnection);
  GLogger.InfoFmt('[%s] Bağlantı kuruldu', [LContextKey]);
end;

procedure TConnectionManager.OnConnectionBeforeDisconnect(Sender: TObject);
var
  LContextKey: string;
begin
  LContextKey := GetContextKey(Sender as TFDConnection);
  GLogger.InfoFmt('[%s] Bağlantı kapatılıyor', [LContextKey]);
end;

procedure TConnectionManager.OnConnectionAfterDisconnect(Sender: TObject);
var
  LContextKey: string;
begin
  LContextKey := GetContextKey(Sender as TFDConnection);
  GLogger.InfoFmt('[%s] Bağlantı kapatıldı', [LContextKey]);
end;

procedure TConnectionManager.OnConnectionError(ASender, AInitiator: TObject; var AException: Exception);
var
  LContextKey: string;
begin
  LContextKey := GetContextKey(ASender as TFDConnection);
  GLogger.ErrorFmt('[%s] Bağlantı hatası: %s', [LContextKey, AException.Message]);
end;

procedure TConnectionManager.OnConnectionLost(ASender: TObject);
var
  LContextKey: string;
begin
  LContextKey := GetContextKey(ASender as TFDConnection);
  GLogger.WarningFmt('[%s] Bağlantı kayboldu!', [LContextKey]);
end;

procedure TConnectionManager.OnConnectionRecover(ASender, AInitiator: TObject;
  AException: Exception; var AAction: TFDPhysConnectionRecoverAction);
var
  LContextKey: string;
begin
  LContextKey := GetContextKey(ASender as TFDConnection);
  GLogger.InfoFmt('[%s] Bağlantı kurtarılmaya çalışılıyor...', [LContextKey]);
  AAction := faRetry;
end;

procedure TConnectionManager.OnConnectionRestored(ASender: TObject);
var
  LContextKey: string;
begin
  LContextKey := GetContextKey(ASender as TFDConnection);
  GLogger.InfoFmt('[%s] Bağlantı geri yüklendi', [LContextKey]);
end;

procedure TConnectionManager.SetupConnectionEvents(AConn: TFDConnection; const AContextKey: string);
begin
  FContextKeys.AddOrSetValue(AConn, AContextKey);

  AConn.AfterConnect := OnConnectionAfterConnect;
  AConn.BeforeDisconnect := OnConnectionBeforeDisconnect;
  AConn.AfterDisconnect := OnConnectionAfterDisconnect;
  AConn.OnError := OnConnectionError;
  AConn.OnLost := OnConnectionLost;
  AConn.OnRecover := OnConnectionRecover;
  AConn.OnRestored := OnConnectionRestored;
end;

procedure TConnectionManager.LogConnectionParams(const AContextKey, AHostName, ADatabase, AUser: string; APort: Integer);
begin
  GLogger.Debug('─────────────────────────────────────────');
  GLogger.DebugFmt('Bağlantı Parametreleri [%s]:', [AContextKey]);
  GLogger.DebugFmt('  Server  : %s:%d', [AHostName, APort]);
  GLogger.DebugFmt('  Database: %s', [ADatabase]);
  GLogger.DebugFmt('  User    : %s', [AUser]);
  GLogger.Debug('─────────────────────────────────────────');
end;

procedure TConnectionManager.LogConnectionInfo(const AContextKey: string; AConn: TFDConnection);
var
  LPID: Integer;
begin
  try
    LPID := GetConnectionPID(AContextKey);
    GLogger.InfoFmt('[%s] PostgreSQL Backend PID: %d', [AContextKey, LPID]);

    if AContextKey = ContextMain then
      GLogger.DBConnectionPID := LPID.ToString;
  except
    on E: Exception do
      GLogger.WarningFmt('[%s] PID alınamadı: %s', [AContextKey, E.Message]);
  end;
end;

procedure TConnectionManager.EnsureConnected(Conn: TFDConnection; const ContextKey: string);
var
  LAttempt: Integer;
  LStopwatch: TStopwatch;
begin
  if Conn.Connected then
  begin
    GLogger.DebugFmt('[%s] Bağlantı zaten aktif', [ContextKey]);
    Exit;
  end;

  if not FConnectionAttempts.TryGetValue(ContextKey, LAttempt) then
    LAttempt := 0;
  Inc(LAttempt);
  FConnectionAttempts.AddOrSetValue(ContextKey, LAttempt);

  GLogger.InfoFmt('[%s] Bağlantı kuruluyor (Deneme: %d)...', [ContextKey, LAttempt]);

  LStopwatch := TStopwatch.StartNew;
  try
    Conn.Open;
    LStopwatch.Stop;

    FConnectionTimes.AddOrSetValue(ContextKey, Now);

    GLogger.InfoFmt('[%s] Bağlantı başarılı (Süre: %d ms)',
      [ContextKey, LStopwatch.ElapsedMilliseconds]);

    LogConnectionInfo(ContextKey, Conn);
  except
    on E: Exception do
    begin
      LStopwatch.Stop;
      GLogger.ErrorFmt('[%s] Bağlantı başarısız (Süre: %d ms, Deneme: %d)',
        [ContextKey, LStopwatch.ElapsedMilliseconds, LAttempt]);
      GLogger.ErrorLog(E, Format('Bağlantı hatası [%s]', [ContextKey]));
      raise Exception.CreateFmt('Connection failed for context "%s": %s', [ContextKey, E.Message]);
    end;
  end;
end;

class function TConnectionManager.Instance: TConnectionManager;
begin
  if FInstance = nil then
  begin
    FInstance := TConnectionManager.Create;
    GLogger.Info('ConnectionManager singleton instance oluşturuldu');
  end;
  Result := FInstance;
end;

function TConnectionManager.GetConnection(
  const AContextKey, AHostName, ADatabase, AUser, APassword: string;
  const APort: Integer = 5432
): TFDConnection;
var
  Conn: TFDConnection;
  LExists: Boolean;
begin
  if AContextKey.IsEmpty then
  begin
    GLogger.Error('ContextKey boş olamaz!');
    raise Exception.Create('Connection ContextKey required!!!');
  end;

  LExists := FConnections.TryGetValue(AContextKey, Conn);

  if not LExists then
  begin
    GLogger.InfoFmt('[%s] Yeni bağlantı oluşturuluyor...', [AContextKey]);
    LogConnectionParams(AContextKey, AHostName, ADatabase, AUser, APort);

    try
      Conn := TFDConnection.Create(nil);
      Conn.Name := AContextKey;
      Conn.DriverName := 'PG';

      with Conn.Params do
      begin
        Values['DriverID'] := 'PG';
        Values['Server'] := AHostName;
        Values['Database'] := ADatabase;
        Values['User_Name'] := AUser;
        Values['Password'] := APassword;
        Values['Port'] := APort.ToString;
        Values['CharacterSet'] := 'UTF8';
        Values['ApplicationName'] := 'ThsErp_' + AContextKey;
      end;

      Conn.LoginPrompt := False;
      Conn.TxOptions.AutoCommit := False;
      Conn.TxOptions.AutoStart := False;
      Conn.TxOptions.DisconnectAction := xdRollback;

      SetupConnectionEvents(Conn, AContextKey);

      Conn.Connected := True;
      FConnections.Add(AContextKey, Conn);

      GLogger.InfoFmt('[%s] Bağlantı pool''a eklendi', [AContextKey]);
    except
      on E: Exception do
      begin
        GLogger.ErrorLog(E, Format('Bağlantı oluşturulurken hata [%s]', [AContextKey]));
        Conn.Free;
        raise;
      end;
    end;
  end
  else
    GLogger.DebugFmt('[%s] Mevcut bağlantı kullanılıyor', [AContextKey]);

  EnsureConnected(Conn, AContextKey);
  Result := Conn;
end;

function TConnectionManager.GetConnection(const AContextKey: string): TFDConnection;
begin
  GLogger.DebugFmt('[%s] Bağlantı getiriliyor...', [AContextKey]);

  if not FConnections.TryGetValue(AContextKey, Result) then
  begin
    GLogger.ErrorFmt('[%s] Bağlantı pool''da bulunamadı!', [AContextKey]);
    raise Exception.Create('Connection not found in Connection Pools by AContextKey[' + AContextKey + ']');
  end;

  EnsureConnected(Result, AContextKey);
end;

function TConnectionManager.GetConnectionPID(const AContextKey: string): Integer;
var
  LConn: TFDConnection;
  LDataSet: TDataSet;
  LStopwatch: TStopwatch;
begin
  Result := 0;
  GLogger.DebugFmt('[%s] Backend PID sorgulanıyor...', [AContextKey]);

  LStopwatch := TStopwatch.StartNew;
  try
    LConn := GetConnection(AContextKey);
    LConn.ExecSQL('SELECT pg_backend_pid()', LDataSet);
    try
      if Assigned(LDataSet) and (LDataSet.FieldCount > 0) and not LDataSet.Fields[0].IsNull then
      begin
        Result := LDataSet.Fields[0].AsInteger;
        LStopwatch.Stop;
        GLogger.DebugFmt('[%s] Backend PID: %d (Sorgu süresi: %d ms)',
          [AContextKey, Result, LStopwatch.ElapsedMilliseconds]);
      end
      else
      begin
        GLogger.WarningFmt('[%s] Backend PID alınamadı', [AContextKey]);
      end;
    finally
      LDataSet.Free;
    end;
  except
    on E: Exception do
    begin
      GLogger.ErrorLog(E, Format('Backend PID sorgulanırken hata [%s]', [AContextKey]));
      raise;
    end;
  end;
end;

function TConnectionManager.IsConnected(const AContextKey: string): Boolean;
var
  Conn: TFDConnection;
begin
  Result := FConnections.TryGetValue(AContextKey, Conn) and Conn.Connected;
  GLogger.DebugFmt('[%s] Bağlantı durumu: %s', [AContextKey, BoolToStr(Result, True)]);
end;

function TConnectionManager.GetConnectionCount: Integer;
begin
  Result := FConnections.Count;
  GLogger.DebugFmt('Toplam bağlantı sayısı: %d', [Result]);
end;

procedure TConnectionManager.LogConnectionStatus;
var
  LPair: TPair<string, TFDConnection>;
  LConnTime: TDateTime;
  LUptime: string;
begin
  GLogger.Info('═════════════════════════════════════════');
  GLogger.Info('BAĞLANTI DURUMU RAPORU');
  GLogger.Info('═════════════════════════════════════════');
  GLogger.InfoFmt('Toplam Bağlantı: %d', [FConnections.Count]);
  GLogger.Info('─────────────────────────────────────────');

  for LPair in FConnections do
  begin
    GLogger.InfoFmt('[%s]', [LPair.Key]);
    GLogger.InfoFmt('  Durum    : %s', [BoolToStr(LPair.Value.Connected, True)]);
    GLogger.InfoFmt('  Server   : %s', [LPair.Value.Params.Values['Server']]);
    GLogger.InfoFmt('  Database : %s', [LPair.Value.Params.Values['Database']]);

    if FConnectionTimes.TryGetValue(LPair.Key, LConnTime) then
    begin
      LUptime := Format('%d dakika', [MinutesBetween(Now, LConnTime)]);
      GLogger.InfoFmt('  Uptime   : %s', [LUptime]);
    end;

    GLogger.Info('─────────────────────────────────────────');
  end;

  GLogger.Info('═════════════════════════════════════════');
end;

procedure TConnectionManager.CloseConnection(const AContextKey: string);
var
  Conn: TFDConnection;
begin
  GLogger.InfoFmt('[%s] Bağlantı kapatılıyor...', [AContextKey]);

  if FConnections.TryGetValue(AContextKey, Conn) then
  begin
    try
      if Conn.Connected then
        Conn.Close;
      FContextKeys.Remove(Conn);
      FConnections.Remove(AContextKey);

      GLogger.InfoFmt('[%s] Bağlantı kapatıldı ve pool''dan kaldırıldı', [AContextKey]);
    except
      on E: Exception do
        GLogger.ErrorLog(E, Format('Bağlantı kapatılırken hata [%s]', [AContextKey]));
    end;
  end
  else
    GLogger.WarningFmt('[%s] Kapatılacak bağlantı bulunamadı', [AContextKey]);
end;

procedure TConnectionManager.CloseAllConnections;
var
//  LPair: TPair<string, TFDConnection>;
  LKeys: TArray<string>;
  LKey: string;
begin
  GLogger.Info('Tüm bağlantılar kapatılıyor...');

  SetLength(LKeys, FConnections.Count);
  LKeys := FConnections.Keys.ToArray;

  for LKey in LKeys do
    CloseConnection(LKey);

  GLogger.Info('Tüm bağlantılar kapatıldı');
end;

end.
