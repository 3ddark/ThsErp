unit SysDashboard.Service;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, UnitOfWork, AppContext, Logger,
  SysDashboard, SysDashboard.Repository;

type
  // Ana ekran özet göstergeleri. Yalnız kullanıcının OKUMA yetkisi olan modüllerin göstergeleri hesaplanır
  // (yetkisiz veri sorgulanmaz bile); super user hepsini görür. Bir göstergenin hatası diğerlerini engellemez.
  TSysDashboardService = class
  private
    FRepo: TSysDashboardRepository;
    FSuperUser: Boolean;
    FReadable: TArray<Integer>;
    function CanRead(APermissionCode: Integer): Boolean;
    procedure LoadPermissions;
  public
    constructor Create;
    destructor Destroy; override;
    function GetKpis: TArray<TDashboardKpi>;
  end;

implementation

uses
  SysPermission.Service, SysAccessRight.Service;

constructor TSysDashboardService.Create;
begin
  inherited Create;
  FRepo := TSysDashboardRepository.Create(TUnitOfWork.Instance.Connection);
end;

destructor TSysDashboardService.Destroy;
begin
  FRepo.Free;
  inherited;
end;

procedure TSysDashboardService.LoadPermissions;
var
  LSvc: TSysAccessRightService;
begin
  FReadable := [];
  FSuperUser := Assigned(TAppContext.Instance.CurrentUser) and TAppContext.Instance.CurrentUser.IsSuperUser;
  if FSuperUser then
    Exit;

  LSvc := TSysAccessRightService.Create;
  try
    FReadable := LSvc.GetReadablePermissionCodes;
  finally
    LSvc.Free;
  end;
end;

function TSysDashboardService.CanRead(APermissionCode: Integer): Boolean;
var
  LCode: Integer;
begin
  if FSuperUser then
    Exit(True);
  for LCode in FReadable do
    if LCode = APermissionCode then
      Exit(True);
  Result := False;
end;

function TSysDashboardService.GetKpis: TArray<TDashboardKpi>;
var
  LList: TList<TDashboardKpi>;
  LReceivable, LPayable: TDashboardKpi;

  procedure Add(APermissionCode: Integer; AGetter: TFunc<TDashboardKpi>);
  begin
    if not CanRead(APermissionCode) then
      Exit;
    try
      LList.Add(AGetter());
    except
      on E: Exception do
        GLogger.ErrorFmt('Dashboard göstergesi okunamadı (%d): %s', [APermissionCode, E.Message]);
    end;
  end;

begin
  LoadPermissions;
  LList := TList<TDashboardKpi>.Create;
  try
    // Finans
    Add(PERMISSION_ACC_EXCHANGE_RATE, function: TDashboardKpi begin Result := FRepo.FxRates; end);
    Add(PERMISSION_FIN_MONEY_ACCOUNT, function: TDashboardKpi begin Result := FRepo.MoneyBalance(1, KPI_CASH_BALANCE); end);
    Add(PERMISSION_FIN_MONEY_ACCOUNT, function: TDashboardKpi begin Result := FRepo.MoneyBalance(2, KPI_BANK_BALANCE); end);
    Add(PERMISSION_FIN_MONEY_TRANSACTION, function: TDashboardKpi begin Result := FRepo.MoneyToday; end);
    // alınan: portföyde / tahsilde / teminatta, verilen: tedavülde
    Add(PERMISSION_FIN_CHEQUE_NOTE, function: TDashboardKpi begin Result := FRepo.ChequeNotes(1, '1, 3, 4', KPI_CHEQUES_RECEIVABLE); end);
    Add(PERMISSION_FIN_CHEQUE_NOTE, function: TDashboardKpi begin Result := FRepo.ChequeNotes(2, '9', KPI_CHEQUES_PAYABLE); end);
    Add(PERMISSION_FIN_POS_TERMINAL, function: TDashboardKpi begin Result := FRepo.PosMonth; end);
    Add(PERMISSION_FIN_CREDIT_CARD, function: TDashboardKpi begin Result := FRepo.CardDebt; end);

    // Satın alma
    Add(PERMISSION_PUR_REQUEST, function: TDashboardKpi begin Result := FRepo.PurRequests; end);
    Add(PERMISSION_PUR_ORDER, function: TDashboardKpi begin Result := FRepo.PurOrdersOpen; end);
    Add(PERMISSION_PUR_ORDER, function: TDashboardKpi begin Result := FRepo.PurOrdersMonth; end);
    Add(PERMISSION_PUR_RECEIPT, function: TDashboardKpi begin Result := FRepo.PurReceiptsMonth; end);
    Add(PERMISSION_PUR_INVOICE, function: TDashboardKpi begin Result := FRepo.PurInvoicesMonth; end);

    // Satış
    Add(PERMISSION_SLS_ORDER, function: TDashboardKpi begin Result := FRepo.SalesDocsMonth('sls_order', 'order_date', KPI_SLS_ORDERS_MONTH); end);
    Add(PERMISSION_SLS_OFFER, function: TDashboardKpi begin Result := FRepo.SalesDocsMonth('sls_offer', 'offer_date', KPI_SLS_OFFERS_MONTH); end);

    // Stok
    Add(PERMISSION_STK_INVENTORY_SUMMARY, function: TDashboardKpi begin Result := FRepo.StockCritical; end);
    Add(PERMISSION_STK_TRANSACTION, function: TDashboardKpi begin Result := FRepo.StockTxToday; end);
    Add(PERMISSION_STK_INVENTORY, function: TDashboardKpi begin Result := FRepo.StockCards; end);

    // Cari
    if CanRead(PERMISSION_ACC_ACCOUNT_TRANSACTION) then
      try
        FRepo.AccountBalances(LReceivable, LPayable);
        LList.Add(LReceivable);
        LList.Add(LPayable);
      except
        on E: Exception do
          GLogger.ErrorFmt('Dashboard cari bakiyeleri okunamadı: %s', [E.Message]);
      end;
    Add(PERMISSION_ACC_ACCOUNT, function: TDashboardKpi begin Result := FRepo.Accounts; end);

    // Genel
    Add(PERMISSION_EMP_EMPLOYEE, function: TDashboardKpi begin Result := FRepo.Employees; end);
    Add(PERMISSION_SYS_USER, function: TDashboardKpi begin Result := FRepo.Users; end);

    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

end.
