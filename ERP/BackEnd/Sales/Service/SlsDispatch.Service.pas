unit SlsDispatch.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SlsDispatch.Repository, SlsDispatch, SlsDispatch.Exception, SlsOrder, SlsOrder.Repository, StkInventorySummary, StkInventorySummary.Repository;

type
  TSlsDispatchService = class(TCrudService<TSlsDispatch>)
  private
    FRepo: IRepository<TSlsDispatch>;
    FOrderRepo: IRepository<TSlsOrder>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TSlsDispatch);
    procedure DoUpdate(AEntity: TSlsDispatch);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsDispatch; AOperation: TCrudOperation); override;
    // Onaylı siparişin kalan miktarlarından sevk irsaliyesi (stok çıkışı dahil); yeni irsaliye id
    function CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsDispatch>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsDispatch; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsDispatch; override;

    procedure Add(AEntity: TSlsDispatch); override;
    procedure Update(AEntity: TSlsDispatch); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsDispatch; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsDispatch>; override;
    procedure BusinessInsert(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsDispatchDetail, SlsDispatchDetail.Service, SlsOrderDetail, SlsOrderDetail.Repository;

constructor TSlsDispatchService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsDispatch, TSlsDispatchRepository>;
  FOrderRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_SLS_DISPATCH;
end;

destructor TSlsDispatchService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsDispatchService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


function TSlsDispatchService.CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;
var
  LOrder: TSlsOrder;
  LDispatch: TSlsDispatch;
  LLines: TList<TSlsOrderDetail>;
  LLine: TSlsOrderDetail;
  LDetail: TSlsDispatchDetail;
  LDetailSvc: TSlsDispatchDetailService;
  LFilter: TFilterCriteria;
  LStarted: Boolean;
  LCount: Integer;
begin
  LStarted := False;
  LDetailSvc := TSlsDispatchDetailService.Create;
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
          raise ESlsDispatchExceptionOrderStatus.Create;

        LDispatch := TSlsDispatch.Create;
        try
          LDispatch.DispatchDate := Date;
          LDispatch.AccAccountId := LOrder.AccAccountId;
          LDispatch.StkWarehouseId := AWarehouseId;
          LDispatch.SlsOrderId := LOrder.Id;
          LDispatch.Currency := LOrder.Currency;
          DoAdd(LDispatch);
          Result := LDispatch.Id;

          LCount := 0;
          LFilter := TFilterCriteria.Create;
          try
            LFilter.Add(TFilterCriterion.New('sls_order_id', '=', TValue.From<Int64>(AOrderId)));
            LLines := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>.Find(LFilter, False);
            try
              for LLine in LLines do
              begin
                if LLine.Quantity - LLine.DeliveredQuantity <= 0 then
                  Continue;
                LDetail := TSlsDispatchDetail.Create;
                try
                  LDetail.SlsDispatchId := LDispatch.Id;
                  LDetail.StkInventoryId := LLine.StkInventoryId;
                  LDetail.Quantity := LLine.Quantity - LLine.DeliveredQuantity;
                  // iskontolu net satış birim fiyatı (fatura önerisi / stok çıkış tutarı)
                  LDetail.UnitPrice := LLine.NetAmount / LLine.Quantity;
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
            raise ESlsDispatchExceptionNothingToDispatch.Create;
        finally
          LDispatch.Free;
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

procedure TSlsDispatchService.ValidateBusinessRules(AEntity: TSlsDispatch; AOperation: TCrudOperation);
var
  LRepo: TSlsDispatchRepository;
  LOld: TSlsDispatch;
  LOrder: TSlsOrder;
  LFilter: TFilterCriteria;
  LModel: TSlsDispatch;
begin
  LRepo := TSlsDispatchRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.InvoicedQuantity(AEntity.Id) > 0 then
      raise ESlsDispatchExceptionHasInvoices.Create;
    Exit;
  end;

  AEntity.DispatchNo := AnsiUpperCase(Trim(AEntity.DispatchNo));
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.DispatchDate <= 0 then
    FailRequired(TLangKeys.TSlsDispatch.ColDispatchDate, 'Delivery Note Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TSlsDispatch.ColAccAccountId, 'Customer');
  if AEntity.StkWarehouseId <= 0 then
    FailRequired(TLangKeys.TSlsDispatch.ColStkWarehouseId, 'Warehouse');

  if AEntity.SlsOrderId > 0 then
  begin
    LOrder := FOrderRepo.FindById(AEntity.SlsOrderId, False);
    try
      if not Assigned(LOrder) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.SlsOrderId]));
      if LOrder.AccAccountId <> AEntity.AccAccountId then
        raise ESlsDispatchExceptionOrderCustomer.Create;
      if (AOperation = coInsert) and not (LOrder.Status in [SLS_ORD_APPROVED, SLS_ORD_PARTIAL]) then
        raise ESlsDispatchExceptionOrderStatus.Create;
      // siparişli irsaliye siparişin para biriminde
      AEntity.Currency := LOrder.Currency;
    finally
      LOrder.Free;
    end;
  end;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    if AEntity.DispatchNo = '' then
      AEntity.DispatchNo := LRepo.NextDocumentNo(SLS_PREFIX_DISPATCH);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if (LRepo.LineCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or
        (LOld.SlsOrderId <> AEntity.SlsOrderId) or (LOld.Currency <> AEntity.Currency)) then
        raise ESlsDispatchExceptionKeyFieldsLocked.Create;
      if AEntity.DispatchNo = '' then
        AEntity.DispatchNo := LOld.DispatchNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('dispatch_no', '=', TValue.From<string>(AEntity.DispatchNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsDispatchExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsDispatchService.DoAdd(AEntity: TSlsDispatch);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSlsDispatchService.DoUpdate(AEntity: TSlsDispatch);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  // tarih / ambar değişikliği stok hareketlerine yansır
  TSlsDispatchRepository(FRepo).SyncStockTransactions(AEntity.Id);
end;

procedure TSlsDispatchService.DoDelete(AId: Int64);
var
  LEntity: TSlsDispatch;
  LInventoryIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler ve stok hareketleri cascade silinir; stok özeti ve sipariş sevk miktarları yenilenir
    LInventoryIds := TSlsDispatchRepository(FRepo).InventoryIdsOfDispatch(AId);
    FRepo.Delete(LEntity);
    for LId in LInventoryIds do
      TStkInventorySummaryRepository(FSummaryRepo).Recalculate(LId);
    if LEntity.SlsOrderId > 0 then
      TSlsOrderRepository(FOrderRepo).RefreshDeliveredQuantities(LEntity.SlsOrderId);
  finally
    LEntity.Free;
  end;
end;

function TSlsDispatchService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsDispatch>;
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

function TSlsDispatchService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsDispatch;
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

procedure TSlsDispatchService.BusinessInsert(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsDispatchService.BusinessUpdate(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsDispatchService.BusinessDelete(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsDispatchService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSlsDispatchService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsDispatch>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSlsDispatchService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsDispatch;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSlsDispatchService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsDispatch;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsDispatchService.Add(AEntity: TSlsDispatch);
begin
  DoAdd(AEntity);
end;

procedure TSlsDispatchService.Update(AEntity: TSlsDispatch);
begin
  DoUpdate(AEntity);
end;

procedure TSlsDispatchService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
