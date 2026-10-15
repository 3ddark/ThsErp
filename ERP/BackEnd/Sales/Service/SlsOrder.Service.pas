unit SlsOrder.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SlsOrder.Repository, SlsOrder, SlsOrder.Exception, SlsOrderDetail, SlsOrderDetail.Repository, SlsOffer, SlsOffer.Repository;

type
  TSlsOrderService = class(TCrudService<TSlsOrder>)
  private
    FRepo: IRepository<TSlsOrder>;
    FDetailRepo: IRepository<TSlsOrderDetail>;
    FOfferRepo: IRepository<TSlsOffer>;

    procedure DoAdd(AEntity: TSlsOrder);
    procedure DoUpdate(AEntity: TSlsOrder);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsOrder; AOperation: TCrudOperation); override;
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
    // Gönderilmiş teklifin kalan miktarlarından taslak sipariş (fiyat / iskonto / KDV tekliften); yeni sipariş id
    function CreateFromOffer(AOfferId: Int64; APermissionControl: Boolean): Int64;
    procedure RefreshOffers(AOrderId: Int64);

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsOrder>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsOrder; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsOrder; override;

    procedure Add(AEntity: TSlsOrder); override;
    procedure Update(AEntity: TSlsOrder); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOrder; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOrder>; override;
    procedure BusinessInsert(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsOrderDetail.Service, SlsOfferDetail, SlsOfferDetail.Repository;

constructor TSlsOrderService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FDetailRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  FOfferRepo := Self.UoW.GetRepository<TSlsOffer, TSlsOfferRepository>;
  Self.PermissionCode := PERMISSION_SLS_ORDER;
end;

destructor TSlsOrderService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsOrderService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Elle durum değişikliği (onay / taslağa alma / red / iptal / kapama); kendi açtığı transaction'ı commit eder
procedure TSlsOrderService.ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
var
  LOld: TSlsOrder;
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
      if not TSlsLookup.CanChangeOrderStatus(LOld.Status, ANewStatus) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsOrder.InvalidStatus,
          'Status cannot be changed from "%s" to "%s".'), [TSlsLookup.Text(slkOrderStatus, LOld.Status), TSlsLookup.Text(slkOrderStatus, ANewStatus)]));
      if (ANewStatus = SLS_ORD_APPROVED) and (TSlsOrderRepository(FRepo).LineCount(AId) = 0) then
        raise ESlsOrderExceptionNoLines.Create;
      if (ANewStatus in [SLS_ORD_DRAFT, SLS_ORD_CANCELLED]) and (TSlsOrderRepository(FRepo).DeliveryCount(AId) > 0) then
        raise ESlsOrderExceptionHasDeliveries.Create;
      TSlsOrderRepository(FRepo).SetStatus(AId, ANewStatus);
      // iptal / yeniden açma teklif kalemlerinin siparişe aktarılan miktarını değiştirir
      RefreshOffers(AId);
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

procedure TSlsOrderService.RefreshOffers(AOrderId: Int64);
var
  LId: Int64;
begin
  for LId in TSlsOrderRepository(FRepo).OfferIdsOfOrder(AOrderId) do
    TSlsOfferRepository(FOfferRepo).RefreshOrderedQuantities(LId);
end;

function TSlsOrderService.CreateFromOffer(AOfferId: Int64; APermissionControl: Boolean): Int64;
var
  LOffer: TSlsOffer;
  LOrder: TSlsOrder;
  LLines: TList<TSlsOfferDetail>;
  LLine: TSlsOfferDetail;
  LDetail: TSlsOrderDetail;
  LDetailSvc: TSlsOrderDetailService;
  LFilter: TFilterCriteria;
  LStarted: Boolean;
  LCount: Integer;
