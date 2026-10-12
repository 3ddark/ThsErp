unit PurOrder.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurOrder.Repository, PurOrder, PurOrder.Exception, PurOrderDetail, PurOrderDetail.Repository, PurRequest, PurRequest.Repository;

type
  TPurOrderService = class(TCrudService<TPurOrder>)
  private
    FRepo: IRepository<TPurOrder>;
    FDetailRepo: IRepository<TPurOrderDetail>;
    FRequestRepo: IRepository<TPurRequest>;

    procedure DoAdd(AEntity: TPurOrder);
    procedure DoUpdate(AEntity: TPurOrder);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurOrder; AOperation: TCrudOperation); override;
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
    // Onaylı talebin kalan miktarlarından taslak sipariş; yeni sipariş id
    function CreateFromRequest(ARequestId, AAccountId: Int64; APermissionControl: Boolean): Int64;
    procedure RefreshRequests(AOrderId: Int64);

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurOrder>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurOrder; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurOrder; override;

    procedure Add(AEntity: TPurOrder); override;
    procedure Update(AEntity: TPurOrder); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurOrder; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurOrder>; override;
    procedure BusinessInsert(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, PurOrderDetail.Service, PurRequestDetail, PurRequestDetail.Repository;

constructor TPurOrderService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurOrder, TPurOrderRepository>;
  FDetailRepo := Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>;
  FRequestRepo := Self.UoW.GetRepository<TPurRequest, TPurRequestRepository>;
  Self.PermissionCode := PERMISSION_PUR_ORDER;
end;

destructor TPurOrderService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TPurOrderService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Elle durum değişikliği (onay / taslağa alma / red / iptal / kapama); kendi açtığı transaction'ı commit eder
procedure TPurOrderService.ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
var
  LOld: TPurOrder;
  LStarted: Boolean;
begin
  LStarted := False;
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);
    if not Self.UoW.InTransaction then
    begin
      Self.UoW.BeginTransaction;
      LStarted := True;
    end;

    LOld := FRepo.FindById(AId, True);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));
      if not TPurLookup.CanChangeOrderStatus(LOld.Status, ANewStatus) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPurOrder.InvalidStatus,
          'Status cannot be changed from "%s" to "%s".'), [TPurLookup.Text(plkOrderStatus, LOld.Status), TPurLookup.Text(plkOrderStatus, ANewStatus)]));
      if (ANewStatus = PUR_ORD_APPROVED) and (TPurOrderRepository(FRepo).LineCount(AId) = 0) then
        raise EPurOrderExceptionNoLines.Create;
      if (ANewStatus in [PUR_ORD_DRAFT, PUR_ORD_CANCELLED]) and (TPurOrderRepository(FRepo).ReceiptCount(AId) > 0) then
        raise EPurOrderExceptionHasReceipts.Create;
      TPurOrderRepository(FRepo).SetStatus(AId, ANewStatus);
      // iptal / yeniden açma talep kalemlerinin sipariş edilen miktarını değiştirir
      RefreshRequests(AId);
    finally
      LOld.Free;
    end;

    if LStarted and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPurOrderService.RefreshRequests(AOrderId: Int64);
var
  LId: Int64;
begin
  for LId in TPurOrderRepository(FRepo).RequestIdsOfOrder(AOrderId) do
    TPurRequestRepository(FRequestRepo).RefreshOrderedQuantities(LId);
end;

function TPurOrderService.CreateFromRequest(ARequestId, AAccountId: Int64; APermissionControl: Boolean): Int64;
var
  LRequest: TPurRequest;
  LOrder: TPurOrder;
  LLines: TList<TPurRequestDetail>;
  LLine: TPurRequestDetail;
  LDetail: TPurOrderDetail;
  LDetailSvc: TPurOrderDetailService;
  LFilter: TFilterCriteria;
  LStarted: Boolean;
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
  LCount: Integer;
