unit BaseRepository;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.StrUtils,
  System.Rtti, System.TypInfo, System.Generics.Collections, DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, TableNameService;

type
  IBaseRepository<T> = interface
    ['{41099611-B2E2-4851-865D-F5417081E31F}']
  end;

  TBaseRepository<T: TEntity> = class(TInterfacedObject, IBaseRepository<T>)
  private
    function CallCreateMethod<T>: T;
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

function TBaseRepository<T>.Find(AFilter: string; ALock: Boolean): TList<T>;
begin
//
end;

function TBaseRepository<T>.FindById(AId: Integer; ALock: Boolean): T;
var
  Q: TFDQuery;
  LTableName, LFieldNames, LParams: string;
  n1: Integer;
begin
  if AId <= 0 then
    Exit;

  Result := CallCreateMethod<T>;

  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(Result.ClassType);

    Q.SQL.Text := Format('SELECT * FROM %s WHERE %s', [LTableName, Result.Id.QryName + '=' + AId.ToString]);

    for n1 := 0 to Result.Fields.Count-1 do
    begin
      case Result.Fields.Items[n1].FieldType of
        ftString: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsString);
        ftWideString: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsWideString);
        ftMemo: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsString);
        ftFmtMemo: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsString);

        ftShortint: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsInteger);
        ftWord: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsInteger);
        ftSmallint: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsInteger);
        ftInteger: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsInteger);
        ftLongWord: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsInteger);
        ftLargeint: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsLargeInt);
        ftBCD: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsInteger);
        ftFMTBcd: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsFloat);

        ftFloat: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsFloat);
        ftCurrency: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsFloat);

        ftBoolean: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsBoolean);

        ftDate: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsDateTime);
        ftTime: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsDateTime);
        ftDateTime: Result.Fields.Items[n1].ValueFirstSet(Q.FieldByName(Result.Fields.Items[n1].FieldName).AsDateTime);
      else
        raise Exception.Create('Unknow FieldType! Process: FindById, Event: Set Query Parameter value. FieldName: ' + (Result.Fields.Items[n1].FieldName));
      end;
    end;

    Q.Open;

  finally
    Q.Free;
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

    for n1 := 0 to AModel.Fields.Count-1 do
    begin
      if AModel.Fields.Items[n1].FieldName = 'id' then
        Continue;

      case AModel.Fields.Items[n1].FieldType of
        ftString: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsString := AModel.Fields.Items[n1].AsString;
        ftWideString: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsWideString := AModel.Fields.Items[n1].AsString;
        ftMemo: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsString := AModel.Fields.Items[n1].AsString;
        ftFmtMemo: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsString := AModel.Fields.Items[n1].AsString;

        ftShortint: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsShortInt := AModel.Fields.Items[n1].AsInteger;
        ftWord: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsWord := AModel.Fields.Items[n1].AsInteger;
        ftSmallint: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsSmallInt := AModel.Fields.Items[n1].AsInteger;
        ftInteger: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsInteger := AModel.Fields.Items[n1].AsInteger;
        ftLongWord: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsLongword := AModel.Fields.Items[n1].AsInteger;
        ftLargeint: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsLargeInt := AModel.Fields.Items[n1].AsInt64;
        ftBCD: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsBCD := AModel.Fields.Items[n1].AsInteger;
        ftFMTBcd: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsFMTBCD := AModel.Fields.Items[n1].AsInteger;

        ftFloat: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsFloat := AModel.Fields.Items[n1].AsFloat;
        ftCurrency: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsCurrency := AModel.Fields.Items[n1].AsFloat;

        ftBoolean: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsBoolean := AModel.Fields.Items[n1].AsBoolean;

        ftDate: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsDate := AModel.Fields.Items[n1].AsDateTime;
        ftTime: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsTime := AModel.Fields.Items[n1].AsDateTime;
        ftDateTime: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsDateTime := AModel.Fields.Items[n1].AsDateTime;
      else
        raise Exception.Create('Unknow FieldType! Process: Add, Event: Set Query Parameter value. FieldName: ' + (AModel.Fields.Items[n1].FieldName));
      end;
    end;

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

function TBaseRepository<T>.CallCreateMethod<T>: T;
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

constructor TBaseRepository<T>.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Repository için geçerli bir bağlantı nesnesi sağlanmadı.');
  FConnection := AConnection;
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

    for n1 := 0 to AModel.Fields.Count-1 do
    begin
      case AModel.Fields.Items[n1].FieldType of
        ftString: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsString := AModel.Fields.Items[n1].AsString;
        ftWideString: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsWideString := AModel.Fields.Items[n1].AsString;
        ftMemo: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsString := AModel.Fields.Items[n1].AsString;
        ftFmtMemo: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsString := AModel.Fields.Items[n1].AsString;

        ftShortint: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsShortInt := AModel.Fields.Items[n1].AsInteger;
        ftWord: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsWord := AModel.Fields.Items[n1].AsInteger;
        ftSmallint: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsSmallInt := AModel.Fields.Items[n1].AsInteger;
        ftInteger: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsInteger := AModel.Fields.Items[n1].AsInteger;
        ftLongWord: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsLongword := AModel.Fields.Items[n1].AsInteger;
        ftLargeint: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsLargeInt := AModel.Fields.Items[n1].AsInt64;
        ftBCD: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsBCD := AModel.Fields.Items[n1].AsInteger;
        ftFMTBcd: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsFMTBCD := AModel.Fields.Items[n1].AsInteger;

        ftFloat: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsFloat := AModel.Fields.Items[n1].AsFloat;
        ftCurrency: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsCurrency := AModel.Fields.Items[n1].AsFloat;

        ftBoolean: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsBoolean := AModel.Fields.Items[n1].AsBoolean;

        ftDate: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsDate := AModel.Fields.Items[n1].AsDateTime;
        ftTime: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsTime := AModel.Fields.Items[n1].AsDateTime;
        ftDateTime: Q.ParamByName(AModel.Fields.Items[n1].FieldName).AsDateTime := AModel.Fields.Items[n1].AsDateTime;
      else
        raise Exception.Create('Unknow FieldType! Process: Add, Event: Set Query Parameter value. FieldName: ' + (AModel.Fields.Items[n1].FieldName));
      end;
    end;

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

function TBaseRepository<T>.NewQuery(AOwner: TComponent): TFDQuery;
begin
  Result := TFDQuery.Create(AOwner);
  Result.Connection := FConnection;
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

