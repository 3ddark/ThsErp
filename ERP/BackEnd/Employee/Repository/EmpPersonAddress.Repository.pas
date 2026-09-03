unit EmpPersonAddress.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Entity, Repository, EmpPersonAddress,
  FilterCriterion, AppContext;

type
  TEmpPersonAddressRepository = class(TRepository<TEmpPersonAddress>)
  protected
    function PrepareSelectSql: string; virtual;
    function PrepareAddSql: string; virtual;
    function PrepareUpdateSql: string; virtual;
    function PrepareDeleteSql: string; virtual;

    procedure SetModelParams(Q: TFDQuery; AModel: TEmpPersonAddress; AIndex: Integer = -1);
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function FindById(AId: TValue; ALock: Boolean = False): TEmpPersonAddress; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEmpPersonAddress; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TEmpPersonAddress>; override;

    procedure Add(AModel: TEmpPersonAddress); override;
    procedure AddBatch(AModels: TArray<TEmpPersonAddress>); override;

    procedure Update(AModel: TEmpPersonAddress); override;
    procedure UpdateBatch(AModels: TArray<TEmpPersonAddress>); override;

    procedure Delete(AID: TValue); overload; override;
    procedure Delete(AModel: TEmpPersonAddress); overload; override;
    procedure DeleteBatch(AModels: TArray<TEmpPersonAddress>); override;
  end;

implementation

constructor TEmpPersonAddressRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEmpPersonAddressRepository.PrepareSelectSql: string;
begin
  Result := 'SELECT id, person_id, address_id, address_type, is_primary, valid_from, valid_to FROM public.' + Self.GetTableName(TEmpPersonAddress);
end;

function TEmpPersonAddressRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEmpPersonAddress) +
            ' (person_id, address_id, address_type, is_primary, valid_from, valid_to) ' +
            ' VALUES (:person_id, :address_id, :address_type, :is_primary, :valid_from, :valid_to)';
end;

function TEmpPersonAddressRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEmpPersonAddress) +
            ' SET person_id = :person_id, address_id = :address_id, address_type = :address_type, ' +
            '     is_primary = :is_primary, valid_from = :valid_from, valid_to = :valid_to WHERE id = :id';
end;

function TEmpPersonAddressRepository.PrepareDeleteSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TEmpPersonAddress) + ' WHERE id = :id';
end;

procedure TEmpPersonAddressRepository.SetModelParams(Q: TFDQuery; AModel: TEmpPersonAddress; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('person_id').AsLargeInt := AModel.PersonId;
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
    Q.ParamByName('person_id').AsLargeInts[AIndex] := AModel.PersonId;
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

function TEmpPersonAddressRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM public.' + Self.GetTableName(TEmpPersonAddress);
end;

procedure TEmpPersonAddressRepository.Add(AModel: TEmpPersonAddress);
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

procedure TEmpPersonAddressRepository.AddBatch(AModels: TArray<TEmpPersonAddress>);
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

procedure TEmpPersonAddressRepository.Update(AModel: TEmpPersonAddress);
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

procedure TEmpPersonAddressRepository.UpdateBatch(AModels: TArray<TEmpPersonAddress>);
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

procedure TEmpPersonAddressRepository.Delete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEmpPersonAddressRepository.Delete(AModel: TEmpPersonAddress);
begin
  if Assigned(AModel) then
    Delete(AModel.Id);
end;

procedure TEmpPersonAddressRepository.DeleteBatch(AModels: TArray<TEmpPersonAddress>);
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

function TEmpPersonAddressRepository.FindById(AId: TValue; ALock: Boolean): TEmpPersonAddress;
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
      Result := TEmpPersonAddress.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.PersonId := Q.FieldByName('person_id').AsLargeInt;
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

function TEmpPersonAddressRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TEmpPersonAddress;
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
      Result := TEmpPersonAddress.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.PersonId := Q.FieldByName('person_id').AsLargeInt;
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

function TEmpPersonAddressRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TEmpPersonAddress>;
var
  Q: TFDQuery;
  Item: TEmpPersonAddress;
  Criterion: TFilterCriterion;
begin
  Result := TObjectList<TEmpPersonAddress>.Create(True);
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
      Item := TEmpPersonAddress.Create;
      Item.Id := Q.FieldByName('id').AsLargeInt;
      Item.PersonId := Q.FieldByName('person_id').AsLargeInt;
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
