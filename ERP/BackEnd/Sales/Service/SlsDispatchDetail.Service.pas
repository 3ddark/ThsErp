unit SlsDispatchDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SlsDispatchDetail.Repository, SlsDispatchDetail, SlsDispatchDetail.Exception, SlsDispatch, SlsDispatch.Repository, SlsOrder, SlsOrder.Repository, SlsOrderDetail, SlsOrderDetail.Repository, StkInventorySummary, StkInventorySummary.Repository;

type
  TSlsDispatchDetailService = class(TCrudService<TSlsDispatchDetail>)
  private
    FRepo: IRepository<TSlsDispatchDetail>;
    FDispatchRepo: IRepository<TSlsDispatch>;
    FOrderRepo: IRepository<TSlsOrder>;
    FOrderDetailRepo: IRepository<TSlsOrderDetail>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TSlsDispatchDetail);
    procedure DoUpdate(AEntity: TSlsDispatchDetail);
    procedure DoDelete(AId: Int64);

    class procedure FailRequired(const AKey, ADefault: string); static;
    class procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string); static;
    procedure AfterWrite(AInventoryId, AOrderDetailId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    // Kalemin kendi alanları (DB'siz): stok, miktar, net fiyat + tutar. Tek kalem kaydı (ValidateBusinessRules) ve belge
    // kaydı (TSlsDispatchService.BusinessSaveWithDetails) ortak kullanır
    class procedure CheckLine(AEntity: TSlsDispatchDetail); static;
    function GetUomCode(AInventoryId: Int64): string;
    procedure ValidateBusinessRules(AEntity: TSlsDispatchDetail; AOperation: TCrudOperation); override;
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsDispatchDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsDispatchDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsDispatchDetail; override;

    procedure Add(AEntity: TSlsDispatchDetail); override;
    procedure Update(AEntity: TSlsDispatchDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsDispatchDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsDispatchDetail>; override;
    procedure BusinessInsert(AEntity: TSlsDispatchDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsDispatchDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsDispatchDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsOfferDetail, SlsOfferDetail.Repository, SlsDispatch.Exception, EInvLookup;

constructor TSlsDispatchDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsDispatchDetail, TSlsDispatchDetailRepository>;
  FDispatchRepo := Self.UoW.GetRepository<TSlsDispatch, TSlsDispatchRepository>;
  FOrderRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_SLS_DISPATCH;
end;

destructor TSlsDispatchDetailService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
class procedure TSlsDispatchDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
class procedure TSlsDispatchDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

function TSlsDispatchDetailService.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
begin
  Result := TSlsOrderDetailRepository(FOrderDetailRepo).GetInventoryDefaults(AInventoryId, APrice, ACurrency, ADiscountRate, AVatRate);
end;

// Stok özeti + bağlı siparişin sevk miktarı / durumu
procedure TSlsDispatchDetailService.AfterWrite(AInventoryId, AOrderDetailId: Int64);
var
  LOrderDetail: TSlsOrderDetail;
begin
  if AInventoryId > 0 then
    TStkInventorySummaryRepository(FSummaryRepo).Recalculate(AInventoryId);
  if AOrderDetailId > 0 then
  begin
    LOrderDetail := FOrderDetailRepo.FindById(AOrderDetailId, False);
    try
      if Assigned(LOrderDetail) then
        TSlsOrderRepository(FOrderRepo).RefreshDeliveredQuantities(LOrderDetail.SlsOrderId);
    finally
      LOrderDetail.Free;
    end;
  end;
end;

class procedure TSlsDispatchDetailService.CheckLine(AEntity: TSlsDispatchDetail);
begin
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TSlsDispatchDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TSlsDispatchDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.UnitPrice < 0 then
    Fail(TLangKeys.TSlsDispatchDetail.ColUnitPrice, 'Net Unit Price', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');
  AEntity.Amount := TSlsLookup.RoundAmount(AEntity.Quantity * AEntity.UnitPrice);
end;

function TSlsDispatchDetailService.GetUomCode(AInventoryId: Int64): string;
begin
  Result := TSlsOfferDetailRepository(Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>).GetUomCode(AInventoryId);
end;

procedure TSlsDispatchDetailService.ValidateBusinessRules(AEntity: TSlsDispatchDetail; AOperation: TCrudOperation);
var
  LRepo: TSlsDispatchDetailRepository;
  LDispatch: TSlsDispatch;
  LOrderDetail: TSlsOrderDetail;
  LOld: TSlsDispatchDetail;
  LInvoiced, LOpen: Currency;
  LFilter: TFilterCriteria;
  LModel: TSlsDispatchDetail;
begin
  LRepo := TSlsDispatchDetailRepository(FRepo);
  // gönderilmiş e-İrsaliyenin kalemi eklenemez / değiştirilemez / silinemez
  if (AEntity.SlsDispatchId > 0) and
     TEInvLookup.IsEInvLocked(TSlsDispatchRepository(FDispatchRepo).EInvStatus(AEntity.SlsDispatchId)) then
    raise ESlsDispatchExceptionEInvLocked.Create;
  if AOperation = coDelete then
  begin
    if LRepo.InvoicedQuantity(AEntity.Id, 0) > 0 then
      raise ESlsDispatchDetailExceptionInvoiced.Create;
    Exit;
  end;

  if AEntity.SlsDispatchId <= 0 then
    FailRequired(TLangKeys.TSlsDispatchDetail.ColSlsDispatchId, 'Delivery Note');
  CheckLine(AEntity);

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := LRepo.NextLineNo(AEntity.SlsDispatchId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('sls_dispatch_id', '=', TValue.From<Int64>(AEntity.SlsDispatchId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsDispatchDetailExceptionLineUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;

  if AOperation = coUpdate then
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      LInvoiced := LRepo.InvoicedQuantity(AEntity.Id, 0);
      if Assigned(LOld) and (LInvoiced > 0) and ((AEntity.Quantity < LInvoiced) or (LOld.StkInventoryId <> AEntity.StkInventoryId) or
        (LOld.SlsDispatchId <> AEntity.SlsDispatchId)) then
        raise ESlsDispatchDetailExceptionInvoiced.Create;
    finally
      LOld.Free;
    end;
  end;

  if AEntity.SlsOrderDetailId > 0 then
  begin
    LDispatch := FDispatchRepo.FindById(AEntity.SlsDispatchId, False);
    LOrderDetail := FOrderDetailRepo.FindById(AEntity.SlsOrderDetailId, False);
    try
      if not Assigned(LDispatch) or not Assigned(LOrderDetail) or (LDispatch.SlsOrderId <> LOrderDetail.SlsOrderId) then
        raise ESlsDispatchDetailExceptionOrderMismatch.Create;
      if LOrderDetail.StkInventoryId <> AEntity.StkInventoryId then
        raise ESlsDispatchDetailExceptionInventoryMismatch.Create;
      LOpen := LOrderDetail.Quantity - LRepo.DeliveredQuantityOfOrderDetail(AEntity.SlsOrderDetailId, AEntity.Id, 0);
      if AEntity.Quantity > LOpen then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.OverDelivery,
          'Quantity exceeds the open order quantity (%s).'), [CurrToStr(LOpen)]));
    finally
      LDispatch.Free;
      LOrderDetail.Free;
    end;
  end;
end;

procedure TSlsDispatchDetailService.DoAdd(AEntity: TSlsDispatchDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  TSlsDispatchDetailRepository(FRepo).UpsertStockTransaction(AEntity.Id);
  AfterWrite(AEntity.StkInventoryId, AEntity.SlsOrderDetailId);
  TSlsDispatchRepository(FDispatchRepo).RefreshInvoiceStatus(AEntity.SlsDispatchId);
end;

procedure TSlsDispatchDetailService.DoUpdate(AEntity: TSlsDispatchDetail);
var
  LOld: TSlsDispatchDetail;
  LOldInventoryId, LOldOrderDetailId: Int64;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldInventoryId := LOld.StkInventoryId;
    LOldOrderDetailId := LOld.SlsOrderDetailId;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  TSlsDispatchDetailRepository(FRepo).UpsertStockTransaction(AEntity.Id);
  AfterWrite(AEntity.StkInventoryId, AEntity.SlsOrderDetailId);
  if LOldInventoryId <> AEntity.StkInventoryId then
    AfterWrite(LOldInventoryId, 0);
  if LOldOrderDetailId <> AEntity.SlsOrderDetailId then
    AfterWrite(0, LOldOrderDetailId);
  TSlsDispatchRepository(FDispatchRepo).RefreshInvoiceStatus(AEntity.SlsDispatchId);
end;

procedure TSlsDispatchDetailService.DoDelete(AId: Int64);
var
  LEntity: TSlsDispatchDetail;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // stok hareketi FK ile cascade silinir
    FRepo.Delete(LEntity);
    AfterWrite(LEntity.StkInventoryId, LEntity.SlsOrderDetailId);
    TSlsDispatchRepository(FDispatchRepo).RefreshInvoiceStatus(LEntity.SlsDispatchId);
  finally
    LEntity.Free;
  end;
end;

function TSlsDispatchDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsDispatchDetail>;
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

function TSlsDispatchDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsDispatchDetail;
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

procedure TSlsDispatchDetailService.BusinessInsert(AEntity: TSlsDispatchDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsDispatchDetailService.BusinessUpdate(AEntity: TSlsDispatchDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsDispatchDetailService.BusinessDelete(AEntity: TSlsDispatchDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsDispatchDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSlsDispatchDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsDispatchDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSlsDispatchDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsDispatchDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSlsDispatchDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsDispatchDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsDispatchDetailService.Add(AEntity: TSlsDispatchDetail);
begin
  DoAdd(AEntity);
end;

procedure TSlsDispatchDetailService.Update(AEntity: TSlsDispatchDetail);
begin
  DoUpdate(AEntity);
end;

procedure TSlsDispatchDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