begin
  LStarted := False;
  LDetailSvc := TSlsOrderDetailService.Create;
  try
    try
      Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
      if not Self.UoW.InTransaction then
      begin
        Self.UoW.BeginTransaction;
        LStarted := True;
      end;

      LOffer := FOfferRepo.FindById(AOfferId, True);
      try
        if not Assigned(LOffer) then
          raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AOfferId]));
        if LOffer.Status <> SLS_OFF_SENT then
          raise ESlsOrderExceptionOfferNotSent.Create;

        LOrder := TSlsOrder.Create;
        try
          LOrder.OrderDate := Date;
          LOrder.AccAccountId := LOffer.AccAccountId;
          LOrder.CustomerRefNo := LOffer.CustomerRefNo;
          LOrder.EmpEmployeeId := LOffer.EmpEmployeeId;
          LOrder.Currency := LOffer.Currency;
          LOrder.ExchangeRate := LOffer.ExchangeRate;
          LOrder.PaymentTermDays := LOffer.PaymentTermDays;
          LOrder.Description := LOffer.OfferNo;
          DoAdd(LOrder);
          Result := LOrder.Id;

          LCount := 0;
          LFilter := TFilterCriteria.Create;
          try
            LFilter.Add(TFilterCriterion.New('sls_offer_id', '=', TValue.From<Int64>(AOfferId)));
            LLines := Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>.Find(LFilter, False);
            try
              for LLine in LLines do
              begin
                if LLine.Quantity - LLine.OrderedQuantity <= 0 then
                  Continue;
                LDetail := TSlsOrderDetail.Create;
                try
                  LDetail.SlsOrderId := LOrder.Id;
                  LDetail.StkInventoryId := LLine.StkInventoryId;
                  LDetail.Quantity := LLine.Quantity - LLine.OrderedQuantity;
                  // teklif fiyatı, iskontosu ve KDV'si
                  LDetail.UnitPrice := LLine.UnitPrice;
                  LDetail.DiscountRate := LLine.DiscountRate;
                  LDetail.VatRate := LLine.VatRate;
                  LDetail.Description := LLine.Description;
                  LDetail.SlsOfferDetailId := LLine.Id;
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
            raise ESlsOrderExceptionNothingToOrder.Create;
        finally
          LOrder.Free;
        end;
      finally
        LOffer.Free;
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

procedure TSlsOrderService.ValidateBusinessRules(AEntity: TSlsOrder; AOperation: TCrudOperation);
var
  LRepo: TSlsOrderRepository;
  LOld: TSlsOrder;
  LFilter: TFilterCriteria;
  LModel: TSlsOrder;
begin
  LRepo := TSlsOrderRepository(FRepo);
  if AOperation = coDelete then
  begin
    if not (AEntity.Status in [SLS_ORD_DRAFT, SLS_ORD_CANCELLED]) then
      raise ESlsOrderExceptionDeleteStatus.Create;
    if LRepo.DeliveryCount(AEntity.Id) > 0 then
      raise ESlsOrderExceptionHasDeliveries.Create;
    Exit;
  end;

  AEntity.OrderNo := AnsiUpperCase(Trim(AEntity.OrderNo));
  AEntity.CustomerRefNo := Trim(AEntity.CustomerRefNo);
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.OrderDate <= 0 then
    FailRequired(TLangKeys.TSlsOrder.ColOrderDate, 'Order Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TSlsOrder.ColAccAccountId, 'Customer');
  if (AEntity.DeliveryDate > 0) and (AEntity.DeliveryDate < AEntity.OrderDate) then
    raise ESlsOrderExceptionDeliveryDate.Create;
  if (AEntity.PaymentTermDays < 0) or (AEntity.PaymentTermDays > 365) then
    raise ESlsOrderExceptionPaymentTerm.Create;
  if AEntity.ExchangeRate <= 0 then
    AEntity.ExchangeRate := 1;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    // durum ve tutarlar servis tarafından tutulur (tutarlar kalemlerden)
    AEntity.Status := SLS_ORD_DRAFT;
    AEntity.GrossAmount := 0;
    AEntity.DiscountAmount := 0;
    AEntity.NetAmount := 0;
    AEntity.VatAmount := 0;
    AEntity.TotalAmount := 0;
    if AEntity.OrderNo = '' then
      AEntity.OrderNo := LRepo.NextDocumentNo(SLS_PREFIX_ORDER);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if LOld.Status in [SLS_ORD_DELIVERED, SLS_ORD_CANCELLED] then
        raise ESlsOrderExceptionNotEditable.Create;
      if (LRepo.DeliveryCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or (LOld.Currency <> AEntity.Currency)) then
        raise ESlsOrderExceptionKeyFieldsLocked.Create;
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
        raise ESlsOrderExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsOrderService.DoAdd(AEntity: TSlsOrder);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSlsOrderService.DoUpdate(AEntity: TSlsOrder);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSlsOrderService.DoDelete(AId: Int64);
var
  LEntity: TSlsOrder;
  LOfferIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler cascade silinir; bağlı teklif kalemlerinin siparişe aktarılan miktarı yenilenir
    LOfferIds := TSlsOrderRepository(FRepo).OfferIdsOfOrder(AId);
    FRepo.Delete(LEntity);
    for LId in LOfferIds do
      TSlsOfferRepository(FOfferRepo).RefreshOrderedQuantities(LId);
  finally
    LEntity.Free;
  end;
end;

function TSlsOrderService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOrder>;
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

function TSlsOrderService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOrder;
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

procedure TSlsOrderService.BusinessInsert(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOrderService.BusinessUpdate(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOrderService.BusinessDelete(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsOrderService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSlsOrderService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsOrder>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSlsOrderService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsOrder;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSlsOrderService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsOrder;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsOrderService.Add(AEntity: TSlsOrder);
begin
  DoAdd(AEntity);
end;

procedure TSlsOrderService.Update(AEntity: TSlsOrder);
begin
  DoUpdate(AEntity);
end;

procedure TSlsOrderService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
