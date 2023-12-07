unit Logger;

interface

uses SysUtils, Forms, Winapi.Windows;

type
  TLogger = class
  private
    FLogFileName: TFileName;
    FProcessID: string;
    FDBConnectionPID: string;
    procedure SetLogFileName(const Value: TFileName);
    procedure SetProcessID(const Value: string);
    procedure SetDBConnectionPID(const Value: string);
  public
    property LogFileName: TFileName read FLogFileName write SetLogFileName;

    property ProcessID: string read FProcessID write SetProcessID;
    property DBConnectionPID: string read FDBConnectionPID write SetDBConnectionPID;

    procedure ErrorLog(E: Exception);
    procedure RunLog(AMessage: String);
    constructor Create(AFileName: TFileName);
  end;

var
  GLogger: TLogger;

implementation

constructor TLogger.Create(AFileName: TFileName);
var
  PID: DWORD;
begin
  if AFileName = '' then
    FLogFileName := ChangeFileExt(ExtractFileName(Application.ExeName), '.log')
  else
    FLogFileName := ExtractFilePath(Application.ExeName) + AFileName + '.log';

  FProcessID := '';
  FDBConnectionPID := '';

  if Application.Handle <> 0 then
    GetWindowThreadProcessID(Application.Handle, @PID);
  FProcessID := PID.ToString;
end;

procedure TLogger.ErrorLog(E: Exception);
var
  LFile: TextFile;
  LData: string;
begin
  AssignFile(LFile, FLogFileName);

  if FileExists(FLogFileName)
  then  Append(LFile)
  else  Rewrite(LFile);

  try
    LData := Format('App:%s DB:%s - %s : %s', [FProcessID, FDBConnectionPID, DateTimeToStr(Now), E.Message]);
    WriteLn(LFile, LData);
    Application.ShowException(E);
  finally
    CloseFile(LFile)
  end;
end;

procedure TLogger.RunLog(AMessage: String);
var
  LFile: TextFile;
  LData: string;
begin
  AssignFile(LFile, FLogFileName);

  if FileExists(FLogFileName)
  then  Append(LFile)
  else  Rewrite(LFile);

  try
    LData := Format('App:%s DB:%s - %s : %s', [FProcessID, FDBConnectionPID, DateTimeToStr(Now), AMessage]);
    WriteLn(LFile, LData);
  finally
    CloseFile(LFile)
  end;
end;

procedure TLogger.SetDBConnectionPID(const Value: string);
begin
  FDBConnectionPID := Value;
end;

procedure TLogger.SetLogFileName(const Value: TFileName);
begin
  FLogFileName := Value;
end;

procedure TLogger.SetProcessID(const Value: string);
begin
  FProcessID := Value;
end;

initialization
  GLogger := TLogger.Create('');
finalization
  FreeAndNil(GLogger);

end.
