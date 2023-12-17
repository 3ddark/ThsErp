unit Ths.Database.Sql.Builder;

interface

uses
  System.DateUtils, System.StrUtils, System.Classes, System.SysUtils,
  System.Variants, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt, FireDAC.Phys.PGDef, FireDAC.Comp.Client,
  FireDAC.Phys.PG, FireDAC.Comp.DataSet;

type
  TThsSqlBuilder = class
  public
    constructor Create();
    destructor Destroy; override;

    //get easy SELECT ... FROM ... sql code
    procedure GetSQLSelectCmd(AQry: TFDQuery; ATableName: string; AFieldNames: TArray<string>; AWhereJoin: TArray<string>; AAllColumn: Boolean=True; AHelper: Boolean=False);
    //get easy INSERT INTO .. (...) VALUES(...) RETURNIN ID
    procedure GetSQLInsertCmd(ATableName: string; AQry: TFDQuery; AFieldNames: TArray<string>);
    //get easy UPDATE .. SET ..... WHERE id=...
    procedure GetSQLUpdateCmd(ATableName: string; AQry: TFDQuery; AFieldNames: TArray<string>);
    //if don't want 0, '' value call this routine (string '' = null) (integer or double 0 = null)
    procedure SetQueryParamsDefaultValue(AQuery: TFDQuery; AInput: Boolean = True);
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table.SysGridKolonlar;

constructor TThsSqlBuilder.Create;
begin
//
end;

destructor TThsSqlBuilder.Destroy;
begin
  inherited;
end;

procedure TThsSqlBuilder.GetSQLInsertCmd(ATableName: string; AQry: TFDQuery; AFieldNames: TArray<string>);
var
  n1: Integer;
  LFields, LParams: string;
  LSQL: TStringList;
begin
  LSQL := TStringList.Create;
  try
    LFields := '';
    LParams := '';

    LSQL.Add('INSERT INTO ' + ATableName + '(');

    for n1 := 0 to Length(AFieldNames)-1 do
    begin
      if AFieldNames[n1] <> '' then
      begin
        LFields := LFields + AFieldNames[n1] + ',';
        LParams := LParams + ':' + AFieldNames[n1] + ',';
      end;

      if (n1 = Length(AFieldNames)-1) and (LFields <> '') then
        LFields := LeftStr(LFields, Length(LFields)-1);

      if (n1 = Length(AFieldNames)-1) and (LParams <> '') then
        LParams := LeftStr(LParams, Length(LParams)-1);
    end;

    LSQL.Add(LFields);
    LSQL.Add(') VALUES (');
    LSQL.Add(LParams);
    LSQL.Add(') RETURNING id');

    if (LFields = '') then
      raise Exception.Create('Database fields not found!');
  finally
    LSQL.LineBreak := '';
    AQry.SQL.Text := LSQL.Text;
    LSQL.Free;
  end;
end;

