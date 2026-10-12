unit PurReceipt.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurReceipt.Repository, PurReceipt, PurReceipt.Exception, PurOrder, PurOrder.Repository, StkInventorySummary, StkInventorySummary.Repository;

type
  TPurReceiptService = class(TCrudService<TPurReceipt>)
  private
    FRepo: IRepository<TPurReceipt>;
    FOrderRepo: IRepository<TPurOrder>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TPurReceipt);
    procedure DoUpdate(AEntity: TPurReceipt);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurReceipt; AOperation: TCrudOperation); override;
    // Onaylı siparişin kalan miktarlarından mal kabul (stok girişi dahil); yeni mal kabul id
    function CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurReceipt>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurReceipt; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurReceipt; override;

    procedure Add(AEntity: TPurReceipt); override;
    procedure Update(AEntity: TPurReceipt); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurReceipt; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurReceipt>; override;
    procedure BusinessInsert(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, PurReceiptDetail, PurReceiptDetail.Service, PurOrderDetail, PurOrderDetail.Repository;

constructor TPurReceiptService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurReceipt, TPurReceiptRepository>;
  FOrderRepo := Self.UoW.GetRepository<TPurOrder, TPurOrderRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_PUR_RECEIPT;
end;

destructor TPurReceiptService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TPurReceiptService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


function TPurReceiptService.CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;
var
  LOrder: TPurOrder;
  LReceipt: TPurReceipt;
  LLines: TList<TPurOrderDetail>;
  LLine: TPurOrderDetail;
  LDetail: TPurReceiptDetail;
  LDetailSvc: TPurReceiptDetailService;
  LFilter: TFilterCriteria;
  LStarted: Boolean;
  LCount: Integer;
begin
  LStarted := False;
  LDetailSvc := TPurReceiptDetailService.Create;
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
        if not (LOrder.Status in [PUR_ORD_APPROVED, PUR_ORD_PARTIAL]) then
          raise EPurReceiptExceptionOrderStatus.Create;

        LReceipt := TPurReceipt.Create;
        try
          LReceipt.ReceiptDate := Date;
          LReceipt.AccAccountId := LOrder.AccAccountId;
          LReceipt.StkWarehouseId := AWarehouseId;
          LReceipt.PurOrderId := LOrder.Id;
          LReceipt.Currency := LOrder.Currency;
          DoAdd(LReceipt);
          Result := LReceipt.Id;

          LCount := 0;
          LFilter := TFilterCriteria.Create;
          try
            LFilter.Add(TFilterCriterion.New('pur_order_id', '=', TValue.From<Int64>(AOrderId)));
            LLines := Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>.Find(LFilter, False);
            try
              for LLine in LLines do
              begin
                if LLine.Quantity - LLine.ReceivedQuantity <= 0 then
                  Continue;
                LDetail := TPurReceiptDetail.Create;
                try
                  LDetail.PurReceiptId := LReceipt.Id;
                  LDetail.StkInventoryId := LLine.StkInventoryId;
                  LDetail.Quantity := LLine.Quantity - LLine.ReceivedQuantity;
                  // stok maliyeti: iskontolu net birim fiyat
                  LDetail.UnitPrice := LLine.NetAmount / LLine.Quantity;
                  LDetail.PurOrderDetailId := LLine.Id;
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
            raise EPurReceiptExceptionNothingToReceive.Create;
        finally
          LReceipt.Free;
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

procedure TPurReceiptService.ValidateBusinessRules(AEntity: TPurReceipt; AOperation: TCrudOperation);
var
  LRepo: TPurReceiptRepository;
  LOld: TPurReceipt;
  LOrder: TPurOrder;
  LFilter: TFilterCriteria;
  LModel: TPurReceipt;
begin
  LRepo := TPurReceiptRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.InvoicedQuantity(AEntity.Id) > 0 then
      raise EPurReceiptExceptionHasInvoices.Create;
    Exit;
  end;

  AEntity.ReceiptNo := AnsiUpperCase(Trim(AEntity.ReceiptNo));
  AEntity.WaybillNo := AnsiUpperCase(Trim(AEntity.WaybillNo));
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.ReceiptDate <= 0 then
    FailRequired(TLangKeys.TPurReceipt.ColReceiptDate, 'Receipt Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TPurReceipt.ColAccAccountId, 'Supplier');
  if AEntity.StkWarehouseId <= 0 then
    FailRequired(TLangKeys.TPurReceipt.ColStkWarehouseId, 'Warehouse');

  if AEntity.PurOrderId > 0 then
  begin
    LOrder := FOrderRepo.FindById(AEntity.PurOrderId, False);
    try
      if not Assigned(LOrder) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.PurOrderId]));
      if LOrder.AccAccountId <> AEntity.AccAccountId then
        raise EPurReceiptExceptionOrderSupplier.Create;
      if (AOperation = coInsert) and not (LOrder.Status in [PUR_ORD_APPROVED, PUR_ORD_PARTIAL]) then
        raise EPurReceiptExceptionOrderStatus.Create;
      // siparişli mal kabul siparişin para biriminde
      AEntity.Currency := LOrder.Currency;
    finally
      LOrder.Free;
    end;
  end;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    if AEntity.ReceiptNo = '' then
      AEntity.ReceiptNo := LRepo.NextDocumentNo(PUR_PREFIX_RECEIPT);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if (LRepo.LineCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or
        (LOld.PurOrderId <> AEntity.PurOrderId) or (LOld.Currency <> AEntity.Currency)) then
        raise EPurReceiptExceptionKeyFieldsLocked.Create;
      if AEntity.ReceiptNo = '' then
        AEntity.ReceiptNo := LOld.ReceiptNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('receipt_no', '=', TValue.From<string>(AEntity.ReceiptNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurReceiptExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurReceiptService.DoAdd(AEntity: TPurReceipt);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurReceiptService.DoUpdate(AEntity: TPurReceipt);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  // tarih / ambar değişikliği stok hareketlerine yansır
  TPurReceiptRepository(FRepo).SyncStockTransactions(AEntity.Id);
end;

procedure TPurReceiptService.DoDelete(AId: Int64);
var
  LEntity: TPurReceipt;
  LInventoryIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler ve stok hareketleri cascade silinir; stok özeti ve sipariş teslim miktarları yenilenir
    LInventoryIds := TPurReceiptRepository(FRepo).InventoryIdsOfReceipt(AId);
    FRepo.Delete(LEntity);
    for LId in LInventoryIds do
      TStkInventorySummaryRepository(FSummaryRepo).Recalculate(LId);
    if LEntity.PurOrderId > 0 then
      TPurOrderRepository(FOrderRepo).RefreshReceivedQuantities(LEntity.PurOrderId);
  finally
    LEntity.Free;
  end;
end;

function TPurReceiptService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurReceipt>;
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

function TPurReceiptService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurReceipt;
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

procedure TPurReceiptService.BusinessInsert(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurReceiptService.BusinessUpdate(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurReceiptService.BusinessDelete(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurReceiptService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPurReceiptService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurReceipt>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurReceiptService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurReceipt;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPurReceiptService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurReceipt;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurReceiptService.Add(AEntity: TPurReceipt);
begin
  DoAdd(AEntity);
end;

procedure TPurReceiptService.Update(AEntity: TPurReceipt);
begin
  DoUpdate(AEntity);
end;

procedure TPurReceiptService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
