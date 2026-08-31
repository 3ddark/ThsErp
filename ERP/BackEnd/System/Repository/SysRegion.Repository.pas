unit SysRegion.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections, System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param, SharedFormTypes, AppContext, Entity,
  Repository, FilterCriterion, SysRegion;

type
  TSysRegionRepository = class(TRepository<TSysRegion>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSysRegion; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSysRegion; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSysRegion; override;
  public
    constructor Create(AConnection: TFDConnection);

    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean = False): TList<TSysRegion>; override;
    function FindById(AId: TValue; ALock: Boolean = False): TSysRegion; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSysRegion; override;

    procedure Add(AModel: TSysRegion); override;
    procedure AddBatch(AModels: TArray<TSysRegion>); override;

    procedure Update(AModel: TSysRegion); override;
    procedure UpdateBatch(AModels: TArray<TSysRegion>); override;

    procedure Delete(AID: Int64); override;
    procedure Delete(AModel: TSysRegion); override;
    procedure DeleteBatch(AModels: TArray<TSysRegion>); override;
    procedure DeleteBatch(AIDs: TArray<Int64>); override;
    procedure DeleteBatch(AFilter: TFilterCriteria); override;
  end;

implementation

constructor TSysRegionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysRegionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSysRegion) + ' (region_name) VALUES (:region_name)';
end;

function TSysRegionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSysRegion) + ' SET region_name = :region_name WHERE id = :id';
end;

function TSysRegionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSysRegion) + ' WHERE';
end;

procedure TSysRegionRepository.SetInsertParams(Q: TFDQuery; AModel: TSysRegion; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('region_name').AsString := AModel.RegionName;
  end
  else
  begin
    Q.ParamByName('region_name').AsStrings[AIndex] := AModel.RegionName;
  end;
end;

procedure TSysRegionRepository.SetUpdateParams(Q: TFDQuery; AModel: TSysRegion; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsSmallInt          := AModel.Id;
    Q.ParamByName('region_name').AsString   := AModel.RegionName;;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex]           := AModel.Id;
    Q.ParamByName('region_name').AsStrings[AIndex]    := AModel.RegionName;
  end;
end;

function TSysRegionRepository.MapFromQuery(Q: TFDQuery): TSysRegion;
begin
  Result              := TSysRegion.Create;
  Result.Id           := Q.FieldByName('id').AsLargeInt;
  Result.RegionName   := Q.FieldByName('region_name').AsString;
end;

function TSysRegionRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM ' + Self.GetFullViewName(TSysRegion) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSysRegionRepository.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysRegion>;
var
  Q: TFDQuery;
  Item: TSysRegion;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSysRegion>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

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

function TSysRegionRepository.FindById(AId: TValue; ALock: Boolean): TSysRegion;
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
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, False);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TSysRegionRepository.FindOne(AFilter: TFilterCriteria; ALock: Boolean): TSysRegion;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := nil;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TSysRegionRepository.Add(AModel: TSysRegion);
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

procedure TSysRegionRepository.AddBatch(AModels: TArray<TSysRegion>);
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

procedure TSysRegionRepository.Update(AModel: TSysRegion);
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

procedure TSysRegionRepository.UpdateBatch(AModels: TArray<TSysRegion>);
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

procedure TSysRegionRepository.Delete(AID: Int64);
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

procedure TSysRegionRepository.Delete(AModel: TSysRegion);
begin
  Delete(AModel.Id);
end;

procedure TSysRegionRepository.DeleteBatch(AModels: TArray<TSysRegion>);
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

procedure TSysRegionRepository.DeleteBatch(AIDs: TArray<Int64>);
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

procedure TSysRegionRepository.DeleteBatch(AFilter: TFilterCriteria);
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
