unit BaseRepository;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.StrUtils, System.Rtti,
  System.TypInfo, System.Generics.Collections, Data.DB, Data.FMTBcd,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Logger, SharedFormTypes, BaseEntity,
  TableNameService;

type
  TRttiHelper = class
  public
    class function IsValueTypeEntity(AFieldObj: TObject; out AEntityRtti: TRttiInstanceType): Boolean;
  end;

  IBaseRepository<T> = interface
    ['{41099611-B2E2-4851-865D-F5417081E31F}']
  end;

  TBaseRepository<T: TEntity> = class(TInterfacedObject, IBaseRepository<T>)
  private
    function ExpandSQLWithParams(Q: TFDQuery): string;
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

    function CreateQueryForUI(const AFilterKey: string): string; virtual;

    function Find(AFilter: string; ALock: Boolean): TList<T>; virtual;
    function FindById(AId: Integer; ALock: Boolean): T; virtual;

    procedure Add(AModel: T); virtual;
    procedure AddBatch(AModels: TArray<T>); virtual;

    procedure Update(AModel: T); virtual;
    procedure UpdateBatch(AModels: TArray<T>); virtual;

    procedure Delete(AId: Int64); overload; virtual;
    procedure Delete(AModel: T); overload; virtual;
    procedure Delete(AFilter: TValue); overload; virtual;

    procedure DeleteBatch(AModels: TArray<T>); overload; virtual;
    procedure DeleteBatch(AIDs: TArray<Int64>); overload; virtual;
    procedure DeleteBatch(AFilter: string = ''); overload; virtual;

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
  AField: IEntityField;
  nestedRtti: TRttiInstanceType;
  NestedEntity: TEntity;
  subFld: IEntityField;
  pref: string;
begin
  for n1 := 0 to AEntity.Fields.Count - 1 do
  begin
    AField := AEntity.Fields.Items[n1];

    // primitive types handled as before
    case AField.FieldType of
      ftString:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsString);
      ftWideString:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsWideString);
      ftMemo:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsString);
      ftFmtMemo:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsString);

      ftShortint, ftWord, ftSmallint, ftInteger, ftLongWord:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsInteger);
      ftLargeint:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsLargeInt);
      ftBCD, ftFMTBcd:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsFloat);

      ftFloat:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsFloat);
      ftCurrency:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsFloat);

      ftBoolean:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsBoolean);

      ftDate, ftTime, ftDateTime:
        AField.ValueFirstSet(AQuery.FieldByName(AField.FieldName).AsDateTime)    else
      // Eğer buraya geliyorsa ftUnknown ya da özel tip — nested olabilir
      if TRttiHelper.IsValueTypeEntity((AField as TObject), nestedRtti) then
      begin
        // prefix: parentField_subFieldName  (örnek: address_street)
        pref := AField.FieldName + '_';

        // create nested entity instance
        NestedEntity := TRttiInstanceType(nestedRtti).MetaclassType.Create as TEntity;
        try
          // for each subfield of nested entity try to read query field by prefix
          for subFld in NestedEntity.Fields do
          begin
            if AQuery.FindField(pref + subFld.FieldName) <> nil then
            begin
              // delegating primitive mapping using existing field type
              case subFld.FieldType of
                ftString, ftMemo, ftFmtMemo:
                  subFld.ValueFirstSet(AQuery.FieldByName(pref + subFld.FieldName).AsString);
                ftWideString:
                  subFld.ValueFirstSet(AQuery.FieldByName(pref + subFld.FieldName).AsWideString);
                ftShortint, ftWord, ftSmallint, ftInteger, ftLongWord:
                  subFld.ValueFirstSet(AQuery.FieldByName(pref + subFld.FieldName).AsInteger);
                ftLargeint:
                  subFld.ValueFirstSet(AQuery.FieldByName(pref + subFld.FieldName).AsLargeInt);
                ftFloat, ftCurrency, ftFMTBcd, ftBCD:
                  subFld.ValueFirstSet(AQuery.FieldByName(pref + subFld.FieldName).AsFloat);
                ftBoolean:
                  subFld.ValueFirstSet(AQuery.FieldByName(pref + subFld.FieldName).AsBoolean);
                ftDate, ftTime, ftDateTime:
                  subFld.ValueFirstSet(AQuery.FieldByName(pref + subFld.FieldName).AsDateTime);
              else
                // nested içinde daha derin nested varsa bu örnekte işlenmedi (isteğe bağlı)
                ;
              end;
            end;
          end;

          // set nested value into AField.Value
          // set via RTTI: find 'Value' property
          var ctx := TRttiContext.Create;
          try
            var fR := ctx.GetType((AField as TObject).ClassType);
            var p := fR.GetProperty('Value');
            if Assigned(p) then
              p.SetValue(AField as TObject, TValue.From<TObject>(NestedEntity)); // NestedEntity ref assigned
          finally
            ctx.Free;
          end;

        except
          NestedEntity.Free;
          raise;
        end;
      end
      else
        raise Exception.Create('Unknow FieldType! Process: FindById, Event: Set Query Parameter value. FieldName: ' + (AEntity.Fields.Items[n1].FieldName));
    end;
  end;
