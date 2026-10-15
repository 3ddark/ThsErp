unit SysDashboard.Repository;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Math, System.Generics.Collections, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Logger, SysDashboard;

type
  // Ana ekran göstergeleri: yalnız okuma, toplama sorguları (tarihler sunucunun CURRENT_DATE'i ile)
  TSysDashboardRepository = class
  private
    FConnection: TFDConnection;
    function Open(const ASql, AOperation: string): TFDQuery;
    procedure AddAmount(var AKpi: TDashboardKpi; const ACurrency: string; AAmount: Currency);
    function MonthFilter(const AColumn: string): string;
    function ReadPoints(const ASql, AOperation: string): TArray<TDashboardPoint>;
    function DailyCounts(const ATable, ADateColumn: string): TArray<TDashboardPoint>;
    function DefaultCurrency: string;
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

    // Genel bakış grafikleri
    function ChartMoneyFlow: TDashboardChart;
    function ChartChequeDue: TDashboardChart;
    function ChartStockFlow: TDashboardChart;
    function ChartFxTrend: TDashboardChart;
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

// Sorgu kolonları: day (date), v1, v2 (sayısal; NULL = 0)
function TSysDashboardRepository.ReadPoints(const ASql, AOperation: string): TArray<TDashboardPoint>;
var
  Q: TFDQuery;
  P: TDashboardPoint;
begin
  Result := [];
  Q := Open(ASql, AOperation);
  try
    while not Q.Eof do
    begin
      P.Day := Q.FieldByName('day').AsDateTime;
      P.Value := Q.FieldByName('v1').AsFloat;
      P.Value2 := Q.FieldByName('v2').AsFloat;
      Result := Result + [P];
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

// Son DASHBOARD_TREND_DAYS günün günlük kayıt sayısı (kart içi küçük grafik)
function TSysDashboardRepository.DailyCounts(const ATable, ADateColumn: string): TArray<TDashboardPoint>;
begin
  Result := ReadPoints(Format(
    'SELECT d::date AS day, count(t.%1:s) AS v1, 0 AS v2 ' +
    '  FROM generate_series(CURRENT_DATE - %2:d, CURRENT_DATE, interval ''1 day'') d ' +
    '  LEFT JOIN public.%0:s t ON t.%1:s = d::date GROUP BY 1 ORDER BY 1',
    [ATable, ADateColumn, DASHBOARD_TREND_DAYS - 1]), 'DailyCounts');
end;

function TSysDashboardRepository.DefaultCurrency: string;
var
  Q: TFDQuery;
begin
  Q := Open('SELECT public.fn_default_currency() AS currency', 'DefaultCurrency');
  try
    Result := Q.FieldByName('currency').AsString;
  finally
    Q.Free;
  end;
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
  // kart içi grafik: ilk para biriminin (USD) son kurları
  if Result.Count > 0 then
    Result.Trend := ReadPoints(Format(
      'SELECT day, v1, 0 AS v2 FROM (SELECT rate_date AS day, rate AS v1 FROM public.acc_exchange_rate ' +
      ' WHERE currency = %s ORDER BY rate_date DESC, id DESC LIMIT %d) r ORDER BY day',
      [QuotedStr(Result.Amounts[0].Currency), DASHBOARD_TREND_DAYS]), 'FxTrend');
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
  Result.Trend := DailyCounts('fin_money_transaction', 'transaction_date');
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
  Result.Ratio := DashboardRatio(Result.Count2, Result.Count);
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
            '       count(*) FILTER (WHERE card_limit > 0 AND available_limit < card_limit * 0.1) AS near_limit, ' +
            '       avg(LEAST(GREATEST(balance, 0) / card_limit, 1)) FILTER (WHERE card_limit > 0) AS usage ' +
            '  FROM public.vw_fin_credit_card WHERE is_active GROUP BY currency ORDER BY currency', 'CardDebt');
  try
    while not Q.Eof do
    begin
      AddAmount(Result, Q.FieldByName('currency').AsString, Q.FieldByName('amount').AsCurrency);
      Inc(Result.Count, Q.FieldByName('cnt').AsInteger);
      Inc(Result.Count2, Q.FieldByName('near_limit').AsInteger);
      // limit kullanım oranı: kartların ortalaması (para birimi gruplarının en yükseği)
      if not Q.FieldByName('usage').IsNull then
        Result.Ratio := Max(Result.Ratio, Q.FieldByName('usage').AsFloat);
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
  Result.Ratio := DashboardRatio(Result.Count2, Result.Count + Result.Count2);
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
  Result.Ratio := DashboardRatio(Result.Count2, Result.Count);
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

// Satış teklif / siparişleri: bu ay (sls_order iptal = 5, sls_offer reddedildi = 3 hariç)
function TSysDashboardRepository.SalesDocsMonth(const ATable, ADateColumn, AKey: string): TDashboardKpi;
var
  Q: TFDQuery;
  LExcluded: Integer;