procedure TThsSqlBuilder.GetSQLSelectCmd(AQry: TFDQuery; ATableName: string; AFieldNames, AWhereJoin: TArray<string>; AAllColumn, AHelper: Boolean);
var
  nx, LIndex: Integer;
  LGridCol: TSysGridKolon;

  procedure _AddAllColumns();
  var
    n1: Integer;
  begin
    for n1 := 0 to Length(AFieldNames)-1 do
      AQry.SQL.Add(AFieldNames[n1] + ', '); //Select için FieldName ekleniyor
  end;

  type TColHelper = (Helper, Defined);

  procedure _AddAllColumnsHelper(AColHelper: TColHelper);
  var
    n1, n2, LPos: Integer;
    LFieldName: string;
  begin
    for n2 := LIndex to LGridCol.List.Count-1 do
    begin
      if (n2 = 0) then
        AQry.SQL.Add(ATableName + '.' + LGridCol.Id.FieldName + ', ');

      if ((TSysGridKolon(LGridCol.List[n2]).IsHelperGorunur.Value) and (AColHelper = Helper))
      or (AColHelper = Defined)
      then
      begin
        for n1 := 0 to Length(AFieldNames)-1 do
        begin
          if Pos(' ', AFieldNames[n1]) > 0 then
            LPos := LastPos(' ', AFieldNames[n1])
          else
            LPos := Pos('.', AFieldNames[n1]);
          LFieldName := AFieldNames[n1].Substring(LPos);
          LFieldName := ReplaceRealColOrTableNameTo(LFieldName);
          if (TSysGridKolon(LGridCol.List[n2]).KolonAdi.Value = LFieldName) then
            AQry.SQL.Add(AFieldNames[n1] + ', ')
        end;
      end;
    end;
  end;

  function ExistsGridColWidth(AHelper: Boolean; out Index: Integer): Boolean;
  var
    n1: Integer;
  begin
    Result := False;
    for n1 := 0 to LGridCol.List.Count-1 do
    begin
      if  ((TSysGridKolon(LGridCol.List[n1]).TabloAdi.Value = ReplaceRealColOrTableNameTo(ATableName))
       and (TSysGridKolon(LGridCol.List[n1]).IsHelperGorunur.AsBoolean = AHelper))
      or AHelper
      then
      begin
        Index := n1;
        Result := True;
        Break;
      end;
    end;
  end;

begin
  if AQry = nil then
    Exit;

  if Length(AFieldNames) = 0 then
    raise Exception.Create('Database fields are not defined!' + AddLBs + 'This process cannot be done');

  AQry.Close;
  AQry.SQL.Clear;
  AQry.SQL.Add('SELECT ');
  //helper tanýmlý ve helper için görünmesi gereken alan seçilmiþse helper gibi ekle aksi durumuda normal olarak tüm fieldlar gelsin
  if AHelper then
  begin
    //helper için select yapýlacaksa sadece helperde görünmesini istediðimiz kolonlar getirildi.
    //Bu þekilde gereksiz kolonlar gelmez ve hýz açýsýnda çok kayýt ve çok kolon olan sorgularda performans artmýþ olur.
    //Gereksiz kolonlar db den getirilmez
    if Length(AFieldNames) = 0 then
      raise Exception.Create('Database fields are not defined!' + AddLBs + 'This process cannot be done');

    LGridCol := TSysGridKolon.Create(GDatabase);
    try
      LGridCol.SelectToList(' AND ' + LGridCol.TabloAdi.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(ATableName)), False, False);

      if ExistsGridColWidth(AHelper, LIndex) then
      begin
        if LGridCol.HasAnyTableColumn(ATableName) then
          _AddAllColumnsHelper(Helper)
        else
          _AddAllColumns;
      end
      else
        _AddAllColumns;  //tüm kolonlar istenmemiþ olsa bile grid kolon geniþliði tanýmlanmamýþsa select içinde tanýmlanan tüm kolonlarý ekle

    finally
      LGridCol.Free;
    end;
  end
  else
  begin
    if AAllColumn then
      _AddAllColumns //tüm kolonlar istenmiþse select içinde tanýmlanan tüm kolonlarý ekle
    else
    begin
      LGridCol := TSysGridKolon.Create(GDatabase);
      try
        LGridCol.SelectToList(' AND ' + LGridCol.TabloAdi.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(ATableName)), False, False);

        if ExistsGridColWidth(AHelper, LIndex) then
          _AddAllColumnsHelper(Defined)  //tüm kolonlar istenmiyorsa sadece IsAlwaysShow tanýmlý kolonlar gelsin
        else
          _AddAllColumns;  //tüm kolonlar istenmemiþ olsa bile grid kolon geniþliði tanýmlanmamýþsa select içinde tanýmlanan tüm kolonlarý ekle
      finally
        LGridCol.Free;
      end;
    end;
  end;

  if AQry.SQL.Count > 1 then
    AQry.SQL.Strings[AQry.SQL.Count-1] := AQry.SQL.Strings[AQry.SQL.Count-1].Replace(', ', ' ');

  AQry.SQL.Add('FROM ' + ATableName + ' ');
  for nx := 0 to Length(AWhereJoin)-1 do
    AQry.SQL.Add(AWhereJoin[nx]);
