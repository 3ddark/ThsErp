unit BaseRepository;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.StrUtils,
  System.Rtti, System.TypInfo, System.Generics.Collections, Data.DB, Data.FMTBcd,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, TableNameService;

type
  IBaseRepository<T> = interface
    ['{41099611-B2E2-4851-865D-F5417081E31F}']
  end;

  TBaseRepository<T: TEntity> = class(TInterfacedObject, IBaseRepository<T>)
  private
    function CallCreateMethod: T;
    procedure QueryToEntityValue(AQuery: TFDQuery; AEntity: T);
    procedure EntityToQueryParam(AQuery: TFDQuery; AEntity: T; AForAdd: Boolean);
  protected
    FConnection: TFDConnection;
    function NewQuery(AOwner: TComponent): TFDQuery;
  public
    constructor Create(AConnection: TFDConnection);

    property Connection: TFDConnection read FConnection;

    function ExistsByField(const AFieldName: string; const AValue: TValue): Boolean;

    function CreateQueryForUI(const AFilterKey: string): string; virtual; abstract;

    function Find(AFilter: string; ALock: Boolean): TList<T>; virtual;
    function FindById(AId: Integer; ALock: Boolean): T; virtual;

    procedure Add(AModel: T); virtual;
    procedure AddBatch(AModels: TArray<T>); virtual;

    procedure Update(AModel: T); virtual;
    procedure UpdateBatch(AModels: TArray<T>); virtual;

    procedure Delete(AId: Int64); overload; virtual;
    procedure Delete(AModel: T); overload; virtual;
    procedure Delete(AFilter: TValue); overload; virtual;

    procedure DeleteBatch(AModels: TArray<T>); overload;
    procedure DeleteBatch(AIDs: TArray<Int64>); overload;
    procedure DeleteBatch(AFilter: string = ''); overload;

    procedure DeleteById(AId: Integer; ATableName: string);
  end;

implementation

constructor TBaseRepository<T>.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Repository için geçerli bir bağlantı nesnesi sağlanmadı.');
  FConnection := AConnection;
end;

function TBaseRepository<T>.CallCreateMethod: T;
var
  rC: TRttiContext;
  rT: TRttiType;
  rM: TRttiMethod;
  n1: Integer;
  rPrms: TArray<TRttiParameter>;
  rParams: TArray<TValue>;
begin
  rT := rC.GetType(TypeInfo(T));
  rM := rT.GetMethod('Create');
  rPrms := rM.GetParameters;
  SetLength(rParams, Length(rPrms));
  for n1 := 0 to Length(rPrms) - 1 do
  begin
    case rPrms[n1].ParamType.TypeKind of
      tkClass:
        rParams[n1] := TValue.From<TObject>(nil);
      tkString, tkLString:
        rParams[n1] := TValue.From<string>('');
      tkUString:
        rParams[n1] := TValue.From<UnicodeString>('');
      tkWideString:
        rParams[n1] := TValue.From<UnicodeString>('');
      tkInteger, tkInt64:
        rParams[n1] := TValue.From<Integer>(0);
      tkFloat:
        rParams[n1] := TValue.From<Double>(0);
    end;
  end;

//  if rM.IsConstructor then
    Result := rM.Invoke(rT.AsInstance.MetaclassType, rParams).AsType<T>;
end;

procedure TBaseRepository<T>.QueryToEntityValue(AQuery: TFDQuery; AEntity: T);
var
  n1: Integer;
begin
  for n1 := 0 to AEntity.Fields.Count-1 do
  begin
    case AEntity.Fields.Items[n1].FieldType of
      ftString: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsString);
      ftWideString: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsWideString);
      ftMemo: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsString);
      ftFmtMemo: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsString);

      ftShortint: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsInteger);
      ftWord: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsInteger);
      ftSmallint: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsInteger);
      ftInteger: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsInteger);
      ftLongWord: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsInteger);
      ftLargeint: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsLargeInt);
      ftBCD: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsInteger);
      ftFMTBcd: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsFloat);

      ftFloat: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsFloat);
      ftCurrency: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsFloat);

      ftBoolean: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsBoolean);

      ftDate: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsDateTime);
      ftTime: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsDateTime);
      ftDateTime: AEntity.Fields.Items[n1].ValueFirstSet(AQuery.FieldByName(AEntity.Fields.Items[n1].FieldName).AsDateTime);
    else
      raise Exception.Create('Unknow FieldType! Process: FindById, Event: Set Query Parameter value. FieldName: ' + (AEntity.Fields.Items[n1].FieldName));
    end;
  end;
end;