begin
  Result := TDashboardKpi.New(AKey);
  if ATable = 'sls_offer' then
    LExcluded := 3
  else
    LExcluded := 5;
  Q := Open(Format('SELECT currency, COALESCE(sum(total_amount), 0) AS amount, count(*) AS cnt ' +
                   '  FROM public.%s WHERE status <> %d AND %s GROUP BY 1 ORDER BY 1', [ATable, LExcluded, MonthFilter(ADateColumn)]), 'SalesDocsMonth');
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
            '       count(*) FILTER (WHERE COALESCE(s.current_quantity, 0) < 0) AS negative, count(*) AS total ' +
            '  FROM public.stk_inventory i LEFT JOIN public.stk_inventory_summary s ON s.stk_inventory_id = i.id', 'StockCritical');
  try
    Result.Count := Q.FieldByName('below_min').AsInteger;
    Result.Count2 := Q.FieldByName('negative').AsInteger;
    Result.Ratio := DashboardRatio(Result.Count, Q.FieldByName('total').AsInteger);
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
  Result.Trend := DailyCounts('stk_transaction', 'transaction_date');
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
    Result.Ratio := DashboardRatio(Result.Count, Result.Count + Result.Count2);
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
    Result.Ratio := DashboardRatio(Result.Count, Result.Count2);
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
    Result.Ratio := DashboardRatio(Result.Count, Result.Count2);
  finally
    Q.Free;
  end;
end;

// Son 14 gün: v1 = giriş (tahsilat / faiz / diğer giriş), v2 = çıkış (ödeme / masraf / diğer çıkış); virman hariç.
// Yalnız varsayılan para birimindeki kasa / banka hesapları (farklı para birimleri toplanmaz)
function TSysDashboardRepository.ChartMoneyFlow: TDashboardChart;
begin
  Result := TDashboardChart.New(CHART_MONEY_FLOW);
  Result.Currency := DefaultCurrency;
  Result.Points := ReadPoints(Format(
    'SELECT d::date AS day, ' +
    '       COALESCE(sum(x.amount) FILTER (WHERE x.transaction_type IN (1, 5, 6)), 0) AS v1, ' +
    '       COALESCE(sum(x.amount) FILTER (WHERE x.transaction_type IN (2, 4, 7)), 0) AS v2 ' +
    '  FROM generate_series(CURRENT_DATE - %d, CURRENT_DATE, interval ''1 day'') d ' +
    '  LEFT JOIN (SELECT t.transaction_date, t.transaction_type, t.amount FROM public.fin_money_transaction t ' +
    '               JOIN public.fin_money_account m ON m.id = t.fin_money_account_id ' +
    '              WHERE m.currency = public.fn_default_currency()) x ON x.transaction_date = d::date ' +
    ' GROUP BY 1 ORDER BY 1', [DASHBOARD_TREND_DAYS - 1]), 'ChartMoneyFlow');
end;

// Önümüzdeki 8 hafta (pazartesi başlangıçlı): v1 = alınan (portföy / tahsil / teminat), v2 = verilen (tedavülde);
// vadesi geçmişler ilk haftaya eklenir. Yalnız varsayılan para birimi.
function TSysDashboardRepository.ChartChequeDue: TDashboardChart;
begin
  Result := TDashboardChart.New(CHART_CHEQUE_DUE);
  Result.Currency := DefaultCurrency;
  Result.Points := ReadPoints(
    'SELECT w::date AS day, ' +
    '       COALESCE(sum(c.amount) FILTER (WHERE c.direction = 1 AND c.status IN (1, 3, 4)), 0) AS v1, ' +
    '       COALESCE(sum(c.amount) FILTER (WHERE c.direction = 2 AND c.status = 9), 0) AS v2 ' +
    '  FROM generate_series(date_trunc(''week'', CURRENT_DATE), date_trunc(''week'', CURRENT_DATE) + interval ''7 weeks'', interval ''1 week'') w ' +
    '  LEFT JOIN public.fin_cheque_note c ON c.currency = public.fn_default_currency() ' +
    '       AND c.due_date < w::date + 7 ' +
    '       AND (c.due_date >= w::date OR w::date = date_trunc(''week'', CURRENT_DATE)::date) ' +
    ' GROUP BY 1 ORDER BY 1', 'ChartChequeDue');
end;

// Son 14 gün stok hareket sayısı: v1 = giriş, v2 = çıkış (transfer hariç)
function TSysDashboardRepository.ChartStockFlow: TDashboardChart;
begin
  Result := TDashboardChart.New(CHART_STOCK_FLOW);
  Result.Points := ReadPoints(Format(
    'SELECT d::date AS day, count(t.id) FILTER (WHERE t.transaction_type = 1) AS v1, ' +
    '       count(t.id) FILTER (WHERE t.transaction_type = 2) AS v2 ' +
    '  FROM generate_series(CURRENT_DATE - %d, CURRENT_DATE, interval ''1 day'') d ' +
    '  LEFT JOIN public.stk_transaction t ON t.transaction_date = d::date GROUP BY 1 ORDER BY 1',
    [DASHBOARD_TREND_DAYS - 1]), 'ChartStockFlow');
end;

// Son 30 kur günü: v1 = USD, v2 = EUR (o gün kaydı yoksa 0 -> çizgide atlanır)
function TSysDashboardRepository.ChartFxTrend: TDashboardChart;
begin
  Result := TDashboardChart.New(CHART_FX_TREND);
  Result.Points := ReadPoints(
    'WITH d AS (SELECT DISTINCT rate_date FROM public.acc_exchange_rate WHERE currency IN (''USD'', ''EUR'') ' +
    '            ORDER BY rate_date DESC LIMIT 30) ' +
    'SELECT d.rate_date AS day, ' +
    '       (SELECT r.rate FROM public.acc_exchange_rate r WHERE r.currency = ''USD'' AND r.rate_date = d.rate_date ORDER BY r.id DESC LIMIT 1) AS v1, ' +
    '       (SELECT r.rate FROM public.acc_exchange_rate r WHERE r.currency = ''EUR'' AND r.rate_date = d.rate_date ORDER BY r.id DESC LIMIT 1) AS v2 ' +
    '  FROM d ORDER BY 1', 'ChartFxTrend');
end;

end.
