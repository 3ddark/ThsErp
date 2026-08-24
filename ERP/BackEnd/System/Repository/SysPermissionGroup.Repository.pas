unit SysPermissionGroup.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, FilterCriterion, AppContext, LocalizationManager,
  SysPermissionGroup, SysLanguage;

type
  TSysPermissionGroupRepository = class(TRepository<TSysPermissionGroup>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    function PrepareLoadTranslationSql: string;
    function PrepareSaveTranslationSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysPermissionGroup; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysPermissionGroup; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysPermissionGroup; override;

    procedure SaveTranslations(AModel: TSysPermissionGroup);
    procedure LoadTranslations(AModel: TSysPermissionGroup);
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysPermissionGroup>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysPermissionGroup; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysPermissionGroup; override;

    procedure Add(AModel: TSysPermissionGroup); override;
    procedure AddBatch(AModels: TArray<TSysPermissionGroup>); override;

    procedure Update(AModel: TSysPermissionGroup); override;
    procedure UpdateBatch(AModels: TArray<TSysPermissionGroup>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysPermissionGroup); override;
    procedure DeleteBatch(AModels: TArray<TSysPermissionGroup>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

constructor TSysPermissionGroupRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysPermissionGroupRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysPermissionGroup) + ' (key) VALUES (:key)';
end;

function TSysPermissionGroupRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysPermissionGroup) + ' SET key = :key WHERE id = :id';
end;

function TSysPermissionGroupRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysPermissionGroup) + ' WHERE';
end;

function TSysPermissionGroupRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.sys_permission_group_id, t.sys_language_id, t.name, ' +
            '       l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TSysPermissionGroupTranslation) + ' t ' +
            ' LEFT JOIN public.sys_language l ON l.id = t.sys_language_id ' +
            ' WHERE t.sys_permission_group_id = :sys_permission_group_id';
end;

function TSysPermissionGroupRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysPermissionGroupTranslation) +
            ' (sys_permission_group_id, sys_language_id, name) ' +
            ' VALUES (:sys_permission_group_id, :sys_language_id, :name) ' +
            ' ON CONFLICT (sys_permission_group_id, sys_language_id) DO UPDATE ' +
            ' SET name = EXCLUDED.name';
end;

procedure TSysPermissionGroupRepository.LoadTranslations(AModel: TSysPermissionGroup);
var
  Q: TFDQuery;
  Trans: TSysPermissionGroupTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) then Exit;
  AModel.Translations.Clear;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('sys_permission_group_id').AsLargeInt := AModel.Id;
    Q.Open;
    while not Q.Eof do
    begin
      Trans := TSysPermissionGroupTranslation.Create;
      Trans.PermissionGroupId := Q.FieldByName('sys_permission_group_id').AsLargeInt;
      Trans.LanguageId := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.Name := Q.FieldByName('name').AsString;

      Trans.Language := TSysLanguage.Create;
      Trans.Language.Id := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.Language.Locale := Q.FieldByName('locale').AsString;
      Trans.Language.NativeName := Q.FieldByName('native_name').AsString;

      AModel.Translations.Add(Trans);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionGroupRepository.SaveTranslations(AModel: TSysPermissionGroup);
var
  Q: TFDQuery;
  Trans: TSysPermissionGroupTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) or (AModel.Translations.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSaveTranslationSql;
    for Trans in AModel.Translations do
    begin
      Trans.PermissionGroupId := AModel.Id;
      Q.ParamByName('sys_permission_group_id').AsLargeInt := Trans.PermissionGroupId;
      Q.ParamByName('sys_language_id').AsLargeInt := Trans.LanguageId;
      Q.ParamByName('name').AsString := Trans.Name;
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionGroupRepository.SetInsertParams(Q: TFDQuery; AModel: TSysPermissionGroup; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('key').AsString := AModel.Key;
  end
  else
  begin
    Q.ParamByName('key').AsStrings[AIndex] := AModel.Key;
  end;
end;

procedure TSysPermissionGroupRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysPermissionGroup; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt     := AModel.Id;
    Q.ParamByName('key').AsString      := AModel.Key;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]     := AModel.Id;
    Q.ParamByName('key').AsStrings[AIndex]      := AModel.Key;
  end;
end;

function TSysPermissionGroupRepository.MapFromQuery(Q: TFDQuery): TSysPermissionGroup;
begin
  Result := TSysPermissionGroup.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.Key          := Q.FieldByName('key').AsString;
end;

function TSysPermissionGroupRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysPermissionGroup) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysPermissionGroupRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysPermissionGroup>;
var
  Q: TFDQuery;
  Item: TSysPermissionGroup;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysPermissionGroup>.Create(True);
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

function TSysPermissionGroupRepository.FindById(AId: TValue; ALock: Boolean): TSysPermissionGroup;
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

function TSysPermissionGroupRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysPermissionGroup;
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

procedure TSysPermissionGroupRepository.Add(AModel: TSysPermissionGroup);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;

  SaveTranslations(AModel);
end;

procedure TSysPermissionGroupRepository.AddBatch(AModels: TArray<TSysPermissionGroup>);
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

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;

  for I := 0 to Count - 1 do
    SaveTranslations(AModels[I]);
end;

procedure TSysPermissionGroupRepository.Update(AModel: TSysPermissionGroup);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  SaveTranslations(AModel);
end;

procedure TSysPermissionGroupRepository.UpdateBatch(AModels: TArray<TSysPermissionGroup>);
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

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;

  for I := 0 to Count - 1 do
    SaveTranslations(AModels[I]);
end;

procedure TSysPermissionGroupRepository.Delete(AID: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionGroupRepository.Delete(AModel: TSysPermissionGroup);
begin
  Delete(AModel.Id);
end;

procedure TSysPermissionGroupRepository.DeleteBatch(AModels: TArray<TSysPermissionGroup>);
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

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionGroupRepository.DeleteBatch(AIDs: TArray<Int64>);
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
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I];

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysPermissionGroupRepository.DeleteBatch(AFilter: TFilterCriteria);
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

    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
