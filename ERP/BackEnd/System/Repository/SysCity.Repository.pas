unit SysCity.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, SharedFormTypes, AppContext, Entity,
  Repository, FilterCriterion, SysCity;

type
  TSysCityRepository = class(TRepository<TSysCity>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysCity; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysCity; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysCity; override;
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysCity>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysCity; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysCity; override;

    procedure Add(AModel: TSysCity); override;
    procedure AddBatch(AModels: TArray<TSysCity>); override;

    procedure Update(AModel: TSysCity); override;
    procedure UpdateBatch(AModels: TArray<TSysCity>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysCity); override;
    procedure DeleteBatch(AModels: TArray<TSysCity>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

constructor TSysCityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysCityRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysCity) +
            ' (city_name, plate_code, country_id, region_id) ' +
            ' VALUES (:city_name, :plate_code, :country_id, :region_id)';
end;

function TSysCityRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysCity) +
            ' SET city_name = :city_name, plate_code = :plate_code, ' +
            '     country_id = :country_id, region_id = :region_id ' +
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
    Q.ParamByName('city_name').AsString     := AModel.CityName;
    Q.ParamByName('plate_code').AsInteger   := AModel.PlateCode;
    Q.ParamByName('country_id').AsLargeInt  := AModel.CountryId;
    Q.ParamByName('region_id').AsLargeInt   := AModel.RegionId;
  end
  else
  begin
    Q.ParamByName('city_name').AsStrings[AIndex]    := AModel.CityName;
    Q.ParamByName('plate_code').AsIntegers[AIndex]  := AModel.PlateCode;
    Q.ParamByName('country_id').AsLargeInts[AIndex] := AModel.CountryId;
    Q.ParamByName('region_id').AsLargeInts[AIndex]  := AModel.RegionId;
  end;
end;

procedure TSysCityRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysCity; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt          := AModel.Id;
    Q.ParamByName('city_name').AsString     := AModel.CityName;
    Q.ParamByName('plate_code').AsInteger   := AModel.PlateCode;
    Q.ParamByName('country_id').AsLargeInt  := AModel.CountryId;
    Q.ParamByName('region_id').AsLargeInt   := AModel.RegionId;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]         := AModel.Id;
    Q.ParamByName('city_name').AsStrings[AIndex]    := AModel.CityName;
    Q.ParamByName('plate_code').AsIntegers[AIndex]  := AModel.PlateCode;
    Q.ParamByName('country_id').AsLargeInts[AIndex] := AModel.CountryId;
    Q.ParamByName('region_id').AsLargeInts[AIndex]  := AModel.RegionId;
  end;
end;

function TSysCityRepository.MapFromQuery(Q: TFDQuery): TSysCity;
begin
  Result := TSysCity.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.CityName     := Q.FieldByName('city_name').AsString;
  Result.PlateCode    := Q.FieldByName('plate_code').AsInteger;
  Result.CountryId    := Q.FieldByName('country_id').AsLargeInt;
  Result.RegionId     := Q.FieldByName('region_id').AsLargeInt;
end;

function TSysCityRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
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

function TSysCityRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysCity>;
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

function TSysCityRepository.FindById(AId: TValue; ALock: Boolean): TSysCity;
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

function TSysCityRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysCity;
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

procedure TSysCityRepository.Add(AModel: TSysCity);
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

procedure TSysCityRepository.AddBatch(AModels: TArray<TSysCity>);
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

procedure TSysCityRepository.Update(AModel: TSysCity);
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

procedure TSysCityRepository.UpdateBatch(AModels: TArray<TSysCity>);
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

procedure TSysCityRepository.Delete(AID: Int64);
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

procedure TSysCityRepository.Delete(AModel: TSysCity);
begin
  Delete(AModel.Id);
end;

procedure TSysCityRepository.DeleteBatch(AModels: TArray<TSysCity>);
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

procedure TSysCityRepository.DeleteBatch(AIDs: TArray<Int64>);
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

procedure TSysCityRepository.DeleteBatch(AFilter: TFilterCriteria);
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
