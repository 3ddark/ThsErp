unit EInvPaymentMeans.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvPaymentMeans;

type
  TEInvPaymentMeansRepository = class(TRepository<TEInvPaymentMeans>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvPaymentMeans; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvPaymentMeans; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvPaymentMeans; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvPaymentMeans>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvPaymentMeans; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvPaymentMeans; override;

    procedure DoAdd(AModel: TEInvPaymentMeans); override;
    procedure DoAddBatch(AModels: TArray<TEInvPaymentMeans>); override;

    procedure DoUpdate(AModel: TEInvPaymentMeans); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvPaymentMeans>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvPaymentMeans); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvPaymentMeans>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function CodeExists(const ACode: string; AExcludeId: Int64): Boolean;
    function UsageCount(AId: Int64): Integer;
  end;

implementation

constructor TEInvPaymentMeansRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvPaymentMeansRepository.CodeExists(const ACode: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.einv_payment_means WHERE code = :code AND id <> :id';
    Q.ParamByName('code').AsWideString := ACode;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'CodeExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

// Kaydı kullanan satır sayısı (silmek yerine pasif yapılmalı)
function TEInvPaymentMeansRepository.UsageCount(AId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT (SELECT count(*) FROM public.sls_invoice WHERE einv_payment_means_id = :id) AS cnt';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'UsageCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TEInvPaymentMeansRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvPaymentMeans) +
            ' (code, name, is_active) ' +
            ' VALUES (:code, :name, :is_active)';
end;

function TEInvPaymentMeansRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvPaymentMeans) +
            ' SET code = :code, name = :name, is_active = :is_active ' +
            ' WHERE id = :id';
end;

function TEInvPaymentMeansRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvPaymentMeans) + ' WHERE';
end;

procedure TEInvPaymentMeansRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvPaymentMeans; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('code').AsWideString := AModel.Code;
    Q.ParamByName('name').AsWideString := AModel.Name;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('code').AsWideStrings[AIndex] := AModel.Code;
    Q.ParamByName('name').AsWideStrings[AIndex] := AModel.Name;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;


end;

procedure TEInvPaymentMeansRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvPaymentMeans; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('code').AsWideString := AModel.Code;
    Q.ParamByName('name').AsWideString := AModel.Name;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('code').AsWideStrings[AIndex] := AModel.Code;
    Q.ParamByName('name').AsWideStrings[AIndex] := AModel.Name;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;


end;

function TEInvPaymentMeansRepository.MapFromQuery(Q: TFDQuery): TEInvPaymentMeans;
begin
  Result := TEInvPaymentMeans.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Code := Q.FieldByName('code').AsString;
  Result.Name := Q.FieldByName('name').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
end;

function TEInvPaymentMeansRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvPaymentMeans) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvPaymentMeansRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvPaymentMeans>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvPaymentMeans>.Create(True);
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

function TEInvPaymentMeansRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvPaymentMeans;
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

function TEInvPaymentMeansRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvPaymentMeans;
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

procedure TEInvPaymentMeansRepository.DoAdd(AModel: TEInvPaymentMeans);
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

procedure TEInvPaymentMeansRepository.DoAddBatch(AModels: TArray<TEInvPaymentMeans>);
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

procedure TEInvPaymentMeansRepository.DoUpdate(AModel: TEInvPaymentMeans);
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

procedure TEInvPaymentMeansRepository.DoUpdateBatch(AModels: TArray<TEInvPaymentMeans>);
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

procedure TEInvPaymentMeansRepository.DoDelete(AID: TValue);
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

procedure TEInvPaymentMeansRepository.DoDelete(AModel: TEInvPaymentMeans);
begin
  Delete(AModel.Id);
end;

procedure TEInvPaymentMeansRepository.DoDeleteBatch(AModels: TArray<TEInvPaymentMeans>);
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

procedure TEInvPaymentMeansRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEInvPaymentMeansRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
