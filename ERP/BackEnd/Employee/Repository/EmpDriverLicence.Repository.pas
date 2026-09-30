unit EmpDriverLicence.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EmpDriverLicence;

type
  TEmpDriverLicenceRepository = class(TRepository<TEmpDriverLicence>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEmpDriverLicence; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEmpDriverLicence; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEmpDriverLicence; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEmpDriverLicence>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEmpDriverLicence; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEmpDriverLicence; override;

    procedure DoAdd(AModel: TEmpDriverLicence); override;
    procedure DoAddBatch(AModels: TArray<TEmpDriverLicence>); override;

    procedure DoUpdate(AModel: TEmpDriverLicence); override;
    procedure DoUpdateBatch(AModels: TArray<TEmpDriverLicence>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEmpDriverLicence); override;
    procedure DoDeleteBatch(AModels: TArray<TEmpDriverLicence>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpDriverLicenceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEmpDriverLicenceRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEmpDriverLicence) +
            ' (emp_employee_id, emp_driver_license_type_id) ' +
            ' VALUES (:emp_employee_id, :emp_driver_license_type_id)';
end;

function TEmpDriverLicenceRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEmpDriverLicence) +
            ' SET emp_employee_id = :emp_employee_id, emp_driver_license_type_id = :emp_driver_license_type_id ' +
            ' WHERE id = :id';
end;

function TEmpDriverLicenceRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEmpDriverLicence) + ' WHERE';
end;

procedure TEmpDriverLicenceRepository.SetInsertParams(Q: TFDQuery; AModel: TEmpDriverLicence; AIndex: Integer);
begin
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetNullableParam(Q.ParamByName('emp_driver_license_type_id'), ftLargeint, AModel.EmpDriverLicenseTypeId, AIndex);
end;

procedure TEmpDriverLicenceRepository.SetUpdateParams(Q: TFDQuery; AModel: TEmpDriverLicence; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
  end;

  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetNullableParam(Q.ParamByName('emp_driver_license_type_id'), ftLargeint, AModel.EmpDriverLicenseTypeId, AIndex);
end;

function TEmpDriverLicenceRepository.MapFromQuery(Q: TFDQuery): TEmpDriverLicence;
begin
  Result := TEmpDriverLicence.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.EmpEmployeeId := Q.FieldByName('emp_employee_id').AsLargeInt;
  Result.EmpDriverLicenseTypeId := Q.FieldByName('emp_driver_license_type_id').AsLargeInt;
  Result.EmployeeFullName := Q.FieldByName('full_name').AsString;
  Result.LicenseName := Q.FieldByName('license_name').AsString;
end;

function TEmpDriverLicenceRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEmpDriverLicence) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEmpDriverLicenceRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEmpDriverLicence>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEmpDriverLicence>.Create(True);
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

function TEmpDriverLicenceRepository.DoFindById(AId: TValue; ALock: Boolean): TEmpDriverLicence;
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

function TEmpDriverLicenceRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEmpDriverLicence;
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

procedure TEmpDriverLicenceRepository.DoAdd(AModel: TEmpDriverLicence);
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

procedure TEmpDriverLicenceRepository.DoAddBatch(AModels: TArray<TEmpDriverLicence>);
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

procedure TEmpDriverLicenceRepository.DoUpdate(AModel: TEmpDriverLicence);
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

procedure TEmpDriverLicenceRepository.DoUpdateBatch(AModels: TArray<TEmpDriverLicence>);
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

procedure TEmpDriverLicenceRepository.DoDelete(AID: TValue);
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

procedure TEmpDriverLicenceRepository.DoDelete(AModel: TEmpDriverLicence);
begin
  Delete(AModel.Id);
end;

procedure TEmpDriverLicenceRepository.DoDeleteBatch(AModels: TArray<TEmpDriverLicence>);
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

procedure TEmpDriverLicenceRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEmpDriverLicenceRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
