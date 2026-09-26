unit SysUom.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysUom, SysLanguage;

type
  TSysUomRepository = class(TRepository<TSysUom>)
  protected
    function PrepareAddSql: string; virtual;
    function PrepareUpdateSql: string; virtual;
    function PrepareDeleteSql: string; virtual;

    function PrepareSaveTranslationSql: string; virtual;
    function PrepareLoadTranslationSql: string; virtual;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysUom; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysUom; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysUom; override;

    procedure SaveTranslations(AModel: TSysUom); virtual;
    procedure LoadTranslations(AModel: TSysUom); virtual;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSysUom>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysUom; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysUom; override;

    procedure DoAdd(AModel: TSysUom); override;
    procedure DoAddBatch(AModels: TArray<TSysUom>); override;

    procedure DoUpdate(AModel: TSysUom); override;
    procedure DoUpdateBatch(AModels: TArray<TSysUom>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysUom); override;
    procedure DoDeleteBatch(AModels: TArray<TSysUom>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

uses
  Logger, Ths.Language.Cache;

constructor TSysUomRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysUomRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysUom) +
            ' (unit_code, unit_einv, decimal, sys_uom_group_id, multiplier) ' +
            ' VALUES (:unit_code, :unit_einv, :decimal, :sys_uom_group_id, :multiplier)';
end;

function TSysUomRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysUom) +
            ' SET unit_code = :unit_code, unit_einv = :unit_einv, ' +
            '     decimal = :decimal, sys_uom_group_id = :sys_uom_group_id, multiplier = :multiplier WHERE id = :id';
end;

function TSysUomRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysUom) + ' WHERE id = :id';
end;

function TSysUomRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.sys_uom_id, t.sys_language_id, t.uom_name, ' +
            '       l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TSysUomTranslation) + ' t ' +
            ' LEFT JOIN public.sys_language l ON l.id = t.sys_language_id ' +
            ' WHERE t.sys_uom_id = :sys_uom_id';
end;

function TSysUomRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysUomTranslation) +
            ' (sys_uom_id, sys_language_id, uom_name) ' +
            ' VALUES (:sys_uom_id, :sys_language_id, :uom_name) ' +
            ' ON CONFLICT (sys_uom_id, sys_language_id) DO UPDATE ' +
            ' SET uom_name = EXCLUDED.uom_name';
end;

procedure TSysUomRepository.LoadTranslations(AModel: TSysUom);
var
  Q: TFDQuery;
  Trans: TSysUomTranslation;
begin
  if (AModel = nil) then Exit;

  if Assigned(AModel.Translations) then
    AModel.Translations.Clear
  else
    AModel.Translations := TObjectList<TSysUomTranslation>.Create(True);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('sys_uom_id').AsLargeInt := AModel.Id;
    LogQuery(Q, 'LoadTranslations');
    Q.Open;

    while not Q.Eof do
    begin
      Trans := TSysUomTranslation.Create;
      Trans.SysUomId := Q.FieldByName('sys_uom_id').AsLargeInt;
      Trans.SysLanguageId := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.UomName := Q.FieldByName('uom_name').AsString;

      Trans.SysLanguage := TSysLanguage.Create;
      Trans.SysLanguage.Id := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.SysLanguage.Locale := TLanguageCache.GetLocaleById(Trans.SysLanguageId);

      if Trans.SysLanguage.Locale = '' then
        Trans.SysLanguage.Locale := Q.FieldByName('locale').AsString;

      Trans.SysLanguage.NativeName := Q.FieldByName('native_name').AsString;

      AModel.Translations.Add(Trans);

      if SameText(Trans.SysLanguage.Locale, TAppContext.Instance.CurrentUser.ActiveLanguage) then
        AModel.UomName := Trans.UomName;

      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysUomRepository.SaveTranslations(AModel: TSysUom);
var
  Q: TFDQuery;
  Trans: TSysUomTranslation;
  LLangId: Int64;
