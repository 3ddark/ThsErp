unit PurReceiptDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurReceiptDetail.Repository, PurReceiptDetail, PurReceiptDetail.Exception, PurReceipt, PurReceipt.Repository, PurOrder, PurOrder.Repository, PurOrderDetail, PurOrderDetail.Repository, StkInventorySummary, StkInventorySummary.Repository;

type
  TPurReceiptDetailService = class(TCrudService<TPurReceiptDetail>)
  private
    FRepo: IRepository<TPurReceiptDetail>;
    FReceiptRepo: IRepository<TPurReceipt>;
    FOrderRepo: IRepository<TPurOrder>;
    FOrderDetailRepo: IRepository<TPurOrderDetail>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TPurReceiptDetail);
    procedure DoUpdate(AEntity: TPurReceiptDetail);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
    procedure AfterWrite(AInventoryId, AOrderDetailId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurReceiptDetail; AOperation: TCrudOperation); override;
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;

    // Satır formu: stok seçilince ölçü birimi
    function GetUomCode(AInventoryId: Int64): string;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurReceiptDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurReceiptDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurReceiptDetail; override;

    procedure Add(AEntity: TPurReceiptDetail); override;
    procedure Update(AEntity: TPurReceiptDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurReceiptDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurReceiptDetail>; override;
    procedure BusinessInsert(AEntity: TPurReceiptDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurReceiptDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurReceiptDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup;

constructor TPurReceiptDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurReceiptDetail, TPurReceiptDetailRepository>;
  FReceiptRepo := Self.UoW.GetRepository<TPurReceipt, TPurReceiptRepository>;
  FOrderRepo := Self.UoW.GetRepository<TPurOrder, TPurOrderRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_PUR_RECEIPT;
end;

destructor TPurReceiptDetailService.Destroy;
begin
  inherited;
end;

function TPurReceiptDetailService.GetUomCode(AInventoryId: Int64): string;
begin
  Result := TPurOrderDetailRepository(FOrderDetailRepo).GetUomCode(AInventoryId);
end;

// Alan adı + "zorunludur" mesajı
procedure TPurReceiptDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
procedure TPurReceiptDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

function TPurReceiptDetailService.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
begin
  Result := TPurOrderDetailRepository(FOrderDetailRepo).GetInventoryDefaults(AInventoryId, APrice, ACurrency, ADiscountRate, AVatRate);
end;

// Stok özeti + bağlı siparişin teslim miktarı / durumu
procedure TPurReceiptDetailService.AfterWrite(AInventoryId, AOrderDetailId: Int64);
var
  LOrderDetail: TPurOrderDetail;
begin
  if AInventoryId > 0 then
    TStkInventorySummaryRepository(FSummaryRepo).Recalculate(AInventoryId);
  if AOrderDetailId > 0 then
  begin
    LOrderDetail := FOrderDetailRepo.FindById(AOrderDetailId, False);
    try
      if Assigned(LOrderDetail) then
        TPurOrderRepository(FOrderRepo).RefreshReceivedQuantities(LOrderDetail.PurOrderId);
    finally
      LOrderDetail.Free;
    end;
  end;
end;

procedure TPurReceiptDetailService.ValidateBusinessRules(AEntity: TPurReceiptDetail; AOperation: TCrudOperation);
var
  LRepo: TPurReceiptDetailRepository;
  LReceipt: TPurReceipt;
  LOrderDetail: TPurOrderDetail;
  LOld: TPurReceiptDetail;
  LInvoiced, LOpen: Currency;
begin
  LRepo := TPurReceiptDetailRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.InvoicedQuantity(AEntity.Id, 0) > 0 then
      raise EPurReceiptDetailExceptionInvoiced.Create;
    Exit;
  end;

  AEntity.Description := Trim(AEntity.Description);
  if AEntity.PurReceiptId <= 0 then
    FailRequired(TLangKeys.TPurReceiptDetail.ColPurReceiptId, 'Goods Receipt');
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TPurReceiptDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TPurReceiptDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.UnitPrice < 0 then
    Fail(TLangKeys.TPurReceiptDetail.ColUnitPrice, 'Unit Cost', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');

  if AOperation = coUpdate then
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      LInvoiced := LRepo.InvoicedQuantity(AEntity.Id, 0);
      if Assigned(LOld) and (LInvoiced > 0) and ((AEntity.Quantity < LInvoiced) or (LOld.StkInventoryId <> AEntity.StkInventoryId) or
        (LOld.PurReceiptId <> AEntity.PurReceiptId)) then
        raise EPurReceiptDetailExceptionInvoiced.Create;
    finally
      LOld.Free;
    end;
  end;

  if AEntity.PurOrderDetailId > 0 then
  begin
    LReceipt := FReceiptRepo.FindById(AEntity.PurReceiptId, False);
    LOrderDetail := FOrderDetailRepo.FindById(AEntity.PurOrderDetailId, False);
    try
      if not Assigned(LReceipt) or not Assigned(LOrderDetail) or (LReceipt.PurOrderId <> LOrderDetail.PurOrderId) then
        raise EPurReceiptDetailExceptionOrderMismatch.Create;
      if LOrderDetail.StkInventoryId <> AEntity.StkInventoryId then
        raise EPurReceiptDetailExceptionInventoryMismatch.Create;
      LOpen := LOrderDetail.Quantity - LRepo.ReceivedQuantityOfOrderDetail(AEntity.PurOrderDetailId, AEntity.Id);
      if AEntity.Quantity > LOpen then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.OverReceipt,
          'Quantity exceeds the open order quantity (%s).'), [CurrToStr(LOpen)]));
    finally
      LReceipt.Free;
      LOrderDetail.Free;
    end;
  end;
