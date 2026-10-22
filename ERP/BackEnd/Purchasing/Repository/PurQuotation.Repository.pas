unit PurQuotation.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, PurQuotation;

type
  TPurQuotationRepository = class(TRepository<TPurQuotation>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TPurQuotation; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TPurQuotation; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TPurQuotation; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TPurQuotation>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TPurQuotation; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TPurQuotation; override;

    procedure DoAdd(AModel: TPurQuotation); override;
    procedure DoAddBatch(AModels: TArray<TPurQuotation>); override;

    procedure DoUpdate(AModel: TPurQuotation); override;
    procedure DoUpdateBatch(AModels: TArray<TPurQuotation>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TPurQuotation); override;
    procedure DoDeleteBatch(AModels: TArray<TPurQuotation>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function NextDocumentNo(const APrefix: string): string;
    function LineCount(AQuotationId: Int64): Integer;
    procedure SetStatus(AQuotationId: Int64; AStatus: SmallInt);
    // Başlık toplamları kalemlerden (tek kalem yolu)
    procedure RecalculateTotals(AQuotationId: Int64);
    // Onay bilgisi: kullanıcı + zaman (AUserId 0 = temizlenir)
    procedure SetApproval(AQuotationId, AUserId: Int64);
    // Siparişe dönüşüm: durum 5 + sipariş bağı
    procedure SetOrder(AQuotationId, AOrderId: Int64);
    // Talebin seçilmiş (onay bekleyen / onaylı / siparişe dönen) teklifi; 0 = yok
    function SelectedOfRequest(ARequestId, AExceptId: Int64): Int64;
    // Tedarikçinin talep için açık (reddedilmemiş / seçilmemiş olmayan) teklifi; 0 = yok
    function OpenOfSupplier(ARequestId, AAccountId, AExceptId: Int64): Int64;
    // Onaylanan teklif dışında talebin taslak / onay bekleyen teklifleri "seçilmedi" olur
    procedure MarkOthersNotSelected(ARequestId, AKeepId: Int64);
    function GetDefaultCurrency: string;
  end;

implementation

constructor TPurQuotationRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;


function TPurQuotationRepository.NextDocumentNo(const APrefix: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT :prefix || lpad((COALESCE(MAX(CAST(substr(quotation_no, length(:prefix) + 1) AS bigint)), 0) + 1)::text, 6, ''0'') AS v ' +
                  '  FROM public.pur_quotation WHERE quotation_no ~ (''^'' || :prefix || ''[0-9]+$'')';
    Q.ParamByName('prefix').DataType := ftWideString;
    Q.ParamByName('prefix').AsWideString := APrefix;
    LogQuery(Q, 'NextDocumentNo');
    Q.Open;
    Result := Q.FieldByName('v').AsString;
  finally
    Q.Free;
  end;
end;


function TPurQuotationRepository.LineCount(AQuotationId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT count(*) AS v FROM public.pur_quotation_detail WHERE pur_quotation_id = :id';
    Q.ParamByName('id').AsLargeInt := AQuotationId;
    LogQuery(Q, 'LineCount');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('v').AsInteger;
  finally
    Q.Free;
  end;
end;


procedure TPurQuotationRepository.SetStatus(AQuotationId: Int64; AStatus: SmallInt);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.pur_quotation SET status = :status WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AQuotationId;
    Q.ParamByName('status').AsSmallInt := AStatus;
    LogQuery(Q, 'SetStatus');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;


procedure TPurQuotationRepository.RecalculateTotals(AQuotationId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.pur_quotation q SET ' +
                  '       gross_amount = s.gross, discount_amount = s.disc, net_amount = s.net, vat_amount = s.vat, total_amount = s.total ' +
                  '  FROM (SELECT COALESCE(sum(gross_amount), 0) AS gross, COALESCE(sum(discount_amount), 0) AS disc, ' +
                  '               COALESCE(sum(net_amount), 0) AS net, COALESCE(sum(vat_amount), 0) AS vat, COALESCE(sum(total_amount), 0) AS total ' +
                  '          FROM public.pur_quotation_detail WHERE pur_quotation_id = :id) s ' +
                  ' WHERE q.id = :id';
    Q.ParamByName('id').AsLargeInt := AQuotationId;
    LogQuery(Q, 'RecalculateTotals');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TPurQuotationRepository.SetApproval(AQuotationId, AUserId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.pur_quotation SET approved_sys_user_id = :user_id, ' +
                  '       approved_at = CASE WHEN CAST(:user_id AS bigint) IS NULL THEN NULL ELSE now() END ' +
                  ' WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AQuotationId;
    SetNullableParam(Q.ParamByName('user_id'), ftLargeint, AUserId);
    LogQuery(Q, 'SetApproval');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;


procedure TPurQuotationRepository.SetOrder(AQuotationId, AOrderId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.pur_quotation SET status = 5, pur_order_id = :order_id WHERE id = :id';
    Q.ParamByName('id').AsLargeInt := AQuotationId;
    Q.ParamByName('order_id').AsLargeInt := AOrderId;
    LogQuery(Q, 'SetOrder');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;


function TPurQuotationRepository.SelectedOfRequest(ARequestId, AExceptId: Int64): Int64;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT id FROM public.pur_quotation ' +
                  ' WHERE pur_request_id = :request_id AND status IN (2, 3, 5) AND id <> :except_id LIMIT 1';
    Q.ParamByName('request_id').AsLargeInt := ARequestId;
    Q.ParamByName('except_id').AsLargeInt := AExceptId;
    LogQuery(Q, 'SelectedOfRequest');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsLargeInt;
  finally
    Q.Free;
  end;
end;


function TPurQuotationRepository.OpenOfSupplier(ARequestId, AAccountId, AExceptId: Int64): Int64;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT id FROM public.pur_quotation ' +
                  ' WHERE pur_request_id = :request_id AND acc_account_id = :account_id AND status IN (1, 2, 3, 5) ' +
                  '   AND id <> :except_id LIMIT 1';
    Q.ParamByName('request_id').AsLargeInt := ARequestId;
    Q.ParamByName('account_id').AsLargeInt := AAccountId;
    Q.ParamByName('except_id').AsLargeInt := AExceptId;
    LogQuery(Q, 'OpenOfSupplier');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsLargeInt;
  finally
    Q.Free;
  end;
end;


procedure TPurQuotationRepository.MarkOthersNotSelected(ARequestId, AKeepId: Int64);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'UPDATE public.pur_quotation SET status = 6 ' +
                  ' WHERE pur_request_id = :request_id AND id <> :keep_id AND status IN (1, 2)';
    Q.ParamByName('request_id').AsLargeInt := ARequestId;
    Q.ParamByName('keep_id').AsLargeInt := AKeepId;
    LogQuery(Q, 'MarkOthersNotSelected');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;


function TPurQuotationRepository.GetDefaultCurrency: string;
var
  Q: TFDQuery;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT public.fn_default_currency() AS currency';

    LogQuery(Q, 'GetDefaultCurrency');
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('currency').AsString;
  finally
    Q.Free;
  end;
end;

function TPurQuotationRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TPurQuotation) +
            ' (quotation_no, quotation_date, pur_request_id, acc_account_id, supplier_ref_no, valid_until, delivery_days, delivery_date, currency, exchange_rate, payment_term_days, payment_terms, status, gross_amount, discount_amount, net_amount, vat_amount, total_amount, description) ' +
            ' VALUES (:quotation_no, :quotation_date, :pur_request_id, :acc_account_id, :supplier_ref_no, :valid_until, :delivery_days, :delivery_date, :currency, :exchange_rate, :payment_term_days, :payment_terms, :status, :gross_amount, :discount_amount, :net_amount, :vat_amount, :total_amount, :description)';
end;

function TPurQuotationRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TPurQuotation) +
            ' SET quotation_no = :quotation_no, quotation_date = :quotation_date, pur_request_id = :pur_request_id, acc_account_id = :acc_account_id, supplier_ref_no = :supplier_ref_no, valid_until = :valid_until, delivery_days = :delivery_days, delivery_date = :delivery_date, currency = :currency, exchange_rate = :exchange_rate, payment_term_days = :payment_term_days, payment_terms = :payment_terms, status = :status, gross_amount = :gross_amount, discount_amount = :discount_amount, net_amount = :net_amount, vat_amount = :vat_amount, total_amount = :total_amount, description = :description ' +
            ' WHERE id = :id';
end;

function TPurQuotationRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TPurQuotation) + ' WHERE';
end;

procedure TPurQuotationRepository.SetInsertParams(Q: TFDQuery; AModel: TPurQuotation; AIndex: Integer);

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
    Q.ParamByName('quotation_no').AsWideString := AModel.QuotationNo;
    Q.ParamByName('supplier_ref_no').AsWideString := AModel.SupplierRefNo;
    Q.ParamByName('delivery_days').AsSmallInt := AModel.DeliveryDays;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('payment_term_days').AsSmallInt := AModel.PaymentTermDays;
    Q.ParamByName('payment_terms').AsWideString := AModel.PaymentTerms;
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
    Q.ParamByName('quotation_no').AsWideStrings[AIndex] := AModel.QuotationNo;
    Q.ParamByName('supplier_ref_no').AsWideStrings[AIndex] := AModel.SupplierRefNo;
    Q.ParamByName('delivery_days').AsSmallInts[AIndex] := AModel.DeliveryDays;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('payment_term_days').AsSmallInts[AIndex] := AModel.PaymentTermDays;
    Q.ParamByName('payment_terms').AsWideStrings[AIndex] := AModel.PaymentTerms;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('quotation_date', AModel.QuotationDate);
  SetNullableParam(Q.ParamByName('pur_request_id'), ftLargeint, AModel.PurRequestId, AIndex);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('valid_until', AModel.ValidUntil);
  SetDate('delivery_date', AModel.DeliveryDate);
end;

procedure TPurQuotationRepository.SetUpdateParams(Q: TFDQuery; AModel: TPurQuotation; AIndex: Integer);

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
    Q.ParamByName('quotation_no').AsWideString := AModel.QuotationNo;
    Q.ParamByName('supplier_ref_no').AsWideString := AModel.SupplierRefNo;
    Q.ParamByName('delivery_days').AsSmallInt := AModel.DeliveryDays;
    Q.ParamByName('currency').AsWideString := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCD := AModel.ExchangeRate;
    Q.ParamByName('payment_term_days').AsSmallInt := AModel.PaymentTermDays;
    Q.ParamByName('payment_terms').AsWideString := AModel.PaymentTerms;
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
    Q.ParamByName('quotation_no').AsWideStrings[AIndex] := AModel.QuotationNo;
    Q.ParamByName('supplier_ref_no').AsWideStrings[AIndex] := AModel.SupplierRefNo;
    Q.ParamByName('delivery_days').AsSmallInts[AIndex] := AModel.DeliveryDays;
    Q.ParamByName('currency').AsWideStrings[AIndex] := AModel.Currency;
    Q.ParamByName('exchange_rate').AsBCDs[AIndex] := AModel.ExchangeRate;
    Q.ParamByName('payment_term_days').AsSmallInts[AIndex] := AModel.PaymentTermDays;
    Q.ParamByName('payment_terms').AsWideStrings[AIndex] := AModel.PaymentTerms;
    Q.ParamByName('status').AsSmallInts[AIndex] := AModel.Status;
    Q.ParamByName('gross_amount').AsBCDs[AIndex] := AModel.GrossAmount;
    Q.ParamByName('discount_amount').AsBCDs[AIndex] := AModel.DiscountAmount;
    Q.ParamByName('net_amount').AsBCDs[AIndex] := AModel.NetAmount;
    Q.ParamByName('vat_amount').AsBCDs[AIndex] := AModel.VatAmount;
    Q.ParamByName('total_amount').AsBCDs[AIndex] := AModel.TotalAmount;
    Q.ParamByName('description').AsWideStrings[AIndex] := AModel.Description;
  end;

  SetDate('quotation_date', AModel.QuotationDate);
  SetNullableParam(Q.ParamByName('pur_request_id'), ftLargeint, AModel.PurRequestId, AIndex);
  SetNullableParam(Q.ParamByName('acc_account_id'), ftLargeint, AModel.AccAccountId, AIndex);
  SetDate('valid_until', AModel.ValidUntil);
  SetDate('delivery_date', AModel.DeliveryDate);
end;

function TPurQuotationRepository.MapFromQuery(Q: TFDQuery): TPurQuotation;
begin
  Result := TPurQuotation.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.QuotationNo := Q.FieldByName('quotation_no').AsString;
  if Q.FieldByName('quotation_date').IsNull then
    Result.QuotationDate := 0
  else
    Result.QuotationDate := Q.FieldByName('quotation_date').AsDateTime;
  Result.PurRequestId := Q.FieldByName('pur_request_id').AsLargeInt;
  Result.AccAccountId := Q.FieldByName('acc_account_id').AsLargeInt;
  Result.SupplierRefNo := Q.FieldByName('supplier_ref_no').AsString;
  if Q.FieldByName('valid_until').IsNull then
    Result.ValidUntil := 0
  else
    Result.ValidUntil := Q.FieldByName('valid_until').AsDateTime;
  Result.DeliveryDays := Q.FieldByName('delivery_days').AsInteger;
  if Q.FieldByName('delivery_date').IsNull then
    Result.DeliveryDate := 0
  else
    Result.DeliveryDate := Q.FieldByName('delivery_date').AsDateTime;
  Result.Currency := Q.FieldByName('currency').AsString;
  Result.ExchangeRate := Q.FieldByName('exchange_rate').AsCurrency;
  Result.PaymentTermDays := Q.FieldByName('payment_term_days').AsInteger;
  Result.PaymentTerms := Q.FieldByName('payment_terms').AsString;
  Result.Status := Q.FieldByName('status').AsInteger;
  Result.GrossAmount := Q.FieldByName('gross_amount').AsCurrency;
  Result.DiscountAmount := Q.FieldByName('discount_amount').AsCurrency;
  Result.NetAmount := Q.FieldByName('net_amount').AsCurrency;
  Result.VatAmount := Q.FieldByName('vat_amount').AsCurrency;
  Result.TotalAmount := Q.FieldByName('total_amount').AsCurrency;
  Result.PurOrderId := Q.FieldByName('pur_order_id').AsLargeInt;
  Result.ApprovedSysUserId := Q.FieldByName('approved_sys_user_id').AsLargeInt;
  if Q.FieldByName('approved_at').IsNull then
    Result.ApprovedAt := 0
  else
    Result.ApprovedAt := Q.FieldByName('approved_at').AsDateTime;
  Result.Description := Q.FieldByName('description').AsString;
  Result.RequestNo := Q.FieldByName('request_no').AsString;
  Result.AccountCode := Q.FieldByName('account_code').AsString;
  Result.AccountName := Q.FieldByName('account_name').AsString;
  Result.OrderNo := Q.FieldByName('order_no').AsString;
  Result.ApprovedBy := Q.FieldByName('approved_by').AsString;
end;

function TPurQuotationRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TPurQuotation) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TPurQuotationRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TPurQuotation>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TPurQuotation>.Create(True);
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

function TPurQuotationRepository.DoFindById(AId: TValue; ALock: Boolean): TPurQuotation;
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

function TPurQuotationRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TPurQuotation;
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

procedure TPurQuotationRepository.DoAdd(AModel: TPurQuotation);
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

procedure TPurQuotationRepository.DoAddBatch(AModels: TArray<TPurQuotation>);
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

procedure TPurQuotationRepository.DoUpdate(AModel: TPurQuotation);
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

procedure TPurQuotationRepository.DoUpdateBatch(AModels: TArray<TPurQuotation>);
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

procedure TPurQuotationRepository.DoDelete(AID: TValue);
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

procedure TPurQuotationRepository.DoDelete(AModel: TPurQuotation);
begin
  Delete(AModel.Id);
end;

procedure TPurQuotationRepository.DoDeleteBatch(AModels: TArray<TPurQuotation>);
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

procedure TPurQuotationRepository.DoDeleteBatch(AIDs: TArray<TValue>);
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

procedure TPurQuotationRepository.DoDeleteBatch(AFilter: TFilterCriteria);
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
