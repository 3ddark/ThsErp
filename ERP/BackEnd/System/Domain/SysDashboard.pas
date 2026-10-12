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

type
  // Kartın vurgu seviyesi (sol şerit rengi)
  TDashboardLevel = (dlNormal, dlInfo, dlWarning, dlDanger);

  TDashboardAmount = record
    Currency: string;
    Amount: Currency;
  end;

  // Tek gösterge: sayılar + para birimi bazında tutarlar; metne çevirme formda (dil)
  TDashboardKpi = record
    Key: string;
    Count: Integer;
    Count2: Integer;
    Amounts: TArray<TDashboardAmount>;
    RefDate: TDate;
    Level: TDashboardLevel;
    class function New(const AKey: string): TDashboardKpi; static;
  end;

implementation

class function TDashboardKpi.New(const AKey: string): TDashboardKpi;
begin
  Result.Key := AKey;
  Result.Count := 0;
  Result.Count2 := 0;
  Result.Amounts := [];
  Result.RefDate := 0;
  Result.Level := dlNormal;
end;

end.