end;

procedure TPurReceiptDetailService.DoAdd(AEntity: TPurReceiptDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  TPurReceiptDetailRepository(FRepo).UpsertStockTransaction(AEntity.Id);
  AfterWrite(AEntity.StkInventoryId, AEntity.PurOrderDetailId);
end;

procedure TPurReceiptDetailService.DoUpdate(AEntity: TPurReceiptDetail);
var
  LOld: TPurReceiptDetail;
  LOldInventoryId, LOldOrderDetailId: Int64;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldInventoryId := LOld.StkInventoryId;
    LOldOrderDetailId := LOld.PurOrderDetailId;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  TPurReceiptDetailRepository(FRepo).UpsertStockTransaction(AEntity.Id);
  AfterWrite(AEntity.StkInventoryId, AEntity.PurOrderDetailId);
  if LOldInventoryId <> AEntity.StkInventoryId then
    AfterWrite(LOldInventoryId, 0);
  if LOldOrderDetailId <> AEntity.PurOrderDetailId then
    AfterWrite(0, LOldOrderDetailId);
end;

procedure TPurReceiptDetailService.DoDelete(AId: Int64);
var
  LEntity: TPurReceiptDetail;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // stok hareketi FK ile cascade silinir
    FRepo.Delete(LEntity);
    AfterWrite(LEntity.StkInventoryId, LEntity.PurOrderDetailId);
  finally
    LEntity.Free;
  end;
end;

function TPurReceiptDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurReceiptDetail>;
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

function TPurReceiptDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurReceiptDetail;
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

procedure TPurReceiptDetailService.BusinessInsert(AEntity: TPurReceiptDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurReceiptDetailService.BusinessUpdate(AEntity: TPurReceiptDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurReceiptDetailService.BusinessDelete(AEntity: TPurReceiptDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurReceiptDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPurReceiptDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurReceiptDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurReceiptDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurReceiptDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPurReceiptDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurReceiptDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurReceiptDetailService.Add(AEntity: TPurReceiptDetail);
begin
  DoAdd(AEntity);
end;

procedure TPurReceiptDetailService.Update(AEntity: TPurReceiptDetail);
begin
  DoUpdate(AEntity);
end;

procedure TPurReceiptDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
