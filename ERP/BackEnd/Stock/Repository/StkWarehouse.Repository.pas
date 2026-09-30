unit StkWarehouse.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, StkWarehouse;

type
  TStkWarehouseRepository = class(TRepository<TStkWarehouse>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TStkWarehouse; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TStkWarehouse; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TStkWarehouse; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TStkWarehouse>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TStkWarehouse; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TStkWarehouse; override;

    procedure DoAdd(AModel: TStkWarehouse); override;
    procedure DoAddBatch(AModels: TArray<TStkWarehouse>); override;

    procedure DoUpdate(AModel: TStkWarehouse); override;
    procedure DoUpdateBatch(AModels: TArray<TStkWarehouse>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TStkWarehouse); override;
    procedure DoDeleteBatch(AModels: TArray<TStkWarehouse>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkWarehouseRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TStkWarehouseRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TStkWarehouse) +
            ' (warehouse_name, default_raw_material, default_production, default_sales) ' +
            ' VALUES (:warehouse_name, :default_raw_material, :default_production, :default_sales)';
end;

function TStkWarehouseRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TStkWarehouse) +
            ' SET warehouse_name = :warehouse_name, default_raw_material = :default_raw_material, default_production = :default_production, default_sales = :default_sales ' +
            ' WHERE id = :id';
end;

function TStkWarehouseRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TStkWarehouse) + ' WHERE';
end;

procedure TStkWarehouseRepository.SetInsertParams(Q: TFDQuery; AModel: TStkWarehouse; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('warehouse_name').AsString := AModel.WarehouseName;
    Q.ParamByName('default_raw_material').AsBoolean := AModel.DefaultRawMaterial;
    Q.ParamByName('default_production').AsBoolean := AModel.DefaultProduction;
    Q.ParamByName('default_sales').AsBoolean := AModel.DefaultSales;
  end
  else
  begin
    Q.ParamByName('warehouse_name').AsStrings[AIndex] := AModel.WarehouseName;
    Q.ParamByName('default_raw_material').AsBooleans[AIndex] := AModel.DefaultRawMaterial;
    Q.ParamByName('default_production').AsBooleans[AIndex] := AModel.DefaultProduction;
    Q.ParamByName('default_sales').AsBooleans[AIndex] := AModel.DefaultSales;
  end;
end;

procedure TStkWarehouseRepository.SetUpdateParams(Q: TFDQuery; AModel: TStkWarehouse; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('warehouse_name').AsString := AModel.WarehouseName;
    Q.ParamByName('default_raw_material').AsBoolean := AModel.DefaultRawMaterial;
    Q.ParamByName('default_production').AsBoolean := AModel.DefaultProduction;
    Q.ParamByName('default_sales').AsBoolean := AModel.DefaultSales;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('warehouse_name').AsStrings[AIndex] := AModel.WarehouseName;
    Q.ParamByName('default_raw_material').AsBooleans[AIndex] := AModel.DefaultRawMaterial;
    Q.ParamByName('default_production').AsBooleans[AIndex] := AModel.DefaultProduction;
    Q.ParamByName('default_sales').AsBooleans[AIndex] := AModel.DefaultSales;
  end;
end;

function TStkWarehouseRepository.MapFromQuery(Q: TFDQuery): TStkWarehouse;
begin
  Result := TStkWarehouse.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.WarehouseName := Q.FieldByName('warehouse_name').AsString;
  Result.DefaultRawMaterial := Q.FieldByName('default_raw_material').AsBoolean;
  Result.DefaultProduction := Q.FieldByName('default_production').AsBoolean;
  Result.DefaultSales := Q.FieldByName('default_sales').AsBoolean;
end;

function TStkWarehouseRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TStkWarehouse) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TStkWarehouseRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TStkWarehouse>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TStkWarehouse>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      Result.Add(MapFromQuery(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TStkWarehouseRepository.DoFindById(AId: TValue; ALock: Boolean): TStkWarehouse;
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
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TStkWarehouseRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TStkWarehouse;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, False);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TStkWarehouseRepository.DoAdd(AModel: TStkWarehouse);
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
end;

procedure TStkWarehouseRepository.DoAddBatch(AModels: TArray<TStkWarehouse>);
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

procedure TStkWarehouseRepository.DoUpdate(AModel: TStkWarehouse);
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
end;

procedure TStkWarehouseRepository.DoUpdateBatch(AModels: TArray<TStkWarehouse>);
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
end;

procedure TStkWarehouseRepository.DoDelete(AID: TValue);
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

procedure TStkWarehouseRepository.DoDelete(AModel: TStkWarehouse);
begin
  Delete(AModel.Id);
end;

procedure TStkWarehouseRepository.DoDeleteBatch(AModels: TArray<TStkWarehouse>);
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

procedure TStkWarehouseRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TStkWarehouseRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