end;

procedure TThsSqlBuilder.GetSQLUpdateCmd(ATableName: string; AQry: TFDQuery; AFieldNames: TArray<string>);
var
  n1, Len: Integer;
  LSQL: TStringList;
  LFields: TStringList;
begin
  LSQL := TStringList.Create;
  LFields := TStringList.Create;
  try
    LFields.Delimiter := ',';

    LSQL.Add('UPDATE ' + ATableName + ' SET ');
    Len := Length(AFieldNames);
    for n1 := 0 to Len-1 do
    begin
      if AFieldNames[n1] <> '' then
        LFields.Add(AFieldNames[n1] + '=:' + RightStr(AFieldNames[n1], Length(AFieldNames[n1])- Pos('.', AFieldNames[n1])));
    end;

    if LFields.Count = 0 then
      raise Exception.Create('Database fields not found!');

    LSQL.Add(LFields.DelimitedText);

    LSQL.Add(' WHERE id=:id;');
  finally
    LSQL.LineBreak := '';
    LSQL.Delimiter := ',';
    AQry.SQL.Text := LSQL.Text;
    LSQL.Free;
    LFields.Free;
  end;
end;

procedure TThsSqlBuilder.SetQueryParamsDefaultValue(AQuery: TFDQuery; AInput: Boolean);
var
  n1: Integer;
begin
  for n1 := 0 to AQuery.Params.Count-1 do
  begin
    AQuery.Params.Items[n1].ParamType := ptInput;

    if (AQuery.Params.Items[n1].DataType = ftString)
    or (AQuery.Params.Items[n1].DataType = ftMemo)
    or (AQuery.Params.Items[n1].DataType = ftWideString)
    or (AQuery.Params.Items[n1].DataType = ftWideMemo)
    or (AQuery.Params.Items[n1].DataType = ftFixedChar)
    or (AQuery.Params.Items[n1].DataType = ftFixedWideChar)
    then
    begin
      if AQuery.Params.Items[n1].Value = '' then
        AQuery.Params.Items[n1].Value := Null;
    end
    else
    if (AQuery.Params.Items[n1].DataType = ftSmallint)
    or (AQuery.Params.Items[n1].DataType = ftInteger)
    or (AQuery.Params.Items[n1].DataType = ftWord)
    or (AQuery.Params.Items[n1].DataType = ftFloat)
    or (AQuery.Params.Items[n1].DataType = ftCurrency)
    or (AQuery.Params.Items[n1].DataType = ftBCD)
    or (AQuery.Params.Items[n1].DataType = ftBytes)
    or (AQuery.Params.Items[n1].DataType = ftLargeint)
    or (AQuery.Params.Items[n1].DataType = ftLongWord)
    or (AQuery.Params.Items[n1].DataType = ftShortint)
    or (AQuery.Params.Items[n1].DataType = ftByte)
    then
    begin
      if AQuery.Params.Items[n1].Value = 0 then
        AQuery.Params.Items[n1].Value := Null;
    end
    else
    if (AQuery.Params.Items[n1].DataType = ftDate)
    or (AQuery.Params.Items[n1].DataType = ftTime)
    or (AQuery.Params.Items[n1].DataType = ftDateTime)
    or (AQuery.Params.Items[n1].DataType = ftTimeStamp)
    then
    begin
      if AQuery.Params.Items[n1].Value = 0 then
        AQuery.Params.Items[n1].Value := Null;
    end;
  end;

  AQuery.SQL.Text := StringReplace(AQuery.SQL.Text, AddLBs, '', [rfReplaceAll]);
end;

end.
