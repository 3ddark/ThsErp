unit AccAccountAddress.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Entity, Repository, AccAccountAddress, FilterCriterion;

type
  TAccAccountAddressRepository = class(TRepository<TAccAccountAddress>)
  protected
    function PrepareSelectSql: string; virtual;
    function PrepareAddSql: string; virtual;
    function PrepareUpdateSql: string; virtual;
    function PrepareDeleteSql: string; virtual;

    procedure SetModelParams(Q: TFDQuery; AModel: TAccAccountAddress; AIndex: Integer = -1);
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function FindById(AId: TValue; ALock: Boolean = False): TAccAccountAddress; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccAccountAddress; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TAccAccountAddress>; override;

    procedure Add(AModel: TAccAccountAddress); override;
    procedure AddBatch(AModels: TArray<TAccAccountAddress>); override;

    procedure Update(AModel: TAccAccountAddress); override;
    procedure UpdateBatch(AModels: TArray<TAccAccountAddress>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TAccAccountAddress); override;
    procedure DeleteBatch(AModels: TArray<TAccAccountAddress>); override;
  end;

implementation

constructor TAccAccountAddressRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccAccountAddressRepository.PrepareSelectSql: string;
begin
  Result := 'SELECT id, account_id, address_id, address_type, is_primary, valid_from, valid_to FROM public.' + Self.GetTableName(TAccAccountAddress);
end;

function TAccAccountAddressRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccAccountAddress) +
    ' (account_id, address_id, address_type, is_primary, valid_from, valid_to)' +
    ' VALUES (:account_id, :address_id, :address_type, :is_primary, :valid_from, :valid_to)';
end;

function TAccAccountAddressRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccAccountAddress) +
    ' SET account_id = :account_id, address_id = :address_id, address_type = :address_type,' +
    ' is_primary = :is_primary, valid_from = :valid_from, valid_to = :valid_to WHERE id = :id';
end;

function TAccAccountAddressRepository.PrepareDeleteSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccAccountAddress) + ' WHERE id = :id';
end;

procedure TAccAccountAddressRepository.SetModelParams(Q: TFDQuery; AModel: TAccAccountAddress; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('account_id').AsLargeInt := AModel.AccountId;
    Q.ParamByName('address_id').AsLargeInt := AModel.AddressId;
    Q.ParamByName('address_type').AsString := AModel.AddressType;
    Q.ParamByName('is_primary').AsBoolean := AModel.IsPrimary;

    if AModel.ValidFrom > 0 then
      Q.ParamByName('valid_from').AsDate := AModel.ValidFrom
    else
      Q.ParamByName('valid_from').Clear;

    if AModel.ValidTo > 0 then
      Q.ParamByName('valid_to').AsDate := AModel.ValidTo
    else
      Q.ParamByName('valid_to').Clear;

    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInt := AModel.Id;
  end
  else
  begin
    Q.ParamByName('account_id').AsLargeInts[AIndex] := AModel.AccountId;
    Q.ParamByName('address_id').AsLargeInts[AIndex] := AModel.AddressId;
    Q.ParamByName('address_type').AsStrings[AIndex] := AModel.AddressType;
    Q.ParamByName('is_primary').AsBooleans[AIndex] := AModel.IsPrimary;

    if AModel.ValidFrom > 0 then
      Q.ParamByName('valid_from').AsDates[AIndex] := AModel.ValidFrom
    else
      Q.ParamByName('valid_from').Clear(AIndex);

    if AModel.ValidTo > 0 then
      Q.ParamByName('valid_to').AsDates[AIndex] := AModel.ValidTo
    else
      Q.ParamByName('valid_to').Clear(AIndex);

    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
  end;
end;

function TAccAccountAddressRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM public.' + GetTableName(TAccAccountAddress) + ' WHERE 1=1 ';
end;

procedure TAccAccountAddressRepository.Add(AModel: TAccAccountAddress);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetModelParams(Q, AModel);
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.AddBatch(AModels: TArray<TAccAccountAddress>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.Update(AModel: TAccAccountAddress);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetModelParams(Q, AModel);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.UpdateBatch(AModels: TArray<TAccAccountAddress>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.Delete(AID: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.ParamByName('id').AsLargeInt := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TAccAccountAddressRepository.Delete(AModel: TAccAccountAddress);
begin
  Delete(AModel.Id);
end;

procedure TAccAccountAddressRepository.DeleteBatch(AModels: TArray<TAccAccountAddress>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

function TAccAccountAddressRepository.FindById(AId: TValue; ALock: Boolean): TAccAccountAddress;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE id = :id';
    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TAccAccountAddress.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.AccountId := Q.FieldByName('account_id').AsLargeInt;
      Result.AddressId := Q.FieldByName('address_id').AsLargeInt;
      Result.AddressType := Q.FieldByName('address_type').AsString;
      Result.IsPrimary := Q.FieldByName('is_primary').AsBoolean;
      Result.ValidFrom := Q.FieldByName('valid_from').AsDateTime;
      Result.ValidTo := Q.FieldByName('valid_to').AsDateTime;
    end;
  finally
    Q.Free;
  end;
end;

function TAccAccountAddressRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccAccountAddress;
var
  Q: TFDQuery;
  Criterion: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    for Criterion in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.SQL.Text := Q.SQL.Text + ' LIMIT 1';

    for Criterion in AFilter do
      Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;

    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TAccAccountAddress.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.AccountId := Q.FieldByName('account_id').AsLargeInt;
      Result.AddressId := Q.FieldByName('address_id').AsLargeInt;
      Result.AddressType := Q.FieldByName('address_type').AsString;
      Result.IsPrimary := Q.FieldByName('is_primary').AsBoolean;
      Result.ValidFrom := Q.FieldByName('valid_from').AsDateTime;
      Result.ValidTo := Q.FieldByName('valid_to').AsDateTime;
    end;
  finally
    Q.Free;
  end;
end;

function TAccAccountAddressRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TAccAccountAddress>;
var
  Q: TFDQuery;
  Item: TAccAccountAddress;
  Criterion: TFilterCriterion;
begin
  Result := TObjectList<TAccAccountAddress>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;
    end;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;
    end;

    Q.Open;
    while not Q.Eof do
    begin
      Item := TAccAccountAddress.Create;
      Item.Id := Q.FieldByName('id').AsLargeInt;
      Item.AccountId := Q.FieldByName('account_id').AsLargeInt;
      Item.AddressId := Q.FieldByName('address_id').AsLargeInt;
      Item.AddressType := Q.FieldByName('address_type').AsString;
      Item.IsPrimary := Q.FieldByName('is_primary').AsBoolean;
      Item.ValidFrom := Q.FieldByName('valid_from').AsDateTime;
      Item.ValidTo := Q.FieldByName('valid_to').AsDateTime;
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.