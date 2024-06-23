unit Ths.Utils.Logger;

interface

uses
  SysUtils, Forms;

type
  TLogger = class
    procedure Log(E: Exception); overload;
    procedure Log(AMsg: string); overload;
  end;

implementation

procedure TLogger.Log(E: Exception) ;
var
   LFileName : string;
   LFile : TextFile;
   LMsg : string;
begin
  LFileName := ChangeFileExt(ParamStr(0), '.log') ;
  AssignFile(LFile, LFileName);
  try
    if FileExists(LFileName) then
      Append(LFile)
    else
      Rewrite(LFile);

    LMsg := Format('%s : %s', [DateTimeToStr(Now), E.Message]);
    WriteLn(LFile, LMsg) ;
    Application.ShowException(E);
  finally
    CloseFile(LFile)
  end;
end;

procedure TLogger.Log(AMsg: string);
var
  LFileName : string;
  LFile : TextFile;
  LMsg : string;
begin
  LFileName := ChangeFileExt(ParamStr(0), '.log');
  AssignFile(LFile, LFileName);
  try
    if FileExists(LFileName) then
      Append(LFile)
    else
      Rewrite(LFile) ;

    LMsg := Format('%s : %s', [DateTimeToStr(Now), AMsg]);
    WriteLn(LFile, LMsg);
   finally
     CloseFile(LFile)
   end;
end;

end.
