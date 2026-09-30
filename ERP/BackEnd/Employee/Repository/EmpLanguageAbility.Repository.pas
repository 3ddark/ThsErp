unit EmpLanguageAbility.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EmpLanguageAbility;

type
  TEmpLanguageAbilityRepository = class(TRepository<TEmpLanguageAbility>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEmpLanguageAbility; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEmpLanguageAbility; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEmpLanguageAbility; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEmpLanguageAbility>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEmpLanguageAbility; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEmpLanguageAbility; override;

    procedure DoAdd(AModel: TEmpLanguageAbility); override;
    procedure DoAddBatch(AModels: TArray<TEmpLanguageAbility>); override;

    procedure DoUpdate(AModel: TEmpLanguageAbility); override;
    procedure DoUpdateBatch(AModels: TArray<TEmpLanguageAbility>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEmpLanguageAbility); override;
    procedure DoDeleteBatch(AModels: TArray<TEmpLanguageAbility>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpLanguageAbilityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEmpLanguageAbilityRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEmpLanguageAbility) +
            ' (emp_employee_id, emp_language_id, read_level, write_level, speak_level) ' +
            ' VALUES (:emp_employee_id, :emp_language_id, :read_level, :write_level, :speak_level)';
end;

function TEmpLanguageAbilityRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEmpLanguageAbility) +
            ' SET emp_employee_id = :emp_employee_id, emp_language_id = :emp_language_id, read_level = :read_level, write_level = :write_level, speak_level = :speak_level ' +
            ' WHERE id = :id';
end;

function TEmpLanguageAbilityRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEmpLanguageAbility) + ' WHERE';
end;

procedure TEmpLanguageAbilityRepository.SetInsertParams(Q: TFDQuery; AModel: TEmpLanguageAbility; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('read_level').AsSmallInt := AModel.ReadLevel;
    Q.ParamByName('write_level').AsSmallInt := AModel.WriteLevel;
    Q.ParamByName('speak_level').AsSmallInt := AModel.SpeakLevel;
  end
  else
  begin
    Q.ParamByName('read_level').AsSmallInts[AIndex] := AModel.ReadLevel;
    Q.ParamByName('write_level').AsSmallInts[AIndex] := AModel.WriteLevel;
    Q.ParamByName('speak_level').AsSmallInts[AIndex] := AModel.SpeakLevel;
  end;

  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetNullableParam(Q.ParamByName('emp_language_id'), ftLargeint, AModel.EmpLanguageId, AIndex);
end;

procedure TEmpLanguageAbilityRepository.SetUpdateParams(Q: TFDQuery; AModel: TEmpLanguageAbility; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('read_level').AsSmallInt := AModel.ReadLevel;
    Q.ParamByName('write_level').AsSmallInt := AModel.WriteLevel;
    Q.ParamByName('speak_level').AsSmallInt := AModel.SpeakLevel;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('read_level').AsSmallInts[AIndex] := AModel.ReadLevel;
    Q.ParamByName('write_level').AsSmallInts[AIndex] := AModel.WriteLevel;
    Q.ParamByName('speak_level').AsSmallInts[AIndex] := AModel.SpeakLevel;
  end;

  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetNullableParam(Q.ParamByName('emp_language_id'), ftLargeint, AModel.EmpLanguageId, AIndex);
end;

function TEmpLanguageAbilityRepository.MapFromQuery(Q: TFDQuery): TEmpLanguageAbility;
begin
  Result := TEmpLanguageAbility.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.EmpEmployeeId := Q.FieldByName('emp_employee_id').AsLargeInt;
  Result.EmpLanguageId := Q.FieldByName('emp_language_id').AsLargeInt;
  Result.ReadLevel := Q.FieldByName('read_level').AsInteger;
  Result.WriteLevel := Q.FieldByName('write_level').AsInteger;
  Result.SpeakLevel := Q.FieldByName('speak_level').AsInteger;
  Result.EmployeeFullName := Q.FieldByName('full_name').AsString;
  Result.LanguageName := Q.FieldByName('language_name').AsString;
end;

function TEmpLanguageAbilityRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEmpLanguageAbility) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEmpLanguageAbilityRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEmpLanguageAbility>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEmpLanguageAbility>.Create(True);
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

function TEmpLanguageAbilityRepository.DoFindById(AId: TValue; ALock: Boolean): TEmpLanguageAbility;
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

function TEmpLanguageAbilityRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEmpLanguageAbility;
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

procedure TEmpLanguageAbilityRepository.DoAdd(AModel: TEmpLanguageAbility);
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

procedure TEmpLanguageAbilityRepository.DoAddBatch(AModels: TArray<TEmpLanguageAbility>);
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

procedure TEmpLanguageAbilityRepository.DoUpdate(AModel: TEmpLanguageAbility);
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

procedure TEmpLanguageAbilityRepository.DoUpdateBatch(AModels: TArray<TEmpLanguageAbility>);
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

procedure TEmpLanguageAbilityRepository.DoDelete(AID: TValue);
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

procedure TEmpLanguageAbilityRepository.DoDelete(AModel: TEmpLanguageAbility);
begin
  Delete(AModel.Id);
end;

procedure TEmpLanguageAbilityRepository.DoDeleteBatch(AModels: TArray<TEmpLanguageAbility>);
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

procedure TEmpLanguageAbilityRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEmpLanguageAbilityRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
