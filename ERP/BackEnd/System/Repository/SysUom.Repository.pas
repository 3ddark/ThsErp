unit SysUom.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Entity, Repository, FilterCriterion, AppContext, SysUom, SysLanguage, LocalizationManager;

type
  TSysUomRepository = class(TRepository<TSysUom>)
  protected
    function PrepareSelectSql: string; virtual;
    function PrepareAddSql: string; virtual;
    function PrepareUpdateSql: string; virtual;
    function PrepareDeleteSql: string; virtual;

    function PrepareSaveTranslationSql: string; virtual;
    function PrepareLoadTranslationSql: string; virtual;
    function PrepareDeleteTranslationSql: string; virtual;

    procedure SetModelParams(Q: TFDQuery; AModel: TSysUom; AIndex: Integer = -1);
    procedure SaveTranslations(AModel: TSysUom); virtual;
    procedure LoadTranslations(AModel: TSysUom); virtual;
    procedure DeleteTranslations(AID: Int64); virtual;
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function FindById(AId: TValue; ALock: Boolean = False): TSysUom; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysUom>; override;

    procedure Add(AModel: TSysUom); override;
    procedure AddBatch(AModels: TArray<TSysUom>); override;

    procedure Update(AModel: TSysUom); override;
    procedure UpdateBatch(AModels: TArray<TSysUom>); override;

    procedure Delete(AID: Int64); override;
    procedure DeleteBatch(AModels: TArray<TSysUom>); override;
  end;

implementation

constructor TSysUomRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysUomRepository.PrepareSelectSql: string;
begin
  Result := 'SELECT id, unit_code, unit_einv, decimali group_id, multiplier FROM public.' + Self.GetTableName(TSysUom);
end;

function TSysUomRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysUom) +
            ' (unit_code, unit_einv, decimal, group_id, multiplier) ' +
            ' VALUES (:unit_code, :unit_einv, :decimal, :group_id, :multiplier)';
end;

function TSysUomRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysUom) +
            ' SET unit_code = :unit_code, unit_einv = :unit_einv, ' +
            '     decimal = :decimal, group_id = :group_id, multiplier = :multiplier WHERE id = :id';
end;

function TSysUomRepository.PrepareDeleteSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysUom) + ' WHERE id = :id';
end;

function TSysUomRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysUomTranslation) +
            ' (sys_uom_id, sys_language_id, name) ' +
            ' VALUES (:uom_id, :lang_id, :name) ' +
            ' ON CONFLICT (sys_uom_id, sys_language_id) DO UPDATE ' +
            ' SET name = EXCLUDED.name';
end;

function TSysUomRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.sys_uom_id, t.sys_language_id, t.name, ' +
            '       l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TSysUomTranslation) + ' t ' +
            ' LEFT JOIN public.sys_language l ON l.id = t.sys_language_id ' +
            ' WHERE t.sys_uom_id = :uom_id';
end;

function TSysUomRepository.PrepareDeleteTranslationSql: string;
begin
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysUomTranslation) +
            ' WHERE sys_uom_id = :id';
end;

procedure TSysUomRepository.SetModelParams(Q: TFDQuery; AModel: TSysUom; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('unit_code').AsString := AModel.UnitCode;
    Q.ParamByName('unit_einv').AsString := AModel.UnitEInv;
    Q.ParamByName('decimal').AsBoolean := AModel.Decimal;
    Q.ParamByName('group_id').AsLargeInt := AModel.GroupId;
    Q.ParamByName('multiplier').AsInteger := AModel.Multiplier;
    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInt := AModel.Id;
  end
  else
  begin
    Q.ParamByName('unit_code').AsStrings[AIndex] := AModel.UnitCode;
    Q.ParamByName('unit_einv').AsStrings[AIndex] := AModel.UnitEInv;
    Q.ParamByName('decimal').AsBooleans[AIndex] := AModel.Decimal;
    Q.ParamByName('group_id').AsLargeInts[AIndex] := AModel.GroupId;
    Q.ParamByName('multiplier').AsIntegers[AIndex] := AModel.Multiplier;
    if (AModel.Id > 0) and (Q.FindParam('id') <> nil) then
      Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
  end;
end;

procedure TSysUomRepository.SaveTranslations(AModel: TSysUom);
var
  Q: TFDQuery;
  Trans: TSysUomTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) or (AModel.Translations.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSaveTranslationSql;
    for Trans in AModel.Translations do
    begin
      Trans.SysUomId := AModel.Id;
      Q.ParamByName('sys_uom_id').AsLargeInt := Trans.SysUomId;
      Q.ParamByName('sys_lang_id').AsLargeInt := Trans.SysLanguageId;
      Q.ParamByName('name').AsString := Trans.Name;
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysUomRepository.LoadTranslations(AModel: TSysUom);
var
  Q: TFDQuery;
  Trans: TSysUomTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) then Exit;
  AModel.Translations.Clear;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('uom_id').AsLargeInt := AModel.Id;
    Q.Open;
    while not Q.Eof do
    begin
      Trans := TSysUomTranslation.Create;
      Trans.SysUomId := Q.FieldByName('sys_uom_id').AsLargeInt;
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

