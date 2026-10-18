unit SysApiService.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SysApiService, ApiService.Config;

type
  TSysApiServiceRepository = class(TRepository<TSysApiService>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysApiService; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysApiService; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysApiService; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysApiService>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysApiService; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysApiService; override;

    procedure DoAdd(AModel: TSysApiService); override;
    procedure DoAddBatch(AModels: TArray<TSysApiService>); override;

    procedure DoUpdate(AModel: TSysApiService); override;
    procedure DoUpdateBatch(AModels: TArray<TSysApiService>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysApiService); override;
    procedure DoDeleteBatch(AModels: TArray<TSysApiService>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function ApplicationSettingId: Int64;
    function KindExists(ASettingId: Int64; const AKind: string; AExcludeId: Int64): Boolean;
    // firma ayarındaki servis türünün bağlantı bilgisi; gizli alanlar şifreli döner (yoksa False)
    function LoadConfig(const AKind: string; out AConfig: TApiServiceConfig; out APasswordEnc, AApiKeyEnc: string): Boolean;
  end;

implementation

constructor TSysApiServiceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysApiServiceRepository.LoadConfig(const AKind: string; out AConfig: TApiServiceConfig;
  out APasswordEnc, AApiKeyEnc: string): Boolean;
var
  Q: TFDQuery;
begin
  AConfig := Default(TApiServiceConfig);
  AConfig.Kind := AKind;
  APasswordEnc := '';
  AApiKeyEnc := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT s.provider_code, s.environment, s.base_url, s.username, s.password_enc, s.api_key_enc, ' +
                  '       s.timeout_seconds, s.options::text AS options, s.is_active ' +
                  '  FROM public.sys_api_service s ' +
                  ' WHERE s.service_kind = :kind ' +
                  '   AND s.sys_application_setting_id = (SELECT min(id) FROM public.sys_application_setting)';
    Q.ParamByName('kind').AsWideString := AKind;
    LogQuery(Q, 'LoadConfig');
    Q.Open;
    Result := not Q.IsEmpty;
    if not Result then
      Exit;
    AConfig.ProviderCode := Q.FieldByName('provider_code').AsString;
    AConfig.Environment := Q.FieldByName('environment').AsInteger;
    AConfig.BaseUrl := Q.FieldByName('base_url').AsString;
    AConfig.Username := Q.FieldByName('username').AsString;
    AConfig.TimeoutSeconds := Q.FieldByName('timeout_seconds').AsInteger;
    AConfig.Options := Q.FieldByName('options').AsString;
    AConfig.Active := Q.FieldByName('is_active').AsBoolean;
    APasswordEnc := Q.FieldByName('password_enc').AsString;
    AApiKeyEnc := Q.FieldByName('api_key_enc').AsString;
  finally
    Q.Free;
  end;
end;

function TSysApiServiceRepository.ApplicationSettingId: Int64;
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

function TSysApiServiceRepository.KindExists(ASettingId: Int64; const AKind: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.sys_api_service WHERE sys_application_setting_id = :s AND service_kind = :k AND id <> :id';
    Q.ParamByName('s').AsLargeInt := ASettingId;
    Q.ParamByName('k').AsWideString := AKind;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'KindExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

function TSysApiServiceRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysApiService) +
            ' (sys_application_setting_id, service_kind, provider_code, environment, base_url, username, timeout_seconds, options, description, is_active, password_enc, api_key_enc) ' +
            ' VALUES (:sys_application_setting_id, :service_kind, :provider_code, :environment, :base_url, :username, :timeout_seconds, CAST(:options AS jsonb), :description, :is_active, :password_enc, :api_key_enc)';
end;

function TSysApiServiceRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysApiService) +
            ' SET sys_application_setting_id = :sys_application_setting_id, service_kind = :service_kind, provider_code = :provider_code, environment = :environment, base_url = :base_url, username = :username, timeout_seconds = :timeout_seconds, options = CAST(:options AS jsonb), description = :description, is_active = :is_active, ' +
            '     password_enc = CASE WHEN :password_enc_set THEN :password_enc ELSE password_enc END, ' +
            '     api_key_enc = CASE WHEN :api_key_enc_set THEN :api_key_enc ELSE api_key_enc END ' +
            ' WHERE id = :id';
end;

function TSysApiServiceRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysApiService) + ' WHERE';
end;

procedure TSysApiServiceRepository.SetInsertParams(Q: TFDQuery; AModel: TSysApiService; AIndex: Integer);

  // gizli bilgi: yalnız yeni değer yazıldığında ya da silme istendiğinde değişir (UPDATE'te *_set)
  procedure SetSecret(const AName, AValue: string; AChange: Boolean);
  begin
    Q.ParamByName(AName).DataType := ftWideString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsWideString := AValue
      else
        Q.ParamByName(AName).AsWideStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
    if Q.FindParam(AName + '_set') <> nil then
      if AIndex < 0 then
        Q.ParamByName(AName + '_set').AsBoolean := AChange
      else
        Q.ParamByName(AName + '_set').AsBooleans[AIndex] := AChange;
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('service_kind').AsWideString := AModel.ServiceKind;
    Q.ParamByName('provider_code').AsWideString := AModel.ProviderCode;
    Q.ParamByName('environment').AsSmallInt := AModel.Environment;
    Q.ParamByName('base_url').AsWideString := AModel.BaseUrl;
    Q.ParamByName('username').AsWideString := AModel.Username;
    Q.ParamByName('timeout_seconds').AsSmallInt := AModel.TimeoutSeconds;
    Q.ParamByName('options').AsWideString := AModel.Options;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('service_kind').AsWideStrings[AIndex] := AModel.ServiceKind;
    Q.ParamByName('provider_code').AsWideStrings[AIndex] := AModel.ProviderCode;
    Q.ParamByName('environment').AsSmallInts[AIndex] := AModel.Environment;
    Q.ParamByName('base_url').AsWideStrings[AIndex] := AModel.BaseUrl;
    Q.ParamByName('username').AsWideStrings[AIndex] := AModel.Username;
    Q.ParamByName('timeout_seconds').AsSmallInts[AIndex] := AModel.TimeoutSeconds;
    Q.ParamByName('options').AsWideStrings[AIndex] := AModel.Options;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;

  SetNullableParam(Q.ParamByName('sys_application_setting_id'), ftLargeint, AModel.SysApplicationSettingId, AIndex);
  SetSecret('password_enc', AModel.PasswordEnc, AModel.ClearSecrets or (AModel.PasswordEnc <> ''));
  SetSecret('api_key_enc', AModel.ApiKeyEnc, AModel.ClearSecrets or (AModel.ApiKeyEnc <> ''));
