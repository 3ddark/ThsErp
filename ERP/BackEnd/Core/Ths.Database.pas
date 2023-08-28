unit Ths.Database;

interface

{$I Ths.inc}

uses
  System.DateUtils,
  System.StrUtils,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Rtti,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZStoredProcedure,
  ZAbstractConnection,
  ZConnection;

{$M+}

type
  TPermissionType = (ptRead, ptAddRecord, ptUpdate, ptDelete, ptSpecial);

type
  TDatabase = class
  private
    FConnection: TZConnection;
    FQueryOfDatabase: TZQuery;

    FNewRecordId: Integer;

    FDateDB: TDate; //Used for today date controls. Data came from the SQL server during the login process
  protected
    property QueryOfDataBase: TZQuery read FQueryOfDatabase;

    procedure ConnBeforeConnect(Sender: TObject);
    procedure ConnBeforeDisconnect(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
    procedure ConnAfterDisconnect(Sender: TObject);
    procedure ConnOnStartTransaction(Sender: TObject);
    procedure ConnOnCommit(Sender: TObject);
    procedure ConnOnRollback(Sender: TObject);
  public
    property Connection: TZConnection read FConnection write FConnection;
    property NewRecordId: Integer read FNewRecordId write FNewRecordId;
    property DateDB: TDate read FDateDB write FDateDB;

    constructor Create;
    function GetNewRecordId: Integer;

    //get easy SELECT ... FROM ... sql code
    procedure GetSQLSelectCmd(AQry: TZQuery; ATableName: string; AFieldNames: TArray<string>; AWhereJoin: TArray<string>; AAllColumn: Boolean=True; AHelper: Boolean=False);
    //get easy INSERT INTO .. (...) VALUES(...) RETURNIN ID
    function GetSQLInsertCmd(ATableName: string; AParamDelimiter: Char; AArrFieldNames: TArray<string>): string;
    //get easy UPDATE .. SET ..... WHERE id=...
    function GetSQLUpdateCmd(ATableName: string; AParamDelimiter: Char; AArrFieldNames: TArray<string>): string;
    //if don't want 0, '' value call this routine (string '' = null) (integer or double 0 = null)
    procedure SetQueryParamsDefaultValue(AQuery: TZQuery; AInput: Boolean = True);

    function NewQuery(AConnection: TZConnection = nil): TZQuery;
    function NewStoredProcedure(AConnection: TZConnection = nil): TZStoredProc;
    function NewDataSource(ADataset: TDataSet): TDataSource;
    function NewConnection: TZConnection;
  published
    destructor Destroy; override;
    function GetToday: TDateTime;
    function GetNow(AOnlyTime: Boolean = True): TDateTime;
    procedure runCustomSQL(ASQL: string);
    procedure ConfigureConnection(AHostName, ADatabase, AUser, APassword: string; APort: Integer);
  end;

implementation

uses
  Ths.Constants,
  Ths.Globals,
  Ths.Database.Table,
  Ths.Database.Table.SysGridKolonlar;

procedure TDatabase.ConfigureConnection(AHostName, ADatabase, AUser, APassword: string; APort: Integer);
begin
  if FConnection.Connected then
    FConnection.Disconnect;

  FConnection.Name := 'ConApp';

  FConnection.LibraryLocation := GUygulamaAnaDizin + PathDelim + 'lib' + PathDelim + 'libpq.dll';
  FConnection.Protocol := 'postgresql-9';
  FConnection.ClientCodepage := 'UTF8';
  FConnection.HostName := AHostName;
  FConnection.Database := ADatabase;
  FConnection.User := AUser;
  FConnection.Password := APassword;
  FConnection.Port := APort;
  FConnection.LoginPrompt := False;
end;

procedure TDatabase.ConnBeforeConnect(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnAfterConnect(Sender: TObject);
begin

end;

procedure TDatabase.ConnBeforeDisconnect(Sender: TObject);
begin

end;

procedure TDatabase.ConnAfterDisconnect(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnOnStartTransaction(Sender: TObject);
begin

end;

procedure TDatabase.ConnOnCommit(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnOnRollback(Sender: TObject);
begin
//
end;

constructor TDatabase.Create();
begin
  if Self.FConnection <> nil then
    Abort
  else
  begin
    inherited;

    GUygulamaAnaDizin := ExtractFilePath(Application.ExeName);

    FConnection := TZConnection.Create(nil);
    FConnection.BeforeConnect       := ConnBeforeConnect;
    FConnection.BeforeDisconnect    := ConnBeforeDisconnect;
    FConnection.AfterConnect        := ConnAfterConnect;
    FConnection.AfterDisconnect     := ConnAfterDisconnect;
    FConnection.OnStartTransaction  := ConnOnStartTransaction;
    FConnection.OnCommit            := ConnOnCommit;
    FConnection.OnRollback          := ConnOnRollback;

    FQueryOfDatabase := NewQuery;
  end;
end;

destructor TDatabase.Destroy;
begin
  FreeAndNil(FQueryOfDatabase);
  FreeAndNil(FConnection);
  inherited;
end;

function TDatabase.GetNewRecordId: Integer;
begin
  Dec(FNewRecordId, 1);
  Result := FNewRecordId;
end;

function TDatabase.GetNow(AOnlyTime: Boolean = True): TDateTime;
begin
  Result := 0;
  with QueryOfDataBase do
  begin
    Close;
    SQL.Text := 'SELECT cast(NOW() as timestamp without time zone);';
    Open;
    while not EOF do
    begin
      Result := Fields.Fields[0].AsDateTime;
      Next;
    end;
    EmptyDataSet;
    Close;
  end;

  if AOnlyTime then
    Result := TimeOf(Result);
end;

function TDatabase.GetSQLInsertCmd(ATableName: string; AParamDelimiter: Char;
  AArrFieldNames: TArray<string>): string;
var
  nIndex: Integer;
  sFields, sParams: string;
  vSQL: TStringList;
begin
  vSQL := TStringList.Create;
  Result := '';
  try
    sFields := '';
    sParams := '';

    vSQL.Add('INSERT INTO ' + ATableName + '(');

    for nIndex := 0 to Length(AArrFieldNames)-1 do
    begin
      if AArrFieldNames[nIndex] <> '' then
      begin
        sFields := sFields + AArrFieldNames[nIndex] + ',';
        sParams := sParams + AParamDelimiter + AArrFieldNames[nIndex] + ',';
      end;

      if (nIndex = Length(AArrFieldNames)-1) and (sFields <> '') then
        sFields := LeftStr(sFields, Length(sFields)-1);

      if (nIndex = Length(AArrFieldNames)-1) and (sParams <> '') then
        sParams := LeftStr(sParams, Length(sParams)-1);
    end;

    vSQL.Add(sFields);
    vSQL.Add(') VALUES (');
    vSQL.Add(sParams);
    vSQL.Add(') RETURNING id');

    if (sFields = '') then
      raise Exception.Create('Database fields not found!');
  finally
    vSQL.LineBreak := '';
    Result := vSQL.Text;
    vSQL.Free;
  end;
end;

procedure TDatabase.GetSQLSelectCmd(AQry: TZQuery; ATableName: string; AFieldNames: TArray<string>; AWhereJoin: TArray<string>; AAllColumn: Boolean=True; AHelper: Boolean=False);
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
  if Length(AFieldNames) = 0 then
    raise Exception.Create('Database fields are not defined!' + AddLBs + 'This process cannot be done');

  if AQry <> nil then
  begin

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
          LGridCol.DisposeOf;
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
            LGridCol.DisposeOf;
          end;
        end;
      end;

      if AQry.SQL.Count > 1 then
        AQry.SQL.Strings[AQry.SQL.Count-1] := AQry.SQL.Strings[AQry.SQL.Count-1].Replace(', ', ' ');

      AQry.SQL.Add('FROM ' + ATableName + ' ');
      for nx := 0 to Length(AWhereJoin)-1 do
        AQry.SQL.Add(AWhereJoin[nx]);

  end;
end;

function TDatabase.GetSQLUpdateCmd(ATableName: string; AParamDelimiter: Char; AArrFieldNames: TArray<string>): string;
var
  nIndex: Integer;
  sFields: string;
  vSQL: TStringList;
begin
  vSQL := TStringList.Create;
  Result := '';
  try
    sFields := '';

    vSQL.Add('UPDATE ' + ATableName + ' SET ');

    for nIndex := 0 to Length(AArrFieldNames)-1 do
    begin
      if AArrFieldNames[nIndex] <> '' then
        sFields := sFields + AArrFieldNames[nIndex] + '=' + AParamDelimiter +
            RightStr(AArrFieldNames[nIndex], Length(AArrFieldNames[nIndex])- Pos('.', AArrFieldNames[nIndex])) + ', ';

      if (nIndex = Length(AArrFieldNames)-1) and (sFields <> '') then
        sFields := LeftStr(sFields, Length(sFields)-2);
    end;

    if sFields = '' then
      raise Exception.Create('Database fields not found!');

    vSQL.Add(sFields);

    vSQL.Add(' WHERE id=' + AParamDelimiter + 'id;');
  finally
    vSQL.LineBreak := '';
    Result := vSQL.Text;
    vSQL.Free;
  end;
end;

function TDatabase.GetToday(): TDateTime;
begin
  Result := 0;
  with QueryOfDataBase do
  begin
    Close;
    SQL.Text := 'SELECT CURRENT_DATE;';
    Open;
    while NOT EOF do
    begin
      Result := Fields.Fields[0].AsDateTime;
      Next;
    end;
    EmptyDataSet;
    Close;
  end;
end;

function TDatabase.NewConnection: TZConnection;
begin
  Result := TZConnection.Create(nil);
end;

function TDatabase.NewQuery(AConnection: TZConnection = nil): TZQuery;
begin
  Result := TZQuery.Create(nil);

  if AConnection = nil then
    Result.Connection := Self.FConnection
  else
    Result.Connection := AConnection;
end;

function TDatabase.NewStoredProcedure(AConnection: TZConnection = nil): TZStoredProc;
begin
  Result := TZStoredProc.Create(nil);

  if AConnection = nil then
    Result.Connection := Self.FConnection
  else
    Result.Connection := AConnection;
end;

function TDatabase.NewDataSource(ADataset: TDataSet): TDataSource;
begin
  Result := TDataSource.Create(nil);
  Result.DataSet := ADataset;
  Result.Enabled := True;
  Result.AutoEdit := True;
end;

procedure TDatabase.runCustomSQL(ASQL: string);
begin
  if ASQL <> '' then
  begin
    with QueryOfDataBase do
    begin
      Close;
      SQL.Text := ASQL;
      ExecSQL;

      SQL.Clear;
      Close;
    end;
  end;
end;

procedure TDatabase.SetQueryParamsDefaultValue(AQuery: TZQuery; AInput: Boolean = True);
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
