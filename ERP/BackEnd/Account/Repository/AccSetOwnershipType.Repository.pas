unit AccSetOwnershipType.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, AccSetOwnershipType, SysLanguage;

type
  TAccSetOwnershipTypeRepository = class(TRepository<TAccSetOwnershipType>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;
    function PrepareLoadTranslationSql: string;
    function PrepareSaveTranslationSql: string;
    function PrepareDeleteTranslationSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TAccSetOwnershipType; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TAccSetOwnershipType; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TAccSetOwnershipType; override;

    procedure LoadTranslations(AModel: TAccSetOwnershipType);
    procedure SaveTranslations(AModel: TAccSetOwnershipType);

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TAccSetOwnershipType>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TAccSetOwnershipType; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TAccSetOwnershipType; override;

    procedure DoAdd(AModel: TAccSetOwnershipType); override;
    procedure DoAddBatch(AModels: TArray<TAccSetOwnershipType>); override;

    procedure DoUpdate(AModel: TAccSetOwnershipType); override;
    procedure DoUpdateBatch(AModels: TArray<TAccSetOwnershipType>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TAccSetOwnershipType); override;
    procedure DoDeleteBatch(AModels: TArray<TAccSetOwnershipType>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

uses
  Logger, Ths.Language.Cache;

constructor TAccSetOwnershipTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TAccSetOwnershipTypeRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccSetOwnershipType) +
            ' (ownership_type_key) ' +
            ' VALUES (:ownership_type_key)';
end;

function TAccSetOwnershipTypeRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TAccSetOwnershipType) +
            ' SET ownership_type_key = :ownership_type_key ' +
            ' WHERE id = :id';
end;

function TAccSetOwnershipTypeRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccSetOwnershipType) + ' WHERE';
end;

function TAccSetOwnershipTypeRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.acc_set_ownership_type_id, t.sys_language_id, t.name, l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TAccSetOwnershipTypeTranslation) + ' t ' +
            ' LEFT JOIN public.sys_language l ON l.id = t.sys_language_id ' +
            ' WHERE t.acc_set_ownership_type_id = :acc_set_ownership_type_id';
end;

function TAccSetOwnershipTypeRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TAccSetOwnershipTypeTranslation) +
            ' (acc_set_ownership_type_id, sys_language_id, name) ' +
            ' VALUES (:acc_set_ownership_type_id, :sys_language_id, :name) ' +
            ' ON CONFLICT (acc_set_ownership_type_id, sys_language_id) DO UPDATE ' +
            ' SET name = EXCLUDED.name';
end;

function TAccSetOwnershipTypeRepository.PrepareDeleteTranslationSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TAccSetOwnershipTypeTranslation) +
            ' WHERE acc_set_ownership_type_id = :acc_set_ownership_type_id AND sys_language_id = :sys_language_id';
end;

procedure TAccSetOwnershipTypeRepository.LoadTranslations(AModel: TAccSetOwnershipType);
var
  Q: TFDQuery;
  Trans: TAccSetOwnershipTypeTranslation;
begin
  if AModel = nil then
    Exit;

  if Assigned(AModel.Translations) then
    AModel.Translations.Clear
  else
    AModel.Translations := TObjectList<TAccSetOwnershipTypeTranslation>.Create(True);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('acc_set_ownership_type_id').AsLargeInt := AModel.Id;
    LogQuery(Q, 'LoadTranslations');
    Q.Open;

    while not Q.Eof do
    begin
      Trans := TAccSetOwnershipTypeTranslation.Create;
      Trans.AccSetOwnershipTypeId := Q.FieldByName('acc_set_ownership_type_id').AsLargeInt;
      Trans.SysLanguageId := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.Name := Q.FieldByName('name').AsString;

      Trans.SysLanguage := TSysLanguage.Create;
      Trans.SysLanguage.Id := Trans.SysLanguageId;
      Trans.SysLanguage.Locale := TLanguageCache.GetLocaleById(Trans.SysLanguageId);
      if Trans.SysLanguage.Locale = '' then
        Trans.SysLanguage.Locale := Q.FieldByName('locale').AsString;
      Trans.SysLanguage.NativeName := Q.FieldByName('native_name').AsString;

      AModel.Translations.Add(Trans);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Boş bırakılan çeviri satırı silinir; view bu durumda key değerine düşer
procedure TAccSetOwnershipTypeRepository.SaveTranslations(AModel: TAccSetOwnershipType);
var
  QSave, QDelete: TFDQuery;
  Trans: TAccSetOwnershipTypeTranslation;
  LLangId: Int64;
