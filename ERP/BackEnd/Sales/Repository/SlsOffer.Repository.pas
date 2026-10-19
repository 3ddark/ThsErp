unit SlsOffer.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, SlsOffer;

type
  TSlsOfferRepository = class(TRepository<TSlsOffer>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TSlsOffer; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TSlsOffer; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TSlsOffer; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TSlsOffer>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TSlsOffer; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TSlsOffer; override;

    procedure DoAdd(AModel: TSlsOffer); override;
    procedure DoAddBatch(AModels: TArray<TSlsOffer>); override;

    procedure DoUpdate(AModel: TSlsOffer); override;
    procedure DoUpdateBatch(AModels: TArray<TSlsOffer>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TSlsOffer); override;
    procedure DoDeleteBatch(AModels: TArray<TSlsOffer>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    function LineCount(AOfferId: Int64): Integer;
    function OrderedTotal(AOfferId: Int64): Currency;
    procedure SetStatus(AOfferId: Int64; AStatus: SmallInt);
    procedure RecalculateTotals(AOfferId: Int64);
    procedure RefreshOrderedQuantities(AOfferId: Int64);
    function GetDefaultCurrency: string;
    // Tablodaki (kayıtlı) belge adresi id'leri; yeni kayıtta 0
    procedure GetSysAddressIds(AOfferId: Int64; out ABillingId, AShippingId: Int64);
  end;

implementation

constructor TSlsOfferRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSlsOfferRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(offer_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.sls_offer WHERE offer_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;

function TSlsOfferRepository.LineCount(AOfferId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.sls_offer_detail WHERE sls_offer_id = :id';
    Q.ParamByName('id').AsLargeInt := AOfferId;
    LogQuery(Q, 'LineCount');
    Q.Open;
    Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;

function TSlsOfferRepository.OrderedTotal(AOfferId: Int64): Currency;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT COALESCE(sum(ordered_quantity), 0) AS v FROM public.sls_offer_detail WHERE sls_offer_id = :id';
    Q.ParamByName('id').AsLargeInt := AOfferId;
    LogQuery(Q, 'OrderedTotal');
    Q.Open;
    Result := Q.FieldByName('v').AsCurrency;
  finally
    Q.Free;
  end;
end;

procedure TSlsOfferRepository.SetStatus(AOfferId: Int64; AStatus: SmallInt);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_offer SET status = :status WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AOfferId;
    Q.ParamByName('status').AsSmallInt := AStatus;
    LogQuery(Q, 'SetStatus');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSlsOfferRepository.RecalculateTotals(AOfferId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_offer o SET ' +
                  '       gross_amount = s.gross, discount_amount = s.disc, net_amount = s.net, vat_amount = s.vat, total_amount = s.total ' +
                  '  FROM (SELECT COALESCE(sum(gross_amount), 0) AS gross, COALESCE(sum(discount_amount), 0) AS disc, ' +
                  '               COALESCE(sum(net_amount), 0) AS net, COALESCE(sum(vat_amount), 0) AS vat, COALESCE(sum(total_amount), 0) AS total ' +
                  '          FROM public.sls_offer_detail WHERE sls_offer_id = :id) s ' +
                  ' WHERE o.id = :id';
    Q.ParamByName('id').AsLargeInt := AOfferId;
    LogQuery(Q, 'RecalculateTotals');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSlsOfferRepository.RefreshOrderedQuantities(AOfferId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.sls_offer_detail d ' +
                  '   SET ordered_quantity = COALESCE((SELECT sum(od.quantity) FROM public.sls_order_detail od ' +
                  '                                     JOIN public.sls_order o ON o.id = od.sls_order_id ' +
                  '                                    WHERE od.sls_offer_detail_id = d.id AND o.status <> 5), 0) ' +
                  ' WHERE d.sls_offer_id = :id';
    Q.ParamByName('id').AsLargeInt := AOfferId;
    LogQuery(Q, 'RefreshOrderedQuantities');
    Q.ExecSQL;
    Q.SQL.Text := 'UPDATE public.sls_offer r ' +
                  '   SET status = CASE WHEN NOT EXISTS (SELECT 1 FROM public.sls_offer_detail d ' +
                  '                                       WHERE d.sls_offer_id = r.id AND d.ordered_quantity < d.quantity) ' +
                  '                     THEN 4 ELSE 2 END ' +
                  ' WHERE r.id = :id AND r.status IN (2, 4) ' +
                  '   AND EXISTS (SELECT 1 FROM public.sls_offer_detail d WHERE d.sls_offer_id = r.id)';
    Q.ParamByName('id').AsLargeInt := AOfferId;
    LogQuery(Q, 'RefreshOrderedQuantities');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSlsOfferRepository.GetDefaultCurrency: string;
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

procedure TSlsOfferRepository.GetSysAddressIds(AOfferId: Int64; out ABillingId, AShippingId: Int64);
var
  Q: TFDQuery;
begin
  ABillingId := 0;
  AShippingId := 0;
  if AOfferId <= 0 then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT billing_sys_address_id, shipping_sys_address_id FROM public.sls_offer WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AOfferId;
    LogQuery(Q, 'GetSysAddressIds');
    Q.Open;
    if not Q.IsEmpty then
    begin
      ABillingId := Q.FieldByName('billing_sys_address_id').AsLargeInt;
      AShippingId := Q.FieldByName('shipping_sys_address_id').AsLargeInt;
    end;
  finally
    Q.Free;
  end;
end;

function TSlsOfferRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TSlsOffer) +
            ' (offer_no, offer_date, valid_until, acc_account_id, customer_ref_no, emp_employee_id, currency, exchange_rate, payment_term_days, status, gross_amount, discount_amount, net_amount, vat_amount, total_amount, description, billing_address_id, billing_sys_address_id, shipping_address_id, shipping_sys_address_id, base_currency, usd_rate, eur_rate) ' +
            ' VALUES (:offer_no, :offer_date, :valid_until, :acc_account_id, :customer_ref_no, :emp_employee_id, :currency, :exchange_rate, :payment_term_days, :status, :gross_amount, :discount_amount, :net_amount, :vat_amount, :total_amount, :description, :billing_address_id, :billing_sys_address_id, :shipping_address_id, :shipping_sys_address_id, :base_currency, :usd_rate, :eur_rate)';
end;

function TSlsOfferRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TSlsOffer) +
            ' SET offer_no = :offer_no, offer_date = :offer_date, valid_until = :valid_until, acc_account_id = :acc_account_id, customer_ref_no = :customer_ref_no, emp_employee_id = :emp_employee_id, currency = :currency, exchange_rate = :exchange_rate, payment_term_days = :payment_term_days, status = :status, gross_amount = :gross_amount, discount_amount = :discount_amount, net_amount = :net_amount, vat_amount = :vat_amount, total_amount = :total_amount, description = :description, billing_address_id = :billing_address_id, billing_sys_address_id = :billing_sys_address_id, shipping_address_id = :shipping_address_id, shipping_sys_address_id = :shipping_sys_address_id, base_currency = :base_currency, usd_rate = :usd_rate, eur_rate = :eur_rate ' +
            ' WHERE id = :id';
end;

function TSlsOfferRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TSlsOffer) + ' WHERE';
end;

procedure TSlsOfferRepository.SetInsertParams(Q: TFDQuery; AModel: TSlsOffer; AIndex: Integer);

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
    Q.ParamByName('offer_no').AsWideString := AModel.OfferNo;
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
    Q.ParamByName('base_currency').AsWideString := AModel.BaseCurrency;
    Q.ParamByName('usd_rate').AsBCD := AModel.UsdRate;
    Q.ParamByName('eur_rate').AsBCD := AModel.EurRate;
  end
  else
  begin
    Q.ParamByName('offer_no').AsWideStrings[AIndex] := AModel.OfferNo;
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
    Q.ParamByName('base_currency').AsWideStrings[AIndex] := AModel.BaseCurrency;
    Q.ParamByName('usd_rate').AsBCDs[AIndex] := AModel.UsdRate;
    Q.ParamByName('eur_rate').AsBCDs[AIndex] := AModel.EurRate;
  end;

  SetDate('offer_date', AModel.OfferDate);
  SetDate('valid_until', AModel.ValidUntil);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetNullableParam(Q.ParamByName('billing_address_id'), ftLargeint, AModel.BillingAddressId, AIndex);
  SetNullableParam(Q.ParamByName('shipping_address_id'), ftLargeint, AModel.ShippingAddressId, AIndex);
  SetNullableParam(Q.ParamByName('billing_sys_address_id'), ftLargeint, AModel.BillingSysAddressId, AIndex);
  SetNullableParam(Q.ParamByName('shipping_sys_address_id'), ftLargeint, AModel.ShippingSysAddressId, AIndex);
end;

procedure TSlsOfferRepository.SetUpdateParams(Q: TFDQuery; AModel: TSlsOffer; AIndex: Integer);

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
    Q.ParamByName('offer_no').AsWideString := AModel.OfferNo;
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
    Q.ParamByName('base_currency').AsWideString := AModel.BaseCurrency;
    Q.ParamByName('usd_rate').AsBCD := AModel.UsdRate;
    Q.ParamByName('eur_rate').AsBCD := AModel.EurRate;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('offer_no').AsWideStrings[AIndex] := AModel.OfferNo;
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
    Q.ParamByName('base_currency').AsWideStrings[AIndex] := AModel.BaseCurrency;
    Q.ParamByName('usd_rate').AsBCDs[AIndex] := AModel.UsdRate;
    Q.ParamByName('eur_rate').AsBCDs[AIndex] := AModel.EurRate;
  end;

  SetDate('offer_date', AModel.OfferDate);
  SetDate('valid_until', AModel.ValidUntil);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetNullableParam(Q.ParamByName('emp_employee_id'), ftLargeint, AModel.EmpEmployeeId, AIndex);
  SetNullableParam(Q.ParamByName('billing_address_id'), ftLargeint, AModel.BillingAddressId, AIndex);
  SetNullableParam(Q.ParamByName('shipping_address_id'), ftLargeint, AModel.ShippingAddressId, AIndex);
  SetNullableParam(Q.ParamByName('billing_sys_address_id'), ftLargeint, AModel.BillingSysAddressId, AIndex);
  SetNullableParam(Q.ParamByName('shipping_sys_address_id'), ftLargeint, AModel.ShippingSysAddressId, AIndex);
end;

function TSlsOfferRepository.MapFromQuery(Q: TFDQuery): TSlsOffer;
begin
  Result := TSlsOffer.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.OfferNo := Q.FieldByName('offer_no').AsString;
  if Q.FieldByName('offer_date').IsNull then
    Result.OfferDate := 0
  else
    Result.OfferDate := Q.FieldByName('offer_date').AsDateTime;
  if Q.FieldByName('valid_until').IsNull then
    Result.ValidUntil := 0
  else
    Result.ValidUntil := Q.FieldByName('valid_until').AsDateTime;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.CustomerRefNo := Q.FieldByName('customer_ref_no').AsString;
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
  Result.BillingAddressId := Q.FieldByName('billing_address_id').AsLargeInt;
  Result.BillingSysAddressId := Q.FieldByName('billing_sys_address_id').AsLargeInt;
  Result.BillingAddressText := Q.FieldByName('billing_address').AsString;
  Result.ShippingAddressId := Q.FieldByName('shipping_address_id').AsLargeInt;
  Result.ShippingSysAddressId := Q.FieldByName('shipping_sys_address_id').AsLargeInt;
  Result.ShippingAddressText := Q.FieldByName('shipping_address').AsString;
  Result.BaseCurrency := Q.FieldByName('base_currency').AsString;
  Result.UsdRate := Q.FieldByName('usd_rate').AsCurrency;
  Result.EurRate := Q.FieldByName('eur_rate').AsCurrency;
  Result.TotalAmountBase := Q.FieldByName('total_amount_base').AsCurrency;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.EmployeeName := Q.FieldByName('employee_name').AsString;
end;

function TSlsOfferRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TSlsOffer) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TSlsOfferRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TSlsOffer>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TSlsOffer>.Create(True);
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

function TSlsOfferRepository.DoFindById(AId: TValue; ALock: Boolean): TSlsOffer;
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

function TSlsOfferRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TSlsOffer;
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

procedure TSlsOfferRepository.DoAdd(AModel: TSlsOffer);
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

procedure TSlsOfferRepository.DoAddBatch(AModels: TArray<TSlsOffer>);
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

procedure TSlsOfferRepository.DoUpdate(AModel: TSlsOffer);
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

procedure TSlsOfferRepository.DoUpdateBatch(AModels: TArray<TSlsOffer>);
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

procedure TSlsOfferRepository.DoDelete(AID: TValue);
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

procedure TSlsOfferRepository.DoDelete(AModel: TSlsOffer);
begin
  Delete(AModel.Id);
end;

procedure TSlsOfferRepository.DoDeleteBatch(AModels: TArray<TSlsOffer>);
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

procedure TSlsOfferRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TSlsOfferRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
