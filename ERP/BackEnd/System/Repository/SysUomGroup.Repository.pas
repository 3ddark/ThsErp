unit SysUomGroup.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, FilterCriterion, AppContext, LocalizationManager,
  SysUomGroup, SysLanguage;

type
  TSysUomGroupRepository = class(TRepository<TSysUomGroup>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    function PrepareLoadTranslationSql: string;
    function PrepareSaveTranslationSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysUomGroup; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysUomGroup; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysUomGroup; override;

    procedure SaveTranslations(AModel: TSysUomGroup);
    procedure LoadTranslations(AModel: TSysUomGroup);
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysUomGroup>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysUomGroup; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysUomGroup; override;

    procedure Add(AModel: TSysUomGroup); override;
    procedure AddBatch(AModels: TArray<TSysUomGroup>); override;

    procedure Update(AModel: TSysUomGroup); override;
    procedure UpdateBatch(AModels: TArray<TSysUomGroup>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysUomGroup); override;
    procedure DeleteBatch(AModels: TArray<TSysUomGroup>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

constructor TSysUomGroupRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysUomGroupRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysUomGroup) + ' (key) VALUES (:key)';
end;

function TSysUomGroupRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysUomGroup) + ' SET key = :key WHERE id = :id';
end;

function TSysUomGroupRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysUomGroup) + ' WHERE';
end;

function TSysUomGroupRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.sys_uom_type_id, t.sys_language_id, t.name, ' +
            '       l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TSysUomGroupTranslation) + ' t ' +
            ' LEFT JOIN public.sys_language l ON l.id = t.sys_language_id ' +
            ' WHERE t.sys_uom_type_id = :sys_uom_type_id';
end;

function TSysUomGroupRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysUomGroupTranslation) +
            ' (sys_uom_type_id, sys_language_id, name) ' +
            ' VALUES (:sys_uom_type_id, :sys_language_id, :name) ' +
            ' ON CONFLICT (sys_uom_type_id, sys_language_id) DO UPDATE ' +
            ' SET name = EXCLUDED.name';
end;

procedure TSysUomGroupRepository.LoadTranslations(AModel: TSysUomGroup);
var
  Q: TFDQuery;
  Trans: TSysUomGroupTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) then Exit;
  AModel.Translations.Clear;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('sys_uom_type_id').AsLargeInt := AModel.Id;
    Q.Open;
    while not Q.Eof do
    begin
      Trans := TSysUomGroupTranslation.Create;
      Trans.SysUomGroupId := Q.FieldByName('sys_uom_type_id').AsLargeInt;
      Trans.SysLanguageId := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.Name := Q.FieldByName('name').AsString;

      Trans.SysLanguage := TSysLanguage.Create;
      Trans.SysLanguage.Id := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.SysLanguage.Locale := Q.FieldByName('locale').AsString;
      Trans.SysLanguage.NativeName := Q.FieldByName('native_name').AsString;

      AModel.Translations.Add(Trans);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysUomGroupRepository.SaveTranslations(AModel: TSysUomGroup);
var
  Q: TFDQuery;
  Trans: TSysUomGroupTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) or (AModel.Translations.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSaveTranslationSql;
    for Trans in AModel.Translations do
    begin
      Trans.SysUomGroupId := AModel.Id;
      Q.ParamByName('sys_uom_type_id').AsLargeInt := Trans.SysUomGroupId;
      Q.ParamByName('sys_language_id').AsLargeInt := Trans.SysLanguageId;
      Q.ParamByName('name').AsString := Trans.Name;
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysUomGroupRepository.SetInsertParams(Q: TFDQuery; AModel: TSysUomGroup; AIndex: Integer);
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

procedure TSysUomGroupRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysUomGroup; AIndex: Integer);
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

function TSysUomGroupRepository.MapFromQuery(Q: TFDQuery): TSysUomGroup;
begin
  Result := TSysUomGroup.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.Key          := Q.FieldByName('key').AsString;
end;

function TSysUomGroupRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysUomGroup) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysUomGroupRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysUomGroup>;
var
  Q: TFDQuery;
  Item: TSysUomGroup;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysUomGroup>.Create(True);
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

function TSysUomGroupRepository.FindById(AId: TValue; ALock: Boolean): TSysUomGroup;
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

function TSysUomGroupRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysUomGroup;
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

procedure TSysUomGroupRepository.Add(AModel: TSysUomGroup);
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

procedure TSysUomGroupRepository.AddBatch(AModels: TArray<TSysUomGroup>);
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

procedure TSysUomGroupRepository.Update(AModel: TSysUomGroup);
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

procedure TSysUomGroupRepository.UpdateBatch(AModels: TArray<TSysUomGroup>);
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

procedure TSysUomGroupRepository.Delete(AID: Int64);
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

procedure TSysUomGroupRepository.Delete(AModel: TSysUomGroup);
begin
  Delete(AModel.Id);
end;

procedure TSysUomGroupRepository.DeleteBatch(AModels: TArray<TSysUomGroup>);
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

procedure TSysUomGroupRepository.DeleteBatch(AIDs: TArray<Int64>);
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

procedure TSysUomGroupRepository.DeleteBatch(AFilter: TFilterCriteria);
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
