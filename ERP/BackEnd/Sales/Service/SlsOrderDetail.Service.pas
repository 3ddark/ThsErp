unit SlsOrderDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SlsOrderDetail.Repository, SlsOrderDetail, SlsOrderDetail.Exception, SlsOrder, SlsOrder.Repository, SlsOfferDetail, SlsOfferDetail.Repository, SlsOffer, SlsOffer.Repository;

type
  TSlsOrderDetailService = class(TCrudService<TSlsOrderDetail>)
  private
    FRepo: IRepository<TSlsOrderDetail>;
    FOrderRepo: IRepository<TSlsOrder>;
    FOfferDetailRepo: IRepository<TSlsOfferDetail>;
    FOfferRepo: IRepository<TSlsOffer>;

    procedure DoAdd(AEntity: TSlsOrderDetail);
    procedure DoUpdate(AEntity: TSlsOrderDetail);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
    procedure EnsureDraft(AOrderId: Int64);
    procedure AfterWrite(AOrderId, AOfferDetailId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsOrderDetail; AOperation: TCrudOperation); override;
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsOrderDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsOrderDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsOrderDetail; override;

    procedure Add(AEntity: TSlsOrderDetail); override;
    procedure Update(AEntity: TSlsOrderDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOrderDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOrderDetail>; override;
    procedure BusinessInsert(AEntity: TSlsOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup;

constructor TSlsOrderDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  FOrderRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FOfferDetailRepo := Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>;
  FOfferRepo := Self.UoW.GetRepository<TSlsOffer, TSlsOfferRepository>;
  Self.PermissionCode := PERMISSION_SLS_ORDER;
end;

destructor TSlsOrderDetailService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsOrderDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
procedure TSlsOrderDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

function TSlsOrderDetailService.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
begin
  Result := TSlsOrderDetailRepository(FRepo).GetInventoryDefaults(AInventoryId, APrice, ACurrency, ADiscountRate, AVatRate);
end;

procedure TSlsOrderDetailService.EnsureDraft(AOrderId: Int64);
var
  LOrder: TSlsOrder;
begin
  LOrder := FOrderRepo.FindById(AOrderId, False);
  try
    if not Assigned(LOrder) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AOrderId]));
    if LOrder.Status <> SLS_ORD_DRAFT then
      raise ESlsOrderDetailExceptionDraftOnly.Create;
  finally
    LOrder.Free;
  end;
end;

// Sipariş toplamları + bağlı teklifin siparişe aktarılan miktarı / durumu
procedure TSlsOrderDetailService.AfterWrite(AOrderId, AOfferDetailId: Int64);
var
  LOfferDetail: TSlsOfferDetail;
begin
  TSlsOrderRepository(FOrderRepo).RecalculateTotals(AOrderId);
  if AOfferDetailId > 0 then
  begin
    LOfferDetail := FOfferDetailRepo.FindById(AOfferDetailId, False);
    try
      if Assigned(LOfferDetail) then
        TSlsOfferRepository(FOfferRepo).RefreshOrderedQuantities(LOfferDetail.SlsOfferId);
    finally
      LOfferDetail.Free;
    end;
  end;
end;

procedure TSlsOrderDetailService.ValidateBusinessRules(AEntity: TSlsOrderDetail; AOperation: TCrudOperation);
var
  LOld: TSlsOrderDetail;
  LOfferDetail: TSlsOfferDetail;
  LFilter: TFilterCriteria;
  LModel: TSlsOrderDetail;
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  if AOperation = coDelete then
  begin
    EnsureDraft(AEntity.SlsOrderId);
    Exit;
  end;

  AEntity.Description := Trim(AEntity.Description);
  if AEntity.SlsOrderId <= 0 then
    FailRequired(TLangKeys.TSlsOrderDetail.ColSlsOrderId, 'Order');
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TSlsOrderDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TSlsOrderDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.UnitPrice < 0 then
    Fail(TLangKeys.TSlsOrderDetail.ColUnitPrice, 'Unit Price', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');
  if (AEntity.DiscountRate < 0) or (AEntity.DiscountRate > 100) or (AEntity.VatRate < 0) or (AEntity.VatRate > 100) then
    raise ESlsOrderDetailExceptionRateRange.Create;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TSlsLookup.CalculateLine(AEntity.Quantity, AEntity.UnitPrice, AEntity.DiscountRate, AEntity.VatRate, LGross, LDiscount, LNet, LVat, LTotal);
  AEntity.GrossAmount := LGross;
  AEntity.DiscountAmount := LDiscount;
  AEntity.NetAmount := LNet;
  AEntity.VatAmount := LVat;
  AEntity.TotalAmount := LTotal;
  EnsureDraft(AEntity.SlsOrderId);

  if AEntity.SlsOfferDetailId > 0 then
  begin
    LOfferDetail := FOfferDetailRepo.FindById(AEntity.SlsOfferDetailId, False);
    try
      if Assigned(LOfferDetail) and (LOfferDetail.StkInventoryId <> AEntity.StkInventoryId) then
        raise ESlsOrderDetailExceptionInventoryMismatch.Create;
    finally
      LOfferDetail.Free;
    end;
  end;

  // sevk edilen miktar irsaliye / irsaliyeli fatura kalemlerinden tutulur
  if AOperation = coInsert then
    AEntity.DeliveredQuantity := 0
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if Assigned(LOld) then
      begin
        AEntity.DeliveredQuantity := LOld.DeliveredQuantity;
        if LOld.SlsOrderId <> AEntity.SlsOrderId then
          EnsureDraft(LOld.SlsOrderId);
      end;
    finally
      LOld.Free;
    end;
  end;

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := TSlsOrderDetailRepository(FRepo).NextLineNo(AEntity.SlsOrderId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('sls_order_id', '=', TValue.From<Int64>(AEntity.SlsOrderId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsOrderDetailExceptionLineUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsOrderDetailService.DoAdd(AEntity: TSlsOrderDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  AfterWrite(AEntity.SlsOrderId, AEntity.SlsOfferDetailId);
end;

procedure TSlsOrderDetailService.DoUpdate(AEntity: TSlsOrderDetail);
var
  LOld: TSlsOrderDetail;
  LOldOrderId, LOldOfferDetailId: Int64;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldOrderId := LOld.SlsOrderId;
    LOldOfferDetailId := LOld.SlsOfferDetailId;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  AfterWrite(AEntity.SlsOrderId, AEntity.SlsOfferDetailId);
  if (LOldOrderId <> AEntity.SlsOrderId) or (LOldOfferDetailId <> AEntity.SlsOfferDetailId) then
    AfterWrite(LOldOrderId, LOldOfferDetailId);
end;

procedure TSlsOrderDetailService.DoDelete(AId: Int64);
var
  LEntity: TSlsOrderDetail;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
    AfterWrite(LEntity.SlsOrderId, LEntity.SlsOfferDetailId);
  finally
    LEntity.Free;
  end;
end;

function TSlsOrderDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOrderDetail>;
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

function TSlsOrderDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOrderDetail;
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

procedure TSlsOrderDetailService.BusinessInsert(AEntity: TSlsOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOrderDetailService.BusinessUpdate(AEntity: TSlsOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOrderDetailService.BusinessDelete(AEntity: TSlsOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsOrderDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSlsOrderDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsOrderDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSlsOrderDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsOrderDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSlsOrderDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsOrderDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsOrderDetailService.Add(AEntity: TSlsOrderDetail);
begin
  DoAdd(AEntity);
end;

procedure TSlsOrderDetailService.Update(AEntity: TSlsOrderDetail);
begin
  DoUpdate(AEntity);
end;

procedure TSlsOrderDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