begin
  if (AModel = nil) or (AModel.Translations = nil) or (AModel.Translations.Count = 0) then
    Exit;

  QSave := TFDQuery.Create(nil);
  QDelete := TFDQuery.Create(nil);
  try
    QSave.Connection := Connection;
    QSave.SQL.Text := PrepareSaveTranslationSql;
    QDelete.Connection := Connection;
    QDelete.SQL.Text := PrepareDeleteTranslationSql;

    for Trans in AModel.Translations do
    begin
      LLangId := Trans.SysLanguageId;
      if (LLangId = 0) and Assigned(Trans.SysLanguage) and (Trans.SysLanguage.Locale <> '') then
        LLangId := TLanguageCache.GetIdByLocale(Trans.SysLanguage.Locale);

      if LLangId = 0 then
      begin
        GLogger.Warning('SaveTranslations: locale could not be resolved');
        Continue;
      end;

      Trans.AccSetOwnershipTypeId := AModel.Id;
      if Trim(Trans.Name) = '' then
      begin
        QDelete.ParamByName('acc_set_ownership_type_id').AsLargeInt := AModel.Id;
        QDelete.ParamByName('sys_language_id').AsLargeInt := LLangId;
        LogQuery(QDelete, 'DeleteTranslation');
        QDelete.ExecSQL;
      end
      else
      begin
        QSave.ParamByName('acc_set_ownership_type_id').AsLargeInt := AModel.Id;
        QSave.ParamByName('sys_language_id').AsLargeInt := LLangId;
        QSave.ParamByName('name').AsString := Trim(Trans.Name);
        LogQuery(QSave, 'SaveTranslations');
        QSave.ExecSQL;
      end;
    end;
  finally
    QSave.Free;
    QDelete.Free;
  end;
end;

procedure TAccSetOwnershipTypeRepository.SetInsertParams(Q: TFDQuery; AModel: TAccSetOwnershipType; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('ownership_type_key').AsString := AModel.OwnershipTypeKey;
  end
  else
  begin
    Q.ParamByName('ownership_type_key').AsStrings[AIndex] := AModel.OwnershipTypeKey;
  end;
end;

procedure TAccSetOwnershipTypeRepository.SetUpdateParams(Q: TFDQuery; AModel: TAccSetOwnershipType; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('ownership_type_key').AsString := AModel.OwnershipTypeKey;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('ownership_type_key').AsStrings[AIndex] := AModel.OwnershipTypeKey;
  end;
end;

function TAccSetOwnershipTypeRepository.MapFromQuery(Q: TFDQuery): TAccSetOwnershipType;
begin
  Result := TAccSetOwnershipType.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.OwnershipTypeKey := Q.FieldByName('ownership_type_key').AsString;
  Result.OwnershipTypeName := Q.FieldByName('ownership_type_name').AsString;
end;

function TAccSetOwnershipTypeRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TAccSetOwnershipType) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TAccSetOwnershipTypeRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TAccSetOwnershipType>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
  Item: TAccSetOwnershipType;
begin
  Result := TObjectList<TAccSetOwnershipType>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
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

function TAccSetOwnershipTypeRepository.DoFindById(AId: TValue; ALock: Boolean): TAccSetOwnershipType;
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

function TAccSetOwnershipTypeRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TAccSetOwnershipType;
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

procedure TAccSetOwnershipTypeRepository.DoAdd(AModel: TAccSetOwnershipType);
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

procedure TAccSetOwnershipTypeRepository.DoAddBatch(AModels: TArray<TAccSetOwnershipType>);
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

procedure TAccSetOwnershipTypeRepository.DoUpdate(AModel: TAccSetOwnershipType);
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

procedure TAccSetOwnershipTypeRepository.DoUpdateBatch(AModels: TArray<TAccSetOwnershipType>);
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

  for I := 0 to Count - 1 do
    SaveTranslations(AModels[I]);
end;

procedure TAccSetOwnershipTypeRepository.DoDelete(AID: TValue);
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

procedure TAccSetOwnershipTypeRepository.DoDelete(AModel: TAccSetOwnershipType);
begin
  Delete(AModel.Id);
end;

procedure TAccSetOwnershipTypeRepository.DoDeleteBatch(AModels: TArray<TAccSetOwnershipType>);
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

procedure TAccSetOwnershipTypeRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TAccSetOwnershipTypeRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
