unit SysDashboard.Repository;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Logger, SysDashboard;

type
  // Ana ekran göstergeleri: yalnız okuma, toplama sorguları (tarihler sunucunun CURRENT_DATE'i ile)
  TSysDashboardRepository = class
  private
    FConnection: TFDConnection;
    function Open(const ASql, AOperation: string): TFDQuery;
    procedure AddAmount(var AKpi: TDashboardKpi; const ACurrency: string; AAmount: Currency);
    function MonthFilter(const AColumn: string): string;
  public
    constructor Create(AConnection: TFDConnection);

    function FxRates: TDashboardKpi;
    function MoneyBalance(AAccountKind: Integer; const AKey: string): TDashboardKpi;
    function MoneyToday: TDashboardKpi;
    function ChequeNotes(ADirection: Integer; const AStatuses, AKey: string): TDashboardKpi;
    function PosMonth: TDashboardKpi;
    function CardDebt: TDashboardKpi;
    function PurRequests: TDashboardKpi;
    function PurOrdersOpen: TDashboardKpi;
    function PurOrdersMonth: TDashboardKpi;
    function PurReceiptsMonth: TDashboardKpi;
    function PurInvoicesMonth: TDashboardKpi;
    function SalesDocsMonth(const ATable, ADateColumn, AKey: string): TDashboardKpi;
    function StockCritical: TDashboardKpi;
    function StockTxToday: TDashboardKpi;
    function StockCards: TDashboardKpi;
    procedure AccountBalances(out AReceivable, APayable: TDashboardKpi);
    function Accounts: TDashboardKpi;
    function Employees: TDashboardKpi;
    function Users: TDashboardKpi;
  end;

implementation

constructor TSysDashboardRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if AConnection = nil then
    raise Exception.Create('Connection Required');
  FConnection := AConnection;
end;

function TSysDashboardRepository.Open(const ASql, AOperation: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConnection;
    Result.SQL.Text := ASql;
    {$IF Defined(DEBUG) or Defined(FULL_LOG_SQL)}
    GLogger.LogSQL(ASql, Self.ClassName + '.' + AOperation);
    {$IFEND}
    Result.Open;
  except
    Result.Free;
    raise;
  end;
end;

procedure TSysDashboardRepository.AddAmount(var AKpi: TDashboardKpi; const ACurrency: string; AAmount: Currency);
var
  LItem: TDashboardAmount;
begin
  LItem.Currency := ACurrency;
  LItem.Amount := AAmount;
  AKpi.Amounts := AKpi.Amounts + [LItem];
end;

function TSysDashboardRepository.MonthFilter(const AColumn: string): string;
begin
  Result := Format('date_trunc(''month'', %s) = date_trunc(''month'', CURRENT_DATE)', [AColumn]);
end;

// Her para birimi için son kur (USD, EUR, GBP önce); kur bugünün değilse uyarı
function TSysDashboardRepository.FxRates: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_FX_RATES);
  Q := Open('SELECT currency, rate, rate_date FROM (' +
            '  SELECT DISTINCT ON (currency) currency, rate, rate_date FROM public.acc_exchange_rate ' +
            '   ORDER BY currency, rate_date DESC, id DESC) r ' +
            ' ORDER BY CASE currency WHEN ''USD'' THEN 1 WHEN ''EUR'' THEN 2 WHEN ''GBP'' THEN 3 ELSE 9 END, currency', 'FxRates');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('rate').AsCurrency);
      if Q.FieldByName('rate_date').AsDateTime > Result.RefDate then
        Result.RefDate := Q.FieldByName('rate_date').AsDateTime;
      Inc(Result.Count);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  if (Result.Count > 0) and (Result.RefDate < Date) then
    Result.Level := dlWarning;
end;

// Aktif kasa (1) / banka (2) hesaplarının para birimi bazında bakiyesi; eksi bakiye kırmızı
function TSysDashboardRepository.MoneyBalance(AAccountKind: Integer; const AKey: string): TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(AKey);
  Q := Open(Format('SELECT currency, sum(balance) AS amount, count(*) AS cnt FROM public.vw_fin_money_account ' +
                   ' WHERE account_kind = %d AND is_active GROUP BY currency ORDER BY currency', [AAccountKind]), 'MoneyBalance');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      if Q.FieldByName('amount').AsCurrency < 0 then
        Result.Level := dlDanger;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Bugünkü para hareketleri: tutar = girişler (tahsilat / faiz / diğer giriş), Count = hareket sayısı