procedure TSysUomRepository.DeleteTranslations(AID: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteTranslationSql;
    Q.ParamByName('id').AsLargeInt := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSysUomRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_sys_uom WHERE locale = :locale';
  Result.ParamByName('locale').AsString := TLocalizationManager.GetCurrentLanguage;
end;

procedure TSysUomRepository.Add(AModel: TSysUom);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetModelParams(Q, AModel);
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;

  SaveTranslations(AModel);
end;

procedure TSysUomRepository.AddBatch(AModels: TArray<TSysUom>);
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
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;

  for I := 0 to Count - 1 do
    SaveTranslations(AModels[I]);
end;

procedure TSysUomRepository.Update(AModel: TSysUom);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetModelParams(Q, AModel);
    Q.ExecSQL;
  finally
    Q.Free;
  end;

  SaveTranslations(AModel);
end;

procedure TSysUomRepository.UpdateBatch(AModels: TArray<TSysUom>);
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
      SetModelParams(Q, AModels[I], I);

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;

  for I := 0 to Count - 1 do
    SaveTranslations(AModels[I]);
end;

procedure TSysUomRepository.Delete(AID: Int64);
var
  Q: TFDQuery;
begin
  DeleteTranslations(AID);

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql;
    Q.ParamByName('id').AsLargeInt := AID;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysUomRepository.DeleteBatch(AModels: TArray<TSysUom>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteTranslationSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    Q.Execute(Count, 0);

    Q.SQL.Text := PrepareDeleteSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

function TSysUomRepository.FindById(AId: TValue; ALock: Boolean): TSysUom;
var
  Q: TFDQuery;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE id = :id';
    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.Open;

    if not Q.IsEmpty then
    begin
      Result := TSysUom.Create;
      Result.Id := Q.FieldByName('id').AsLargeInt;
      Result.UnitCode := Q.FieldByName('unit').AsString;
      Result.UnitEInv := Q.FieldByName('unit_einv').AsString;
      Result.Decimal := Q.FieldByName('decimal').AsBoolean;
      Result.GroupId := Q.FieldByName('group_id').AsLargeInt;
      Result.Multiplier := Q.FieldByName('multiplier').AsInteger;
      LoadTranslations(Result);
    end;
  finally
    Q.Free;
  end;
end;

function TSysUomRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysUom>;
var
  Q: TFDQuery;
  Item: TSysUom;
  Criterion: TFilterCriterion;
begin
  Result := TList<TSysUom>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSelectSql + ' WHERE 1=1';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.SQL.Text := Q.SQL.Text + ' AND ' + Criterion.FieldName + ' ' + Criterion.Operator + ' :' + Criterion.FieldName;
    end;

    if ALock then
      Q.SQL.Text := Q.SQL.Text + ' FOR UPDATE';

    if Assigned(AFilter) and (AFilter.Count > 0) then
    begin
      for Criterion in AFilter do
        Q.ParamByName(Criterion.FieldName).Value := Criterion.Value.AsVariant;
    end;

    Q.Open;
    while not Q.Eof do
    begin
      Item := TSysUom.Create;
      Item.Id := Q.FieldByName('id').AsLargeInt;
      Item.UnitCode := Q.FieldByName('unit').AsString;
      Item.UnitEInv := Q.FieldByName('unit_einv').AsString;
      Item.Decimal := Q.FieldByName('decimal').AsBoolean;
      Item.GroupId := Q.FieldByName('group_id').AsLargeInt;
      Item.Multiplier := Q.FieldByName('multiplier').AsInteger;
      LoadTranslations(Item);
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
