unit EmpPersonAddress.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EmpPersonAddress;

type
  TEmpPersonAddressRepository = class(TRepository<TEmpPersonAddress>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEmpPersonAddress; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEmpPersonAddress; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEmpPersonAddress; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEmpPersonAddress>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEmpPersonAddress; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEmpPersonAddress; override;

    procedure DoAdd(AModel: TEmpPersonAddress); override;
    procedure DoAddBatch(AModels: TArray<TEmpPersonAddress>); override;

    procedure DoUpdate(AModel: TEmpPersonAddress); override;
    procedure DoUpdateBatch(AModels: TArray<TEmpPersonAddress>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEmpPersonAddress); override;
    procedure DoDeleteBatch(AModels: TArray<TEmpPersonAddress>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpPersonAddressRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEmpPersonAddressRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEmpPersonAddress) +
            ' (emp_employee_id, sys_address_id, address_type, is_primary, valid_from, valid_to) ' +
            ' VALUES (:emp_employee_id, :sys_address_id, :address_type, :is_primary, :valid_from, :valid_to)';
end;

function TEmpPersonAddressRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEmpPersonAddress) +
            ' SET emp_employee_id = :emp_employee_id, sys_address_id = :sys_address_id, address_type = :address_type, is_primary = :is_primary, valid_from = :valid_from, valid_to = :valid_to ' +
            ' WHERE id = :id';
end;

function TEmpPersonAddressRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEmpPersonAddress) + ' WHERE';
end;

procedure TEmpPersonAddressRepository.SetInsertParams(Q: TFDQuery; AModel: TEmpPersonAddress; AIndex: Integer);

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

  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetNullableParam(Q.ParamByName('sys_address_id'), ftLargeint, AModel.SysAddressId, AIndex);
  SetDate('valid_from', AModel.ValidFrom);
  SetDate('valid_to', AModel.ValidTo);
end;

procedure TEmpPersonAddressRepository.SetUpdateParams(Q: TFDQuery; AModel: TEmpPersonAddress; AIndex: Integer);

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

  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetNullableParam(Q.ParamByName('sys_address_id'), ftLargeint, AModel.SysAddressId, AIndex);
  SetDate('valid_from', AModel.ValidFrom);
  SetDate('valid_to', AModel.ValidTo);
end;

function TEmpPersonAddressRepository.MapFromQuery(Q: TFDQuery): TEmpPersonAddress;
begin
  Result := TEmpPersonAddress.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.EmpEmployeeId := Q.FieldByName('emp_employee_id').AsLargeInt;
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
  Result.EmployeeFullName := Q.FieldByName('full_name').AsString;
  Result.AddressText := Q.FieldByName('address_text').AsString;
end;

function TEmpPersonAddressRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEmpPersonAddress) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEmpPersonAddressRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEmpPersonAddress>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEmpPersonAddress>.Create(True);
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

function TEmpPersonAddressRepository.DoFindById(AId: TValue; ALock: Boolean): TEmpPersonAddress;
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

function TEmpPersonAddressRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEmpPersonAddress;
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

procedure TEmpPersonAddressRepository.DoAdd(AModel: TEmpPersonAddress);
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

procedure TEmpPersonAddressRepository.DoAddBatch(AModels: TArray<TEmpPersonAddress>);
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

procedure TEmpPersonAddressRepository.DoUpdate(AModel: TEmpPersonAddress);
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

procedure TEmpPersonAddressRepository.DoUpdateBatch(AModels: TArray<TEmpPersonAddress>);
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

procedure TEmpPersonAddressRepository.DoDelete(AID: TValue);
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

procedure TEmpPersonAddressRepository.DoDelete(AModel: TEmpPersonAddress);
begin
  Delete(AModel.Id);
end;

procedure TEmpPersonAddressRepository.DoDeleteBatch(AModels: TArray<TEmpPersonAddress>);
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

procedure TEmpPersonAddressRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEmpPersonAddressRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