function TSysDashboardRepository.MoneyToday: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_MONEY_TODAY);
  Q := Open('SELECT m.currency, COALESCE(sum(t.amount) FILTER (WHERE t.transaction_type IN (1, 5, 6)), 0) AS amount, ' +
            '       count(*) AS cnt, count(*) FILTER (WHERE t.transaction_type = 1) AS collections ' +
            '  FROM public.fin_money_transaction t JOIN public.fin_money_account m ON m.id = t.fin_money_account_id ' +
            ' WHERE t.transaction_date = CURRENT_DATE GROUP BY m.currency ORDER BY m.currency', 'MoneyToday');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Inc(Result.Count2, Q.FieldByName('collections').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Açık çek / senetler: Count = belge, Count2 = 7 gün içinde vadesi gelen (gecikmiş dahil); gecikmiş varsa kırmızı
function TSysDashboardRepository.ChequeNotes(ADirection: Integer; const AStatuses, AKey: string): TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(AKey);
  Q := Open(Format('SELECT currency, sum(amount) AS amount, count(*) AS cnt, ' +
                   '       count(*) FILTER (WHERE due_date <= CURRENT_DATE + 7) AS due7, ' +
                   '       count(*) FILTER (WHERE due_date < CURRENT_DATE) AS overdue ' +
                   '  FROM public.fin_cheque_note WHERE direction = %d AND status IN (%s) ' +
                   ' GROUP BY currency ORDER BY currency', [ADirection, AStatuses]), 'ChequeNotes');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Inc(Result.Count2, Q.FieldByName('due7').AsInteger);
      if Q.FieldByName('overdue').AsInteger > 0 then
        Result.Level := dlDanger
      else if (Q.FieldByName('due7').AsInteger > 0) and (Result.Level < dlWarning) then
        Result.Level := dlWarning;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Bu ayki POS tahsilatları (net; iadeler düşülür)
function TSysDashboardRepository.PosMonth: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_POS_MONTH);
  Q := Open('SELECT p.currency, sum(CASE WHEN t.transaction_type = 1 THEN t.net_amount ELSE -t.net_amount END) AS amount, count(*) AS cnt ' +
            '  FROM public.fin_pos_transaction t JOIN public.fin_pos_terminal p ON p.id = t.fin_pos_terminal_id ' +
            ' WHERE ' + MonthFilter('t.transaction_date') + ' GROUP BY p.currency ORDER BY p.currency', 'PosMonth');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Aktif firma kredi kartlarının borcu; Count2 = kullanılabilir limiti %10'un altına inen kart
function TSysDashboardRepository.CardDebt: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_CARD_DEBT);
  Q := Open('SELECT currency, sum(balance) AS amount, count(*) AS cnt, ' +
            '       count(*) FILTER (WHERE card_limit > 0 AND available_limit < card_limit * 0.1) AS near_limit ' +
            '  FROM public.vw_fin_credit_card WHERE is_active GROUP BY currency ORDER BY currency', 'CardDebt');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Inc(Result.Count2, Q.FieldByName('near_limit').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  if Result.Count2 > 0 then
    Result.Level := dlWarning;
end;

// Talepler: Count = taslak, Count2 = onaylı (siparişe dönüştürülmeyi bekleyen)
function TSysDashboardRepository.PurRequests: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_PUR_REQUESTS);
  Q := Open('SELECT count(*) FILTER (WHERE status = 1) AS drafts, count(*) FILTER (WHERE status = 2) AS approved ' +
            '  FROM public.pur_request', 'PurRequests');
  try
    Result.Count := Q.FieldByName('drafts').AsInteger;
    Result.Count2 := Q.FieldByName('approved').AsInteger;
  finally
    Q.Free;
  end;
  if Result.Count2 > 0 then
    Result.Level := dlInfo;