procedure TBaseRepository<T>.EntityToQueryParam(AQuery: TFDQuery; AEntity: T; AForAdd: Boolean);
var
  n1: Integer;
begin
  for n1 := 0 to AEntity.Fields.Count-1 do
  begin
    if AForAdd and (AEntity.Fields.Items[n1].FieldName = 'id') then
      Continue;

    case AEntity.Fields.Items[n1].FieldType of
      ftString: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsString := AEntity.Fields.Items[n1].AsString;
      ftWideString: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsWideString := AEntity.Fields.Items[n1].AsString;
      ftMemo: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsString := AEntity.Fields.Items[n1].AsString;
      ftFmtMemo: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsString := AEntity.Fields.Items[n1].AsString;

      ftShortint: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsShortInt := AEntity.Fields.Items[n1].AsInteger;
      ftWord: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsWord := AEntity.Fields.Items[n1].AsInteger;
      ftSmallint: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsSmallInt := AEntity.Fields.Items[n1].AsInteger;
      ftInteger: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsInteger := AEntity.Fields.Items[n1].AsInteger;
      ftLongWord: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsLongword := AEntity.Fields.Items[n1].AsInteger;
      ftLargeint: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsLargeInt := AEntity.Fields.Items[n1].AsInt64;
      ftBCD: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsBCD := AEntity.Fields.Items[n1].AsInteger;
      ftFMTBcd: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsFMTBCD := AEntity.Fields.Items[n1].AsInteger;

      ftFloat: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsFloat := AEntity.Fields.Items[n1].AsFloat;
      ftCurrency: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsCurrency := AEntity.Fields.Items[n1].AsFloat;

      ftBoolean: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsBoolean := AEntity.Fields.Items[n1].AsBoolean;

      ftDate: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsDate := AEntity.Fields.Items[n1].AsDateTime;
      ftTime: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsTime := AEntity.Fields.Items[n1].AsDateTime;
      ftDateTime: AQuery.ParamByName(AEntity.Fields.Items[n1].FieldName).AsDateTime := AEntity.Fields.Items[n1].AsDateTime;
    else
      raise Exception.Create('Unknow FieldType! Event: Set Query Parameter value. FieldName: ' + (AEntity.Fields.Items[n1].FieldName));
    end;
  end;
end;

function TBaseRepository<T>.NewQuery(AOwner: TComponent): TFDQuery;
begin
  Result := TFDQuery.Create(AOwner);
  Result.Connection := FConnection;
end;

function TBaseRepository<T>.Find(AFilter: string; ALock: Boolean): TList<T>;
var
  Q: TFDQuery;
  LTableName: string;
  LTable: T;
begin
  Result := TList<T>.Create;

  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(T);

    Q.SQL.Text := Format('SELECT * FROM %s WHERE 1=1 %s', [LTableName, AFilter]);
    Q.Open;

    while not Q.Eof do
    begin
      LTable := CallCreateMethod;
      QueryToEntityValue(Q, LTable);
      Result.Add(LTable);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TBaseRepository<T>.FindById(AId: Integer; ALock: Boolean): T;
var
  Q: TFDQuery;
  LTableName: string;
begin
  if AId <= 0 then
    Exit(nil);

  Result := CallCreateMethod;
  try
    Q := NewQuery(nil);
    try
      LTableName := TTableNameService.TableName(Result.ClassType);
      Q.SQL.Text := Format('SELECT * FROM %s WHERE %s', [LTableName, Result.Id.QryName + '=' + AId.ToString]);
      Q.Open;
      QueryToEntityValue(Q, Result);
    finally
      Q.Free;
    end;
  except
    raise;
  end;
end;

procedure TBaseRepository<T>.Add(AModel: T);
var
  Q: TFDQuery;
  LTableName, LFieldNames, LParams: string;
  n1: Integer;
begin
  if AModel.Fields.Count < 2 then
    Exit;

  if AModel.Id.Value > 0 then
    Exit;

  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(AModel.ClassType);

    LFieldNames := '';
    LParams := '';
    for n1 := 0 to AModel.Fields.Count-1 do
    begin
      if AModel.Fields[n1].FieldName <> 'id' then
      begin
        LFieldNames := LFieldNames + AModel.Fields[n1].FieldName + ',';
        LParams := LParams + ':' + AModel.Fields[n1].FieldName + ',';
      end;
    end;
    LFieldNames := Trim(LFieldNames);
    LFieldNames := LeftStr(LFieldNames, Length(LFieldNames)-1);

    LParams := Trim(LParams);
    LParams := LeftStr(LParams, Length(LParams)-1);

    Q.SQL.Text := Format('INSERT INTO %s (' + LFieldNames + ') VALUES (' + LParams + ') RETURNING %s', [LTableName, AModel.Id.FieldName]);

    EntityToQueryParam(Q, AModel, True);

    Q.Open;
    AModel.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
  finally
    Q.Free;
  end;
