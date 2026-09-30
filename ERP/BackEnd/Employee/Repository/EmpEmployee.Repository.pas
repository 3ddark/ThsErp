unit EmpEmployee.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EmpEmployee;

type
  TEmpEmployeeRepository = class(TRepository<TEmpEmployee>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetParams(Q: TFDQuery; AModel: TEmpEmployee; AIndex: Integer = -1);
    procedure SetInsertParams(Q: TFDQuery; AModel: TEmpEmployee; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEmpEmployee; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEmpEmployee; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEmpEmployee>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEmpEmployee; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEmpEmployee; override;

    procedure DoAdd(AModel: TEmpEmployee); override;
    procedure DoAddBatch(AModels: TArray<TEmpEmployee>); override;

    procedure DoUpdate(AModel: TEmpEmployee); override;
    procedure DoUpdateBatch(AModels: TArray<TEmpEmployee>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEmpEmployee); override;
    procedure DoDeleteBatch(AModels: TArray<TEmpEmployee>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

const
  EMP_COLUMNS =
    'name, surname, full_name, phone1, phone2, emp_person_type_id, emp_unit_id, emp_task_id, ' +
    'birth_date, blood_type, gender, military_status, marital_status, child, relative_name, ' +
    'relative_phone, shoe_size, clothing_size, notes, emp_transportation_id, special_notes, ' +
    'salary_amount, bonus_count, bonus_amount, id_document_no, active';

  EMP_PARAMS =
    ':name, :surname, :full_name, :phone1, :phone2, :emp_person_type_id, :emp_unit_id, :emp_task_id, ' +
    ':birth_date, :blood_type, :gender, :military_status, :marital_status, :child, :relative_name, ' +
    ':relative_phone, :shoe_size, :clothing_size, :notes, :emp_transportation_id, :special_notes, ' +
    ':salary_amount, :bonus_count, :bonus_amount, :id_document_no, :active';

constructor TEmpEmployeeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEmpEmployeeRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEmpEmployee) +
            ' (' + EMP_COLUMNS + ') VALUES (' + EMP_PARAMS + ')';
end;

function TEmpEmployeeRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEmpEmployee) +
            ' SET (' + EMP_COLUMNS + ') = (' + EMP_PARAMS + ') ' +
            ' WHERE id = :id';
end;

function TEmpEmployeeRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEmpEmployee) + ' WHERE';
end;

procedure TEmpEmployeeRepository.SetParams(Q: TFDQuery; AModel: TEmpEmployee; AIndex: Integer);

  procedure SetStr(const AName, AValue: string);
  begin
    if AIndex < 0 then
      Q.ParamByName(AName).AsString := AValue
    else
      Q.ParamByName(AName).AsStrings[AIndex] := AValue;
  end;

  procedure SetNullableStr(const AName, AValue: string);
  begin
    Q.ParamByName(AName).DataType := ftString;
    if AValue <> '' then
      SetStr(AName, AValue)
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

  procedure SetSmall(const AName: string; AValue: SmallInt);
  begin
    if AIndex < 0 then
      Q.ParamByName(AName).AsSmallInt := AValue
    else
      Q.ParamByName(AName).AsSmallInts[AIndex] := AValue;
  end;

  procedure SetCurr(const AName: string; AValue: Currency);
  begin
    if AIndex < 0 then
      Q.ParamByName(AName).AsCurrency := AValue
    else
      Q.ParamByName(AName).AsCurrencys[AIndex] := AValue;
  end;

  procedure SetDate(const AName: string; AValue: TDate);
  var
    LParam: TFDParam;
  begin
    LParam := Q.ParamByName(AName);
    LParam.DataType := ftDate;
    if AValue <= 0 then
    begin
      if AIndex < 0 then LParam.Clear else LParam.Clear(AIndex);
    end
    else if AIndex < 0 then
      LParam.AsDate := AValue
    else
      LParam.AsDates[AIndex] := AValue;
  end;

begin
  SetStr('name', AModel.Name);
  SetStr('surname', AModel.Surname);
  SetStr('full_name', AModel.FullName);
  SetStr('phone1', AModel.Phone1);
  SetStr('phone2', AModel.Phone2);
  SetNullableParam(Q.ParamByName('emp_person_type_id'), ftLargeint, AModel.EmpPersonTypeId, AIndex);
  SetNullableParam(Q.ParamByName('emp_unit_id'), ftLargeint, AModel.EmpUnitId, AIndex);
  SetNullableParam(Q.ParamByName('emp_task_id'), ftLargeint, AModel.EmpTaskId, AIndex);
  SetDate('birth_date', AModel.BirthDate);
  SetNullableStr('blood_type', AModel.BloodType);
  SetSmall('gender', AModel.Gender);
  SetNullableParam(Q.ParamByName('military_status'), ftInteger, AModel.MilitaryStatus, AIndex);
  SetSmall('marital_status', AModel.MaritalStatus);
  SetSmall('child', AModel.Child);
  SetStr('relative_name', AModel.RelativeName);
  SetStr('relative_phone', AModel.RelativePhone);
  SetSmall('shoe_size', AModel.ShoeSize);
  SetNullableStr('clothing_size', AModel.ClothingSize);
  SetStr('notes', AModel.Notes);
  SetNullableParam(Q.ParamByName('emp_transportation_id'), ftLargeint, AModel.EmpTransportationId, AIndex);
  SetStr('special_notes', AModel.SpecialNotes);
  SetCurr('salary_amount', AModel.SalaryAmount);
  if AIndex < 0 then
  begin
    Q.ParamByName('bonus_count').AsInteger := AModel.BonusCount;
    Q.ParamByName('active').AsBoolean := AModel.Active;
  end
  else
  begin
    Q.ParamByName('bonus_count').AsIntegers[AIndex] := AModel.BonusCount;
    Q.ParamByName('active').AsBooleans[AIndex] := AModel.Active;
  end;
  SetCurr('bonus_amount', AModel.BonusAmount);
  SetStr('id_document_no', AModel.IdDocumentNo);