end;

procedure TBaseRepository<T>.EntityToQueryParam(AQuery: TFDQuery; AEntity: T; AForAdd: Boolean);
var
  n1: Integer;
  AField: IEntityField;
  nestedRtti: TRttiInstanceType;
  NestedEntity: TEntity;
  subFld: IEntityField;
  pref: string;
  ctx: TRttiContext;
  fR: TRttiType;
  p: TRttiProperty;
begin
  for n1 := 0 to AEntity.Fields.Count - 1 do
  begin
    AField := AEntity.Fields.Items[n1];

    if AForAdd and (AField.FieldName = 'id') then
      Continue;

    if TRttiHelper.IsValueTypeEntity(AField as TObject, nestedRtti) then
    begin
      // nested: set parameters using prefix parent_subfield
      pref := AField.FieldName + '_';
      ctx := TRttiContext.Create;
      try
        fR := ctx.GetType((AField as TObject).ClassType);
        p := fR.GetProperty('Value');
        if Assigned(p) then
        begin
          if not p.GetValue(AField as TObject).IsEmpty then
          begin
            NestedEntity := TEntity(p.GetValue(AField as TObject).AsObject);
            if Assigned(NestedEntity) then
            begin
              for subFld in NestedEntity.Fields do
              begin
                if AQuery.ParamByName(pref + subFld.FieldName) = nil then
                  Continue; // param yoksa atla

                case subFld.FieldType of
                  ftString, ftMemo, ftFmtMemo:
                    AQuery.ParamByName(pref + subFld.FieldName).AsString := subFld.AsString;
                  ftWideString:
                    AQuery.ParamByName(pref + subFld.FieldName).AsWideString := subFld.AsString;
                  ftShortint, ftWord, ftSmallint, ftInteger, ftLongWord:
                    AQuery.ParamByName(pref + subFld.FieldName).AsInteger := subFld.AsInteger;
                  ftLargeint:
                    AQuery.ParamByName(pref + subFld.FieldName).AsLargeInt := subFld.AsInt64;
                  ftFloat, ftCurrency, ftFMTBcd, ftBCD:
                    AQuery.ParamByName(pref + subFld.FieldName).AsFloat := subFld.AsFloat;
                  ftBoolean:
                    AQuery.ParamByName(pref + subFld.FieldName).AsBoolean := subFld.AsBoolean;
                  ftDate, ftTime, ftDateTime:
                    AQuery.ParamByName(pref + subFld.FieldName).AsDateTime := subFld.AsDateTime;
                else
                  ;
                end;
              end;
            end;
          end;
        end;
      finally
        ctx.Free;
      end;
    end
    else
    begin
      // mevcut kodunuzu koruyun (primitive mapping)
      case AField.FieldType of
        ftString:
          AQuery.ParamByName(AField.FieldName).AsString := AField.AsString;
        ftWideString:
          AQuery.ParamByName(AField.FieldName).AsWideString := AField.AsString;
        ftMemo:
          AQuery.ParamByName(AField.FieldName).AsString := AField.AsString;
        ftFmtMemo:
          AQuery.ParamByName(AField.FieldName).AsString := AField.AsString;

        ftShortint:
          AQuery.ParamByName(AField.FieldName).AsShortInt := AField.AsInteger;
        ftWord:
          AQuery.ParamByName(AField.FieldName).AsWord := AField.AsInteger;
        ftSmallint:
          AQuery.ParamByName(AField.FieldName).AsSmallInt := AField.AsInteger;
        ftInteger:
          AQuery.ParamByName(AField.FieldName).AsInteger := AField.AsInteger;
        ftLongWord:
          AQuery.ParamByName(AField.FieldName).AsLongword := AField.AsInteger;
        ftLargeint:
          AQuery.ParamByName(AField.FieldName).AsLargeInt := AField.AsInt64;
        ftBCD:
          AQuery.ParamByName(AField.FieldName).AsBCD := AField.AsInteger;
        ftFMTBcd:
          AQuery.ParamByName(AField.FieldName).AsFMTBCD := AField.AsInteger;

        ftFloat:
          AQuery.ParamByName(AField.FieldName).AsFloat := AField.AsFloat;
        ftCurrency:
          AQuery.ParamByName(AField.FieldName).AsCurrency := AField.AsFloat;

        ftBoolean:
          AQuery.ParamByName(AField.FieldName).AsBoolean := AField.AsBoolean;

        ftDate:
          AQuery.ParamByName(AField.FieldName).AsDate := AField.AsDateTime;
        ftTime:
          AQuery.ParamByName(AField.FieldName).AsTime := AField.AsDateTime;
        ftDateTime:
          AQuery.ParamByName(AField.FieldName).AsDateTime := AField.AsDateTime;
      else
        raise Exception.Create('Unknow FieldType! Event: Set Query Parameter value. FieldName: ' + (AField.FieldName));
      end;
    end;
  end;
