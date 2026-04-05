unit Logger;

interface

uses
  SysUtils, Winapi.Windows, Vcl.Forms, System.IOUtils, System.SyncObjs, Classes;

type
  TLogLevel = (llDebug, llInfo, llWarning, llError, llCritical);

  TLogger = class
  private
    FLogFileName: TFileName;
    FProcessID: string;
    FDBConnectionPID: string;
    FMinLogLevel: TLogLevel;
    FMaxFileSize: Int64;
    FCriticalSection: TCriticalSection;
    FEnabled: Boolean;
    procedure InternalWriteLog(const AMessage: string; ALevel: TLogLevel);
    function LevelToStr(ALevel: TLogLevel): string;
    procedure CheckAndRotateLog;
    function GetLogFilePath: string;
  public
    property LogFileName: TFileName read FLogFileName write FLogFileName;
    property ProcessID: string read FProcessID write FProcessID;
    property DBConnectionPID: string read FDBConnectionPID write FDBConnectionPID;
    property MinLogLevel: TLogLevel read FMinLogLevel write FMinLogLevel;
    property MaxFileSize: Int64 read FMaxFileSize write FMaxFileSize;
    property Enabled: Boolean read FEnabled write FEnabled;

    constructor Create(AFileName: TFileName = '');
    destructor Destroy; override;

    procedure Debug(const AMessage: string);
    procedure Info(const AMessage: string);
    procedure Warning(const AMessage: string);
    procedure Error(const AMessage: string);
    procedure Critical(const AMessage: string);
    procedure ErrorLog(E: Exception; const AContext: string = '');
    procedure Log(const AMessage: string; ALevel: TLogLevel);

    procedure DebugFmt(const AFormat: string; const Args: array of const);
    procedure InfoFmt(const AFormat: string; const Args: array of const);
    procedure WarningFmt(const AFormat: string; const Args: array of const);
    procedure ErrorFmt(const AFormat: string; const Args: array of const);
    procedure CriticalFmt(const AFormat: string; const Args: array of const);

    procedure ClearLog;
    function GetLogFileSize: Int64;
  end;

var
  GLogger: TLogger;

implementation

constructor TLogger.Create(AFileName: TFileName);
var
  PID: DWORD;
begin
  inherited Create;

  FCriticalSection := TCriticalSection.Create;
  FEnabled := True;
  FMinLogLevel := llInfo;
  FMaxFileSize := 10 * 1024 * 1024; // 10 MB varsayılan

  if AFileName = '' then
    AFileName := ChangeFileExt(ExtractFileName(Application.ExeName), '');

  PID := GetCurrentProcessId;
  FProcessID := PID.ToString;
  FDBConnectionPID := '';

  FLogFileName := Format('%s-%s.log', [AFileName, FormatDateTime('YYYYMMDD', Now)]);
end;

destructor TLogger.Destroy;
begin
  FCriticalSection.Free;
  inherited;
end;

function TLogger.GetLogFilePath: string;
begin
  Result := TPath.Combine(ExtractFilePath(Application.ExeName), FLogFileName);
end;

procedure TLogger.CheckAndRotateLog;
var
  LFullPath: string;
  LBackupPath: string;
begin
  LFullPath := GetLogFilePath;

  if not FileExists(LFullPath) then
    Exit;

  if GetLogFileSize > FMaxFileSize then
  begin
    LBackupPath := ChangeFileExt(LFullPath, Format('.%s.log', [FormatDateTime('HHNNSS', Now)]));
    try
      TFile.Move(LFullPath, LBackupPath);
    except
      TFile.Delete(LFullPath);
    end;
  end;
end;

procedure TLogger.InternalWriteLog(const AMessage: string; ALevel: TLogLevel);
var
  LData: string;
  LFullPath: string;
begin
  if not FEnabled then
    Exit;

  if ALevel < FMinLogLevel then
    Exit;

  FCriticalSection.Enter;
  try
    CheckAndRotateLog;

    LData := Format('[%s] %s [App:%s] [DB:%s] %s',
      [LevelToStr(ALevel),
       FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
       FProcessID,
       FDBConnectionPID,
       AMessage]);

    LFullPath := GetLogFilePath;

    try
      TFile.AppendAllText(LFullPath, LData + sLineBreak, TEncoding.UTF8);
    except
      on E: Exception do
      begin
        OutputDebugString(PChar('Logger Error: ' + E.Message));
      end;
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

function TLogger.LevelToStr(ALevel: TLogLevel): string;
begin
  case ALevel of
    llDebug:    Result := 'DEBUG   ';
    llInfo:     Result := 'INFO    ';
    llWarning:  Result := 'WARNING ';
    llError:    Result := 'ERROR   ';
    llCritical: Result := 'CRITICAL';
  else
    Result := 'INFO    ';
  end;
end;

procedure TLogger.Log(const AMessage: string; ALevel: TLogLevel);
begin
  InternalWriteLog(AMessage, ALevel);
end;

procedure TLogger.Debug(const AMessage: string);
begin
  InternalWriteLog(AMessage, llDebug);
end;

procedure TLogger.Info(const AMessage: string);
begin
  InternalWriteLog(AMessage, llInfo);
end;

procedure TLogger.Warning(const AMessage: string);
begin
  InternalWriteLog(AMessage, llWarning);
end;

procedure TLogger.Error(const AMessage: string);
begin
  InternalWriteLog(AMessage, llError);
end;

procedure TLogger.Critical(const AMessage: string);
begin
  InternalWriteLog(AMessage, llCritical);
end;

procedure TLogger.ErrorLog(E: Exception; const AContext: string);
var
  LMsg: string;
begin
  if AContext <> '' then
    LMsg := Format('%s: %s', [AContext, E.Message])
  else
    LMsg := E.Message;

  InternalWriteLog(LMsg, llError);

  if E.StackTrace <> '' then
    InternalWriteLog('StackTrace: ' + E.StackTrace, llError);

  Application.ShowException(E);
end;

procedure TLogger.DebugFmt(const AFormat: string; const Args: array of const);
begin
  Debug(Format(AFormat, Args));
end;

procedure TLogger.InfoFmt(const AFormat: string; const Args: array of const);
begin
  Info(Format(AFormat, Args));
end;

procedure TLogger.WarningFmt(const AFormat: string; const Args: array of const);
begin
  Warning(Format(AFormat, Args));
end;

procedure TLogger.ErrorFmt(const AFormat: string; const Args: array of const);
begin
  Error(Format(AFormat, Args));
end;

procedure TLogger.CriticalFmt(const AFormat: string; const Args: array of const);
begin
  Critical(Format(AFormat, Args));
end;

procedure TLogger.ClearLog;
var
  LFullPath: string;
begin
  FCriticalSection.Enter;
  try
    LFullPath := GetLogFilePath;
    if FileExists(LFullPath) then
      TFile.Delete(LFullPath);
  finally
    FCriticalSection.Leave;
  end;
end;

function TLogger.GetLogFileSize: Int64;
var
  LFullPath: string;
begin
  Result := 0;
  LFullPath := GetLogFilePath;
  if FileExists(LFullPath) then
    Result := TFile.GetSize(LFullPath);
end;

initialization
  GLogger := TLogger.Create('');

finalization
  FreeAndNil(GLogger);

end.
