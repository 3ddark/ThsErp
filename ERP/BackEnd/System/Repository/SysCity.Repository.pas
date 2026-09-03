unit SysCity.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, Service,
  FilterCriterion, UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysCity, SysCountry;

type
  TSysCityRepository = class(TRepository<TSysCity>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysCity; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysCity; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysCity; override;


    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysCity>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSysCity; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysCity; override;

    procedure DoAdd(AModel: TSysCity); override;
    procedure DoAddBatch(AModels: TArray<TSysCity>); override;

    procedure DoUpdate(AModel: TSysCity); override;
    procedure DoUpdateBatch(AModels: TArray<TSysCity>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSysCity); override;
    procedure DoDeleteBatch(AModels: TArray<TSysCity>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysCityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysCityRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysCity) +
            ' (city_name, car_plate_code, sys_country_id, sys_region_id) ' +
            ' VALUES (:city_name, :car_plate_code, :sys_country_id, :sys_region_id)';
end;

function TSysCityRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysCity) +
            ' SET city_name = :city_name, car_plate_code = :car_plate_code, ' +
            '     sys_country_id = :sys_country_id, sys_region_id = :sys_region_id ' +
            ' WHERE id = :id';
end;

function TSysCityRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysCity) + ' WHERE';
end;

procedure TSysCityRepository.SetInsertParams(Q: TFDQuery; AModel: TSysCity; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('city_name').AsString := AModel.CityName;
    Q.ParamByName('car_plate_code').AsInteger := AModel.CarPlateCode;
    Q.ParamByName('sys_country_id').AsLargeInt := AModel.SysCountryId;
    Q.ParamByName('sys_region_id').AsLargeInt := AModel.SysRegionId;
  end
  else
  begin
    Q.ParamByName('city_name').AsStrings[AIndex] := AModel.CityName;
    Q.ParamByName('car_plate_code').AsIntegers[AIndex] := AModel.CarPlateCode;
    Q.ParamByName('sys_country_id').AsLargeInts[AIndex] := AModel.SysCountryId;
    Q.ParamByName('sys_region_id').AsLargeInts[AIndex] := AModel.SysRegionId;
  end;
end;

procedure TSysCityRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysCity; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('city_name').AsString := AModel.CityName;
    Q.ParamByName('car_plate_code').AsInteger := AModel.CarPlateCode;
    Q.ParamByName('sys_country_id').AsLargeInt := AModel.SysCountryId;
    Q.ParamByName('sys_region_id').AsLargeInt := AModel.SysRegionId;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('city_name').AsStrings[AIndex] := AModel.CityName;
    Q.ParamByName('car_plate_code').AsIntegers[AIndex] := AModel.CarPlateCode;
    Q.ParamByName('sys_country_id').AsLargeInts[AIndex] := AModel.SysCountryId;
    Q.ParamByName('sys_region_id').AsLargeInts[AIndex] := AModel.SysRegionId;
  end;
end;

function TSysCityRepository.MapFromQuery(Q: TFDQuery): TSysCity;
begin
  Result := TSysCity.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.CityName := Q.FieldByName('city_name').AsString;
  Result.CarPlateCode := Q.FieldByName('car_plate_code').AsInteger;
  Result.SysCountryId := Q.FieldByName('sys_country_id').AsLargeInt;
  Result.SysRegionId := Q.FieldByName('sys_region_id').AsLargeInt;
  Result.SysCountry.Id := Q.FieldByName('sys_country_id').AsLargeInt;
  Result.SysCountry.CountryCode := Q.FieldByName('country_code').AsString;
  Result.SysCountry.CountryName := Q.FieldByName('country_name').AsString;
  Result.SysRegion.RegionName := Q.FieldByName('region_name').AsString;
end;

function TSysCityRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysCity) + ' WHERE locale = :locale ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
  Result.ParamByName('locale').Value := TAppContext.Instance.CurrentUser.ActiveLanguage;
end;

function TSysCityRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysCity>;
var
  Q: TFDQuery;
  Item: TSysCity;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysCity>.Create(True);
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
      Result.Add(Item);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSysCityRepository.DoFindById(AId: TValue; ALock: Boolean): TSysCity;
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
    end;
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysCityRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysCity;
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
    end;
  finally
    Q.Free;
  end;
end;

procedure TSysCityRepository.DoAdd(AModel: TSysCity);
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
end;

procedure TSysCityRepository.DoAddBatch(AModels: TArray<TSysCity>);
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
end;

procedure TSysCityRepository.DoUpdate(AModel: TSysCity);
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
end;

procedure TSysCityRepository.DoUpdateBatch(AModels: TArray<TSysCity>);
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
end;

procedure TSysCityRepository.DoDelete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSysCityRepository.DoDelete(AModel: TSysCity);
begin
  Delete(AModel.Id);
end;

procedure TSysCityRepository.DoDeleteBatch(AModels: TArray<TSysCity>);
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

procedure TSysCityRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSysCityRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
