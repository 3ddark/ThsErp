unit SysAddress.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, SharedFormTypes, AppContext, Entity,
  Repository, SysAddress, FilterCriterion;

type
  TSysAddressRepository = class(TRepository<TSysAddress>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysAddress; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysAddress; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysAddress; override;
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysAddress>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysAddress; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysAddress; override;

    procedure Add(AModel: TSysAddress); override;
    procedure AddBatch(AModels: TArray<TSysAddress>); override;

    procedure Update(AModel: TSysAddress); override;
    procedure UpdateBatch(AModels: TArray<TSysAddress>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysAddress); override;
    procedure DeleteBatch(AModels: TArray<TSysAddress>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

constructor TSysAddressRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysAddressRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysAddress) +
            ' (sys_city_id, district, neighborhood, quarter, road, street, building_name, door_number, zip_code, web, email) ' +
            ' VALUES (:sys_city_id, :district, :neighborhood, :quarter, :road, :street, :building_name, :door_number, :zip_code, :web, :email)';
end;

function TSysAddressRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysAddress) +
            ' SET sys_city_id = :sys_city_id, district = :district, neighborhood = :neighborhood, ' +
            '     quarter = :quarter, road = :road, street = :street, building_name = :building_name, ' +
            '     door_number = :door_number, zip_code = :zip_code, web = :web, email = :email  ' +
            ' WHERE id = :id';
end;

function TSysAddressRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysAddress) + ' WHERE';
end;

procedure TSysAddressRepository.SetInsertParams(Q: TFDQuery; AModel: TSysAddress; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('sys_city_id').AsLargeInt           := AModel.SysCityId;
    Q.ParamByName('district').AsString                := AModel.District;
    Q.ParamByName('neighborhood').AsString            := AModel.Neighborhood;
    Q.ParamByName('quarter').AsString                 := AModel.Quarter;
    Q.ParamByName('road').AsString                    := AModel.Road;
    Q.ParamByName('street').AsString                  := AModel.Street;
    Q.ParamByName('building_name').AsString           := AModel.BuildingName;
    Q.ParamByName('door_number').AsString             := AModel.DoorNumber;
    Q.ParamByName('zip_code').AsString                := AModel.ZipCode;
    Q.ParamByName('web').AsString                     := AModel.Web;
    Q.ParamByName('email').AsString                   := AModel.Email;
  end
  else
  begin
    Q.ParamByName('sys_city_id').AsLargeInts[AIndex]  := AModel.SysCityId;
    Q.ParamByName('district').AsStrings[AIndex]       := AModel.District;
    Q.ParamByName('neighborhood').AsStrings[AIndex]   := AModel.Neighborhood;
    Q.ParamByName('quarter').AsStrings[AIndex]        := AModel.Quarter;
    Q.ParamByName('road').AsStrings[AIndex]           := AModel.Road;
    Q.ParamByName('street').AsStrings[AIndex]         := AModel.Street;
    Q.ParamByName('building_name').AsStrings[AIndex]  := AModel.BuildingName;
    Q.ParamByName('door_number').AsStrings[AIndex]    := AModel.DoorNumber;
    Q.ParamByName('zip_code').AsStrings[AIndex]       := AModel.ZipCode;
    Q.ParamByName('web').AsStrings[AIndex]            := AModel.Web;
    Q.ParamByName('email').AsStrings[AIndex]          := AModel.Email;
  end;
end;

procedure TSysAddressRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysAddress; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt                    := AModel.Id;
    Q.ParamByName('sys_city_id').AsLargeInt           := AModel.SysCityId;
    Q.ParamByName('district').AsString                := AModel.District;
    Q.ParamByName('neighborhood').AsString            := AModel.Neighborhood;
    Q.ParamByName('quarter').AsString                 := AModel.Quarter;
    Q.ParamByName('road').AsString                    := AModel.Road;
    Q.ParamByName('street').AsString                  := AModel.Street;
    Q.ParamByName('building_name').AsString           := AModel.BuildingName;
    Q.ParamByName('door_number').AsString             := AModel.DoorNumber;
    Q.ParamByName('zip_code').AsString                := AModel.ZipCode;
    Q.ParamByName('web').AsString                     := AModel.Web;
    Q.ParamByName('email').AsString                   := AModel.Email;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]           := AModel.Id;
    Q.ParamByName('sys_city_id').AsLargeInts[AIndex]  := AModel.SysCityId;
    Q.ParamByName('district').AsStrings[AIndex]       := AModel.District;
    Q.ParamByName('neighborhood').AsStrings[AIndex]   := AModel.Neighborhood;
    Q.ParamByName('quarter').AsStrings[AIndex]        := AModel.Quarter;
    Q.ParamByName('road').AsStrings[AIndex]           := AModel.Road;
    Q.ParamByName('street').AsStrings[AIndex]         := AModel.Street;
    Q.ParamByName('building_name').AsStrings[AIndex]  := AModel.BuildingName;
    Q.ParamByName('door_number').AsStrings[AIndex]    := AModel.DoorNumber;
    Q.ParamByName('zip_code').AsStrings[AIndex]       := AModel.ZipCode;
    Q.ParamByName('web').AsStrings[AIndex]            := AModel.Web;
    Q.ParamByName('email').AsStrings[AIndex]          := AModel.Email;
  end;
end;

function TSysAddressRepository.MapFromQuery(Q: TFDQuery): TSysAddress;
begin
  Result := TSysAddress.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.SysCityId    := Q.ParamByName('sys_city_id').AsLargeInt;
  Result.District     := Q.ParamByName('district').AsString;
  Result.Neighborhood := Q.ParamByName('neighborhood').AsString;
  Result.Quarter      := Q.ParamByName('quarter').AsString;
  Result.Road         := Q.ParamByName('road').AsString;
  Result.Street       := Q.ParamByName('street').AsString;
  Result.BuildingName := Q.ParamByName('building_name').AsString;
  Result.DoorNumber   := Q.ParamByName('door_number').AsString;
  Result.ZipCode      := Q.ParamByName('zip_code').AsString;
  Result.Web          := Q.ParamByName('web').AsString;
  Result.Email        := Q.ParamByName('email').AsString;
end;

function TSysAddressRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysAddress) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysAddressRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysAddress>;
var
  Q: TFDQuery;
  Item: TSysAddress;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysAddress>.Create(True);
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

function TSysAddressRepository.FindById(AId: TValue; ALock: Boolean): TSysAddress;
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
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysAddressRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysAddress;
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
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysAddressRepository.Add(AModel: TSysAddress);
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

procedure TSysAddressRepository.AddBatch(AModels: TArray<TSysAddress>);
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

procedure TSysAddressRepository.Update(AModel: TSysAddress);
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

procedure TSysAddressRepository.UpdateBatch(AModels: TArray<TSysAddress>);
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

procedure TSysAddressRepository.Delete(AID: Int64);
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

procedure TSysAddressRepository.Delete(AModel: TSysAddress);
begin
  Delete(AModel.Id);
end;

procedure TSysAddressRepository.DeleteBatch(AModels: TArray<TSysAddress>);
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

procedure TSysAddressRepository.DeleteBatch(AIDs: TArray<Int64>);
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

procedure TSysAddressRepository.DeleteBatch(AFilter: TFilterCriteria);
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