end;

function TBaseRepository<T>.NewQuery(AOwner: TComponent): TFDQuery;
begin
  Result := TFDQuery.Create(AOwner);
  Result.Connection := FConnection;
end;

function TBaseRepository<T>.CreateQueryForUI(const AFilterKey: string): string;
var
  SQL, LTableName: string;
  Entity: T;
  n1: Integer;
begin
  Result := '';
  try
    Entity := CallCreateMethod;
    try
      LTableName := TTableNameService.TableName(Entity);
      SQL := Format('SELECT * FROM %s WHERE 1=1 ;', [LTableName]);
    finally
      for n1 := 0 to Entity.Fields.Count - 1 do
      begin
        if Entity.Fields[n1].OwnerEntity <> nil then
          Entity.Fields[n1].OwnerEntity := nil;
      end;
    end;

    Result := SQL;
  except
    raise;
  end;
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

    Q.SQL.Text := Format('SELECT * FROM %s WHERE 1=1 %s;', [LTableName, AFilter]);
    Q.Open;
    GLogger.RunLog(ExpandSQLWithParams(Q));

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
  LTableName, LockQuery: string;
begin
  if AId <= 0 then
    Exit(nil);

  Result := CallCreateMethod;

  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(Result.ClassType);

    LockQuery := ';';
    if ALock then
      LockQuery := ' FOR UPDATE OF ' + LTableName + ' NOWAIT; ';

    Q.SQL.Text := Format('SELECT * FROM %s WHERE %s %s', [LTableName, Result.Id.QryName + '=' + AId.ToString, LockQuery]);
    Q.Open;
    GLogger.RunLog(ExpandSQLWithParams(Q));
    QueryToEntityValue(Q, Result);
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
    for n1 := 0 to AModel.Fields.Count - 1 do
    begin
      if AModel.Fields[n1].FieldName <> 'id' then
      begin
        LFieldNames := LFieldNames + AModel.Fields[n1].FieldName + ',';
        LParams := LParams + ':' + AModel.Fields[n1].FieldName + ',';
      end;
    end;
    LFieldNames := Trim(LFieldNames);
    LFieldNames := LeftStr(LFieldNames, Length(LFieldNames) - 1);

    LParams := Trim(LParams);
    LParams := LeftStr(LParams, Length(LParams) - 1);

    Q.SQL.Text := Format('INSERT INTO %s (' + LFieldNames + ') VALUES (' + LParams + ') RETURNING %s;', [LTableName, AModel.Id.FieldName]);

    EntityToQueryParam(Q, AModel, True);

    Q.Open;
    GLogger.RunLog(ExpandSQLWithParams(Q));
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
  Self.DeleteById(AModel.Id.Value, TTableNameService.TableName(AModel.ClassType));
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
    Q.SQL.Text := Format('DELETE FROM %s WHERE 1=1 %s;', [LTableName, 'p_filter']);
    Q.ParamByName('p_filter').AsString := AFilter.AsString;
    Q.ExecSQL;
    GLogger.RunLog(ExpandSQLWithParams(Q));
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
    Q.SQL.Text := Format('DELETE FROM %s WHERE id=:%s;', [ATableName, 'p_id']);
    Q.ParamByName('p_id').AsInteger := AId;
    Q.ExecSQL;
    GLogger.RunLog(ExpandSQLWithParams(Q));
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
    for n1 := 0 to AModel.Fields.Count - 1 do
    begin
      if AModel.Fields[n1].FieldName <> 'id' then
        LFieldNames := LFieldNames + AModel.Fields[n1].FieldName + ':' + AModel.Fields[n1].FieldName + ',';
    end;
    LFieldNames := Trim(LFieldNames);
    LFieldNames := LeftStr(LFieldNames, Length(LFieldNames) - 1);

    LParams := Trim(LParams);
    LParams := LeftStr(LParams, Length(LParams) - 1);

    Q.SQL.Text := Format('UPDATE %s SET ' + LFieldNames + ' WHERE %s', [LTableName, LFieldNames, AModel.Id.FieldName + ':' + AModel.Id.FieldName]);

    EntityToQueryParam(Q, AModel, False);

    Q.ExecSQL;
    GLogger.RunLog(ExpandSQLWithParams(Q));
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
    GLogger.RunLog(ExpandSQLWithParams(Q));
    Result := Q.Fields[0].AsBoolean;
  finally
    Q.Free;
  end;
