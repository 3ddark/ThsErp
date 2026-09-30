unit AccBankBranch.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccBankBranch;

type
  TAccBankBranchRepository = class(TRepository<TAccBankBranch>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccBankBranch; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccBankBranch; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccBankBranch; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccBankBranch>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccBankBranch; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccBankBranch; override;

    procedure DoAdd(AModel: TAccBankBranch); override;
    procedure DoAddBatch(AModels: TArray<TAccBankBranch>); override;

    procedure DoUpdate(AModel: TAccBankBranch); override;
    procedure DoUpdateBatch(AModels: TArray<TAccBankBranch>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccBankBranch); override;
    procedure DoDeleteBatch(AModels: TArray<TAccBankBranch>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TAccBankBranchRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccBankBranchRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccBankBranch) +
            ' (acc_bank_id, branch_code, branch_name, sys_city_id) ' +
            ' VALUES (:acc_bank_id, :branch_code, :branch_name, :sys_city_id)';
end;

function TAccBankBranchRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccBankBranch) +
            ' SET acc_bank_id = :acc_bank_id, branch_code = :branch_code, branch_name = :branch_name, sys_city_id = :sys_city_id ' +
            ' WHERE id = :id';
end;

function TAccBankBranchRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccBankBranch) + ' WHERE';
end;

procedure TAccBankBranchRepository.SetInsertParams(Q: TFDQuery; AModel: TAccBankBranch; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('branch_code').AsInteger := AModel.BranchCode;
    Q.ParamByName('branch_name').AsString := AModel.BranchName;
  end
  else
  begin
    Q.ParamByName('branch_code').AsIntegers[AIndex] := AModel.BranchCode;
    Q.ParamByName('branch_name').AsStrings[AIndex] := AModel.BranchName;
  end;

  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
  SetNullableParam(Q.ParamByName('sys_city_id'), ftLargeint, AModel.SysCityId, AIndex);
end;

procedure TAccBankBranchRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccBankBranch; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('branch_code').AsInteger := AModel.BranchCode;
    Q.ParamByName('branch_name').AsString := AModel.BranchName;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('branch_code').AsIntegers[AIndex] := AModel.BranchCode;
    Q.ParamByName('branch_name').AsStrings[AIndex] := AModel.BranchName;
  end;

  SetNullableParam(Q.ParamByName('acc_bank_id'), ftLargeint, AModel.AccBankId, AIndex);
  SetNullableParam(Q.ParamByName('sys_city_id'), ftLargeint, AModel.SysCityId, AIndex);
end;

function TAccBankBranchRepository.MapFromQuery(Q: TFDQuery): TAccBankBranch;
begin
  Result := TAccBankBranch.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.AccBankId := Q.FieldByName('acc_bank_id').AsLargeInt;
  Result.BranchCode := Q.FieldByName('branch_code').AsInteger;
  Result.BranchName := Q.FieldByName('branch_name').AsString;
  Result.SysCityId := Q.FieldByName('sys_city_id').AsLargeInt;
  Result.BankName := Q.FieldByName('bank_name').AsString;
  Result.CityName := Q.FieldByName('city_name').AsString;
end;

function TAccBankBranchRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccBankBranch) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TAccBankBranchRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccBankBranch>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TAccBankBranch>.Create(True);
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

function TAccBankBranchRepository.DoFindById(AId: TValue; ALock: Boolean): TAccBankBranch;
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

function TAccBankBranchRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccBankBranch;
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

procedure TAccBankBranchRepository.DoAdd(AModel: TAccBankBranch);
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

procedure TAccBankBranchRepository.DoAddBatch(AModels: TArray<TAccBankBranch>);
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

procedure TAccBankBranchRepository.DoUpdate(AModel: TAccBankBranch);
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

procedure TAccBankBranchRepository.DoUpdateBatch(AModels: TArray<TAccBankBranch>);
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

procedure TAccBankBranchRepository.DoDelete(AID: TValue);
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

procedure TAccBankBranchRepository.DoDelete(AModel: TAccBankBranch);
begin
  Delete(AModel.Id);
end;

procedure TAccBankBranchRepository.DoDeleteBatch(AModels: TArray<TAccBankBranch>);
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

procedure TAccBankBranchRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TAccBankBranchRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