end;

// Açık siparişler (onaylı / kısmi teslim); Count2 = teslim tarihi geçmiş
function TSysDashboardRepository.PurOrdersOpen: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_PUR_ORDERS_OPEN);
  Q := Open('SELECT currency, sum(total_amount) AS amount, count(*) AS cnt, ' +
            '       count(*) FILTER (WHERE delivery_date < CURRENT_DATE) AS late ' +
            '  FROM public.pur_order WHERE status IN (2, 3) GROUP BY currency ORDER BY currency', 'PurOrdersOpen');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Inc(Result.Count2, Q.FieldByName('late').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  if Result.Count2 > 0 then
    Result.Level := dlWarning;
end;

// Bu ay açılan siparişler (iptaller hariç)
function TSysDashboardRepository.PurOrdersMonth: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_PUR_ORDERS_MONTH);
  Q := Open('SELECT currency, sum(total_amount) AS amount, count(*) AS cnt FROM public.pur_order ' +
            ' WHERE status <> 5 AND ' + MonthFilter('order_date') + ' GROUP BY currency ORDER BY currency', 'PurOrdersMonth');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Mal kabuller: Count = bu ay, Count2 = bugün
function TSysDashboardRepository.PurReceiptsMonth: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_PUR_RECEIPTS_MONTH);
  Q := Open('SELECT count(*) FILTER (WHERE ' + MonthFilter('receipt_date') + ') AS month_cnt, ' +
            '       count(*) FILTER (WHERE receipt_date = CURRENT_DATE) AS today_cnt FROM public.pur_receipt', 'PurReceiptsMonth');
  try
    Result.Count := Q.FieldByName('month_cnt').AsInteger;
    Result.Count2 := Q.FieldByName('today_cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

// Bu ayki alış faturaları; Count2 = 7 gün içinde vadesi gelen (tüm faturalar)
function TSysDashboardRepository.PurInvoicesMonth: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_PUR_INVOICES_MONTH);
  Q := Open('SELECT currency, sum(total_amount) AS amount, count(*) AS cnt FROM public.pur_invoice ' +
            ' WHERE ' + MonthFilter('invoice_date') + ' GROUP BY currency ORDER BY currency', 'PurInvoicesMonth');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  Q := Open('SELECT count(*) AS cnt FROM public.pur_invoice WHERE due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 7', 'PurInvoicesDue');
  try
    Result.Count2 := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
  if Result.Count2 > 0 then
    Result.Level := dlInfo;
end;