begin
  LStarted := False;
  LDetailSvc := TPurOrderDetailService.Create;
  try
    try
      Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
      if not Self.UoW.InTransaction then
      begin
        Self.UoW.BeginTransaction;
        LStarted := True;
      end;

      LRequest := FRequestRepo.FindById(ARequestId, True);
      try
        if not Assigned(LRequest) then
          raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ARequestId]));
        if LRequest.Status <> PUR_REQ_APPROVED then
          raise EPurOrderExceptionRequestNotApproved.Create;

        LOrder := TPurOrder.Create;
        try
          LOrder.OrderDate := Date;
          LOrder.AccAccountId := AAccountId;
          LOrder.Description := LRequest.RequestNo;
          DoAdd(LOrder);
          Result := LOrder.Id;

          LCount := 0;
          LFilter := TFilterCriteria.Create;
          try
            LFilter.Add(TFilterCriterion.New('pur_request_id', '=', TValue.From<Int64>(ARequestId)));
            LLines := Self.UoW.GetRepository<TPurRequestDetail, TPurRequestDetailRepository>.Find(LFilter, False);
            try
              for LLine in LLines do
              begin
                if LLine.Quantity - LLine.OrderedQuantity <= 0 then
                  Continue;
                LDetail := TPurOrderDetail.Create;
                try
                  LDetail.PurOrderId := LOrder.Id;
                  LDetail.StkInventoryId := LLine.StkInventoryId;
                  LDetail.Quantity := LLine.Quantity - LLine.OrderedQuantity;
                  LDetail.DeliveryDate := LLine.RequiredDate;
                  LDetail.PurRequestDetailId := LLine.Id;
                  if TPurOrderDetailRepository(FDetailRepo).GetInventoryDefaults(LLine.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
                  begin
                    // fiyat yalnız sipariş para biriminde ise önerilir
                    if LCurrency = LOrder.Currency then
                      LDetail.UnitPrice := LPrice;
                    LDetail.DiscountRate := LDiscount;
                    LDetail.VatRate := LVat;
                  end;
                  LDetailSvc.Add(LDetail);
                  Inc(LCount);
                finally
                  LDetail.Free;
                end;
              end;
            finally
              LLines.Free;
            end;
          finally
            LFilter.Free;
          end;
          if LCount = 0 then
            raise EPurOrderExceptionNothingToOrder.Create;
        finally
          LOrder.Free;
        end;
      finally
        LRequest.Free;
      end;

      if LStarted and Self.UoW.InTransaction then
        Self.UoW.Commit;
    except
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  finally
    LDetailSvc.Free;
  end;
end;

procedure TPurOrderService.ValidateBusinessRules(AEntity: TPurOrder; AOperation: TCrudOperation);
var
  LRepo: TPurOrderRepository;
  LOld: TPurOrder;
  LFilter: TFilterCriteria;
  LModel: TPurOrder;
begin
  LRepo := TPurOrderRepository(FRepo);
  if AOperation = coDelete then
  begin
    if not (AEntity.Status in [PUR_ORD_DRAFT, PUR_ORD_CANCELLED]) then
      raise EPurOrderExceptionDeleteStatus.Create;
    if LRepo.ReceiptCount(AEntity.Id) > 0 then
      raise EPurOrderExceptionHasReceipts.Create;
    Exit;
  end;

  AEntity.OrderNo := AnsiUpperCase(Trim(AEntity.OrderNo));
  AEntity.SupplierRefNo := Trim(AEntity.SupplierRefNo);
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.OrderDate <= 0 then
    FailRequired(TLangKeys.TPurOrder.ColOrderDate, 'Order Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TPurOrder.ColAccAccountId, 'Supplier');
  if (AEntity.DeliveryDate > 0) and (AEntity.DeliveryDate < AEntity.OrderDate) then
    raise EPurOrderExceptionDeliveryDate.Create;
  if (AEntity.PaymentTermDays < 0) or (AEntity.PaymentTermDays > 365) then
    raise EPurOrderExceptionPaymentTerm.Create;
  if AEntity.ExchangeRate <= 0 then
    AEntity.ExchangeRate := 1;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    // durum ve tutarlar servis tarafından tutulur (tutarlar kalemlerden)
    AEntity.Status := PUR_ORD_DRAFT;
    AEntity.GrossAmount := 0;
    AEntity.DiscountAmount := 0;
    AEntity.NetAmount := 0;
    AEntity.VatAmount := 0;
    AEntity.TotalAmount := 0;
    if AEntity.OrderNo = '' then
      AEntity.OrderNo := LRepo.NextDocumentNo(PUR_PREFIX_ORDER);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if LOld.Status in [PUR_ORD_RECEIVED, PUR_ORD_CANCELLED] then
        raise EPurOrderExceptionNotEditable.Create;
      if (LRepo.ReceiptCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or (LOld.Currency <> AEntity.Currency)) then
        raise EPurOrderExceptionKeyFieldsLocked.Create;
      AEntity.Status := LOld.Status;
      AEntity.GrossAmount := LOld.GrossAmount;
      AEntity.DiscountAmount := LOld.DiscountAmount;
      AEntity.NetAmount := LOld.NetAmount;
      AEntity.VatAmount := LOld.VatAmount;
      AEntity.TotalAmount := LOld.TotalAmount;
      if AEntity.OrderNo = '' then
        AEntity.OrderNo := LOld.OrderNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('order_no', '=', TValue.From<string>(AEntity.OrderNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurOrderExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurOrderService.DoAdd(AEntity: TPurOrder);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurOrderService.DoUpdate(AEntity: TPurOrder);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPurOrderService.DoDelete(AId: Int64);
var
  LEntity: TPurOrder;
  LRequestIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler cascade silinir; bağlı talep kalemlerinin sipariş miktarı yenilenir
    LRequestIds := TPurOrderRepository(FRepo).RequestIdsOfOrder(AId);
    FRepo.Delete(LEntity);
    for LId in LRequestIds do
      TPurRequestRepository(FRequestRepo).RefreshOrderedQuantities(LId);
  finally
    LEntity.Free;
  end;
end;

function TPurOrderService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurOrder>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TPurOrderService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurOrder;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPurOrderService.BusinessInsert(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPurOrderService.BusinessUpdate(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPurOrderService.BusinessDelete(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TPurOrderService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPurOrderService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurOrder>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurOrderService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurOrder;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPurOrderService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurOrder;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurOrderService.Add(AEntity: TPurOrder);
begin
  DoAdd(AEntity);
end;

procedure TPurOrderService.Update(AEntity: TPurOrder);
begin
  DoUpdate(AEntity);
end;

procedure TPurOrderService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