end;

procedure TBaseRepository<T>.AddBatch(AModels: TArray<T>);
var
  AModel: T;
begin
  for AModel in AModels do
    Self.Add(AModel);
end;

procedure TBaseRepository<T>.Delete(AModel: T);
begin
  Self.DeleteById(AModel.Id.Value, TTableNameService.TableName(AModel));
end;

procedure TBaseRepository<T>.Delete(AId: Int64);
begin
  Self.DeleteById(AId, TTableNameService.TableName(T));
end;

procedure TBaseRepository<T>.Delete(AFilter: TValue);
var
  Q: TFDQuery;
  LTableName: string;
begin
  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(T);
    Q.SQL.Text := Format('DELETE FROM %s WHERE 1=1 ', [LTableName, 'p_filter']);
    Q.ParamByName('p_filter').AsString := AFilter.AsString;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TBaseRepository<T>.DeleteBatch(AFilter: string);
begin
  Self.Delete(AFilter);
end;

procedure TBaseRepository<T>.DeleteBatch(AIDs: TArray<Int64>);
var
  LID: Int64;
begin
  for LID in AIDs do
    Self.Delete(LID);
end;

procedure TBaseRepository<T>.DeleteBatch(AModels: TArray<T>);
var
  AModel: T;
begin
  for AModel in AModels do
    Self.Delete(AModel);
end;

procedure TBaseRepository<T>.DeleteById(AId: Integer; ATableName: string);
var
  Q: TFDQuery;
begin
  Q := NewQuery(nil);
  try
    Q.SQL.Text := Format('DELETE FROM %s WHERE id = :%s', [ATableName, 'p_id']);
    Q.ParamByName('p_id').AsInteger := AId;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TBaseRepository<T>.Update(AModel: T);
var
  Q: TFDQuery;
  LTableName, LFieldNames, LParams: string;
  n1: Integer;
begin
  if AModel.Fields.Count < 2 then
    Exit;

  if AModel.Id.Value > 0 then
    Exit;

  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(AModel.ClassType);

    LFieldNames := '';
    LParams := '';
    for n1 := 0 to AModel.Fields.Count-1 do
    begin
      if AModel.Fields[n1].FieldName <> 'id' then
        LFieldNames := LFieldNames + AModel.Fields[n1].FieldName + ':' + AModel.Fields[n1].FieldName + ',';
    end;
    LFieldNames := Trim(LFieldNames);
    LFieldNames := LeftStr(LFieldNames, Length(LFieldNames)-1);

    LParams := Trim(LParams);
    LParams := LeftStr(LParams, Length(LParams)-1);

    Q.SQL.Text := Format('UPDATE %s SET ' + LFieldNames + ' WHERE %s', [LTableName, LFieldNames, AModel.Id.FieldName + ':' + AModel.Id.FieldName]);

    EntityToQueryParam(Q, AModel, False);

    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TBaseRepository<T>.UpdateBatch(AModels: TArray<T>);
var
  AModel: T;
begin
  for AModel in AModels do
    Self.Update(AModel);
end;

function TBaseRepository<T>.ExistsByField(const AFieldName: string; const AValue: TValue): Boolean;
var
  Q: TFDQuery;
  V: TValue;
  LTableName: string;
begin
  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(T);
    Q.SQL.Text := Format('SELECT EXISTS(SELECT id FROM %s WHERE %s = :p_value);', [LTableName, AFieldName]);

    V := TValue.From(AValue);
    case V.Kind of
      tkUString, tkString, tkWString:
        Q.ParamByName('p_value').AsString := V.AsString;
      tkInteger, tkInt64:
        Q.ParamByName('p_value').AsInteger := V.AsInteger;
      tkFloat:
        begin
          if SameText(string(V.TypeInfo.Name), 'TDateTime') then
            Q.ParamByName('p_value').AsDateTime := V.AsExtended
          else if SameText(string(V.TypeInfo.Name), 'TDate') then
            Q.ParamByName('p_value').AsDate := V.AsExtended
          else if SameText(string(V.TypeInfo.Name), 'TTime') then
            Q.ParamByName('p_value').AsDate := V.AsExtended
          else
            Q.ParamByName('p_value').AsFloat := V.AsExtended;
        end;
    else
        raise Exception.Create('Unsupported field type in ExistsByField');
    end;

    Q.Open;
    Result := Q.Fields[0].AsBoolean;
  finally
    Q.Free;
  end;
end;

end.

