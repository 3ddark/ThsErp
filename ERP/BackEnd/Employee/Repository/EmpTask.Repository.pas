unit EmpTask.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EmpTask, SysLanguage;

type
  TEmpTaskRepository = class(TRepository<TEmpTask>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;
    function PrepareLoadTranslationSql: string;
    function PrepareSaveTranslationSql: string;
    function PrepareDeleteTranslationSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEmpTask; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEmpTask; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEmpTask; override;

    procedure LoadTranslations(AModel: TEmpTask);
    procedure SaveTranslations(AModel: TEmpTask);

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEmpTask>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEmpTask; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEmpTask; override;

    procedure DoAdd(AModel: TEmpTask); override;
    procedure DoAddBatch(AModels: TArray<TEmpTask>); override;

    procedure DoUpdate(AModel: TEmpTask); override;
    procedure DoUpdateBatch(AModels: TArray<TEmpTask>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEmpTask); override;
    procedure DoDeleteBatch(AModels: TArray<TEmpTask>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

uses
  Logger, Ths.Language.Cache;

constructor TEmpTaskRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEmpTaskRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEmpTask) +
            ' (task_key) ' +
            ' VALUES (:task_key)';
end;

function TEmpTaskRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEmpTask) +
            ' SET task_key = :task_key ' +
            ' WHERE id = :id';
end;

function TEmpTaskRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEmpTask) + ' WHERE';
end;

function TEmpTaskRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.emp_task_id, t.sys_language_id, t.name, l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TEmpTaskTranslation) + ' t ' +
            ' LEFT JOIN public.sys_language l ON l.id = t.sys_language_id ' +
            ' WHERE t.emp_task_id = :emp_task_id';
end;

function TEmpTaskRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEmpTaskTranslation) +
            ' (emp_task_id, sys_language_id, name) ' +
            ' VALUES (:emp_task_id, :sys_language_id, :name) ' +
            ' ON CONFLICT (emp_task_id, sys_language_id) DO UPDATE ' +
            ' SET name = EXCLUDED.name';
end;

function TEmpTaskRepository.PrepareDeleteTranslationSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TEmpTaskTranslation) +
            ' WHERE emp_task_id = :emp_task_id AND sys_language_id = :sys_language_id';
end;

procedure TEmpTaskRepository.LoadTranslations(AModel: TEmpTask);
var
  Q: TFDQuery;
  Trans: TEmpTaskTranslation;
begin
  if AModel = nil then
    Exit;

  if Assigned(AModel.Translations) then
    AModel.Translations.Clear
  else
    AModel.Translations := TObjectList<TEmpTaskTranslation>.Create(True);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('emp_task_id').AsLargeInt := AModel.Id;
    LogQuery(Q, 'LoadTranslations');
    Q.Open;

    while not Q.Eof do
    begin
      Trans := TEmpTaskTranslation.Create;
      Trans.EmpTaskId := Q.FieldByName('emp_task_id').AsLargeInt;
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
procedure TEmpTaskRepository.SaveTranslations(AModel: TEmpTask);
var
  QSave, QDelete: TFDQuery;
  Trans: TEmpTaskTranslation;
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

      Trans.EmpTaskId := AModel.Id;
      if Trim(Trans.Name) = '' then
      begin
        QDelete.ParamByName('emp_task_id').AsLargeInt := AModel.Id;
        QDelete.ParamByName('sys_language_id').AsLargeInt := LLangId;
        LogQuery(QDelete, 'DeleteTranslation');
        QDelete.ExecSQL;
      end
      else
      begin
        QSave.ParamByName('emp_task_id').AsLargeInt := AModel.Id;
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

procedure TEmpTaskRepository.SetInsertParams(Q: TFDQuery; AModel: TEmpTask; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('task_key').AsString := AModel.TaskKey;
  end
  else
  begin
    Q.ParamByName('task_key').AsStrings[AIndex] := AModel.TaskKey;
  end;
end;

procedure TEmpTaskRepository.SetUpdateParams(Q: TFDQuery; AModel: TEmpTask; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('task_key').AsString := AModel.TaskKey;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('task_key').AsStrings[AIndex] := AModel.TaskKey;
  end;
end;

function TEmpTaskRepository.MapFromQuery(Q: TFDQuery): TEmpTask;
begin
  Result := TEmpTask.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.TaskKey := Q.FieldByName('task_key').AsString;
  Result.TaskName := Q.FieldByName('task_name').AsString;
end;

function TEmpTaskRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEmpTask) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TEmpTaskRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEmpTask>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
  Item: TEmpTask;
begin
  Result := TObjectList<TEmpTask>.Create(True);
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

function TEmpTaskRepository.DoFindById(AId: TValue; ALock: Boolean): TEmpTask;
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

function TEmpTaskRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEmpTask;
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

procedure TEmpTaskRepository.DoAdd(AModel: TEmpTask);
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

procedure TEmpTaskRepository.DoAddBatch(AModels: TArray<TEmpTask>);
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

procedure TEmpTaskRepository.DoUpdate(AModel: TEmpTask);
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

procedure TEmpTaskRepository.DoUpdateBatch(AModels: TArray<TEmpTask>);
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

procedure TEmpTaskRepository.DoDelete(AID: TValue);
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

procedure TEmpTaskRepository.DoDelete(AModel: TEmpTask);
begin
  Delete(AModel.Id);
end;

procedure TEmpTaskRepository.DoDeleteBatch(AModels: TArray<TEmpTask>);
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

procedure TEmpTaskRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TEmpTaskRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
