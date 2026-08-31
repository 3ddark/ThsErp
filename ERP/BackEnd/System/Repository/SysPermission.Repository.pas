unit SysPermission.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, FilterCriterion, AppContext, LocalizationManager,
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
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysPermission>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysPermission; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysPermission; override;

    procedure Add(AModel: TSysPermission); override;
    procedure AddBatch(AModels: TArray<TSysPermission>); override;

    procedure Update(AModel: TSysPermission); override;
    procedure UpdateBatch(AModels: TArray<TSysPermission>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysPermission); override;
    procedure DeleteBatch(AModels: TArray<TSysPermission>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

constructor TSysPermissionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysPermissionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysPermission) +
            ' (code, group_id, key) VALUES (:code, :group_id, :key)';
end;

function TSysPermissionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysPermission) +
            ' SET code = :code, group_id = :group_id, key = :key WHERE id = :id';
end;

function TSysPermissionRepository.PrepareDeleteSql: string;
begin
  //WHERE kýsmý özellikle böyle yazýldý. Filtre vermeden iþlem yapýlmamasý için. Hatalý kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysPermission) + ' WHERE';
end;

function TSysPermissionRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.sys_permission_id, t.sys_language_id, t.name, ' +
            '       l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TSysPermissionTranslation) + ' t ' +
            ' LEFT JOIN public.' + Self.GetTableName(TSysLanguage) + ' l ON l.id = t.sys_language_id ' +
            ' WHERE t.sys_permission_id = :permission_id';
end;

function TSysPermissionRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysPermissionTranslation) +
            ' (sys_permission_id, sys_language_id, name) ' +
            ' VALUES (:sys_permission_id, :sys_language_id, :name) ' +
            ' ON CONFLICT (sys_permission_id, sys_language_id) DO UPDATE ' +
            ' SET name = EXCLUDED.name';
end;

procedure TSysPermissionRepository.LoadTranslations(AModel: TSysPermission);
var
  Q: TFDQuery;
  Trans: TSysPermissionTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) then Exit;
  AModel.Translations.Clear;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('permission_id').AsLargeInt := AModel.Id;
    Q.Open;
    while not Q.Eof do
    begin
      Trans := TSysPermissionTranslation.Create;
      Trans.PermissionId := Q.FieldByName('sys_permission_id').AsLargeInt;
      Trans.LanguageId := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.Name := Q.FieldByName('name').AsWideString;

      Trans.Language := TSysLanguage.Create;
      Trans.Language.Id := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.Language.Locale := Q.FieldByName('locale').AsWideString;
      Trans.Language.NativeName := Q.FieldByName('native_name').AsWideString;

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
      Trans.PermissionId := AModel.Id;
      Q.ParamByName('sys_permission_id').AsLargeInt := Trans.PermissionId;
      Q.ParamByName('sys_language_id').AsLargeInt := Trans.LanguageId;
      Q.ParamByName('name').AsWideString := Trans.Name;
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
    Q.ParamByName('code').AsInteger                 := AModel.Code;
    Q.ParamByName('group_id').AsLargeInt            := AModel.GroupId;
    Q.ParamByName('key').AsWideString               := AModel.Key;
  end
  else
  begin
    Q.ParamByName('code').AsIntegers[AIndex]        := AModel.Code;
    Q.ParamByName('group_id').AsLargeInts[AIndex]   := AModel.GroupId;
    Q.ParamByName('key').AsWideStrings[AIndex]          := AModel.Key;
  end;
end;

procedure TSysPermissionRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysPermission; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt                  := AModel.Id;
    Q.ParamByName('code').AsInteger                 := AModel.Code;
    Q.ParamByName('group_id').AsLargeInt            := AModel.GroupId;
    Q.ParamByName('key').AsString                   := AModel.Key;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]         := AModel.Id;
    Q.ParamByName('code').AsIntegers[AIndex]        := AModel.Code;
    Q.ParamByName('group_id').AsLargeInts[AIndex]   := AModel.GroupId;
    Q.ParamByName('key').AsStrings[AIndex]          := AModel.Key;
  end;
end;

function TSysPermissionRepository.MapFromQuery(Q: TFDQuery): TSysPermission;
begin
  Result := TSysPermission.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.Code         := Q.FieldByName('code').AsInteger;
  Result.GroupId      := Q.FieldByName('group_id').AsLargeInt;
  Result.Key          := Q.FieldByName('key').AsString;
end;

function TSysPermissionRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysPermission) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysPermissionRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysPermission>;
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

function TSysPermissionRepository.FindById(AId: TValue; ALock: Boolean): TSysPermission;
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

function TSysPermissionRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysPermission;
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

procedure TSysPermissionRepository.Add(AModel: TSysPermission);
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

procedure TSysPermissionRepository.AddBatch(AModels: TArray<TSysPermission>);
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

procedure TSysPermissionRepository.Update(AModel: TSysPermission);
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

procedure TSysPermissionRepository.UpdateBatch(AModels: TArray<TSysPermission>);
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

procedure TSysPermissionRepository.Delete(AID: Int64);
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

procedure TSysPermissionRepository.Delete(AModel: TSysPermission);
begin
  Delete(AModel.Id);
end;

procedure TSysPermissionRepository.DeleteBatch(AModels: TArray<TSysPermission>);
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

procedure TSysPermissionRepository.DeleteBatch(AIDs: TArray<Int64>);
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

procedure TSysPermissionRepository.DeleteBatch(AFilter: TFilterCriteria);
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
