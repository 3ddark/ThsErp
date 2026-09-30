unit AccAccountAddress.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccAccountAddress;

type
  TAccAccountAddressRepository = class(TRepository<TAccAccountAddress>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccAccountAddress; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccAccountAddress; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccAccountAddress; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccAccountAddress>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccAccountAddress; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccAccountAddress; override;

    procedure DoAdd(AModel: TAccAccountAddress); override;
    procedure DoAddBatch(AModels: TArray<TAccAccountAddress>); override;

    procedure DoUpdate(AModel: TAccAccountAddress); override;
    procedure DoUpdateBatch(AModels: TArray<TAccAccountAddress>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccAccountAddress); override;
    procedure DoDeleteBatch(AModels: TArray<TAccAccountAddress>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TAccAccountAddressRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccAccountAddressRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccAccountAddress) +
            ' (acc_account_id, sys_address_id, address_type, is_primary, valid_from, valid_to) ' +
            ' VALUES (:acc_account_id, :sys_address_id, :address_type, :is_primary, :valid_from, :valid_to)';
end;

function TAccAccountAddressRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccAccountAddress) +
            ' SET acc_account_id = :acc_account_id, sys_address_id = :sys_address_id, address_type = :address_type, is_primary = :is_primary, valid_from = :valid_from, valid_to = :valid_to ' +
            ' WHERE id = :id';
end;

function TAccAccountAddressRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccAccountAddress) + ' WHERE';
end;

procedure TAccAccountAddressRepository.SetInsertParams(Q: TFDQuery; AModel: TAccAccountAddress; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('address_type').AsString := AModel.AddressType;
    Q.ParamByName('is_primary').AsBoolean := AModel.IsPrimary;
  end
  else
  begin
    Q.ParamByName('address_type').AsStrings[AIndex] := AModel.AddressType;
    Q.ParamByName('is_primary').AsBooleans[AIndex] := AModel.IsPrimary;
  end;

  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('sys_address_id'), ftLargeint, AModel.SysAddressId, AIndex);
  SetDate('valid_from', AModel.ValidFrom);
  SetDate('valid_to', AModel.ValidTo);
end;

procedure TAccAccountAddressRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccAccountAddress; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('address_type').AsString := AModel.AddressType;
    Q.ParamByName('is_primary').AsBoolean := AModel.IsPrimary;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('address_type').AsStrings[AIndex] := AModel.AddressType;
    Q.ParamByName('is_primary').AsBooleans[AIndex] := AModel.IsPrimary;
  end;

  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('sys_address_id'), ftLargeint, AModel.SysAddressId, AIndex);
  SetDate('valid_from', AModel.ValidFrom);
  SetDate('valid_to', AModel.ValidTo);
end;

function TAccAccountAddressRepository.MapFromQuery(Q: TFDQuery): TAccAccountAddress;
begin
  Result := TAccAccountAddress.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.SysAddressId := Q.FieldByName('sys_address_id').AsLargeInt;
  Result.AddressType := Q.FieldByName('address_type').AsString;
  Result.IsPrimary := Q.FieldByName('is_primary').AsBoolean;
  if Q.FieldByName('valid_from').IsNull then
    Result.ValidFrom := 0
  else
    Result.ValidFrom := Q.FieldByName('valid_from').AsDateTime;
  if Q.FieldByName('valid_to').IsNull then
    Result.ValidTo := 0
  else
    Result.ValidTo := Q.FieldByName('valid_to').AsDateTime;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.AddressText := Q.FieldByName('address_text').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
end;

function TAccAccountAddressRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccAccountAddress) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TAccAccountAddressRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccAccountAddress>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TAccAccountAddress>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      Result.Add(MapFromQuery(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TAccAccountAddressRepository.DoFindById(AId: TValue; ALock: Boolean): TAccAccountAddress;
var
  Q: TFDQuery;
  Criteria: TFilterCriteria;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  Criteria := TFilterCriteria.Create;
  try
    Q.Connection := Connection;

    Criteria.Add(TFilterCriterion.New('id', '=', AId));
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, False);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TAccAccountAddressRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccAccountAddress;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, False);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.DoAdd(AModel: TAccAccountAddress);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.DoAddBatch(AModels: TArray<TAccAccountAddress>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetInsertParams(Q, AModels[I], I);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.DoUpdate(AModel: TAccAccountAddress);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.DoUpdateBatch(AModels: TArray<TAccAccountAddress>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetUpdateParams(Q, AModels[I], I);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.DoDelete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    LogQuery(Q, 'DoDelete');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.DoDelete(AModel: TAccAccountAddress);
begin
  Delete(AModel.Id);
end;

procedure TAccAccountAddressRepository.DoDeleteBatch(AModels: TArray<TAccAccountAddress>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AIDs);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I].AsInt64;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.DoDeleteBatch(AFilter: TFilterCriteria);
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' 1=1 ';

    for Criteria in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoDeleteBatch');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
