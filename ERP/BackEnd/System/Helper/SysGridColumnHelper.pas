unit SysGridColumnHelper;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Logger;

type
  TGridColumnHelper = class
  public
    class function BuildSelectColumns(
      AConnection: TFDConnection;
      const ATableName: string;
      const AAlwaysFetch: TArray<string>
    ): string;
  end;

implementation

class function TGridColumnHelper.BuildSelectColumns(
  AConnection: TFDConnection;
  const ATableName: string;
  const AAlwaysFetch: TArray<string>
): string;
var
  Qry: TFDQuery;
  ColList: TStringList;
  Col: string;
  CleanTbl: string;
begin
  if (AConnection = nil) or not AConnection.Connected then
  begin
    Result := '*';
    Exit;
  end;

  ColList := TStringList.Create;
  try
    ColList.CaseSensitive := False;

    // Mandatory columns (id, locale, etc.)
    for Col in AAlwaysFetch do
    begin
      if (Col <> '') and (ColList.IndexOf(Col) < 0) then
        ColList.Add(Col);
    end;

    CleanTbl := ATableName;
    if CleanTbl.StartsWith('public.', True) then
      CleanTbl := CleanTbl.Substring(7);

    Qry := TFDQuery.Create(nil);
    try
      Qry.Connection := AConnection;
      Qry.SQL.Text :=
        'SELECT column_name FROM public.sys_grid_column ' +
        'WHERE (table_name = :tbl OR table_name = :tbl_vw) AND is_fetch = true ' +
        'ORDER BY column_order';
      Qry.ParamByName('tbl').AsString := CleanTbl;
      Qry.ParamByName('tbl_vw').AsString := 'vw_' + CleanTbl;
      try
        Qry.Open;
        while not Qry.Eof do
        begin
          Col := Qry.FieldByName('column_name').AsString;
          if (Col <> '') and (ColList.IndexOf(Col) < 0) then
            ColList.Add(Col);
          Qry.Next;
        end;
      except
        on E: Exception do
        begin
          GLogger.WarningFmt('BuildSelectColumns table [%s] query error: %s', [ATableName, E.Message]);
        end;
      end;
    finally
      Qry.Free;
    end;

    // Fallback to '*' if no specific columns configured in sys_grid_column
    if ColList.Count = 0 then
      Result := '*'
    else
      Result := string.Join(', ', ColList.ToStringArray);
  finally
    ColList.Free;
  end;
end;

end.
