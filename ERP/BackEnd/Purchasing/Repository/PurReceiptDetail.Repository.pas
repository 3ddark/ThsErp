unit PurReceiptDetail.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PurReceiptDetail;

type
  TPurReceiptDetailRepository = class(TRepository<TPurReceiptDetail>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPurReceiptDetail; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPurReceiptDetail; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPurReceiptDetail; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPurReceiptDetail>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPurReceiptDetail; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPurReceiptDetail; override;

    procedure DoAdd(AModel: TPurReceiptDetail); override;
    procedure DoAddBatch(AModels: TArray<TPurReceiptDetail>); override;

    procedure DoUpdate(AModel: TPurReceiptDetail); override;
    procedure DoUpdateBatch(AModels: TArray<TPurReceiptDetail>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPurReceiptDetail); override;
    procedure DoDeleteBatch(AModels: TArray<TPurReceiptDetail>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    // Mal kabullerin kalemleri tek sorguda (başlık + satır no sırasıyla): belge yükleme
    function FindByReceiptIds(const AIds: TArray<Int64>): TObjectList<TPurReceiptDetail>;
    function NextLineNo(AParentId: Int64): SmallInt;
    function InvoicedQuantity(AReceiptDetailId: Int64; AExcludeInvoiceDetailId: Int64): Currency;
    function ReceivedQuantityOfOrderDetail(AOrderDetailId: Int64; AExcludeId: Int64): Currency;
    procedure UpsertStockTransaction(AReceiptDetailId: Int64);
  end;

implementation

constructor TPurReceiptDetailRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPurReceiptDetailRepository.NextLineNo(AParentId: Int64): SmallInt;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(MAX(line_no), 0) + 1 AS v FROM public.pur_receipt_detail WHERE pur_receipt_id = :id';
    Q.ParamByName('id').AsLargeInt := AParentId;
    LogQuery(Q, 'NextLineNo');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TPurReceiptDetailRepository.FindByReceiptIds(const AIds: TArray<Int64>): TObjectList<TPurReceiptDetail>;
var
  Q: TFDQuery;
  LIds: string;
  LId: Int64;
begin
  Result := TObjectList<TPurReceiptDetail>.Create(True);
  LIds := '';
  for LId in AIds do
    if LId > 0 then
    begin
      if LIds <> '' then
        LIds := LIds + ',';
      LIds := LIds + IntToStr(LId);   // sayısal id: doğrudan yazılır
    end;
  if LIds = '' then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT v.* FROM ' + Self.GetFullViewName(TPurReceiptDetail) + ' v ' +
                  ' WHERE v.pur_receipt_id IN (' + LIds + ') ORDER BY v.pur_receipt_id, v.line_no, v.id';
    LogQuery(Q, 'FindByReceiptIds');
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

function TPurReceiptDetailRepository.InvoicedQuantity(AReceiptDetailId: Int64; AExcludeInvoiceDetailId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(sum(quantity), 0) AS v FROM public.pur_invoice_detail ' +
                  ' WHERE pur_receipt_detail_id = :id AND id <> :exclude_id';
    Q.ParamByName('id').AsLargeInt := AReceiptDetailId;
    Q.ParamByName('exclude_id').AsLargeInt := AExcludeInvoiceDetailId;
    LogQuery(Q, 'InvoicedQuantity');
    Q.Open;
    Result := Q.FieldByName('v').AsCurrency;
  finally
    Q.Free;
  end;
end;

function TPurReceiptDetailRepository.ReceivedQuantityOfOrderDetail(AOrderDetailId: Int64; AExcludeId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(sum(quantity), 0) AS v FROM public.pur_receipt_detail ' +
                  ' WHERE pur_order_detail_id = :id AND id <> :exclude_id';
    Q.ParamByName('id').AsLargeInt := AOrderDetailId;
    Q.ParamByName('exclude_id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'ReceivedQuantityOfOrderDetail');
    Q.Open;
    Result := Q.FieldByName('v').AsCurrency;
  finally
    Q.Free;
  end;
end;

procedure TPurReceiptDetailRepository.UpsertStockTransaction(AReceiptDetailId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'INSERT INTO public.stk_transaction (transaction_type, stk_inventory_id, to_stk_warehouse_id, quantity, amount, currency, ' +
                  '       transaction_date, description, pur_receipt_detail_id) ' +
                  'SELECT 1, d.stk_inventory_id, p.stk_warehouse_id, d.quantity, round(d.quantity * d.unit_price, 2), p.currency, ' +
                  '       p.receipt_date, ''MK '' || p.receipt_no, d.id ' +
                  '  FROM public.pur_receipt_detail d JOIN public.pur_receipt p ON p.id = d.pur_receipt_id ' +
                  ' WHERE d.id = :id ' +
                  'ON CONFLICT ON CONSTRAINT stk_transaction_pur_receipt_detail_key DO UPDATE SET ' +
                  '       stk_inventory_id = EXCLUDED.stk_inventory_id, to_stk_warehouse_id = EXCLUDED.to_stk_warehouse_id, ' +
                  '       quantity = EXCLUDED.quantity, amount = EXCLUDED.amount, currency = EXCLUDED.currency, ' +
                  '       transaction_date = EXCLUDED.transaction_date, description = EXCLUDED.description';
    Q.ParamByName('id').AsLargeInt := AReceiptDetailId;
    LogQuery(Q, 'UpsertStockTransaction');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TPurReceiptDetailRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPurReceiptDetail) +
            ' (pur_receipt_id, line_no, stk_inventory_id, quantity, unit_price, pur_order_detail_id, description) ' +
            ' VALUES (:pur_receipt_id, :line_no, :stk_inventory_id, :quantity, :unit_price, :pur_order_detail_id, :description)';
end;

function TPurReceiptDetailRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPurReceiptDetail) +
            ' SET pur_receipt_id = :pur_receipt_id, line_no = :line_no, stk_inventory_id = :stk_inventory_id, quantity = :quantity, unit_price = :unit_price, pur_order_detail_id = :pur_order_detail_id, description = :description ' +
            ' WHERE id = :id';
end;

function TPurReceiptDetailRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPurReceiptDetail) + ' WHERE';
end;

procedure TPurReceiptDetailRepository.SetInsertParams(Q: TFDQuery; AModel: TPurReceiptDetail; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCD := AModel.UnitPrice;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCDs[AIndex] := AModel.UnitPrice;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('pur_receipt_id'), ftLargeint, AModel.PurReceiptId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('pur_order_detail_id'), ftLargeint, AModel.PurOrderDetailId, AIndex);
end;

procedure TPurReceiptDetailRepository.SetUpdateParams(Q: TFDQuery; AModel: TPurReceiptDetail; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('line_no').AsSmallInt := AModel.LineNo;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCD := AModel.UnitPrice;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('line_no').AsSmallInts[AIndex] := AModel.LineNo;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCDs[AIndex] := AModel.UnitPrice;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetNullableParam(Q.ParamByName('pur_receipt_id'), ftLargeint, AModel.PurReceiptId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('pur_order_detail_id'), ftLargeint, AModel.PurOrderDetailId, AIndex);
end;

function TPurReceiptDetailRepository.MapFromQuery(Q: TFDQuery): TPurReceiptDetail;
begin
  Result := TPurReceiptDetail.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PurReceiptId := Q.FieldByName('pur_receipt_id').AsLargeInt;
  Result.LineNo := Q.FieldByName('line_no').AsInteger;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.UnitPrice := Q.FieldByName('unit_price').AsCurrency;
  Result.PurOrderDetailId := Q.FieldByName('pur_order_detail_id').AsLargeInt;
  Result.Description := Q.FieldByName('description').AsString;
  Result.ReceiptNo := Q.FieldByName('receipt_no').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.UomCode := Q.FieldByName('uom_code').AsString;
  Result.OrderNo := Q.FieldByName('order_no').AsString;
  Result.Amount := Q.FieldByName('amount').AsCurrency;
  Result.InvoicedQuantity := Q.FieldByName('invoiced_quantity').AsCurrency;
end;

function TPurReceiptDetailRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPurReceiptDetail) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPurReceiptDetailRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPurReceiptDetail>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPurReceiptDetail>.Create(True);
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

function TPurReceiptDetailRepository.DoFindById(AId: TValue; ALock: Boolean): TPurReceiptDetail;
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

function TPurReceiptDetailRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPurReceiptDetail;
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

procedure TPurReceiptDetailRepository.DoAdd(AModel: TPurReceiptDetail);
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

procedure TPurReceiptDetailRepository.DoAddBatch(AModels: TArray<TPurReceiptDetail>);
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

procedure TPurReceiptDetailRepository.DoUpdate(AModel: TPurReceiptDetail);
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

procedure TPurReceiptDetailRepository.DoUpdateBatch(AModels: TArray<TPurReceiptDetail>);
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

procedure TPurReceiptDetailRepository.DoDelete(AID: TValue);
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

procedure TPurReceiptDetailRepository.DoDelete(AModel: TPurReceiptDetail);
begin
  Delete(AModel.Id);
end;

procedure TPurReceiptDetailRepository.DoDeleteBatch(AModels: TArray<TPurReceiptDetail>);
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

procedure TPurReceiptDetailRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPurReceiptDetailRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
