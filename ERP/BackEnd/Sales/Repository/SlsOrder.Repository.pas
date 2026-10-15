unit SlsOrder.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SlsOrder;

type
  TSlsOrderRepository = class(TRepository<TSlsOrder>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSlsOrder; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSlsOrder; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSlsOrder; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSlsOrder>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSlsOrder; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSlsOrder; override;

    procedure DoAdd(AModel: TSlsOrder); override;
    procedure DoAddBatch(AModels: TArray<TSlsOrder>); override;

    procedure DoUpdate(AModel: TSlsOrder); override;
    procedure DoUpdateBatch(AModels: TArray<TSlsOrder>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSlsOrder); override;
    procedure DoDeleteBatch(AModels: TArray<TSlsOrder>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    function LineCount(AOrderId: Int64): Integer;
    function DeliveryCount(AOrderId: Int64): Integer;
    procedure SetStatus(AOrderId: Int64; AStatus: SmallInt);
    procedure RecalculateTotals(AOrderId: Int64);
    procedure RefreshDeliveredQuantities(AOrderId: Int64);
    function OfferIdsOfOrder(AOrderId: Int64): TArray<Int64>;
    function GetDefaultCurrency: string;
  end;

implementation

constructor TSlsOrderRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSlsOrderRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(order_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.sls_order WHERE order_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;

function TSlsOrderRepository.LineCount(AOrderId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.sls_order_detail WHERE sls_order_id = :id';
    Q.ParamByName('id').AsLargeInt := AOrderId;
    LogQuery(Q, 'LineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TSlsOrderRepository.DeliveryCount(AOrderId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT (SELECT count(*) FROM public.sls_dispatch WHERE sls_order_id = :id) + ' +
                  '       (SELECT count(*) FROM public.sls_invoice_detail f JOIN public.sls_order_detail d ON d.id = f.sls_order_detail_id ' +
                  '         WHERE d.sls_order_id = :id) AS v';
    Q.ParamByName('id').AsLargeInt := AOrderId;
    LogQuery(Q, 'DeliveryCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

procedure TSlsOrderRepository.SetStatus(AOrderId: Int64; AStatus: SmallInt);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_order SET status = :status WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AOrderId;
    Q.ParamByName('status').AsSmallInt := AStatus;
    LogQuery(Q, 'SetStatus');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSlsOrderRepository.RecalculateTotals(AOrderId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_order o SET ' +
                  '       gross_amount = s.gross, discount_amount = s.disc, net_amount = s.net, vat_amount = s.vat, total_amount = s.total ' +
                  '  FROM (SELECT COALESCE(sum(gross_amount), 0) AS gross, COALESCE(sum(discount_amount), 0) AS disc, ' +
                  '               COALESCE(sum(net_amount), 0) AS net, COALESCE(sum(vat_amount), 0) AS vat, COALESCE(sum(total_amount), 0) AS total ' +
                  '          FROM public.sls_order_detail WHERE sls_order_id = :id) s ' +
                  ' WHERE o.id = :id';
    Q.ParamByName('id').AsLargeInt := AOrderId;
    LogQuery(Q, 'RecalculateTotals');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSlsOrderRepository.RefreshDeliveredQuantities(AOrderId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_order_detail d ' +
                  '   SET delivered_quantity = COALESCE((SELECT sum(pd.quantity) FROM public.sls_dispatch_detail pd ' +
                  '                                       WHERE pd.sls_order_detail_id = d.id), 0) + ' +
                  '                            COALESCE((SELECT sum(fd.quantity) FROM public.sls_invoice_detail fd ' +
                  '                                       WHERE fd.sls_order_detail_id = d.id), 0) ' +
                  ' WHERE d.sls_order_id = :id';
    Q.ParamByName('id').AsLargeInt := AOrderId;
    LogQuery(Q, 'RefreshDeliveredQuantities');
    Q.ExecSQL;
    Q.SQL.Text := 'UPDATE public.sls_order o ' +
                  '   SET status = CASE WHEN NOT EXISTS (SELECT 1 FROM public.sls_order_detail d ' +
                  '                                       WHERE d.sls_order_id = o.id AND d.delivered_quantity < d.quantity) THEN 4 ' +
                  '                     WHEN EXISTS (SELECT 1 FROM public.sls_order_detail d ' +
                  '                                   WHERE d.sls_order_id = o.id AND d.delivered_quantity > 0) THEN 3 ' +
                  '                     ELSE 2 END ' +
                  ' WHERE o.id = :id AND o.status IN (2, 3, 4)';
    Q.ParamByName('id').AsLargeInt := AOrderId;
    LogQuery(Q, 'RefreshDeliveredQuantities');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

// Siparişin kalemlerinin bağlı olduğu teklifler
function TSlsOrderRepository.OfferIdsOfOrder(AOrderId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT fd.sls_offer_id FROM public.sls_order_detail d ' +
                  '  JOIN public.sls_offer_detail fd ON fd.id = d.sls_offer_detail_id ' +
                  ' WHERE d.sls_order_id = :id';
    Q.ParamByName('id').AsLargeInt := AOrderId;
    LogQuery(Q, 'OfferIdsOfOrder');
    Q.Open;
    while not Q.Eof do
    begin
      Result := Result + [Q.Fields[0].AsLargeInt];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSlsOrderRepository.GetDefaultCurrency: string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT public.fn_default_currency() AS currency';
    LogQuery(Q, 'GetDefaultCurrency');
    Q.Open;
    Result := Q.FieldByName('currency').AsString;
  finally
    Q.Free;
  end;
end;

function TSlsOrderRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSlsOrder) +
            ' (order_no, order_date, acc_account_id, customer_ref_no, delivery_date, stk_warehouse_id, emp_employee_id, currency, exchange_rate, payment_term_days, status, gross_amount, discount_amount, net_amount, vat_amount, total_amount, description) ' +
            ' VALUES (:order_no, :order_date, :acc_account_id, :customer_ref_no, :delivery_date, :stk_warehouse_id, :emp_employee_id, :currency, :exchange_rate, :payment_term_days, :status, :gross_amount, :discount_amount, :net_amount, :vat_amount, :total_amount, :description)';
end;

function TSlsOrderRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSlsOrder) +
            ' SET order_no = :order_no, order_date = :order_date, acc_account_id = :acc_account_id, customer_ref_no = :customer_ref_no, delivery_date = :delivery_date, stk_warehouse_id = :stk_warehouse_id, emp_employee_id = :emp_employee_id, currency = :currency, exchange_rate = :exchange_rate, payment_term_days = :payment_term_days, status = :status, gross_amount = :gross_amount, discount_amount = :discount_amount, net_amount = :net_amount, vat_amount = :vat_amount, total_amount = :total_amount, description = :description ' +
            ' WHERE id = :id';
end;

function TSlsOrderRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSlsOrder) + ' WHERE';
end;

procedure TSlsOrderRepository.SetInsertParams(Q: TFDQuery; AModel: TSlsOrder; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('order_no').AsWideString := AModel.OrderNo;
    Q.ParamByName('customer_ref_no').AsWideString := AModel.CustomerRefNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('payment_term_days').AsSmallInt := AModel.PaymentTermDays;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
    Q.ParamByName('gross_amount').AsBCD := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCD := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCD := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCD := AModel.TotalAmount;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('order_no').AsWideStrings[AIndex] := AModel.OrderNo;
    Q.ParamByName('customer_ref_no').AsWideStrings[AIndex] := AModel.CustomerRefNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('payment_term_days').AsSmallInts[AIndex] := AModel.PaymentTermDays;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('order_date', AModel.OrderDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('delivery_date', AModel.DeliveryDate);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
end;

procedure TSlsOrderRepository.SetUpdateParams(Q: TFDQuery; AModel: TSlsOrder; AIndex: Integer);

  procedure SetDate(const AName: string; AValue: TDate);
  begin
    Q.ParamByName(AName).DataType := ftDate;
    if AValue > 0 then
    begin
      if AIndex < 0 then
        Q.ParamByName(AName).AsDate := AValue
      else
        Q.ParamByName(AName).AsDates[AIndex] := AValue;
    end
    else if AIndex < 0 then
      Q.ParamByName(AName).Clear
    else
      Q.ParamByName(AName).Clear(AIndex);
  end;

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('order_no').AsWideString := AModel.OrderNo;
    Q.ParamByName('customer_ref_no').AsWideString := AModel.CustomerRefNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('payment_term_days').AsSmallInt := AModel.PaymentTermDays;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
    Q.ParamByName('gross_amount').AsBCD := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCD := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCD := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCD := AModel.TotalAmount;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('order_no').AsWideStrings[AIndex] := AModel.OrderNo;
    Q.ParamByName('customer_ref_no').AsWideStrings[AIndex] := AModel.CustomerRefNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('payment_term_days').AsSmallInts[AIndex] := AModel.PaymentTermDays;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('order_date', AModel.OrderDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('delivery_date', AModel.DeliveryDate);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
end;

function TSlsOrderRepository.MapFromQuery(Q: TFDQuery): TSlsOrder;
begin
  Result := TSlsOrder.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.OrderNo := Q.FieldByName('order_no').AsString;
  if Q.FieldByName('order_date').IsNull then
    Result.OrderDate := 0
  else
    Result.OrderDate := Q.FieldByName('order_date').AsDateTime;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.CustomerRefNo := Q.FieldByName('customer_ref_no').AsString;
  if Q.FieldByName('delivery_date').IsNull then
    Result.DeliveryDate := 0
  else
    Result.DeliveryDate := Q.FieldByName('delivery_date').AsDateTime;
  Result.StkWarehouseId := Q.FieldByName('stk_warehouse_id').AsLargeInt;
  Result.EmpEmployeeId := Q.FieldByName('emp_employee_id').AsLargeInt;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.ExchangeRate := Q.FieldByName('exchange_rate').AsCurrency;
  Result.PaymentTermDays := Q.FieldByName('payment_term_days').AsInteger;
  Result.Status := Q.FieldByName('status').AsInteger;
  Result.GrossAmount := Q.FieldByName('gross_amount').AsCurrency;
  Result.DiscountAmount := Q.FieldByName('discount_amount').AsCurrency;
  Result.NetAmount := Q.FieldByName('net_amount').AsCurrency;
  Result.VatAmount := Q.FieldByName('vat_amount').AsCurrency;
  Result.TotalAmount := Q.FieldByName('total_amount').AsCurrency;
  Result.Description := Q.FieldByName('description').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.WarehouseName := Q.FieldByName('warehouse_name').AsString;
  Result.EmployeeName := Q.FieldByName('employee_name').AsString;
end;

function TSlsOrderRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSlsOrder) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSlsOrderRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSlsOrder>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSlsOrder>.Create(True);
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

function TSlsOrderRepository.DoFindById(AId: TValue; ALock: Boolean): TSlsOrder;
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

function TSlsOrderRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSlsOrder;
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

procedure TSlsOrderRepository.DoAdd(AModel: TSlsOrder);
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

procedure TSlsOrderRepository.DoAddBatch(AModels: TArray<TSlsOrder>);
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

procedure TSlsOrderRepository.DoUpdate(AModel: TSlsOrder);
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

procedure TSlsOrderRepository.DoUpdateBatch(AModels: TArray<TSlsOrder>);
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

procedure TSlsOrderRepository.DoDelete(AID: TValue);
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

procedure TSlsOrderRepository.DoDelete(AModel: TSlsOrder);
begin
  Delete(AModel.Id);
end;

procedure TSlsOrderRepository.DoDeleteBatch(AModels: TArray<TSlsOrder>);
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

procedure TSlsOrderRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSlsOrderRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