end;

procedure TEmpEmployeeRepository.SetInsertParams(Q: TFDQuery; AModel: TEmpEmployee; AIndex: Integer);
begin
  SetParams(Q, AModel, AIndex);
end;

procedure TEmpEmployeeRepository.SetUpdateParams(Q: TFDQuery; AModel: TEmpEmployee; AIndex: Integer);
begin
  if AIndex < 0 then
    Q.ParamByName('id').AsLargeInt := AModel.Id
  else
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
  SetParams(Q, AModel, AIndex);
end;

function TEmpEmployeeRepository.MapFromQuery(Q: TFDQuery): TEmpEmployee;
begin
  Result := TEmpEmployee.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Name := Q.FieldByName('name').AsString;
  Result.Surname := Q.FieldByName('surname').AsString;
  Result.FullName := Q.FieldByName('full_name').AsString;
  Result.Phone1 := Q.FieldByName('phone1').AsString;
  Result.Phone2 := Q.FieldByName('phone2').AsString;
  Result.EmpPersonTypeId := Q.FieldByName('emp_person_type_id').AsLargeInt;
  Result.EmpUnitId := Q.FieldByName('emp_unit_id').AsLargeInt;
  Result.EmpTaskId := Q.FieldByName('emp_task_id').AsLargeInt;
  if Q.FieldByName('birth_date').IsNull then
    Result.BirthDate := 0
  else
    Result.BirthDate := Q.FieldByName('birth_date').AsDateTime;
  Result.BloodType := Q.FieldByName('blood_type').AsString;
  Result.Gender := Q.FieldByName('gender').AsInteger;
  Result.MilitaryStatus := Q.FieldByName('military_status').AsInteger;
  Result.MaritalStatus := Q.FieldByName('marital_status').AsInteger;
  Result.Child := Q.FieldByName('child').AsInteger;
  Result.RelativeName := Q.FieldByName('relative_name').AsString;
  Result.RelativePhone := Q.FieldByName('relative_phone').AsString;
  Result.ShoeSize := Q.FieldByName('shoe_size').AsInteger;
  Result.ClothingSize := Q.FieldByName('clothing_size').AsString;
  Result.Notes := Q.FieldByName('notes').AsString;
  Result.EmpTransportationId := Q.FieldByName('emp_transportation_id').AsLargeInt;
  Result.SpecialNotes := Q.FieldByName('special_notes').AsString;
  Result.SalaryAmount := Q.FieldByName('salary_amount').AsCurrency;
  Result.BonusCount := Q.FieldByName('bonus_count').AsInteger;
  Result.BonusAmount := Q.FieldByName('bonus_amount').AsCurrency;
  Result.IdDocumentNo := Q.FieldByName('id_document_no').AsString;
  Result.Active := Q.FieldByName('active').AsBoolean;

  Result.PersonType := Q.FieldByName('person_type').AsString;
  Result.EmpUnitName := Q.FieldByName('unit_name').AsString;
  Result.SectionName := Q.FieldByName('section_name').AsString;
  Result.TaskName := Q.FieldByName('task_name').AsString;
  Result.TransportationName := Q.FieldByName('transportation_name').AsString;
end;

function TEmpEmployeeRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEmpEmployee) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TEmpEmployeeRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEmpEmployee>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEmpEmployee>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;

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

function TEmpEmployeeRepository.DoFindById(AId: TValue; ALock: Boolean): TEmpEmployee;
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
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, True);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TEmpEmployeeRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEmpEmployee;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, True);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TEmpEmployeeRepository.DoAdd(AModel: TEmpEmployee);
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

procedure TEmpEmployeeRepository.DoAddBatch(AModels: TArray<TEmpEmployee>);
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
      SetInsertParams(Q, AModels[I], I);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEmpEmployeeRepository.DoUpdate(AModel: TEmpEmployee);
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

procedure TEmpEmployeeRepository.DoUpdateBatch(AModels: TArray<TEmpEmployee>);
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
      SetUpdateParams(Q, AModels[I], I);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEmpEmployeeRepository.DoDelete(AID: TValue);
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

procedure TEmpEmployeeRepository.DoDelete(AModel: TEmpEmployee);
begin
  Delete(AModel.Id);
end;

procedure TEmpEmployeeRepository.DoDeleteBatch(AModels: TArray<TEmpEmployee>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

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

procedure TEmpEmployeeRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AIDs);
  if Count = 0 then Exit;

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

procedure TEmpEmployeeRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
