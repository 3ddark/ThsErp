unit PurQuotationComparison.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PurQuotationComparison;

type
  TPurQuotationComparisonRepository = class(TRepository<TPurQuotationComparison>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPurQuotationComparison; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPurQuotationComparison; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPurQuotationComparison; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPurQuotationComparison>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPurQuotationComparison; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPurQuotationComparison; override;

    procedure DoAdd(AModel: TPurQuotationComparison); override;
    procedure DoAddBatch(AModels: TArray<TPurQuotationComparison>); override;

    procedure DoUpdate(AModel: TPurQuotationComparison); override;
    procedure DoUpdateBatch(AModels: TArray<TPurQuotationComparison>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPurQuotationComparison); override;
    procedure DoDeleteBatch(AModels: TArray<TPurQuotationComparison>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TPurQuotationComparisonRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TPurQuotationComparisonRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPurQuotationComparison) +
            ' (pur_request_id, request_no, pur_request_detail_id, request_line_no, stk_inventory_id, inventory_code, inventory_name, uom_code, request_quantity, pur_quotation_id, quotation_no, quotation_date, status, acc_account_id, account_code, account_name, currency, exchange_rate, quantity, unit_price, discount_rate, vat_rate, net_unit_price, net_unit_price_base, net_amount_base, delivery_days, delivery_date, payment_term_days, payment_terms, valid_until, price_rank) ' +
            ' VALUES (:pur_request_id, :request_no, :pur_request_detail_id, :request_line_no, :stk_inventory_id, :inventory_code, :inventory_name, :uom_code, :request_quantity, :pur_quotation_id, :quotation_no, :quotation_date, :status, :acc_account_id, :account_code, :account_name, :currency, :exchange_rate, :quantity, :unit_price, :discount_rate, :vat_rate, :net_unit_price, :net_unit_price_base, :net_amount_base, :delivery_days, :delivery_date, :payment_term_days, :payment_terms, :valid_until, :price_rank)';
end;

function TPurQuotationComparisonRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPurQuotationComparison) +
            ' SET pur_request_id = :pur_request_id, request_no = :request_no, pur_request_detail_id = :pur_request_detail_id, request_line_no = :request_line_no, stk_inventory_id = :stk_inventory_id, inventory_code = :inventory_code, inventory_name = :inventory_name, uom_code = :uom_code, request_quantity = :request_quantity, pur_quotation_id = :pur_quotation_id, quotation_no = :quotation_no, quotation_date = :quotation_date, status = :status, acc_account_id = :acc_account_id, account_code = :account_code, account_name = :account_name, currency = :currency, exchange_rate = :exchange_rate, quantity = :quantity, unit_price = :unit_price, discount_rate = :discount_rate, vat_rate = :vat_rate, net_unit_price = :net_unit_price, net_unit_price_base = :net_unit_price_base, net_amount_base = :net_amount_base, delivery_days = :delivery_days, delivery_date = :delivery_date, payment_term_days = :payment_term_days, payment_terms = :payment_terms, valid_until = :valid_until, price_rank = :price_rank ' +
            ' WHERE id = :id';
end;

function TPurQuotationComparisonRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPurQuotationComparison) + ' WHERE';
end;

