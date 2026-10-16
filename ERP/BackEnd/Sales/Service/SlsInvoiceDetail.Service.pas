unit SlsInvoiceDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SlsInvoiceDetail.Repository, SlsInvoiceDetail, SlsInvoiceDetail.Exception, SlsInvoice, SlsInvoice.Repository, SlsDispatch, SlsDispatch.Repository, SlsDispatchDetail, SlsDispatchDetail.Repository, SlsOrder, SlsOrder.Repository, SlsOrderDetail, SlsOrderDetail.Repository, StkInventorySummary, StkInventorySummary.Repository;

type
  TSlsInvoiceDetailService = class(TCrudService<TSlsInvoiceDetail>)
  private
    FRepo: IRepository<TSlsInvoiceDetail>;
    FInvoiceRepo: IRepository<TSlsInvoice>;
    FDispatchRepo: IRepository<TSlsDispatch>;
    FDispatchDetailRepo: IRepository<TSlsDispatchDetail>;
    FOrderRepo: IRepository<TSlsOrder>;
    FOrderDetailRepo: IRepository<TSlsOrderDetail>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TSlsInvoiceDetail);
    procedure DoUpdate(AEntity: TSlsInvoiceDetail);
    procedure DoDelete(AId: Int64);

    class procedure FailRequired(const AKey, ADefault: string); static;
    class procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string); static;
    procedure AfterWrite(AInvoiceId, AInventoryId, AOrderDetailId: Int64);
    // irsaliyeli kalemin irsaliyesinin durumu (bekliyor / kapandı)
    procedure RefreshDispatchStatus(ADispatchDetailId: Int64);
    procedure ValidateDispatchLink(AEntity: TSlsInvoiceDetail; AInvoice: TSlsInvoice);
    procedure ValidateOrderLink(AEntity: TSlsInvoiceDetail; AInvoice: TSlsInvoice; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    // Kalemin kendi alanları (DB'siz): stok, miktar, fiyat, oranlar, kaynak (irsaliye xor sipariş) + tutarların hesabı.
    // Tek kalem kaydı (ValidateBusinessRules) ve belge kaydı (TSlsInvoiceService.BusinessSaveWithDetails) ortak kullanır
    class procedure CheckLine(AEntity: TSlsInvoiceDetail); static;
    function GetVatRates: TArray<Currency>;
    function GetUomCode(AInventoryId: Int64): string;
    procedure ValidateBusinessRules(AEntity: TSlsInvoiceDetail; AOperation: TCrudOperation); override;
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsInvoiceDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsInvoiceDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsInvoiceDetail; override;

    procedure Add(AEntity: TSlsInvoiceDetail); override;
    procedure Update(AEntity: TSlsInvoiceDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsInvoiceDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsInvoiceDetail>; override;
    procedure BusinessInsert(AEntity: TSlsInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsOfferDetail, SlsOfferDetail.Repository, SlsOfferDetail.Service;

constructor TSlsInvoiceDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsInvoiceDetail, TSlsInvoiceDetailRepository>;
  FInvoiceRepo := Self.UoW.GetRepository<TSlsInvoice, TSlsInvoiceRepository>;
  FDispatchRepo := Self.UoW.GetRepository<TSlsDispatch, TSlsDispatchRepository>;
  FDispatchDetailRepo := Self.UoW.GetRepository<TSlsDispatchDetail, TSlsDispatchDetailRepository>;
  FOrderRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_SLS_INVOICE;
end;

destructor TSlsInvoiceDetailService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
class procedure TSlsInvoiceDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
class procedure TSlsInvoiceDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

function TSlsInvoiceDetailService.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
begin
  Result := TSlsOrderDetailRepository(FOrderDetailRepo).GetInventoryDefaults(AInventoryId, APrice, ACurrency, ADiscountRate, AVatRate);
end;

// Fatura toplamları + stok özeti (irsaliyesiz kalem) + bağlı siparişin sevk miktarı / durumu
procedure TSlsInvoiceDetailService.AfterWrite(AInvoiceId, AInventoryId, AOrderDetailId: Int64);
var
  LOrderDetail: TSlsOrderDetail;
begin
  if AInvoiceId > 0 then
    TSlsInvoiceRepository(FInvoiceRepo).RecalculateTotals(AInvoiceId);
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

// İrsaliyeli kalem: aynı stok, aynı müşteri, faturalanmamış sevk miktarı aşılamaz
procedure TSlsInvoiceDetailService.ValidateDispatchLink(AEntity: TSlsInvoiceDetail; AInvoice: TSlsInvoice);
var
  LDispatchDetail: TSlsDispatchDetail;
  LDispatch: TSlsDispatch;
  LOpen: Currency;
begin
  LDispatchDetail := FDispatchDetailRepo.FindById(AEntity.SlsDispatchDetailId, False);
  LDispatch := nil;
  try
    if not Assigned(LDispatchDetail) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.SlsDispatchDetailId]));
    if LDispatchDetail.StkInventoryId <> AEntity.StkInventoryId then
      raise ESlsInvoiceDetailExceptionInventoryMismatch.Create;
    LDispatch := FDispatchRepo.FindById(LDispatchDetail.SlsDispatchId, False);
    if not Assigned(LDispatch) or (LDispatch.AccAccountId <> AInvoice.AccAccountId) then
      raise ESlsInvoiceDetailExceptionCustomerMismatch.Create;
    LOpen := LDispatchDetail.Quantity - TSlsDispatchDetailRepository(FDispatchDetailRepo).InvoicedQuantity(AEntity.SlsDispatchDetailId, AEntity.Id);
    if AEntity.Quantity > LOpen then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.OverInvoice,
        'Quantity exceeds the delivered quantity not yet invoiced (%s).'), [CurrToStr(LOpen)]));
  finally
    LDispatchDetail.Free;
    LDispatch.Free;
  end;