end;

function TBaseRepository<T>.ExpandSQLWithParams(Q: TFDQuery): string;
var
  SQLText: string;
  Param: TFDParam;
  ParamValue: string;
  i: Integer;
begin
  SQLText := Q.SQL.Text;

  for i := 0 to Q.Params.Count - 1 do
  begin
    Param := Q.Params[i];

    // NULL değer kontrolü
    if Param.IsNull then
      ParamValue := 'NULL'

    // Sayısal değerler doğrudan yazılır
    else if Param.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftLargeInt, ftShortint, ftByte, ftLongWord, ftExtended] then
      ParamValue := Param.AsString

    // Boolean değerler için true/false yazılır
    else if Param.DataType = ftBoolean then
    begin
      if Param.AsBoolean then
        ParamValue := 'TRUE'
      else
        ParamValue := 'FALSE';
    end

    // Tarih / saat değerleri için uygun format ve tek tırnak
    else if Param.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then
      ParamValue := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Param.AsDateTime))

    // Diğerleri (metin vs.) tek tırnak içinde yazılır
    else
      ParamValue := QuotedStr(Param.AsString);

    // Parametre adlarını tüm geçtiği yerlerde değiştir
    SQLText := StringReplace(SQLText, ':' + Param.Name, ParamValue, [rfReplaceAll, rfIgnoreCase]);
  end;

  Result := SQLText;
end;

{ TRttiHelper }

class function TRttiHelper.IsValueTypeEntity(AFieldObj: TObject; out AEntityRtti: TRttiInstanceType): Boolean;
var
  ctx: TRttiContext;
  fldType: TRttiType;
  valProp: TRttiProperty;
  valType: TRttiType;
begin
  Result := False;
  AEntityRtti := nil;
  ctx := TRttiContext.Create;
  try
    fldType := ctx.GetType(AFieldObj.ClassType);
    valProp := fldType.GetProperty('Value');
    if not Assigned(valProp) then
      Exit;

    valType := valProp.PropertyType;
    if (valType is TRttiInstanceType) then
    begin
      if TRttiInstanceType(valType).MetaclassType.InheritsFrom(TEntity) then
      begin
        AEntityRtti := TRttiInstanceType(valType);
        Result := True;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

end.

