unit ItSpecific;

interface

uses
  System.SysUtils, System.Classes, SysUser.Repository;

var
  GPass, GFail, GWarn: Integer;

procedure OpenReport(const AFile: string);
procedure CloseReport;
procedure Report(const AKind, AModule, AEntity, AStep, AMsg: string);
procedure RunSpecific(AUserRepo: TSysUserRepository);

implementation

uses
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, Data.DB, UnitOfWork, ItModules;

var
  GOut: TStreamWriter;

procedure OpenReport(const AFile: string);
begin
  GOut := TStreamWriter.Create(AFile, False, TEncoding.UTF8);
end;

procedure CloseReport;
begin
  FreeAndNil(GOut);
end;

procedure Report(const AKind, AModule, AEntity, AStep, AMsg: string);
var
  L: string;
begin
  if AKind = 'PASS' then Inc(GPass)
  else if AKind = 'FAIL' then Inc(GFail)
  else if AKind = 'WARN' then Inc(GWarn);
  L := Format('%s|%s|%s|%s|%s', [AKind, AModule, AEntity, AStep,
    StringReplace(StringReplace(AMsg, #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll])]);
  Writeln(L);
  if Assigned(GOut) then
  begin
    GOut.WriteLine(L);
    GOut.Flush;
  end;
end;

function Probe(AConn: TFDConnection; AMode: Integer): string;
const
  Txt = '₺ ş İ € Ж α 😀';
var
  Q: TFDQuery;
  R: TFDMapRule;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConn;
    if AMode = 2 then
    begin
      Q.FormatOptions.OwnMapRules := True;
      R := Q.FormatOptions.MapRules.Add;
      R.SourceDataType := dtWideString; R.TargetDataType := dtWideString;
      R := Q.FormatOptions.MapRules.Add;
      R.SourceDataType := dtWideString; R.TargetDataType := dtAnsiString;
    end;
    Q.SQL.Text := 'SELECT CAST(:s AS varchar) AS s';
    if AMode = 1 then
      Q.ParamByName('s').AsWideString := Txt
    else
      Q.ParamByName('s').AsString := Txt;
    Q.Open;
    Result := Q.Fields[0].AsString;
    if Result = Txt then Result := 'OK ' + Result + ' (' + Q.Fields[0].ClassName + ')'
    else Result := 'LOST ' + Result + ' (' + Q.Fields[0].ClassName + ')';
  finally
    Q.Free;
  end;
end;

function ProbeNum(AConn: TFDConnection; ABcd: Boolean): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text := 'SELECT CAST(:p AS numeric(18,6))::text, pg_typeof(:p)::text, (CAST(0.1250 AS numeric(10,4)) = :p)::text';
    if ABcd then Q.ParamByName('p').AsBCD := 0.125 else Q.ParamByName('p').AsCurrency := 0.125;
    try
      Q.Open;
      Result := Q.Fields[0].AsString + ' type=' + Q.Fields[1].AsString + ' eq=' + Q.Fields[2].AsString;
    except
      on E: Exception do Result := 'ERR ' + E.Message;
    end;
  finally
    Q.Free;
  end;
end;

procedure RunSpecific(AUserRepo: TSysUserRepository);
var
  C: TFDConnection;
begin
  C := TUnitOfWork.Instance.Connection;
  Report('INFO', 'Core', 'Numeric', 'AsCurrency', ProbeNum(C, False));
  Report('INFO', 'Core', 'Numeric', 'AsBCD', ProbeNum(C, True));
  Report('INFO', 'Core', 'Unicode', 'AsString', Probe(C, 0));
  Report('INFO', 'Core', 'Unicode', 'AsWideString', Probe(C, 1));
  Report('INFO', 'Core', 'Unicode', 'MapRules', Probe(C, 2));
  RunModuleTests;
end;

end.