end;

// İrsaliyesiz siparişli kalem: aynı stok, aynı müşteri, onaylı sipariş, açık sipariş miktarı aşılamaz
procedure TSlsInvoiceDetailService.ValidateOrderLink(AEntity: TSlsInvoiceDetail; AInvoice: TSlsInvoice; AOperation: TCrudOperation);
var
  LOrderDetail: TSlsOrderDetail;
  LOrder: TSlsOrder;
  LOpen: Currency;
begin
  LOrderDetail := FOrderDetailRepo.FindById(AEntity.SlsOrderDetailId, False);
  LOrder := nil;
  try
    if not Assigned(LOrderDetail) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.SlsOrderDetailId]));
    if LOrderDetail.StkInventoryId <> AEntity.StkInventoryId then
      raise ESlsInvoiceDetailExceptionInventoryMismatch.Create;
    LOrder := FOrderRepo.FindById(LOrderDetail.SlsOrderId, False);
    if not Assigned(LOrder) or (LOrder.AccAccountId <> AInvoice.AccAccountId) then
      raise ESlsInvoiceDetailExceptionCustomerMismatch.Create;
    if (AOperation = coInsert) and not (LOrder.Status in [SLS_ORD_APPROVED, SLS_ORD_PARTIAL]) then
      raise ESlsInvoiceDetailExceptionOrderStatus.Create;
    LOpen := LOrderDetail.Quantity -
      TSlsDispatchDetailRepository(FDispatchDetailRepo).DeliveredQuantityOfOrderDetail(AEntity.SlsOrderDetailId, 0, AEntity.Id);
    if AEntity.Quantity > LOpen then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.OverDelivery,
        'Quantity exceeds the open order quantity (%s).'), [CurrToStr(LOpen)]));
  finally
    LOrderDetail.Free;
    LOrder.Free;
  end;
end;

