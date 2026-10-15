unit SlsInvoice.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SlsInvoice.Repository, SlsInvoice, SlsInvoice.Exception, SlsDispatch, SlsDispatch.Repository, SlsOrder, SlsOrder.Repository, SlsDispatchDetail, SlsDispatchDetail.Repository, SlsOrderDetail, SlsOrderDetail.Repository, StkInventorySummary, StkInventorySummary.Repository;

type
  TSlsInvoiceService = class(TCrudService<TSlsInvoice>)
  private
    FRepo: IRepository<TSlsInvoice>;
    FDispatchRepo: IRepository<TSlsDispatch>;
    FOrderRepo: IRepository<TSlsOrder>;
    FDispatchDetailRepo: IRepository<TSlsDispatchDetail>;
    FOrderDetailRepo: IRepository<TSlsOrderDetail>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TSlsInvoice);
    procedure DoUpdate(AEntity: TSlsInvoice);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // Sipariş kurundan / vadesinden fatura başlığı
    procedure ApplyOrderTerms(AInvoice: TSlsInvoice; AOrderId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsInvoice; AOperation: TCrudOperation); override;
    // İrsaliyenin faturalanmamış miktarlarından satış faturası (fiyat / iskonto / KDV sipariş kaleminden); yeni fatura id
    function CreateFromDispatch(ADispatchId: Int64; APermissionControl: Boolean): Int64;
    // Onaylı siparişin sevk edilmemiş miktarlarından irsaliyeli fatura (stok faturadan, verilen ambardan düşer); yeni fatura id
    function CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsInvoice>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsInvoice; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsInvoice; override;

    procedure Add(AEntity: TSlsInvoice); override;
    procedure Update(AEntity: TSlsInvoice); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsInvoice; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsInvoice>; override;
    procedure BusinessInsert(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsInvoiceDetail, SlsInvoiceDetail.Service;

constructor TSlsInvoiceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsInvoice, TSlsInvoiceRepository>;
  FDispatchRepo := Self.UoW.GetRepository<TSlsDispatch, TSlsDispatchRepository>;
  FOrderRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FDispatchDetailRepo := Self.UoW.GetRepository<TSlsDispatchDetail, TSlsDispatchDetailRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_SLS_INVOICE;
end;

destructor TSlsInvoiceService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsInvoiceService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TSlsInvoiceService.ApplyOrderTerms(AInvoice: TSlsInvoice; AOrderId: Int64);
var
  LOrder: TSlsOrder;
begin
  if AOrderId <= 0 then
    Exit;
  LOrder := FOrderRepo.FindById(AOrderId, False);
  try
    if Assigned(LOrder) then
    begin
      AInvoice.ExchangeRate := LOrder.ExchangeRate;
      if LOrder.PaymentTermDays > 0 then
        AInvoice.DueDate := AInvoice.InvoiceDate + LOrder.PaymentTermDays;
    end;
  finally
    LOrder.Free;
  end;
end;

function TSlsInvoiceService.CreateFromDispatch(ADispatchId: Int64; APermissionControl: Boolean): Int64;
var
  LDispatch: TSlsDispatch;
  LInvoice: TSlsInvoice;
  LLines: TList<TSlsDispatchDetail>;
  LLine: TSlsDispatchDetail;
  LOrderDetail: TSlsOrderDetail;
  LDetail: TSlsInvoiceDetail;
  LDetailSvc: TSlsInvoiceDetailService;
  LDispatchDetailRepo: TSlsDispatchDetailRepository;
  LFilter: TFilterCriteria;
  LStarted: Boolean;
  LOpen, LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
  LCount: Integer;
begin
  LStarted := False;
  LDetailSvc := TSlsInvoiceDetailService.Create;
  try
    try
      Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
      if not Self.UoW.InTransaction then
      begin
        Self.UoW.BeginTransaction;
        LStarted := True;
      end;

      LDispatchDetailRepo := TSlsDispatchDetailRepository(FDispatchDetailRepo);
      LDispatch := FDispatchRepo.FindById(ADispatchId, True);
      try
        if not Assigned(LDispatch) then
          raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADispatchId]));

        LInvoice := TSlsInvoice.Create;
        try
          LInvoice.InvoiceDate := Date;
          LInvoice.AccAccountId := LDispatch.AccAccountId;
          LInvoice.Currency := LDispatch.Currency;
          LInvoice.Description := LDispatch.DispatchNo;
          ApplyOrderTerms(LInvoice, LDispatch.SlsOrderId);
          DoAdd(LInvoice);
          Result := LInvoice.Id;

          LCount := 0;
          LFilter := TFilterCriteria.Create;
          try
            LFilter.Add(TFilterCriterion.New('sls_dispatch_id', '=', TValue.From<Int64>(ADispatchId)));
            LLines := LDispatchDetailRepo.Find(LFilter, False);
            try
              for LLine in LLines do
              begin
                LOpen := LLine.Quantity - LDispatchDetailRepo.InvoicedQuantity(LLine.Id, 0);
                if LOpen <= 0 then
                  Continue;
                LDetail := TSlsInvoiceDetail.Create;
                try
                  LDetail.SlsInvoiceId := LInvoice.Id;
                  LDetail.StkInventoryId := LLine.StkInventoryId;
                  LDetail.Quantity := LOpen;
                  LDetail.SlsDispatchDetailId := LLine.Id;
                  LDetail.UnitPrice := LLine.UnitPrice;
                  LDetail.Description := LLine.Description;
                  LOrderDetail := nil;
                  if LLine.SlsOrderDetailId > 0 then
                    LOrderDetail := FOrderDetailRepo.FindById(LLine.SlsOrderDetailId, False);
                  try
                    if Assigned(LOrderDetail) then
                    begin
                      // sipariş fiyatı, iskontosu ve KDV'si
                      LDetail.UnitPrice := LOrderDetail.UnitPrice;
                      LDetail.DiscountRate := LOrderDetail.DiscountRate;
                      LDetail.VatRate := LOrderDetail.VatRate;
                    end
                    else if TSlsOrderDetailRepository(FOrderDetailRepo).GetInventoryDefaults(LLine.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
                      LDetail.VatRate := LVat;
                  finally
                    LOrderDetail.Free;
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
            raise ESlsInvoiceExceptionNothingToInvoice.Create;
        finally
          LInvoice.Free;
        end;
      finally
        LDispatch.Free;
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

function TSlsInvoiceService.CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;
var
  LOrder: TSlsOrder;
  LInvoice: TSlsInvoice;
  LLines: TList<TSlsOrderDetail>;
  LLine: TSlsOrderDetail;
  LDetail: TSlsInvoiceDetail;
  LDetailSvc: TSlsInvoiceDetailService;
  LFilter: TFilterCriteria;
  LStarted: Boolean;
  LCount: Integer;
begin
  LStarted := False;
  LDetailSvc := TSlsInvoiceDetailService.Create;
  try
    try
      Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
      if not Self.UoW.InTransaction then
      begin
        Self.UoW.BeginTransaction;
        LStarted := True;
      end;

      LOrder := FOrderRepo.FindById(AOrderId, True);
      try
        if not Assigned(LOrder) then
          raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AOrderId]));
        if not (LOrder.Status in [SLS_ORD_APPROVED, SLS_ORD_PARTIAL]) then
          raise ESlsInvoiceExceptionOrderStatus.Create;

        LInvoice := TSlsInvoice.Create;
        try
          LInvoice.InvoiceDate := Date;
          LInvoice.AccAccountId := LOrder.AccAccountId;
          LInvoice.StkWarehouseId := AWarehouseId;
          LInvoice.Currency := LOrder.Currency;
          LInvoice.Description := LOrder.OrderNo;
          ApplyOrderTerms(LInvoice, LOrder.Id);
          DoAdd(LInvoice);
          Result := LInvoice.Id;

          LCount := 0;
          LFilter := TFilterCriteria.Create;
          try
            LFilter.Add(TFilterCriterion.New('sls_order_id', '=', TValue.From<Int64>(AOrderId)));
            LLines := FOrderDetailRepo.Find(LFilter, False);
            try
              for LLine in LLines do
              begin
                if LLine.Quantity - LLine.DeliveredQuantity <= 0 then
                  Continue;
                LDetail := TSlsInvoiceDetail.Create;
                try
                  LDetail.SlsInvoiceId := LInvoice.Id;
                  LDetail.StkInventoryId := LLine.StkInventoryId;
                  LDetail.Quantity := LLine.Quantity - LLine.DeliveredQuantity;
                  LDetail.UnitPrice := LLine.UnitPrice;
                  LDetail.DiscountRate := LLine.DiscountRate;
                  LDetail.VatRate := LLine.VatRate;
                  LDetail.Description := LLine.Description;
                  LDetail.SlsOrderDetailId := LLine.Id;
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
            raise ESlsInvoiceExceptionNothingToInvoice.Create;
        finally
          LInvoice.Free;
        end;
      finally
        LOrder.Free;
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

