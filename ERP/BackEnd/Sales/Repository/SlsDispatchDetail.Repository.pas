unit SlsDispatchDetail.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SlsDispatchDetail;

type
  TSlsDispatchDetailRepository = class(TRepository<TSlsDispatchDetail>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSlsDispatchDetail; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSlsDispatchDetail; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSlsDispatchDetail; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSlsDispatchDetail>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSlsDispatchDetail; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSlsDispatchDetail; override;

    procedure DoAdd(AModel: TSlsDispatchDetail); override;
    procedure DoAddBatch(AModels: TArray<TSlsDispatchDetail>); override;

    procedure DoUpdate(AModel: TSlsDispatchDetail); override;
    procedure DoUpdateBatch(AModels: TArray<TSlsDispatchDetail>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSlsDispatchDetail); override;
    procedure DoDeleteBatch(AModels: TArray<TSlsDispatchDetail>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function InvoicedQuantity(ADispatchDetailId: Int64; AExcludeInvoiceDetailId: Int64): Currency;
    function DeliveredQuantityOfOrderDetail(AOrderDetailId: Int64; AExcludeDispatchDetailId: Int64; AExcludeInvoiceDetailId: Int64): Currency;
    procedure UpsertStockTransaction(ADispatchDetailId: Int64);
  end;

implementation

constructor TSlsDispatchDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSlsDispatchDetailRepository.InvoicedQuantity(ADispatchDetailId: Int64; AExcludeInvoiceDetailId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(sum(quantity), 0) AS v FROM public.sls_invoice_detail ' +
                  ' WHERE sls_dispatch_detail_id = :id AND id <> :exclude_id';
    Q.ParamByName('id').AsLargeInt := ADispatchDetailId;
    Q.ParamByName('exclude_id').AsLargeInt := AExcludeInvoiceDetailId;
    LogQuery(Q, 'InvoicedQuantity');
    Q.Open;
    Result := Q.FieldByName('v').AsCurrency;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchDetailRepository.DeliveredQuantityOfOrderDetail(AOrderDetailId: Int64; AExcludeDispatchDetailId: Int64; AExcludeInvoiceDetailId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE((SELECT sum(quantity) FROM public.sls_dispatch_detail ' +
                  '                   WHERE sls_order_detail_id = :id AND id <> :exclude_dispatch_id), 0) + ' +
                  '       COALESCE((SELECT sum(quantity) FROM public.sls_invoice_detail ' +
                  '                   WHERE sls_order_detail_id = :id AND id <> :exclude_invoice_id), 0) AS v';
    Q.ParamByName('id').AsLargeInt := AOrderDetailId;
    Q.ParamByName('exclude_dispatch_id').AsLargeInt := AExcludeDispatchDetailId;
    Q.ParamByName('exclude_invoice_id').AsLargeInt := AExcludeInvoiceDetailId;
    LogQuery(Q, 'DeliveredQuantityOfOrderDetail');
    Q.Open;
    Result := Q.FieldByName('v').AsCurrency;
  finally
    Q.Free;
  end;
end;

procedure TSlsDispatchDetailRepository.UpsertStockTransaction(ADispatchDetailId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'INSERT INTO public.stk_transaction (transaction_type, stk_inventory_id, from_stk_warehouse_id, quantity, amount, currency, ' +
                  '       transaction_date, description, sls_dispatch_detail_id) ' +
                  'SELECT 2, d.stk_inventory_id, p.stk_warehouse_id, d.quantity, round(d.quantity * d.unit_price, 2), p.currency, ' +
                  '       p.dispatch_date, p.dispatch_no, d.id ' +
                  '  FROM public.sls_dispatch_detail d JOIN public.sls_dispatch p ON p.id = d.sls_dispatch_id ' +
                  ' WHERE d.id = :id ' +
                  'ON CONFLICT ON CONSTRAINT stk_transaction_sls_dispatch_detail_key DO UPDATE SET ' +
                  '       stk_inventory_id = EXCLUDED.stk_inventory_id, from_stk_warehouse_id = EXCLUDED.from_stk_warehouse_id, ' +
                  '       quantity = EXCLUDED.quantity, amount = EXCLUDED.amount, currency = EXCLUDED.currency, ' +
                  '       transaction_date = EXCLUDED.transaction_date, description = EXCLUDED.description';
    Q.ParamByName('id').AsLargeInt := ADispatchDetailId;
    LogQuery(Q, 'UpsertStockTransaction');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSlsDispatchDetailRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSlsDispatchDetail) +
            ' (sls_dispatch_id, stk_inventory_id, quantity, unit_price, sls_order_detail_id, description) ' +
            ' VALUES (:sls_dispatch_id, :stk_inventory_id, :quantity, :unit_price, :sls_order_detail_id, :description)';
end;

function TSlsDispatchDetailRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSlsDispatchDetail) +
            ' SET sls_dispatch_id = :sls_dispatch_id, stk_inventory_id = :stk_inventory_id, quantity = :quantity, unit_price = :unit_price, sls_order_detail_id = :sls_order_detail_id, description = :description ' +
            ' WHERE id = :id';
end;

function TSlsDispatchDetailRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSlsDispatchDetail) + ' WHERE';
end;

procedure TSlsDispatchDetailRepository.SetInsertParams(Q: TFDQuery; AModel: TSlsDispatchDetail; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCD := AModel.UnitPrice;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCDs[AIndex] := AModel.UnitPrice;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('sls_dispatch_id'), ftLargeint, AModel.SlsDispatchId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('sls_order_detail_id'), ftLargeint, AModel.SlsOrderDetailId, AIndex);
end;

procedure TSlsDispatchDetailRepository.SetUpdateParams(Q: TFDQuery; AModel: TSlsDispatchDetail; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCD := AModel.UnitPrice;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCDs[AIndex] := AModel.UnitPrice;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('sls_dispatch_id'), ftLargeint, AModel.SlsDispatchId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('sls_order_detail_id'), ftLargeint, AModel.SlsOrderDetailId, AIndex);
end;

function TSlsDispatchDetailRepository.MapFromQuery(Q: TFDQuery): TSlsDispatchDetail;
begin
  Result := TSlsDispatchDetail.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.SlsDispatchId := Q.FieldByName('sls_dispatch_id').AsLargeInt;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.UnitPrice := Q.FieldByName('unit_price').AsCurrency;
  Result.SlsOrderDetailId := Q.FieldByName('sls_order_detail_id').AsLargeInt;
  Result.Description := Q.FieldByName('description').AsString;
  Result.DispatchNo := Q.FieldByName('dispatch_no').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.UomCode := Q.FieldByName('uom_code').AsString;
  Result.OrderNo := Q.FieldByName('order_no').AsString;
end;

function TSlsDispatchDetailRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSlsDispatchDetail) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSlsDispatchDetailRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSlsDispatchDetail>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSlsDispatchDetail>.Create(True);
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

function TSlsDispatchDetailRepository.DoFindById(AId: TValue; ALock: Boolean): TSlsDispatchDetail;
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

function TSlsDispatchDetailRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSlsDispatchDetail;
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

procedure TSlsDispatchDetailRepository.DoAdd(AModel: TSlsDispatchDetail);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TSlsDispatchDetailRepository.DoAddBatch(AModels: TArray<TSlsDispatchDetail>);
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

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSlsDispatchDetailRepository.DoUpdate(AModel: TSlsDispatchDetail);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSlsDispatchDetailRepository.DoUpdateBatch(AModels: TArray<TSlsDispatchDetail>);
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

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TSlsDispatchDetailRepository.DoDelete(AID: TValue);
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

procedure TSlsDispatchDetailRepository.DoDelete(AModel: TSlsDispatchDetail);
begin
  Delete(AModel.Id);
end;

procedure TSlsDispatchDetailRepository.DoDeleteBatch(AModels: TArray<TSlsDispatchDetail>);
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

procedure TSlsDispatchDetailRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSlsDispatchDetailRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