procedure TPurQuotationComparisonRepository.SetInsertParams(Q: TFDQuery; AModel: TPurQuotationComparison; AIndex: Integer);

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
    Q.ParamByName('request_no').AsWideString := AModel.RequestNo;
    Q.ParamByName('request_line_no').AsSmallInt := AModel.RequestLineNo;
    Q.ParamByName('inventory_code').AsWideString := AModel.InventoryCode;
    Q.ParamByName('inventory_name').AsWideString := AModel.InventoryName;
    Q.ParamByName('uom_code').AsWideString := AModel.UomCode;
    Q.ParamByName('request_quantity').AsBCD := AModel.RequestQuantity;
    Q.ParamByName('quotation_no').AsWideString := AModel.QuotationNo;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
    Q.ParamByName('account_code').AsWideString := AModel.AccountCode;
    Q.ParamByName('account_name').AsWideString := AModel.AccountName;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCD := AModel.UnitPrice;
    Q.ParamByName('discount_rate').AsBCD := AModel.DiscountRate;
    Q.ParamByName('vat_rate').AsBCD := AModel.VatRate;
    Q.ParamByName('net_unit_price').AsBCD := AModel.NetUnitPrice;
    Q.ParamByName('net_unit_price_base').AsBCD := AModel.NetUnitPriceBase;
    Q.ParamByName('net_amount_base').AsBCD := AModel.NetAmountBase;
    Q.ParamByName('delivery_days').AsSmallInt := AModel.DeliveryDays;
    Q.ParamByName('payment_term_days').AsSmallInt := AModel.PaymentTermDays;
    Q.ParamByName('payment_terms').AsWideString := AModel.PaymentTerms;
    Q.ParamByName('price_rank').AsInteger := AModel.PriceRank;
  end
  else
  begin
    Q.ParamByName('request_no').AsWideStrings[AIndex] := AModel.RequestNo;
    Q.ParamByName('request_line_no').AsSmallInts[AIndex] := AModel.RequestLineNo;
    Q.ParamByName('inventory_code').AsWideStrings[AIndex] := AModel.InventoryCode;
    Q.ParamByName('inventory_name').AsWideStrings[AIndex] := AModel.InventoryName;
    Q.ParamByName('uom_code').AsWideStrings[AIndex] := AModel.UomCode;
    Q.ParamByName('request_quantity').AsBCDs[AIndex] := AModel.RequestQuantity;
    Q.ParamByName('quotation_no').AsWideStrings[AIndex] := AModel.QuotationNo;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('account_code').AsWideStrings[AIndex] := AModel.AccountCode;
    Q.ParamByName('account_name').AsWideStrings[AIndex] := AModel.AccountName;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCDs[AIndex] := AModel.UnitPrice;
    Q.ParamByName('discount_rate').AsBCDs[AIndex] := AModel.DiscountRate;
    Q.ParamByName('vat_rate').AsBCDs[AIndex] := AModel.VatRate;
    Q.ParamByName('net_unit_price').AsBCDs[AIndex] := AModel.NetUnitPrice;
    Q.ParamByName('net_unit_price_base').AsBCDs[AIndex] := AModel.NetUnitPriceBase;
    Q.ParamByName('net_amount_base').AsBCDs[AIndex] := AModel.NetAmountBase;
    Q.ParamByName('delivery_days').AsSmallInts[AIndex] := AModel.DeliveryDays;
    Q.ParamByName('payment_term_days').AsSmallInts[AIndex] := AModel.PaymentTermDays;
    Q.ParamByName('payment_terms').AsWideStrings[AIndex] := AModel.PaymentTerms;
    Q.ParamByName('price_rank').AsIntegers[AIndex] := AModel.PriceRank;
  end;

  SetNullableParam(Q.ParamByName('pur_request_id'), ftLargeint, AModel.PurRequestId, AIndex);
  SetNullableParam(Q.ParamByName('pur_request_detail_id'), ftLargeint, AModel.PurRequestDetailId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('pur_quotation_id'), ftLargeint, AModel.PurQuotationId, AIndex);
  SetDate('quotation_date', AModel.QuotationDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('delivery_date', AModel.DeliveryDate);
  SetDate('valid_until', AModel.ValidUntil);
end;

procedure TPurQuotationComparisonRepository.SetUpdateParams(Q: TFDQuery; AModel: TPurQuotationComparison; AIndex: Integer);

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
    Q.ParamByName('request_no').AsWideString := AModel.RequestNo;
    Q.ParamByName('request_line_no').AsSmallInt := AModel.RequestLineNo;
    Q.ParamByName('inventory_code').AsWideString := AModel.InventoryCode;
    Q.ParamByName('inventory_name').AsWideString := AModel.InventoryName;
    Q.ParamByName('uom_code').AsWideString := AModel.UomCode;
    Q.ParamByName('request_quantity').AsBCD := AModel.RequestQuantity;
    Q.ParamByName('quotation_no').AsWideString := AModel.QuotationNo;
    Q.ParamByName('status').AsSmallInt := AModel.Status;
    Q.ParamByName('account_code').AsWideString := AModel.AccountCode;
    Q.ParamByName('account_name').AsWideString := AModel.AccountName;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('quantity').AsBCD := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCD := AModel.UnitPrice;
    Q.ParamByName('discount_rate').AsBCD := AModel.DiscountRate;
    Q.ParamByName('vat_rate').AsBCD := AModel.VatRate;
    Q.ParamByName('net_unit_price').AsBCD := AModel.NetUnitPrice;
    Q.ParamByName('net_unit_price_base').AsBCD := AModel.NetUnitPriceBase;
    Q.ParamByName('net_amount_base').AsBCD := AModel.NetAmountBase;
    Q.ParamByName('delivery_days').AsSmallInt := AModel.DeliveryDays;
    Q.ParamByName('payment_term_days').AsSmallInt := AModel.PaymentTermDays;
    Q.ParamByName('payment_terms').AsWideString := AModel.PaymentTerms;
    Q.ParamByName('price_rank').AsInteger := AModel.PriceRank;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('request_no').AsWideStrings[AIndex] := AModel.RequestNo;
    Q.ParamByName('request_line_no').AsSmallInts[AIndex] := AModel.RequestLineNo;
    Q.ParamByName('inventory_code').AsWideStrings[AIndex] := AModel.InventoryCode;
    Q.ParamByName('inventory_name').AsWideStrings[AIndex] := AModel.InventoryName;
    Q.ParamByName('uom_code').AsWideStrings[AIndex] := AModel.UomCode;
    Q.ParamByName('request_quantity').AsBCDs[AIndex] := AModel.RequestQuantity;
    Q.ParamByName('quotation_no').AsWideStrings[AIndex] := AModel.QuotationNo;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('account_code').AsWideStrings[AIndex] := AModel.AccountCode;
    Q.ParamByName('account_name').AsWideStrings[AIndex] := AModel.AccountName;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('quantity').AsBCDs[AIndex] := AModel.Quantity;
    Q.ParamByName('unit_price').AsBCDs[AIndex] := AModel.UnitPrice;
    Q.ParamByName('discount_rate').AsBCDs[AIndex] := AModel.DiscountRate;
    Q.ParamByName('vat_rate').AsBCDs[AIndex] := AModel.VatRate;
    Q.ParamByName('net_unit_price').AsBCDs[AIndex] := AModel.NetUnitPrice;
    Q.ParamByName('net_unit_price_base').AsBCDs[AIndex] := AModel.NetUnitPriceBase;
    Q.ParamByName('net_amount_base').AsBCDs[AIndex] := AModel.NetAmountBase;
    Q.ParamByName('delivery_days').AsSmallInts[AIndex] := AModel.DeliveryDays;
    Q.ParamByName('payment_term_days').AsSmallInts[AIndex] := AModel.PaymentTermDays;
    Q.ParamByName('payment_terms').AsWideStrings[AIndex] := AModel.PaymentTerms;
    Q.ParamByName('price_rank').AsIntegers[AIndex] := AModel.PriceRank;
  end;

  SetNullableParam(Q.ParamByName('pur_request_id'), ftLargeint, AModel.PurRequestId, AIndex);
  SetNullableParam(Q.ParamByName('pur_request_detail_id'), ftLargeint, AModel.PurRequestDetailId, AIndex);
  SetNullableParam(Q.ParamByName('stk_inventory_id'), ftLargeint, AModel.StkInventoryId, AIndex);
  SetNullableParam(Q.ParamByName('pur_quotation_id'), ftLargeint, AModel.PurQuotationId, AIndex);
  SetDate('quotation_date', AModel.QuotationDate);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('delivery_date', AModel.DeliveryDate);
  SetDate('valid_until', AModel.ValidUntil);
end;

function TPurQuotationComparisonRepository.MapFromQuery(Q: TFDQuery): TPurQuotationComparison;
begin
  Result := TPurQuotationComparison.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.PurRequestId := Q.FieldByName('pur_request_id').AsLargeInt;
  Result.RequestNo := Q.FieldByName('request_no').AsString;
  Result.PurRequestDetailId := Q.FieldByName('pur_request_detail_id').AsLargeInt;
  Result.RequestLineNo := Q.FieldByName('request_line_no').AsInteger;
  Result.StkInventoryId := Q.FieldByName('stk_inventory_id').AsLargeInt;
  Result.InventoryCode := Q.FieldByName('inventory_code').AsString;
  Result.InventoryName := Q.FieldByName('inventory_name').AsString;
  Result.UomCode := Q.FieldByName('uom_code').AsString;
  Result.RequestQuantity := Q.FieldByName('request_quantity').AsCurrency;
  Result.PurQuotationId := Q.FieldByName('pur_quotation_id').AsLargeInt;
  Result.QuotationNo := Q.FieldByName('quotation_no').AsString;
  if Q.FieldByName('quotation_date').IsNull then
    Result.QuotationDate := 0
  else
    Result.QuotationDate := Q.FieldByName('quotation_date').AsDateTime;
  Result.Status := Q.FieldByName('status').AsInteger;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.ExchangeRate := Q.FieldByName('exchange_rate').AsCurrency;
  Result.Quantity := Q.FieldByName('quantity').AsCurrency;
  Result.UnitPrice := Q.FieldByName('unit_price').AsCurrency;
  Result.DiscountRate := Q.FieldByName('discount_rate').AsCurrency;
  Result.VatRate := Q.FieldByName('vat_rate').AsCurrency;
  Result.NetUnitPrice := Q.FieldByName('net_unit_price').AsCurrency;
  Result.NetUnitPriceBase := Q.FieldByName('net_unit_price_base').AsCurrency;
  Result.NetAmountBase := Q.FieldByName('net_amount_base').AsCurrency;
  Result.DeliveryDays := Q.FieldByName('delivery_days').AsInteger;
  if Q.FieldByName('delivery_date').IsNull then
    Result.DeliveryDate := 0
  else
    Result.DeliveryDate := Q.FieldByName('delivery_date').AsDateTime;
  Result.PaymentTermDays := Q.FieldByName('payment_term_days').AsInteger;
  Result.PaymentTerms := Q.FieldByName('payment_terms').AsString;
  if Q.FieldByName('valid_until').IsNull then
    Result.ValidUntil := 0
  else
    Result.ValidUntil := Q.FieldByName('valid_until').AsDateTime;
  Result.PriceRank := Q.FieldByName('price_rank').AsInteger;
end;

function TPurQuotationComparisonRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPurQuotationComparison) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPurQuotationComparisonRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPurQuotationComparison>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPurQuotationComparison>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, False, False, False);

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

function TPurQuotationComparisonRepository.DoFindById(AId: TValue; ALock: Boolean): TPurQuotationComparison;
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
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, False, True, False);

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

function TPurQuotationComparisonRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPurQuotationComparison;
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
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, False, True, False);

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

procedure TPurQuotationComparisonRepository.DoAdd(AModel: TPurQuotationComparison);
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

procedure TPurQuotationComparisonRepository.DoAddBatch(AModels: TArray<TPurQuotationComparison>);
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

procedure TPurQuotationComparisonRepository.DoUpdate(AModel: TPurQuotationComparison);
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

procedure TPurQuotationComparisonRepository.DoUpdateBatch(AModels: TArray<TPurQuotationComparison>);
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

procedure TPurQuotationComparisonRepository.DoDelete(AID: TValue);
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

procedure TPurQuotationComparisonRepository.DoDelete(AModel: TPurQuotationComparison);
begin
  Delete(AModel.Id);
end;

procedure TPurQuotationComparisonRepository.DoDeleteBatch(AModels: TArray<TPurQuotationComparison>);
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

procedure TPurQuotationComparisonRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPurQuotationComparisonRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
