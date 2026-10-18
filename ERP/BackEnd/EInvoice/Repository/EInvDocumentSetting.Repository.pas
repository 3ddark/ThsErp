unit EInvDocumentSetting.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvDocumentSetting;

type
  TEInvDocumentSettingRepository = class(TRepository<TEInvDocumentSetting>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvDocumentSetting; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvDocumentSetting; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvDocumentSetting; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvDocumentSetting>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvDocumentSetting; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvDocumentSetting; override;

    procedure DoAdd(AModel: TEInvDocumentSetting); override;
    procedure DoAddBatch(AModels: TArray<TEInvDocumentSetting>); override;

    procedure DoUpdate(AModel: TEInvDocumentSetting); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvDocumentSetting>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvDocumentSetting); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvDocumentSetting>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function ApplicationSettingId: Int64;
    function ScopeExists(ASettingId: Int64; AScope: Integer; AExcludeId: Int64): Boolean;
    function SeriesScopeOf(ASeriesId: Int64): Integer;
  end;

implementation

constructor TEInvDocumentSettingRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvDocumentSettingRepository.ApplicationSettingId: Int64;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(min(id), 0) AS id FROM public.sys_application_setting';
    LogQuery(Q, 'ApplicationSettingId');
    Q.Open;
    Result := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentSettingRepository.ScopeExists(ASettingId: Int64; AScope: Integer; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.einv_document_setting WHERE sys_application_setting_id = :s AND series_scope = :c AND id <> :id';
    Q.ParamByName('s').AsLargeInt := ASettingId;
    Q.ParamByName('c').AsSmallInt := AScope;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'ScopeExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentSettingRepository.SeriesScopeOf(ASeriesId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE((SELECT series_scope FROM public.einv_series WHERE id = :id), 0) AS v';
    Q.ParamByName('id').AsLargeInt := ASeriesId;
    LogQuery(Q, 'SeriesScopeOf');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TEInvDocumentSettingRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvDocumentSetting) +
            ' (sys_application_setting_id, series_scope, einv_series_id, sys_api_service_id, sender_alias) ' +
            ' VALUES (:sys_application_setting_id, :series_scope, :einv_series_id, :sys_api_service_id, :sender_alias)';
end;

function TEInvDocumentSettingRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvDocumentSetting) +
            ' SET sys_application_setting_id = :sys_application_setting_id, series_scope = :series_scope, einv_series_id = :einv_series_id, sys_api_service_id = :sys_api_service_id, sender_alias = :sender_alias ' +
            ' WHERE id = :id';
end;

function TEInvDocumentSettingRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvDocumentSetting) + ' WHERE';
end;

procedure TEInvDocumentSettingRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvDocumentSetting; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('series_scope').AsSmallInt := AModel.SeriesScope;
    Q.ParamByName('sender_alias').AsWideString := AModel.SenderAlias;
  end
  else
  begin
    Q.ParamByName('series_scope').AsSmallInts[AIndex] := AModel.SeriesScope;
    Q.ParamByName('sender_alias').AsWideStrings[AIndex] := AModel.SenderAlias;
  end;

  SetNullableParam(Q.ParamByName('sys_application_setting_id'), ftLargeint, AModel.SysApplicationSettingId, AIndex);
  SetNullableParam(Q.ParamByName('einv_series_id'), ftLargeint, AModel.EinvSeriesId, AIndex);
  SetNullableParam(Q.ParamByName('sys_api_service_id'), ftLargeint, AModel.SysApiServiceId, AIndex);
end;

procedure TEInvDocumentSettingRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvDocumentSetting; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('series_scope').AsSmallInt := AModel.SeriesScope;
    Q.ParamByName('sender_alias').AsWideString := AModel.SenderAlias;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('series_scope').AsSmallInts[AIndex] := AModel.SeriesScope;
    Q.ParamByName('sender_alias').AsWideStrings[AIndex] := AModel.SenderAlias;
  end;

  SetNullableParam(Q.ParamByName('sys_application_setting_id'), ftLargeint, AModel.SysApplicationSettingId, AIndex);
  SetNullableParam(Q.ParamByName('einv_series_id'), ftLargeint, AModel.EinvSeriesId, AIndex);
  SetNullableParam(Q.ParamByName('sys_api_service_id'), ftLargeint, AModel.SysApiServiceId, AIndex);
end;

function TEInvDocumentSettingRepository.MapFromQuery(Q: TFDQuery): TEInvDocumentSetting;
begin
  Result := TEInvDocumentSetting.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SysApplicationSettingId := Q.FieldByName('sys_application_setting_id').AsLargeInt;
  Result.SeriesScope := Q.FieldByName('series_scope').AsInteger;
  Result.EinvSeriesId := Q.FieldByName('einv_series_id').AsLargeInt;
  Result.SysApiServiceId := Q.FieldByName('sys_api_service_id').AsLargeInt;
  Result.SenderAlias := Q.FieldByName('sender_alias').AsString;
  Result.SeriesCode := Q.FieldByName('series_code').AsString;
  Result.SeriesName := Q.FieldByName('series_name').AsString;
  Result.ServiceKind := Q.FieldByName('service_kind').AsString;
  Result.ProviderCode := Q.FieldByName('provider_code').AsString;
end;

function TEInvDocumentSettingRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvDocumentSetting) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvDocumentSettingRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvDocumentSetting>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvDocumentSetting>.Create(True);
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

function TEInvDocumentSettingRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvDocumentSetting;
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

function TEInvDocumentSettingRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvDocumentSetting;
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

procedure TEInvDocumentSettingRepository.DoAdd(AModel: TEInvDocumentSetting);
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

procedure TEInvDocumentSettingRepository.DoAddBatch(AModels: TArray<TEInvDocumentSetting>);
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

procedure TEInvDocumentSettingRepository.DoUpdate(AModel: TEInvDocumentSetting);
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

procedure TEInvDocumentSettingRepository.DoUpdateBatch(AModels: TArray<TEInvDocumentSetting>);
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

procedure TEInvDocumentSettingRepository.DoDelete(AID: TValue);
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

procedure TEInvDocumentSettingRepository.DoDelete(AModel: TEInvDocumentSetting);
begin
  Delete(AModel.Id);
end;

procedure TEInvDocumentSettingRepository.DoDeleteBatch(AModels: TArray<TEInvDocumentSetting>);
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

procedure TEInvDocumentSettingRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEInvDocumentSettingRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
