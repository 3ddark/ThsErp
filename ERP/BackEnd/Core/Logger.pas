unit Logger;

interface

uses
  SysUtils, Winapi.Windows, Vcl.Forms, System.IOUtils, System.SyncObjs,
  Classes, System.Generics.Collections, System.Threading;

type
  TLogLevel = (llDebug, llInfo, llWarning, llError, llCritical);

  TLogger = class
  private
    FLogFileName    : TFileName;
    FCachedFilePath : string;
    FProcessID      : string;
    FDBConnectionPID: string;
    FMinLogLevel    : TLogLevel;
    FMaxFileSize    : Int64;
    FEnabled        : Boolean;

    FQueue          : TQueue<string>;
    FQueueLock      : TCriticalSection;
    FFlushEvent     : TEvent;
    FWorker         : TThread;
    FShutdown       : Boolean;

    procedure BuildFilePath;
    procedure CheckAndRotateLog;
    function  LevelToStr(ALevel: TLogLevel): string;
    procedure EnqueueLine(const ALine: string);
    procedure FlushQueue;
  public
    property LogFileName    : TFileName read FLogFileName;
    property ProcessID      : string    read FProcessID      write FProcessID;
    property DBConnectionPID: string    read FDBConnectionPID write FDBConnectionPID;
    property MinLogLevel    : TLogLevel read FMinLogLevel    write FMinLogLevel;
    property MaxFileSize    : Int64     read FMaxFileSize    write FMaxFileSize;
    property Enabled        : Boolean   read FEnabled        write FEnabled;

    constructor Create(AFileName: TFileName = '');
    destructor  Destroy; override;

    procedure Debug   (const AMessage: string);
    procedure Info    (const AMessage: string);
    procedure Warning (const AMessage: string);
    procedure Error   (const AMessage: string);
    procedure Critical(const AMessage: string);
    procedure ErrorLog(E: Exception; const AContext: string = '');
    procedure Log     (const AMessage: string; ALevel: TLogLevel);

    procedure DebugFmt   (const AFormat: string; const Args: array of const);
    procedure InfoFmt    (const AFormat: string; const Args: array of const);
    procedure WarningFmt (const AFormat: string; const Args: array of const);
    procedure ErrorFmt   (const AFormat: string; const Args: array of const);
    procedure CriticalFmt(const AFormat: string; const Args: array of const);

    procedure Flush;
    procedure ClearLog;
    function  GetLogFileSize: Int64;
  end;

  TLogWorker = class(TThread)
  private
    FOwner: TLogger;
  public
    constructor Create(AOwner: TLogger);
    procedure Execute; override;
  end;

var
  GLogger: TLogger;

implementation

constructor TLogWorker.Create(AOwner: TLogger);
begin
  inherited Create(False);
  FOwner := AOwner;
  FreeOnTerminate := False;
end;

procedure TLogWorker.Execute;
begin
  while not Terminated do
  begin
    FOwner.FFlushEvent.WaitFor(200);
    FOwner.FFlushEvent.ResetEvent;
    FOwner.FlushQueue;
  end;
  FOwner.FlushQueue;
end;

constructor TLogger.Create(AFileName: TFileName);
var
  PID: DWORD;
begin
  inherited Create;

  FEnabled     := True;
  FMinLogLevel := llInfo;
  FMaxFileSize := 10 * 1024 * 1024;
  FShutdown    := False;

  if AFileName = '' then
    AFileName := ChangeFileExt(ExtractFileName(Application.ExeName), '');

  PID        := GetCurrentProcessId;
  FProcessID := PID.ToString;
  FDBConnectionPID := '';

  FLogFileName := Format('%s-%s.log',
    [AFileName, FormatDateTime('YYYYMMDD', Now)]);

  BuildFilePath;

  FQueue     := TQueue<string>.Create;
  FQueueLock := TCriticalSection.Create;
  FFlushEvent:= TEvent.Create(nil, True, False, '');
  FWorker    := TLogWorker.Create(Self);
end;

destructor TLogger.Destroy;
begin
  FShutdown := True;
  FWorker.Terminate;
  FFlushEvent.SetEvent;
  FWorker.WaitFor;

  FWorker.Free;
  FFlushEvent.Free;
  FQueueLock.Free;
  FQueue.Free;
  inherited;
end;

procedure TLogger.BuildFilePath;
begin
  FCachedFilePath := TPath.Combine(ExtractFilePath(Application.ExeName), FLogFileName);
end;

procedure TLogger.CheckAndRotateLog;
var
  LBackupPath: string;