class procedure TSlsInvoiceDetailService.CheckLine(AEntity: TSlsInvoiceDetail);
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TSlsInvoiceDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TSlsInvoiceDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.UnitPrice < 0 then
    Fail(TLangKeys.TSlsInvoiceDetail.ColUnitPrice, 'Unit Price', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');
  if (AEntity.DiscountRate < 0) or (AEntity.DiscountRate > 100) or (AEntity.VatRate < 0) or (AEntity.VatRate > 100) then
    raise ESlsInvoiceDetailExceptionRateRange.Create;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TSlsLookup.CalculateLine(AEntity.Quantity, AEntity.UnitPrice, AEntity.DiscountRate, AEntity.VatRate, LGross, LDiscount, LNet, LVat, LTotal);
  AEntity.GrossAmount := LGross;
  AEntity.DiscountAmount := LDiscount;
  AEntity.NetAmount := LNet;
  AEntity.VatAmount := LVat;
  AEntity.TotalAmount := LTotal;
  if (AEntity.SlsDispatchDetailId > 0) and (AEntity.SlsOrderDetailId > 0) then
    raise ESlsInvoiceDetailExceptionSourceConflict.Create;
end;

function TSlsInvoiceDetailService.GetVatRates: TArray<Currency>;
begin
  Result := TSlsOfferDetailRepository(Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>).GetVatRates;
end;

function TSlsInvoiceDetailService.GetUomCode(AInventoryId: Int64): string;
begin
  Result := TSlsOfferDetailRepository(Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>).GetUomCode(AInventoryId);
end;

procedure TSlsInvoiceDetailService.RefreshDispatchStatus(ADispatchDetailId: Int64);
var
  LId: Int64;
begin
  if ADispatchDetailId <= 0 then
    Exit;
  for LId in TSlsDispatchDetailRepository(FDispatchDetailRepo).DispatchIdsOfDetails([ADispatchDetailId]) do
    TSlsDispatchRepository(FDispatchRepo).RefreshInvoiceStatus(LId);
end;

procedure TSlsInvoiceDetailService.ValidateBusinessRules(AEntity: TSlsInvoiceDetail; AOperation: TCrudOperation);
var
  LInvoice: TSlsInvoice;
  LFilter: TFilterCriteria;
  LModel: TSlsInvoiceDetail;
begin
  if AOperation = coDelete then
    Exit;

  if AEntity.SlsInvoiceId <= 0 then
    FailRequired(TLangKeys.TSlsInvoiceDetail.ColSlsInvoiceId, 'Invoice');
  CheckLine(AEntity);
  TSlsOfferDetailService.CheckVatRate(AEntity.VatRate, GetVatRates);

  LInvoice := FInvoiceRepo.FindById(AEntity.SlsInvoiceId, False);
  try
    if not Assigned(LInvoice) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.SlsInvoiceId]));
    if AEntity.SlsDispatchDetailId > 0 then
      ValidateDispatchLink(AEntity, LInvoice)
    else
    begin
      // irsaliyesiz kalem faturanın ambarından stok düşer
      if LInvoice.StkWarehouseId <= 0 then
        raise ESlsInvoiceDetailExceptionWarehouseRequired.Create;
      if AEntity.SlsOrderDetailId > 0 then
        ValidateOrderLink(AEntity, LInvoice, AOperation);
    end;
  finally
    LInvoice.Free;
  end;

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := TSlsInvoiceDetailRepository(FRepo).NextLineNo(AEntity.SlsInvoiceId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('sls_invoice_id', '=', TValue.From<Int64>(AEntity.SlsInvoiceId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsInvoiceDetailExceptionLineUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsInvoiceDetailService.DoAdd(AEntity: TSlsInvoiceDetail);
var
  LInventoryId: Int64;
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  LInventoryId := 0;
  if AEntity.SlsDispatchDetailId <= 0 then
  begin
    TSlsInvoiceDetailRepository(FRepo).UpsertStockTransaction(AEntity.Id);
    LInventoryId := AEntity.StkInventoryId;
  end;
  AfterWrite(AEntity.SlsInvoiceId, LInventoryId, AEntity.SlsOrderDetailId);
  RefreshDispatchStatus(AEntity.SlsDispatchDetailId);
end;

procedure TSlsInvoiceDetailService.DoUpdate(AEntity: TSlsInvoiceDetail);
var
  LOld: TSlsInvoiceDetail;
  LOldInvoiceId, LOldInventoryId, LOldOrderDetailId, LOldDispatchDetailId: Int64;
  LOldStockLine: Boolean;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldInvoiceId := LOld.SlsInvoiceId;
    LOldInventoryId := LOld.StkInventoryId;
    LOldOrderDetailId := LOld.SlsOrderDetailId;
    LOldDispatchDetailId := LOld.SlsDispatchDetailId;
    LOldStockLine := LOld.SlsDispatchDetailId <= 0;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  if AEntity.SlsDispatchDetailId <= 0 then
  begin
    TSlsInvoiceDetailRepository(FRepo).UpsertStockTransaction(AEntity.Id);
    AfterWrite(AEntity.SlsInvoiceId, AEntity.StkInventoryId, AEntity.SlsOrderDetailId);
  end
  else
  begin
    TSlsInvoiceDetailRepository(FRepo).DeleteStockTransaction(AEntity.Id);
    AfterWrite(AEntity.SlsInvoiceId, 0, AEntity.SlsOrderDetailId);
  end;
  if LOldInvoiceId <> AEntity.SlsInvoiceId then
    AfterWrite(LOldInvoiceId, 0, 0);
  if LOldStockLine and ((LOldInventoryId <> AEntity.StkInventoryId) or (AEntity.SlsDispatchDetailId > 0)) then
    AfterWrite(0, LOldInventoryId, 0);
  if LOldOrderDetailId <> AEntity.SlsOrderDetailId then
    AfterWrite(0, 0, LOldOrderDetailId);
  RefreshDispatchStatus(AEntity.SlsDispatchDetailId);
  if LOldDispatchDetailId <> AEntity.SlsDispatchDetailId then
    RefreshDispatchStatus(LOldDispatchDetailId);
end;

procedure TSlsInvoiceDetailService.DoDelete(AId: Int64);
var
  LEntity: TSlsInvoiceDetail;
  LInventoryId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // stok hareketi FK ile cascade silinir
    FRepo.Delete(LEntity);
    LInventoryId := 0;
    if LEntity.SlsDispatchDetailId <= 0 then
      LInventoryId := LEntity.StkInventoryId;
    AfterWrite(LEntity.SlsInvoiceId, LInventoryId, LEntity.SlsOrderDetailId);
    RefreshDispatchStatus(LEntity.SlsDispatchDetailId);
  finally
    LEntity.Free;
  end;
end;

function TSlsInvoiceDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsInvoiceDetail>;
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

function TSlsInvoiceDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsInvoiceDetail;
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

procedure TSlsInvoiceDetailService.BusinessInsert(AEntity: TSlsInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsInvoiceDetailService.BusinessUpdate(AEntity: TSlsInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsInvoiceDetailService.BusinessDelete(AEntity: TSlsInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsInvoiceDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSlsInvoiceDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsInvoiceDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSlsInvoiceDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsInvoiceDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSlsInvoiceDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsInvoiceDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsInvoiceDetailService.Add(AEntity: TSlsInvoiceDetail);
begin
  DoAdd(AEntity);
end;

procedure TSlsInvoiceDetailService.Update(AEntity: TSlsInvoiceDetail);
begin
  DoUpdate(AEntity);
end;

procedure TSlsInvoiceDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