begin
  if (AModel = nil) or (AModel.Translations = nil) or (AModel.Translations.Count = 0) then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text   := PrepareSaveTranslationSql;

    for Trans in AModel.Translations do
    begin
      LLangId := Trans.SysLanguageId;

      if (LLangId = 0) and Assigned(Trans.SysLanguage) and (Trans.SysLanguage.Locale <> '') then
        LLangId := TLanguageCache.GetIdByLocale(Trans.SysLanguage.Locale);

      if LLangId = 0 then
      begin
        GLogger.WarningFmt('SaveTranslations: locale could not be resolved [%s]', [Trans.SysLanguage.Locale]);
        Continue;
      end;

      Trans.SysUomId := AModel.Id;
      Q.ParamByName('sys_uom_id').AsLargeInt := Trans.SysUomId;
      Q.ParamByName('sys_language_id').AsLargeInt := Trans.SysLanguageId;
      Q.ParamByName('uom_name').AsString := Trans.UomName;
      LogQuery(Q, 'SaveTranslations');
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysUomRepository.SetInsertParams(Q: TFDQuery; AModel: TSysUom; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('unit_code').AsString := AModel.UnitCode;
    Q.ParamByName('unit_einv').AsString := AModel.UnitEInv;
    Q.ParamByName('decimal').AsBoolean := AModel.Decimal;
    Q.ParamByName('sys_uom_group_id').AsLargeInt := AModel.SysUomGroupId;
    Q.ParamByName('multiplier').AsInteger := AModel.Multiplier;
  end
  else
  begin
    Q.ParamByName('unit_code').AsStrings[AIndex] := AModel.UnitCode;
    Q.ParamByName('unit_einv').AsStrings[AIndex] := AModel.UnitEInv;
    Q.ParamByName('decimal').AsBooleans[AIndex] := AModel.Decimal;
    Q.ParamByName('sys_uom_group_id').AsLargeInts[AIndex] := AModel.SysUomGroupId;
    Q.ParamByName('multiplier').AsIntegers[AIndex] := AModel.Multiplier;
  end;
end;

procedure TSysUomRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysUom; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('unit_code').AsString := AModel.UnitCode;
    Q.ParamByName('unit_einv').AsString := AModel.UnitEInv;
    Q.ParamByName('decimal').AsBoolean := AModel.Decimal;
    Q.ParamByName('sys_uom_group_id').AsLargeInt := AModel.SysUomGroupId;
    Q.ParamByName('multiplier').AsInteger := AModel.Multiplier;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('unit_code').AsStrings[AIndex] := AModel.UnitCode;
    Q.ParamByName('unit_einv').AsStrings[AIndex] := AModel.UnitEInv;
    Q.ParamByName('decimal').AsBooleans[AIndex] := AModel.Decimal;
    Q.ParamByName('sys_uom_group_id').AsLargeInts[AIndex] := AModel.SysUomGroupId;
    Q.ParamByName('multiplier').AsIntegers[AIndex] := AModel.Multiplier;
  end;
end;

function TSysUomRepository.MapFromQuery(Q: TFDQuery): TSysUom;
begin
  Result := TSysUom.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.UnitCode := Q.FieldByName('unit_code').AsString;
  Result.UnitEInv := Q.FieldByName('unit_einv').AsString;
  Result.Decimal := Q.FieldByName('decimal').AsBoolean;
  Result.SysUomGroupId := Q.FieldByName('sys_uom_group_id').AsLargeInt;
  Result.Multiplier := Q.FieldByName('multiplier').AsInteger;
  Result.UomName := Q.FieldByName('uom_name').AsString;
end;

function TSysUomRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id', 'locale']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSysUom) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysUomRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSysUom>;
var
  Q: TFDQuery;
  Item: TSysUom;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysUom>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, True);

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criteria in AFilter do
        Q.SQL.Text := Q.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.FieldName;
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

function TSysUomRepository.DoFindById(AId: TValue; ALock: Boolean): TSysUom;
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
      if Assigned(Result) then
        LoadTranslations(Result);
    end;
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysUomRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysUom;
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

procedure TSysUomRepository.DoAdd(AModel: TSysUom);
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

procedure TSysUomRepository.DoAddBatch(AModels: TArray<TSysUom>);
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

procedure TSysUomRepository.DoUpdate(AModel: TSysUom);
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

procedure TSysUomRepository.DoUpdateBatch(AModels: TArray<TSysUom>);
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

procedure TSysUomRepository.DoDelete(AID: TValue);
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

procedure TSysUomRepository.DoDelete(AModel: TSysUom);
begin
  Delete(AModel.Id);
end;

procedure TSysUomRepository.DoDeleteBatch(AModels: TArray<TSysUom>);
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

procedure TSysUomRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSysUomRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