begin
  if not FileExists(FCachedFilePath) then Exit;

  if GetLogFileSize > FMaxFileSize then
  begin
    LBackupPath := ChangeFileExt(FCachedFilePath, Format('.%s.log', [FormatDateTime('HHNNSS', Now)]));
    try
      TFile.Move(FCachedFilePath, LBackupPath);
    except
      try
        TFile.Delete(FCachedFilePath);
      except
      end;
    end;
  end;
end;

procedure TLogger.EnqueueLine(const ALine: string);
begin
  if not FEnabled then Exit;

  FQueueLock.Enter;
  try
    FQueue.Enqueue(ALine);
    if FQueue.Count >= 500 then
      FFlushEvent.SetEvent;
  finally
    FQueueLock.Leave;
  end;
end;

procedure TLogger.FlushQueue;
var
  LLines : TStringBuilder;
  LLine  : string;
  LCount : Integer;
begin
  FQueueLock.Enter;
  LCount := FQueue.Count;
  FQueueLock.Leave;

  if LCount = 0 then Exit;

  LLines := TStringBuilder.Create;
  try
    FQueueLock.Enter;
    try
      while FQueue.Count > 0 do
        LLines.AppendLine(FQueue.Dequeue);
    finally
      FQueueLock.Leave;
    end;

    CheckAndRotateLog;

    try
      TFile.AppendAllText(FCachedFilePath, LLines.ToString, TEncoding.UTF8);
    except
      on E: Exception do
        OutputDebugString(PChar('Logger flush error: ' + E.Message));
    end;
  finally
    LLines.Free;
  end;
end;

procedure TLogger.Log(const AMessage: string; ALevel: TLogLevel);
var
  LLine: string;
begin
  if not FEnabled then Exit;
  if ALevel < FMinLogLevel then Exit;

  LLine := Format('[%s] %s [App:%s] [DB:%s] %s',
    [LevelToStr(ALevel),
     FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
     FProcessID,
     FDBConnectionPID,
     AMessage
    ]);

  EnqueueLine(LLine);

  if ALevel = llCritical then
    FFlushEvent.SetEvent;
end;

function TLogger.LevelToStr(ALevel: TLogLevel): string;
begin
  case ALevel of
    llDebug   : Result := 'DEBUG   ';
    llInfo    : Result := 'INFO    ';
    llWarning : Result := 'WARNING ';
    llError   : Result := 'ERROR   ';
    llCritical: Result := 'CRITICAL';
  else
    Result := 'INFO    ';
  end;
end;

procedure TLogger.Debug   (const AMessage: string);
begin
  Log(AMessage, llDebug);
end;

procedure TLogger.Info    (const AMessage: string);
begin
  Log(AMessage, llInfo);
end;

procedure TLogger.Warning (const AMessage: string);
begin
  Log(AMessage, llWarning);
end;

procedure TLogger.Error   (const AMessage: string);
begin
  Log(AMessage, llError);
end;

procedure TLogger.Critical(const AMessage: string);
begin
  Log(AMessage, llCritical);
end;

procedure TLogger.ErrorLog(E: Exception; const AContext: string);
var
  LMsg: string;
begin
  if AContext <> '' then
    LMsg := Format('%s: %s', [AContext, E.Message])
  else
    LMsg := E.Message;

  Log(LMsg, llError);

  if E.StackTrace <> '' then
    Log('StackTrace: ' + E.StackTrace, llError);
end;

procedure TLogger.DebugFmt   (const AFormat: string; const Args: array of const);
begin
  Debug(Format(AFormat, Args));
end;

procedure TLogger.InfoFmt    (const AFormat: string; const Args: array of const);
begin
  Info(Format(AFormat, Args));
end;

procedure TLogger.WarningFmt (const AFormat: string; const Args: array of const);
begin
  Warning(Format(AFormat, Args));
end;

procedure TLogger.ErrorFmt   (const AFormat: string; const Args: array of const);
begin
  Error(Format(AFormat, Args));
end;

procedure TLogger.CriticalFmt(const AFormat: string; const Args: array of const);
begin
  Critical(Format(AFormat, Args));
end;

procedure TLogger.Flush;
begin
  FFlushEvent.SetEvent;
  Sleep(50);
end;

procedure TLogger.ClearLog;
begin
  FQueueLock.Enter;
  try
    FQueue.Clear;
  finally
    FQueueLock.Leave;
  end;

  if FileExists(FCachedFilePath) then
  begin
    try
      TFile.Delete(FCachedFilePath);
    except
    end;
  end;
end;

function TLogger.GetLogFileSize: Int64;
begin
  Result := 0;
  if FileExists(FCachedFilePath) then
    Result := TFile.GetSize(FCachedFilePath);
end;

initialization
  GLogger := TLogger.Create('');

finalization
  FreeAndNil(GLogger);

end.