// Satış teklif / siparişleri (eski tablolar; yalnız sayım + genel toplam): bu ay
function TSysDashboardRepository.SalesDocsMonth(const ATable, ADateColumn, AKey: string): TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(AKey);
  Q := Open(Format('SELECT COALESCE(currency_code, '''') AS currency, COALESCE(sum(grand_total), 0) AS amount, count(*) AS cnt ' +
                   '  FROM public.%s WHERE %s GROUP BY 1 ORDER BY 1', [ATable, MonthFilter(ADateColumn)]), 'SalesDocsMonth');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Kritik stok: Count = minimumun altında, Count2 = eksi stok
function TSysDashboardRepository.StockCritical: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_STOCK_CRITICAL);
  Q := Open('SELECT count(*) FILTER (WHERE i.min_stock_amount > 0 AND COALESCE(s.current_quantity, 0) < i.min_stock_amount) AS below_min, ' +
            '       count(*) FILTER (WHERE COALESCE(s.current_quantity, 0) < 0) AS negative ' +
            '  FROM public.stk_inventory i LEFT JOIN public.stk_inventory_summary s ON s.stk_inventory_id = i.id', 'StockCritical');
  try
    Result.Count := Q.FieldByName('below_min').AsInteger;
    Result.Count2 := Q.FieldByName('negative').AsInteger;
  finally
    Q.Free;
  end;
  if Result.Count2 > 0 then
    Result.Level := dlDanger
  else if Result.Count > 0 then
    Result.Level := dlWarning;
end;

// Stok hareketleri: Count = bugün, Count2 = bu ay
function TSysDashboardRepository.StockTxToday: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_STOCK_TX_TODAY);
  Q := Open('SELECT count(*) FILTER (WHERE transaction_date = CURRENT_DATE) AS today_cnt, ' +
            '       count(*) FILTER (WHERE ' + MonthFilter('transaction_date') + ') AS month_cnt FROM public.stk_transaction', 'StockTxToday');
  try
    Result.Count := Q.FieldByName('today_cnt').AsInteger;
    Result.Count2 := Q.FieldByName('month_cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

// Stok kartı sayısı; Count2 = satılabilir
function TSysDashboardRepository.StockCards: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_STOCK_CARDS);
  Q := Open('SELECT count(*) AS cnt, count(*) FILTER (WHERE sellable) AS sellable FROM public.stk_inventory', 'StockCards');
  try
    Result.Count := Q.FieldByName('cnt').AsInteger;
    Result.Count2 := Q.FieldByName('sellable').AsInteger;
  finally
    Q.Free;
  end;
end;

// Cari bakiyeler (cari hareketlerinden, cari + para birimi bazında): alacaklarımız (borçlu cariler) / borçlarımız
procedure TSysDashboardRepository.AccountBalances(out AReceivable, APayable: TDashboardKpi);
var
  Q: TFDQuery;
begin
  AReceivable := TDashboardKpi.New(KPI_ACC_RECEIVABLE);
  APayable := TDashboardKpi.New(KPI_ACC_PAYABLE);
  Q := Open('WITH b AS (SELECT acc_account_id, currency, sum(debit - credit) AS bal ' +
            '             FROM public.vw_acc_account_transaction GROUP BY acc_account_id, currency) ' +
            'SELECT currency, COALESCE(sum(bal) FILTER (WHERE bal > 0), 0) AS receivable, ' +
            '       COALESCE(-sum(bal) FILTER (WHERE bal < 0), 0) AS payable, ' +
            '       count(*) FILTER (WHERE bal > 0) AS rcv_cnt, count(*) FILTER (WHERE bal < 0) AS pay_cnt ' +
            '  FROM b GROUP BY currency ORDER BY currency', 'AccountBalances');
  try
    while not Q.Eof do
    begin
      if Q.FieldByName('rcv_cnt').AsInteger > 0 then
        AddAmount(AReceivable, Q.FieldByName('currency').AsString, Q.FieldByName('receivable').AsCurrency);
      if Q.FieldByName('pay_cnt').AsInteger > 0 then
        AddAmount(APayable, Q.FieldByName('currency').AsString, Q.FieldByName('payable').AsCurrency);
      Inc(AReceivable.Count, Q.FieldByName('rcv_cnt').AsInteger);
      Inc(APayable.Count, Q.FieldByName('pay_cnt').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Cari kartlar: Count = aktif, Count2 = pasif
function TSysDashboardRepository.Accounts: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_ACCOUNTS);
  Q := Open('SELECT count(*) FILTER (WHERE NOT is_passive) AS active_cnt, count(*) FILTER (WHERE is_passive) AS passive_cnt ' +
            '  FROM public.acc_account', 'Accounts');
  try
    Result.Count := Q.FieldByName('active_cnt').AsInteger;
    Result.Count2 := Q.FieldByName('passive_cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

// Personel: Count = aktif, Count2 = toplam
function TSysDashboardRepository.Employees: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_EMPLOYEES);
  Q := Open('SELECT count(*) FILTER (WHERE active) AS active_cnt, count(*) AS cnt FROM public.emp_employee', 'Employees');
  try
    Result.Count := Q.FieldByName('active_cnt').AsInteger;
    Result.Count2 := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

// Kullanıcılar: Count = aktif, Count2 = toplam
function TSysDashboardRepository.Users: TDashboardKpi;
var
  Q: TFDQuery;
begin
  Result := TDashboardKpi.New(KPI_USERS);
  Q := Open('SELECT count(*) FILTER (WHERE active) AS active_cnt, count(*) AS cnt FROM public.sys_user', 'Users');
  try
    Result.Count := Q.FieldByName('active_cnt').AsInteger;
    Result.Count2 := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

end.
