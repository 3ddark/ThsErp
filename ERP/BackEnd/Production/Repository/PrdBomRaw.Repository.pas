unit PrdBomRaw.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PrdBomRaw;

type
  TPrdBomRawRepository = class(TRepository<TPrdBomRaw>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPrdBomRaw; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPrdBomRaw; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPrdBomRaw; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPrdBomRaw>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPrdBomRaw; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPrdBomRaw; override;

    procedure DoAdd(AModel: TPrdBomRaw); override;
    procedure DoAddBatch(AModels: TArray<TPrdBomRaw>); override;

    procedure DoUpdate(AModel: TPrdBomRaw); override;
    procedure DoUpdateBatch(AModels: TArray<TPrdBomRaw>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPrdBomRaw); override;
    procedure DoDeleteBatch(AModels: TArray<TPrdBomRaw>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TPrdBomRawRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPrdBomRawRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPrdBomRaw) +
            ' (prd_bom_id, stk_inventory_id, sub_prd_bom_id, quantity, scrap_rate) ' +
            ' VALUES (:prd_bom_id, :stk_inventory_id, :sub_prd_bom_id, :quantity, :scrap_rate)';
end;

function TPrdBomRawRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPrdBomRaw) +
            ' SET prd_bom_id = :prd_bom_id, stk_inventory_id = :stk_inventory_id, sub_prd_bom_id = :sub_prd_bom_id, quantity = :quantity, scrap_rate = :scrap_rate ' +
            ' WHERE id = :id';
end;

function TPrdBomRawRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPrdBomRaw) + ' WHERE';
end;

procedure TPrdBomRawRepository.SetInsertParams(Q: TFDQuery; AModel: TPrdBomRaw; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('quantity').AsCurrency := AModel.Quantity;
    Q.ParamByName('scrap_rate').AsCurrency := AModel.ScrapRate;
  end
  else
  begin
    Q.ParamByName('quantity').AsCurrencys[AIndex] := AModel.Quantity;
    Q.ParamByName('scrap_rate').AsCurrencys[AIndex] := AModel.ScrapRate;
  end;

  SetNullableParam(Q.ParamByName('prd_bom_id'), ftLargeint, AModel.PrdBomId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('sub_prd_bom_id'), ftLargeint, AModel.SubPrdBomId, AIndex);
end;

procedure TPrdBomRawRepository.SetUpdateParams(Q: TFDQuery; AModel: TPrdBomRaw; AIndex: Integer);
begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('quantity').AsCurrency := AModel.Quantity;
    Q.ParamByName('scrap_rate').AsCurrency := AModel.ScrapRate;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('quantity').AsCurrencys[AIndex] := AModel.Quantity;
    Q.ParamByName('scrap_rate').AsCurrencys[AIndex] := AModel.ScrapRate;
  end;

  SetNullableParam(Q.ParamByName('prd_bom_id'), ftLargeint, AModel.PrdBomId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('sub_prd_bom_id'), ftLargeint, AModel.SubPrdBomId, AIndex);
end;

function TPrdBomRawRepository.MapFromQuery(Q: TFDQuery): TPrdBomRaw;
begin
  Result := TPrdBomRaw.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PrdBomId := Q.FieldByName('prd_bom_id').AsLargeInt;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.SubPrdBomId := Q.FieldByName('sub_prd_bom_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.ScrapRate := Q.FieldByName('scrap_rate').AsCurrency;
  Result.BomName := Q.FieldByName('bom_name').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.SubBomName := Q.FieldByName('sub_bom_name').AsString;
  Result.GrossQuantity := Q.FieldByName('gross_quantity').AsString;
end;

function TPrdBomRawRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPrdBomRaw) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPrdBomRawRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPrdBomRaw>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPrdBomRaw>.Create(True);
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

function TPrdBomRawRepository.DoFindById(AId: TValue; ALock: Boolean): TPrdBomRaw;
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

function TPrdBomRawRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPrdBomRaw;
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

procedure TPrdBomRawRepository.DoAdd(AModel: TPrdBomRaw);
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

procedure TPrdBomRawRepository.DoAddBatch(AModels: TArray<TPrdBomRaw>);
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

procedure TPrdBomRawRepository.DoUpdate(AModel: TPrdBomRaw);
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

procedure TPrdBomRawRepository.DoUpdateBatch(AModels: TArray<TPrdBomRaw>);
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

procedure TPrdBomRawRepository.DoDelete(AID: TValue);
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

procedure TPrdBomRawRepository.DoDelete(AModel: TPrdBomRaw);
begin
  Delete(AModel.Id);
end;

procedure TPrdBomRawRepository.DoDeleteBatch(AModels: TArray<TPrdBomRaw>);
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

procedure TPrdBomRawRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPrdBomRawRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