end;

procedure TSysApiServiceRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysApiService; AIndex: Integer);

  // gizli bilgi: yalnız yeni değer yazıldığında ya da silme istendiğinde değişir (UPDATE'te *_set)
  procedure SetSecret(const AName, AValue: string; AChange: Boolean);
  begin
    Q.ParamByName(AName).DataType := ftWideString;
    if AValue <> '' then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsWideString := AValue
      else
        Q.ParamByName(AName).AsWideStrings[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
    if Q.FindParam(AName + '_set') <> nil then
      if AIndex < 0 then
        Q.ParamByName(AName + '_set').AsBoolean := AChange
      else
        Q.ParamByName(AName + '_set').AsBooleans[AIndex] := AChange;
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('service_kind').AsWideString := AModel.ServiceKind;
    Q.ParamByName('provider_code').AsWideString := AModel.ProviderCode;
    Q.ParamByName('environment').AsSmallInt := AModel.Environment;
    Q.ParamByName('base_url').AsWideString := AModel.BaseUrl;
    Q.ParamByName('username').AsWideString := AModel.Username;
    Q.ParamByName('timeout_seconds').AsSmallInt := AModel.TimeoutSeconds;
    Q.ParamByName('options').AsWideString := AModel.Options;
    Q.ParamByName('description').AsWideString := AModel.Description;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('service_kind').AsWideStrings[AIndex] := AModel.ServiceKind;
    Q.ParamByName('provider_code').AsWideStrings[AIndex] := AModel.ProviderCode;
    Q.ParamByName('environment').AsSmallInts[AIndex] := AModel.Environment;
    Q.ParamByName('base_url').AsWideStrings[AIndex] := AModel.BaseUrl;
    Q.ParamByName('username').AsWideStrings[AIndex] := AModel.Username;
    Q.ParamByName('timeout_seconds').AsSmallInts[AIndex] := AModel.TimeoutSeconds;
    Q.ParamByName('options').AsWideStrings[AIndex] := AModel.Options;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;

  SetNullableParam(Q.ParamByName('sys_application_setting_id'), ftLargeint, AModel.SysApplicationSettingId, AIndex);
  SetSecret('password_enc', AModel.PasswordEnc, AModel.ClearSecrets or (AModel.PasswordEnc <> ''));
  SetSecret('api_key_enc', AModel.ApiKeyEnc, AModel.ClearSecrets or (AModel.ApiKeyEnc <> ''));
end;

function TSysApiServiceRepository.MapFromQuery(Q: TFDQuery): TSysApiService;
begin
  Result := TSysApiService.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SysApplicationSettingId := Q.FieldByName('sys_application_setting_id').AsLargeInt;
  Result.ServiceKind := Q.FieldByName('service_kind').AsString;
  Result.ProviderCode := Q.FieldByName('provider_code').AsString;
  Result.Environment := Q.FieldByName('environment').AsInteger;
  Result.BaseUrl := Q.FieldByName('base_url').AsString;
  Result.Username := Q.FieldByName('username').AsString;
  Result.TimeoutSeconds := Q.FieldByName('timeout_seconds').AsInteger;
  Result.Options := Q.FieldByName('options').AsString;
  Result.HasPassword := Q.FieldByName('has_password').AsBoolean;
  Result.HasApiKey := Q.FieldByName('has_api_key').AsBoolean;
  Result.Description := Q.FieldByName('description').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
end;

function TSysApiServiceRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysApiService) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysApiServiceRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysApiService>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysApiService>.Create(True);
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

function TSysApiServiceRepository.DoFindById(AId: TValue; ALock: Boolean): TSysApiService;
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

function TSysApiServiceRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysApiService;
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

procedure TSysApiServiceRepository.DoAdd(AModel: TSysApiService);
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

procedure TSysApiServiceRepository.DoAddBatch(AModels: TArray<TSysApiService>);
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

procedure TSysApiServiceRepository.DoUpdate(AModel: TSysApiService);
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

procedure TSysApiServiceRepository.DoUpdateBatch(AModels: TArray<TSysApiService>);
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

procedure TSysApiServiceRepository.DoDelete(AID: TValue);
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

procedure TSysApiServiceRepository.DoDelete(AModel: TSysApiService);
begin
  Delete(AModel.Id);
end;

procedure TSysApiServiceRepository.DoDeleteBatch(AModels: TArray<TSysApiService>);
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

procedure TSysApiServiceRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSysApiServiceRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
