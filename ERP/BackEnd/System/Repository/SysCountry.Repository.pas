unit SysCountry.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysCountry, SysLanguage;

type
  TSysCountryRepository = class(TRepository<TSysCountry>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    function PrepareLoadTranslationSql: string;
    function PrepareSaveTranslationSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysCountry; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysCountry; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysCountry; override;

    procedure SaveTranslations(AModel: TSysCountry);
    procedure LoadTranslations(AModel: TSysCountry);
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysCountry>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysCountry; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysCountry; override;

    procedure Add(AModel: TSysCountry); override;
    procedure AddBatch(AModels: TArray<TSysCountry>); override;

    procedure Update(AModel: TSysCountry); override;
    procedure UpdateBatch(AModels: TArray<TSysCountry>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysCountry); override;
    procedure DeleteBatch(AModels: TArray<TSysCountry>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

constructor TSysCountryRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysCountryRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysCountry) +
              ' (country_code, iso_year, iso_cctld, is_eu_member) ' +
            'VALUES (:country_code, :iso_year, :iso_cctld, :is_eu_member)';
end;

function TSysCountryRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysCountry) +
            ' SET country_code = :country_code, iso_year = :iso_year, ' +
            '     iso_cctld = :iso_cctld, is_eu_member = :is_eu_member WHERE id = :id';
end;

function TSysCountryRepository.PrepareDeleteSql: string;
begin
  //WHERE kýsmý özellikle böyle yazýldý. Filtre vermeden iþlem yapýlmamasý için. Hatalý kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysCountry) + ' WHERE';
end;

function TSysCountryRepository.PrepareLoadTranslationSql: string;
begin
  Result := 'SELECT t.sys_country_id, t.sys_language_id, t.country_name, ' +
            '       l.locale, l.native_name ' +
            ' FROM public.' + Self.GetTableName(TSysCountryTranslation) + ' t ' +
            ' LEFT JOIN public.sys_language l ON l.id = t.sys_language_id ' +
            ' WHERE t.sys_country_id = :sys_country_id';
end;

function TSysCountryRepository.PrepareSaveTranslationSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysCountryTranslation) +
            ' (sys_country_id, sys_language_id, country_name) ' +
            ' VALUES (:sys_country_id, :sys_language_id, :country_name) ' +
            ' ON CONFLICT (sys_country_id, sys_language_id) DO UPDATE ' +
            ' SET country_name = EXCLUDED.country_name';
end;

procedure TSysCountryRepository.LoadTranslations(AModel: TSysCountry);
var
  Q: TFDQuery;
  Trans: TSysCountryTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) then Exit;
  AModel.Translations.Clear;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareLoadTranslationSql;
    Q.ParamByName('sys_country_id').AsLargeInt := AModel.Id;
    Q.Open;
    while not Q.Eof do
    begin
      Trans := TSysCountryTranslation.Create;
      Trans.SysCountryId := Q.FieldByName('sys_country_id').AsLargeInt;
      Trans.SysLanguageId := Q.FieldByName('sys_language_id').AsLargeInt;
      Trans.CountryName := Q.FieldByName('country_name').AsString;

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

procedure TSysCountryRepository.SaveTranslations(AModel: TSysCountry);
var
  Q: TFDQuery;
  Trans: TSysCountryTranslation;
begin
  if (AModel = nil) or (AModel.Translations = nil) or (AModel.Translations.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareSaveTranslationSql;
    for Trans in AModel.Translations do
    begin
      Trans.SysCountryId := AModel.Id;
      Q.ParamByName('sys_country_id').AsLargeInt := Trans.SysCountryId;
      Q.ParamByName('sys_language_id').AsLargeInt := Trans.SysLanguageId;
      Q.ParamByName('country_name').AsString := Trans.CountryName;
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysCountryRepository.SetInsertParams(Q: TFDQuery; AModel: TSysCountry; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('country_code').AsString := AModel.CountryCode;
    Q.ParamByName('iso_year').AsInteger := AModel.ISOYear;
    Q.ParamByName('iso_cctld').AsString := AModel.ISOCCTLD;
    Q.ParamByName('is_eu_member').AsBoolean := AModel.IsEuMember;
  end
  else
  begin
    Q.ParamByName('country_code').AsStrings[AIndex] := AModel.CountryCode;
    Q.ParamByName('iso_year').AsIntegers[AIndex] := AModel.ISOYear;
    Q.ParamByName('iso_cctld').AsStrings[AIndex] := AModel.ISOCCTLD;
    Q.ParamByName('is_eu_member').AsBooleans[AIndex] := AModel.IsEuMember;
  end;
end;

procedure TSysCountryRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysCountry; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('country_code').AsString := AModel.CountryCode;
    Q.ParamByName('iso_year').AsInteger := AModel.ISOYear;
    Q.ParamByName('iso_cctld').AsString := AModel.ISOCCTLD;
    Q.ParamByName('is_eu_member').AsBoolean := AModel.IsEuMember;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('country_code').AsStrings[AIndex] := AModel.CountryCode;
    Q.ParamByName('iso_year').AsIntegers[AIndex] := AModel.ISOYear;
    Q.ParamByName('iso_cctld').AsStrings[AIndex] := AModel.ISOCCTLD;
    Q.ParamByName('is_eu_member').AsBooleans[AIndex] := AModel.IsEuMember;
  end;
end;

function TSysCountryRepository.MapFromQuery(Q: TFDQuery): TSysCountry;
begin
  Result := TSysCountry.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.CountryCode := Q.FieldByName('country_code').AsString;
  Result.ISOYear := Q.FieldByName('iso_year').AsInteger;
  Result.ISOCCTLD := Q.FieldByName('iso_cctld').AsString;
  Result.IsEuMember := Q.FieldByName('is_eu_member').AsBoolean;
end;

function TSysCountryRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysCountry) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysCountryRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysCountry>;
var
  Q: TFDQuery;
  Item: TSysCountry;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysCountry>.Create(True);
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

function TSysCountryRepository.FindById(AId: TValue; ALock: Boolean): TSysCountry;
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

function TSysCountryRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysCountry;
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

procedure TSysCountryRepository.Add(AModel: TSysCountry);
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

procedure TSysCountryRepository.AddBatch(AModels: TArray<TSysCountry>);
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

procedure TSysCountryRepository.Update(AModel: TSysCountry);
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

procedure TSysCountryRepository.UpdateBatch(AModels: TArray<TSysCountry>);
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

procedure TSysCountryRepository.Delete(AID: Int64);
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

procedure TSysCountryRepository.Delete(AModel: TSysCountry);
begin
  Delete(AModel.Id);
end;

procedure TSysCountryRepository.DeleteBatch(AModels: TArray<TSysCountry>);
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

procedure TSysCountryRepository.DeleteBatch(AIDs: TArray<Int64>);
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

procedure TSysCountryRepository.DeleteBatch(AFilter: TFilterCriteria);
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
