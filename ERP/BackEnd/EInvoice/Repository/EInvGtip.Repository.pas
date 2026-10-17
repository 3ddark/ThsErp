unit EInvGtip.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvGtip;

type
  TEInvGtipRepository = class(TRepository<TEInvGtip>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvGtip; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvGtip; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvGtip; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvGtip>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvGtip; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvGtip; override;

    procedure DoAdd(AModel: TEInvGtip); override;
    procedure DoAddBatch(AModels: TArray<TEInvGtip>); override;

    procedure DoUpdate(AModel: TEInvGtip); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvGtip>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvGtip); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvGtip>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function CodeExists(const ACode: string; AExcludeId: Int64): Boolean;
    function UsageCount(AId: Int64): Integer;
  end;

implementation

constructor TEInvGtipRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvGtipRepository.CodeExists(const ACode: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.einv_gtip WHERE code = :code AND id <> :id';
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
function TEInvGtipRepository.UsageCount(AId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT (SELECT count(*) FROM public.stk_inventory WHERE einv_gtip_id = :id) + (SELECT count(*) FROM public.einv_diib_line WHERE einv_gtip_id = :id) + (SELECT count(*) FROM public.sls_invoice_detail WHERE einv_gtip_id = :id) AS cnt';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'UsageCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TEInvGtipRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvGtip) +
            ' (code, name, is_active) ' +
            ' VALUES (:code, :name, :is_active)';
end;

function TEInvGtipRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvGtip) +
            ' SET code = :code, name = :name, is_active = :is_active ' +
            ' WHERE id = :id';
end;

function TEInvGtipRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvGtip) + ' WHERE';
end;

procedure TEInvGtipRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvGtip; AIndex: Integer);

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

procedure TEInvGtipRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvGtip; AIndex: Integer);

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

function TEInvGtipRepository.MapFromQuery(Q: TFDQuery): TEInvGtip;
begin
  Result := TEInvGtip.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Code := Q.FieldByName('code').AsString;
  Result.Name := Q.FieldByName('name').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
end;

function TEInvGtipRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvGtip) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvGtipRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvGtip>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvGtip>.Create(True);
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

function TEInvGtipRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvGtip;
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

function TEInvGtipRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvGtip;
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

procedure TEInvGtipRepository.DoAdd(AModel: TEInvGtip);
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

procedure TEInvGtipRepository.DoAddBatch(AModels: TArray<TEInvGtip>);
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

procedure TEInvGtipRepository.DoUpdate(AModel: TEInvGtip);
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

procedure TEInvGtipRepository.DoUpdateBatch(AModels: TArray<TEInvGtip>);
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

procedure TEInvGtipRepository.DoDelete(AID: TValue);
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

procedure TEInvGtipRepository.DoDelete(AModel: TEInvGtip);
begin
  Delete(AModel.Id);
end;

procedure TEInvGtipRepository.DoDeleteBatch(AModels: TArray<TEInvGtip>);
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

procedure TEInvGtipRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEInvGtipRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
