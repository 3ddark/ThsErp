unit PurReceipt.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PurReceipt;

type
  TPurReceiptRepository = class(TRepository<TPurReceipt>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPurReceipt; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPurReceipt; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPurReceipt; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPurReceipt>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPurReceipt; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPurReceipt; override;

    procedure DoAdd(AModel: TPurReceipt); override;
    procedure DoAddBatch(AModels: TArray<TPurReceipt>); override;

    procedure DoUpdate(AModel: TPurReceipt); override;
    procedure DoUpdateBatch(AModels: TArray<TPurReceipt>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPurReceipt); override;
    procedure DoDeleteBatch(AModels: TArray<TPurReceipt>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    function LineCount(AReceiptId: Int64): Integer;
    function InvoicedQuantity(AReceiptId: Int64): Currency;
    procedure SyncStockTransactions(AReceiptId: Int64);
    function InventoryIdsOfReceipt(AReceiptId: Int64): TArray<Int64>;
    function GetDefaultCurrency: string;
  end;

implementation

constructor TPurReceiptRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPurReceiptRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(receipt_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.pur_receipt WHERE receipt_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;

function TPurReceiptRepository.LineCount(AReceiptId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.pur_receipt_detail WHERE pur_receipt_id = :id';
    Q.ParamByName('id').AsLargeInt := AReceiptId;
    LogQuery(Q, 'LineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TPurReceiptRepository.InvoicedQuantity(AReceiptId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(sum(f.quantity), 0) AS v FROM public.pur_invoice_detail f ' +
                  '  JOIN public.pur_receipt_detail d ON d.id = f.pur_receipt_detail_id WHERE d.pur_receipt_id = :id';
    Q.ParamByName('id').AsLargeInt := AReceiptId;
    LogQuery(Q, 'InvoicedQuantity');
    Q.Open;
    Result := Q.FieldByName('v').AsCurrency;
  finally
    Q.Free;
  end;
end;

procedure TPurReceiptRepository.SyncStockTransactions(AReceiptId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.stk_transaction t ' +
                  '   SET transaction_date = p.receipt_date, to_stk_warehouse_id = p.stk_warehouse_id, currency = p.currency, ' +
                  '       description = ''MK '' || p.receipt_no ' +
                  '  FROM public.pur_receipt_detail d JOIN public.pur_receipt p ON p.id = d.pur_receipt_id ' +
                  ' WHERE t.pur_receipt_detail_id = d.id AND p.id = :id';
    Q.ParamByName('id').AsLargeInt := AReceiptId;
    LogQuery(Q, 'SyncStockTransactions');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TPurReceiptRepository.InventoryIdsOfReceipt(AReceiptId: Int64): TArray<Int64>;
var
  Q: TFDQuery;
begin
  Result := [];
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT DISTINCT stk_inventory_id FROM public.pur_receipt_detail WHERE pur_receipt_id = :id';
    Q.ParamByName('id').AsLargeInt := AReceiptId;
    LogQuery(Q, 'InventoryIdsOfReceipt');
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

function TPurReceiptRepository.GetDefaultCurrency: string;
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

function TPurReceiptRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPurReceipt) +
            ' (receipt_no, receipt_date, acc_account_id, stk_warehouse_id, waybill_no, pur_order_id, currency, description) ' +
            ' VALUES (:receipt_no, :receipt_date, :acc_account_id, :stk_warehouse_id, :waybill_no, :pur_order_id, :currency, :description)';
end;

function TPurReceiptRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPurReceipt) +
            ' SET receipt_no = :receipt_no, receipt_date = :receipt_date, acc_account_id = :acc_account_id, stk_warehouse_id = :stk_warehouse_id, waybill_no = :waybill_no, pur_order_id = :pur_order_id, currency = :currency, description = :description ' +
            ' WHERE id = :id';
end;

function TPurReceiptRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPurReceipt) + ' WHERE';
end;

procedure TPurReceiptRepository.SetInsertParams(Q: TFDQuery; AModel: TPurReceipt; AIndex: Integer);

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
    Q.ParamByName('receipt_no').AsWideString := AModel.ReceiptNo;
    Q.ParamByName('waybill_no').AsWideString := AModel.WaybillNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('receipt_no').AsWideStrings[AIndex] := AModel.ReceiptNo;
    Q.ParamByName('waybill_no').AsWideStrings[AIndex] := AModel.WaybillNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('receipt_date', AModel.ReceiptDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('pur_order_id'), ftLargeint, AModel.PurOrderId, AIndex);
end;

procedure TPurReceiptRepository.SetUpdateParams(Q: TFDQuery; AModel: TPurReceipt; AIndex: Integer);

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
    Q.ParamByName('receipt_no').AsWideString := AModel.ReceiptNo;
    Q.ParamByName('waybill_no').AsWideString := AModel.WaybillNo;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('description').AsWideString := AModel.Description;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('receipt_no').AsWideStrings[AIndex] := AModel.ReceiptNo;
    Q.ParamByName('waybill_no').AsWideStrings[AIndex] := AModel.WaybillNo;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('receipt_date', AModel.ReceiptDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('stk_warehouse_id'), ftLargeint, AModel.StkWarehouseId, AIndex);
  SetNullableParam(Q.ParamByName('pur_order_id'), ftLargeint, AModel.PurOrderId, AIndex);
end;

function TPurReceiptRepository.MapFromQuery(Q: TFDQuery): TPurReceipt;
begin
  Result := TPurReceipt.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.ReceiptNo := Q.FieldByName('receipt_no').AsString;
  if Q.FieldByName('receipt_date').IsNull then
    Result.ReceiptDate := 0
  else
    Result.ReceiptDate := Q.FieldByName('receipt_date').AsDateTime;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.StkWarehouseId := Q.FieldByName('stk_warehouse_id').AsLargeInt;
  Result.WaybillNo := Q.FieldByName('waybill_no').AsString;
  Result.PurOrderId := Q.FieldByName('pur_order_id').AsLargeInt;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.Description := Q.FieldByName('description').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.WarehouseName := Q.FieldByName('warehouse_name').AsString;
  Result.OrderNo := Q.FieldByName('order_no').AsString;
end;

function TPurReceiptRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPurReceipt) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPurReceiptRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPurReceipt>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPurReceipt>.Create(True);
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

function TPurReceiptRepository.DoFindById(AId: TValue; ALock: Boolean): TPurReceipt;
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

function TPurReceiptRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPurReceipt;
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

procedure TPurReceiptRepository.DoAdd(AModel: TPurReceipt);
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

procedure TPurReceiptRepository.DoAddBatch(AModels: TArray<TPurReceipt>);
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

procedure TPurReceiptRepository.DoUpdate(AModel: TPurReceipt);
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

procedure TPurReceiptRepository.DoUpdateBatch(AModels: TArray<TPurReceipt>);
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

procedure TPurReceiptRepository.DoDelete(AID: TValue);
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

procedure TPurReceiptRepository.DoDelete(AModel: TPurReceipt);
begin
  Delete(AModel.Id);
end;

procedure TPurReceiptRepository.DoDeleteBatch(AModels: TArray<TPurReceipt>);
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

procedure TPurReceiptRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPurReceiptRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
