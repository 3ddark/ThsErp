unit SysPermission.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysPermission, SysPermissionGroup, SysLanguage;

type
  TSysPermissionRepository = class(TRepository<TSysPermission>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    function PrepareLoadTranslationSql: string;
    function PrepareSaveTranslationSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysPermission; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysPermission; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysPermission; override;

    procedure SaveTranslations(AModel: TSysPermission);
    procedure LoadTranslations(AModel: TSysPermission);


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysPermission>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysPermission; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysPermission; override;

    procedure DoAdd(AModel: TSysPermission); override;
    procedure DoAddBatch(AModels: TArray<TSysPermission>); override;

    procedure DoUpdate(AModel: TSysPermission); override;
    procedure DoUpdateBatch(AModels: TArray<TSysPermission>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysPermission); override;
    procedure DoDeleteBatch(AModels: TArray<TSysPermission>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysPermissionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysPermissionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysPermission) +
            ' (permission_code, sys_permission_group_id, permission_key) VALUES (:permission_code, :sys_permission_group_id, :permission_key)';
end;

function TSysPermissionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysPermission) +
            ' SET permission_code = :permission_code, sys_permission_group_id = :sys_permission_group_id, permission_key = :permission_key WHERE id = :id';
end;

function TSysPermissionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysPermission) + ' WHERE';
end;

function TSysPermissionRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.sys_permission_id, t.sys_language_id, t.permission_name, ' +
            '       l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TSysPermissionTranslation) + ' t ' +
            ' LEFT JOIN public.' + Self.GetTableName(TSysLanguage) + ' l ON l.id = t.sys_language_id ' +
            ' WHERE t.sys_permission_id = :sys_permission_id';
end;

function TSysPermissionRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysPermissionTranslation) +
            ' (sys_permission_id, sys_language_id, permission_name) ' +
            ' VALUES (:sys_permission_id, :sys_language_id, :permission_name) ' +
            ' ON CONFLICT (sys_permission_id, sys_language_id) DO UPDATE ' +
            ' SET permission_name = EXCLUDED.permission_name';
end;

procedure TSysPermissionRepository.LoadTranslations(AModel: TSysPermission);
var
  Q: TFDQuery;
  Trans: TSysPermissionTranslation;
begin
  if (AModel = nil) then Exit;

  if Assigned(AModel.Translations) then
    AModel.Translations.Clear
  else
    AModel.Translations := TObjectList<TSysPermissionTranslation>.Create(True);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('sys_permission_id').AsLargeInt := AModel.Id;
    LogQuery(Q, 'LoadTranslations');
    Q.Open;
    while not Q.Eof do
    begin
      Trans := TSysPermissionTranslation.Create;
      Trans.SysPermissionId := Q.FieldByName('sys_permission_id').AsLargeInt;
      Trans.SysLanguageId := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.PermissionName := Q.FieldByName('permission_name').AsWideString;

      Trans.SysLanguage := TSysLanguage.Create;
      Trans.SysLanguage.Id := Trans.SysLanguageId;
      Trans.SysLanguage.Locale := Q.FieldByName('locale').AsWideString;
      Trans.SysLanguage.NativeName := Q.FieldByName('native_name').AsWideString;

      AModel.Translations.Add(Trans);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionRepository.SaveTranslations(AModel: TSysPermission);
var
  Q: TFDQuery;
  Trans: TSysPermissionTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) or (AModel.Translations.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSaveTranslationSql;
    for Trans in AModel.Translations do
    begin
      Trans.SysPermissionId := AModel.Id;
      Q.ParamByName('sys_permission_id').AsLargeInt := Trans.SysPermissionId;
      Q.ParamByName('sys_language_id').AsLargeInt := Trans.SysLanguageId;
      Q.ParamByName('permission_name').AsWideString := Trans.PermissionName;
      LogQuery(Q, 'SaveTranslations');
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionRepository.SetInsertParams(Q: TFDQuery; AModel: TSysPermission; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('permission_code').AsInteger := AModel.PermissionCode;
    Q.ParamByName('sys_permission_group_id').AsLargeInt := AModel.SysPermissionGroupId;
    Q.ParamByName('permission_key').AsWideString := AModel.PermissionKey;
  end
  else
  begin
    Q.ParamByName('permission_code').AsIntegers[AIndex] := AModel.PermissionCode;
    Q.ParamByName('sys_permission_group_id').AsLargeInts[AIndex] := AModel.SysPermissionGroupId;
    Q.ParamByName('permission_key').AsWideStrings[AIndex] := AModel.PermissionKey;
  end;
end;

procedure TSysPermissionRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysPermission; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('permission_code').AsInteger := AModel.PermissionCode;
    Q.ParamByName('sys_permission_group_id').AsLargeInt := AModel.SysPermissionGroupId;
    Q.ParamByName('permission_key').AsString := AModel.PermissionKey;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('permission_code').AsIntegers[AIndex] := AModel.PermissionCode;
    Q.ParamByName('sys_permission_group_id').AsLargeInts[AIndex] := AModel.SysPermissionGroupId;
    Q.ParamByName('permission_key').AsStrings[AIndex] := AModel.PermissionKey;
  end;
end;

function TSysPermissionRepository.MapFromQuery(Q: TFDQuery): TSysPermission;
begin
  Result := TSysPermission.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PermissionCode := Q.FieldByName('permission_code').AsInteger;
  Result.SysPermissionGroupId := Q.FieldByName('sys_permission_group_id').AsLargeInt;
  Result.PermissionKey := Q.FieldByName('permission_key').AsString;
end;

function TSysPermissionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysPermission) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysPermissionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysPermission>;
var
  Q: TFDQuery;
  Item: TSysPermission;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysPermission>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    end;

    Q.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;

    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      Item := MapFromQuery(Q);
      LoadTranslations(Item);
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysPermissionRepository.DoFindById(AId: TValue; ALock: Boolean): TSysPermission;
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
    begin
      Result := MapFromQuery(Q);
      LoadTranslations(Result);
    end;
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysPermissionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysPermission;
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
    begin
      Result := MapFromQuery(Q);
      LoadTranslations(Result);
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionRepository.DoAdd(AModel: TSysPermission);
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

  SaveTranslations(AModel);
end;

procedure TSysPermissionRepository.DoAddBatch(AModels: TArray<TSysPermission>);
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

  for I := 0 to Count - 1 do
    SaveTranslations(AModels[I]);
end;

procedure TSysPermissionRepository.DoUpdate(AModel: TSysPermission);
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

  SaveTranslations(AModel);
end;

procedure TSysPermissionRepository.DoUpdateBatch(AModels: TArray<TSysPermission>);
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

  for I := 0 to Count - 1 do
    SaveTranslations(AModels[I]);
end;

procedure TSysPermissionRepository.DoDelete(AID: TValue);
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

procedure TSysPermissionRepository.DoDelete(AModel: TSysPermission);
begin
  Delete(AModel.Id);
end;

procedure TSysPermissionRepository.DoDeleteBatch(AModels: TArray<TSysPermission>);
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

procedure TSysPermissionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSysPermissionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
