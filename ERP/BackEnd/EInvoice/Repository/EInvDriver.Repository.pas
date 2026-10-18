unit EInvDriver.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvDriver;

type
  TEInvDriverRepository = class(TRepository<TEInvDriver>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvDriver; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvDriver; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvDriver; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvDriver>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvDriver; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvDriver; override;

    procedure DoAdd(AModel: TEInvDriver); override;
    procedure DoAddBatch(AModels: TArray<TEInvDriver>); override;

    procedure DoUpdate(AModel: TEInvDriver); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvDriver>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvDriver); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvDriver>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NationalIdExists(const AValue: string; AExcludeId: Int64): Boolean;
    function UsageCount(AId: Int64): Integer;
  end;

implementation

constructor TEInvDriverRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvDriverRepository.NationalIdExists(const AValue: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.einv_driver WHERE national_id = :v AND id <> :id';
    Q.ParamByName('v').AsWideString := AValue;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'NationalIdExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

// Kaydı kullanan irsaliye sayısı (silmek yerine pasif yapılmalı)
function TEInvDriverRepository.UsageCount(AId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS cnt FROM public.sls_dispatch WHERE :id IN (driver1_einv_driver_id, driver2_einv_driver_id)';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'UsageCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TEInvDriverRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvDriver) +
            ' (first_name, family_name, national_id, phone, is_active) ' +
            ' VALUES (:first_name, :family_name, :national_id, :phone, :is_active)';
end;

function TEInvDriverRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvDriver) +
            ' SET first_name = :first_name, family_name = :family_name, national_id = :national_id, phone = :phone, is_active = :is_active ' +
            ' WHERE id = :id';
end;

function TEInvDriverRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvDriver) + ' WHERE';
end;

procedure TEInvDriverRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvDriver; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('first_name').AsWideString := AModel.FirstName;
    Q.ParamByName('family_name').AsWideString := AModel.FamilyName;
    Q.ParamByName('national_id').AsWideString := AModel.NationalId;
    Q.ParamByName('phone').AsWideString := AModel.Phone;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('first_name').AsWideStrings[AIndex] := AModel.FirstName;
    Q.ParamByName('family_name').AsWideStrings[AIndex] := AModel.FamilyName;
    Q.ParamByName('national_id').AsWideStrings[AIndex] := AModel.NationalId;
    Q.ParamByName('phone').AsWideStrings[AIndex] := AModel.Phone;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;


end;

procedure TEInvDriverRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvDriver; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('first_name').AsWideString := AModel.FirstName;
    Q.ParamByName('family_name').AsWideString := AModel.FamilyName;
    Q.ParamByName('national_id').AsWideString := AModel.NationalId;
    Q.ParamByName('phone').AsWideString := AModel.Phone;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('first_name').AsWideStrings[AIndex] := AModel.FirstName;
    Q.ParamByName('family_name').AsWideStrings[AIndex] := AModel.FamilyName;
    Q.ParamByName('national_id').AsWideStrings[AIndex] := AModel.NationalId;
    Q.ParamByName('phone').AsWideStrings[AIndex] := AModel.Phone;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;


end;

function TEInvDriverRepository.MapFromQuery(Q: TFDQuery): TEInvDriver;
begin
  Result := TEInvDriver.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.FirstName := Q.FieldByName('first_name').AsString;
  Result.FamilyName := Q.FieldByName('family_name').AsString;
  Result.NationalId := Q.FieldByName('national_id').AsString;
  Result.Phone := Q.FieldByName('phone').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.FullName := Q.FieldByName('full_name').AsString;
end;

function TEInvDriverRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvDriver) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvDriverRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvDriver>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvDriver>.Create(True);
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

function TEInvDriverRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvDriver;
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

function TEInvDriverRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvDriver;
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

procedure TEInvDriverRepository.DoAdd(AModel: TEInvDriver);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TEInvDriverRepository.DoAddBatch(AModels: TArray<TEInvDriver>);
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

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEInvDriverRepository.DoUpdate(AModel: TEInvDriver);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEInvDriverRepository.DoUpdateBatch(AModels: TArray<TEInvDriver>);
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

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEInvDriverRepository.DoDelete(AID: TValue);
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

procedure TEInvDriverRepository.DoDelete(AModel: TEInvDriver);
begin
  Delete(AModel.Id);
end;

procedure TEInvDriverRepository.DoDeleteBatch(AModels: TArray<TEInvDriver>);
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

procedure TEInvDriverRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEInvDriverRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
