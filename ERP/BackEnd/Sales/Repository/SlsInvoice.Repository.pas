unit SlsInvoice.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SlsInvoice;

type
  TSlsInvoiceRepository = class(TRepository<TSlsInvoice>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSlsInvoice; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSlsInvoice; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSlsInvoice; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSlsInvoice>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSlsInvoice; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSlsInvoice; override;

    procedure DoAdd(AModel: TSlsInvoice); override;
    procedure DoAddBatch(AModels: TArray<TSlsInvoice>); override;

    procedure DoUpdate(AModel: TSlsInvoice); override;
    procedure DoUpdateBatch(AModels: TArray<TSlsInvoice>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSlsInvoice); override;
    procedure DoDeleteBatch(AModels: TArray<TSlsInvoice>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    function LineCount(AInvoiceId: Int64): Integer;
    function StockLineCount(AInvoiceId: Int64): Integer;
    procedure RecalculateTotals(AInvoiceId: Int64);
    procedure SyncStockTransactions(AInvoiceId: Int64);
    function StockInventoryIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
    function OrderIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
    // Faturanın irsaliyeli kalemlerinin irsaliyeleri (tekil; irsaliye durumu)
    function DispatchIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
    function GetDefaultCurrency: string;
  end;

implementation

constructor TSlsInvoiceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSlsInvoiceRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(invoice_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.sls_invoice WHERE invoice_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.LineCount(AInvoiceId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.sls_invoice_detail WHERE sls_invoice_id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'LineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.StockLineCount(AInvoiceId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.sls_invoice_detail WHERE sls_invoice_id = :id AND sls_dispatch_detail_id IS NULL';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'StockLineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

procedure TSlsInvoiceRepository.RecalculateTotals(AInvoiceId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_invoice f SET ' +
                  '       gross_amount = s.gross, discount_amount = s.disc, net_amount = s.net, vat_amount = s.vat, total_amount = s.total ' +
                  '  FROM (SELECT COALESCE(sum(gross_amount), 0) AS gross, COALESCE(sum(discount_amount), 0) AS disc, ' +
                  '               COALESCE(sum(net_amount), 0) AS net, COALESCE(sum(vat_amount), 0) AS vat, COALESCE(sum(total_amount), 0) AS total ' +
                  '          FROM public.sls_invoice_detail WHERE sls_invoice_id = :id) s ' +
                  ' WHERE f.id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'RecalculateTotals');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSlsInvoiceRepository.SyncStockTransactions(AInvoiceId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.stk_transaction t ' +
                  '   SET transaction_date = f.invoice_date, from_stk_warehouse_id = f.stk_warehouse_id, currency = f.currency, ' +
                  '       description = f.invoice_no ' +
                  '  FROM public.sls_invoice_detail d JOIN public.sls_invoice f ON f.id = d.sls_invoice_id ' +
                  ' WHERE t.sls_invoice_detail_id = d.id AND f.id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'SyncStockTransactions');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.StockInventoryIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT stk_inventory_id FROM public.sls_invoice_detail WHERE sls_invoice_id = :id AND sls_dispatch_detail_id IS NULL';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'StockInventoryIdsOfInvoice');
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

function TSlsInvoiceRepository.OrderIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT od.sls_order_id FROM public.sls_invoice_detail d ' +
                  '  JOIN public.sls_order_detail od ON od.id = d.sls_order_detail_id WHERE d.sls_invoice_id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'OrderIdsOfInvoice');
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

function TSlsInvoiceRepository.DispatchIdsOfInvoice(AInvoiceId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
  n: Integer;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT dd.sls_dispatch_id FROM public.sls_invoice_detail i ' +
                  '  JOIN public.sls_dispatch_detail dd ON dd.id = i.sls_dispatch_detail_id WHERE i.sls_invoice_id = :id';
    Q.ParamByName('id').AsLargeInt := AInvoiceId;
    LogQuery(Q, 'DispatchIdsOfInvoice');
    Q.Open;
    SetLength(Result, Q.RecordCount);
    n := 0;
    while not Q.Eof do
    begin
      Result[n] := Q.Fields[0].AsLargeInt;
      Inc(n);
      Q.Next;
    end;
    SetLength(Result, n);
  finally
    Q.Free;
  end;
end;

function TSlsInvoiceRepository.GetDefaultCurrency: string;
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

function TSlsInvoiceRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSlsInvoice) +
            ' (invoice_no, invoice_date, acc_account_id, due_date, stk_warehouse_id, currency, exchange_rate, gross_amount, discount_amount, net_amount, vat_amount, total_amount, description) ' +
            ' VALUES (:invoice_no, :invoice_date, :acc_account_id, :due_date, :stk_warehouse_id, :currency, :exchange_rate, :gross_amount, :discount_amount, :net_amount, :vat_amount, :total_amount, :description)';
end;

function TSlsInvoiceRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSlsInvoice) +
            ' SET invoice_no = :invoice_no, invoice_date = :invoice_date, acc_account_id = :acc_account_id, due_date = :due_date, stk_warehouse_id = :stk_warehouse_id, currency = :currency, exchange_rate = :exchange_rate, gross_amount = :gross_amount, discount_amount = :discount_amount, net_amount = :net_amount, vat_amount = :vat_amount, total_amount = :total_amount, description = :description ' +
            ' WHERE id = :id';
end;

function TSlsInvoiceRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSlsInvoice) + ' WHERE';
end;

procedure TSlsInvoiceRepository.SetInsertParams(Q: TFDQuery; AModel: TSlsInvoice; AIndex: Integer);

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
    Q.ParamByName('invoice_no').AsWideString := AModel.InvoiceNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('gross_amount').AsBCD := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCD := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCD := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCD := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCD := AModel.TotalAmount;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('invoice_no').AsWideStrings[AIndex] := AModel.InvoiceNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('invoice_date', AModel.InvoiceDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('due_date', AModel.DueDate);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
end;

procedure TSlsInvoiceRepository.SetUpdateParams(Q: TFDQuery; AModel: TSlsInvoice; AIndex: Integer);

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
    Q.ParamByName('invoice_no').AsWideString := AModel.InvoiceNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
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
    Q.ParamByName('invoice_no').AsWideStrings[AIndex] := AModel.InvoiceNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('invoice_date', AModel.InvoiceDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('due_date', AModel.DueDate);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
end;

function TSlsInvoiceRepository.MapFromQuery(Q: TFDQuery): TSlsInvoice;
begin
  Result := TSlsInvoice.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.InvoiceNo := Q.FieldByName('invoice_no').AsString;
  if Q.FieldByName('invoice_date').IsNull then
    Result.InvoiceDate := 0
  else
    Result.InvoiceDate := Q.FieldByName('invoice_date').AsDateTime;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  if Q.FieldByName('due_date').IsNull then
    Result.DueDate := 0
  else
    Result.DueDate := Q.FieldByName('due_date').AsDateTime;
  Result.StkWarehouseId := Q.FieldByName('stk_warehouse_id').AsLargeInt;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.ExchangeRate := Q.FieldByName('exchange_rate').AsCurrency;
  Result.GrossAmount := Q.FieldByName('gross_amount').AsCurrency;
  Result.DiscountAmount := Q.FieldByName('discount_amount').AsCurrency;
  Result.NetAmount := Q.FieldByName('net_amount').AsCurrency;
  Result.VatAmount := Q.FieldByName('vat_amount').AsCurrency;
  Result.TotalAmount := Q.FieldByName('total_amount').AsCurrency;
  Result.Description := Q.FieldByName('description').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.WarehouseName := Q.FieldByName('warehouse_name').AsString;
end;

function TSlsInvoiceRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSlsInvoice) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSlsInvoiceRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSlsInvoice>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSlsInvoice>.Create(True);
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

function TSlsInvoiceRepository.DoFindById(AId: TValue; ALock: Boolean): TSlsInvoice;
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

function TSlsInvoiceRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSlsInvoice;
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

procedure TSlsInvoiceRepository.DoAdd(AModel: TSlsInvoice);
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

procedure TSlsInvoiceRepository.DoAddBatch(AModels: TArray<TSlsInvoice>);
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

procedure TSlsInvoiceRepository.DoUpdate(AModel: TSlsInvoice);
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

procedure TSlsInvoiceRepository.DoUpdateBatch(AModels: TArray<TSlsInvoice>);
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

procedure TSlsInvoiceRepository.DoDelete(AID: TValue);
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

procedure TSlsInvoiceRepository.DoDelete(AModel: TSlsInvoice);
begin
  Delete(AModel.Id);
end;

procedure TSlsInvoiceRepository.DoDeleteBatch(AModels: TArray<TSlsInvoice>);
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

procedure TSlsInvoiceRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSlsInvoiceRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