procedure TSlsInvoiceService.ValidateBusinessRules(AEntity: TSlsInvoice; AOperation: TCrudOperation);
var
  LRepo: TSlsInvoiceRepository;
  LOld: TSlsInvoice;
  LFilter: TFilterCriteria;
  LModel: TSlsInvoice;
begin
  LRepo := TSlsInvoiceRepository(FRepo);
  if AOperation = coDelete then
    Exit;

  AEntity.InvoiceNo := AnsiUpperCase(Trim(AEntity.InvoiceNo));
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.InvoiceDate <= 0 then
    FailRequired(TLangKeys.TSlsInvoice.ColInvoiceDate, 'Invoice Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TSlsInvoice.ColAccAccountId, 'Customer');
  if (AEntity.DueDate > 0) and (AEntity.DueDate < AEntity.InvoiceDate) then
    raise ESlsInvoiceExceptionDueDate.Create;
  if AEntity.ExchangeRate <= 0 then
    AEntity.ExchangeRate := 1;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    AEntity.GrossAmount := 0;
    AEntity.DiscountAmount := 0;
    AEntity.NetAmount := 0;
    AEntity.VatAmount := 0;
    AEntity.TotalAmount := 0;
    if AEntity.InvoiceNo = '' then
      AEntity.InvoiceNo := LRepo.NextDocumentNo(SLS_PREFIX_INVOICE);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if (LRepo.LineCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or (LOld.Currency <> AEntity.Currency)) then
        raise ESlsInvoiceExceptionKeyFieldsLocked.Create;
      // irsaliyesiz kalem stoktan düşer: ambar boşaltılamaz
      if (AEntity.StkWarehouseId <= 0) and (LRepo.StockLineCount(AEntity.Id) > 0) then
        raise ESlsInvoiceExceptionWarehouseRequired.Create;
      AEntity.GrossAmount := LOld.GrossAmount;
      AEntity.DiscountAmount := LOld.DiscountAmount;
      AEntity.NetAmount := LOld.NetAmount;
      AEntity.VatAmount := LOld.VatAmount;
      AEntity.TotalAmount := LOld.TotalAmount;
      if AEntity.InvoiceNo = '' then
        AEntity.InvoiceNo := LOld.InvoiceNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('invoice_no', '=', TValue.From<string>(AEntity.InvoiceNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsInvoiceExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsInvoiceService.DoAdd(AEntity: TSlsInvoice);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSlsInvoiceService.DoUpdate(AEntity: TSlsInvoice);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  // tarih / ambar değişikliği irsaliyesiz kalemlerin stok hareketlerine yansır
  TSlsInvoiceRepository(FRepo).SyncStockTransactions(AEntity.Id);
end;

procedure TSlsInvoiceService.DoDelete(AId: Int64);
var
  LEntity: TSlsInvoice;
  LInventoryIds, LOrderIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler ve stok hareketleri cascade silinir; stok özeti ve sipariş sevk miktarları yenilenir
    LInventoryIds := TSlsInvoiceRepository(FRepo).StockInventoryIdsOfInvoice(AId);
    LOrderIds := TSlsInvoiceRepository(FRepo).OrderIdsOfInvoice(AId);
    FRepo.Delete(LEntity);
    for LId in LInventoryIds do
      TStkInventorySummaryRepository(FSummaryRepo).Recalculate(LId);
    for LId in LOrderIds do
      TSlsOrderRepository(FOrderRepo).RefreshDeliveredQuantities(LId);
  finally
    LEntity.Free;
  end;
end;

function TSlsInvoiceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsInvoice>;
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

function TSlsInvoiceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsInvoice;
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

procedure TSlsInvoiceService.BusinessInsert(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsInvoiceService.BusinessUpdate(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsInvoiceService.BusinessDelete(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsInvoiceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSlsInvoiceService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsInvoice>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSlsInvoiceService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsInvoice;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSlsInvoiceService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsInvoice;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsInvoiceService.Add(AEntity: TSlsInvoice);
begin
  DoAdd(AEntity);
end;

procedure TSlsInvoiceService.Update(AEntity: TSlsInvoice);
begin
  DoUpdate(AEntity);
end;

procedure TSlsInvoiceService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
