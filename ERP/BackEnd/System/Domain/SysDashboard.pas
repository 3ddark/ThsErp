unit SysDashboard;

interface

{$I Ths.inc}

uses
  System.SysUtils;

const
  // Gösterge anahtarları (ana ekran kartları; başlık / biçim / açılacak ekran formda)
  KPI_FX_RATES           = 'fx_rates';
  KPI_CASH_BALANCE       = 'cash_balance';
  KPI_BANK_BALANCE       = 'bank_balance';
  KPI_MONEY_TODAY        = 'money_today';
  KPI_CHEQUES_RECEIVABLE = 'cheques_receivable';
  KPI_CHEQUES_PAYABLE    = 'cheques_payable';
  KPI_POS_MONTH          = 'pos_month';
  KPI_CARD_DEBT          = 'card_debt';
  KPI_PUR_REQUESTS       = 'pur_requests';
  KPI_PUR_ORDERS_OPEN    = 'pur_orders_open';
  KPI_PUR_ORDERS_MONTH   = 'pur_orders_month';
  KPI_PUR_RECEIPTS_MONTH = 'pur_receipts_month';
  KPI_PUR_INVOICES_MONTH = 'pur_invoices_month';
  KPI_SLS_ORDERS_MONTH   = 'sls_orders_month';
  KPI_SLS_OFFERS_MONTH   = 'sls_offers_month';
  KPI_STOCK_CRITICAL     = 'stock_critical';
  KPI_STOCK_TX_TODAY     = 'stock_tx_today';
  KPI_STOCK_CARDS        = 'stock_cards';
  KPI_ACC_RECEIVABLE     = 'acc_receivable';
  KPI_ACC_PAYABLE        = 'acc_payable';
  KPI_ACCOUNTS           = 'accounts';
  KPI_EMPLOYEES          = 'employees';
  KPI_USERS              = 'users';

  // Grafik anahtarları (ana ekran "Genel Bakış" satırı)
  CHART_MONEY_FLOW = 'money_flow';   // son 14 gün para girişi / çıkışı (varsayılan para birimi)
  CHART_CHEQUE_DUE = 'cheque_due';   // önümüzdeki 8 hafta çek / senet vadeleri (alınan / verilen)
  CHART_STOCK_FLOW = 'stock_flow';   // son 14 gün stok giriş / çıkış hareket sayısı
  CHART_FX_TREND   = 'fx_trend';     // son 30 kur kaydı (USD / EUR)

  DASHBOARD_TREND_DAYS = 14;

type
  // Kartın vurgu seviyesi (sol şerit rengi)
  TDashboardLevel = (dlNormal, dlInfo, dlWarning, dlDanger);

  TDashboardAmount = record
    Currency: string;
    Amount: Currency;
  end;

  // Grafik noktası: Value = 1. seri, Value2 = 2. seri (yoksa 0)
  TDashboardPoint = record
    Day: TDate;
    Value: Double;
    Value2: Double;
  end;

  // Tek gösterge: sayılar + para birimi bazında tutarlar; metne çevirme formda (dil)
  TDashboardKpi = record
    Key: string;
    Count: Integer;
    Count2: Integer;
    Amounts: TArray<TDashboardAmount>;
    RefDate: TDate;
    Level: TDashboardLevel;
    Ratio: Double;                      // 0..1 doluluk çubuğu; < 0 = çubuk yok
    Trend: TArray<TDashboardPoint>;     // kart içi küçük grafik (eskiden yeniye); boş = yok
    class function New(const AKey: string): TDashboardKpi; static;
  end;

  // Genel bakış grafiği: noktalar eskiden yeniye; Currency boş = adet
  TDashboardChart = record
    Key: string;
    Currency: string;
    Points: TArray<TDashboardPoint>;
    class function New(const AKey: string): TDashboardChart; static;
    function HasData: Boolean;
  end;

// Count / Total oranı (Total <= 0 ise çubuk yok)
function DashboardRatio(ACount, ATotal: Double): Double;

implementation

class function TDashboardKpi.New(const AKey: string): TDashboardKpi;
begin
  Result.Key := AKey;
  Result.Count := 0;
  Result.Count2 := 0;
  Result.Amounts := [];
  Result.RefDate := 0;
  Result.Level := dlNormal;
  Result.Ratio := -1;
  Result.Trend := [];
end;

class function TDashboardChart.New(const AKey: string): TDashboardChart;
begin
  Result.Key := AKey;
  Result.Currency := '';
  Result.Points := [];
end;

function TDashboardChart.HasData: Boolean;
var
  P: TDashboardPoint;
begin
  for P in Points do
    if (P.Value <> 0) or (P.Value2 <> 0) then
      Exit(True);
  Result := False;
end;

function DashboardRatio(ACount, ATotal: Double): Double;
begin
  if ATotal <= 0 then
    Result := -1
  else if ACount <= 0 then
    Result := 0
  else if ACount >= ATotal then
    Result := 1
  else
    Result := ACount / ATotal;
end;

end.
