unit PurOrderDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurOrderDetail.Repository, PurOrderDetail, PurOrderDetail.Exception, PurOrder, PurOrder.Repository, PurRequestDetail, PurRequestDetail.Repository, PurRequest, PurRequest.Repository;

type
  TPurOrderDetailService = class(TCrudService<TPurOrderDetail>)
  private
    FRepo: IRepository<TPurOrderDetail>;
    FOrderRepo: IRepository<TPurOrder>;
    FRequestDetailRepo: IRepository<TPurRequestDetail>;
    FRequestRepo: IRepository<TPurRequest>;

    procedure DoAdd(AEntity: TPurOrderDetail);
    procedure DoUpdate(AEntity: TPurOrderDetail);
    procedure DoDelete(AId: Int64);

    class procedure FailRequired(const AKey, ADefault: string); static;
    class procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string); static;
    procedure EnsureDraft(AOrderId: Int64);
    procedure AfterWrite(AOrderId, ARequestDetailId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    // Kalemin kendi alanları (DB'siz): stok, miktar, fiyat, oranlar + tutarların hesabı. Tek kalem kaydı
    // (ValidateBusinessRules) ve belge kaydı (TPurOrderService.BusinessSaveWithDetails) ortak kullanır
    class procedure CheckLine(AEntity: TPurOrderDetail); static;
    procedure ValidateBusinessRules(AEntity: TPurOrderDetail; AOperation: TCrudOperation); override;
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;

    // Satır formu: stok seçilince ölçü birimi ; KDV combo'su tanımlı oranlardan (acc_set_tax_rate)
    function GetUomCode(AInventoryId: Int64): string;
    function GetVatRates: TArray<Currency>;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurOrderDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurOrderDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurOrderDetail; override;

    procedure Add(AEntity: TPurOrderDetail); override;
    procedure Update(AEntity: TPurOrderDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurOrderDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurOrderDetail>; override;
    procedure BusinessInsert(AEntity: TPurOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, AccSetTaxRate, AccSetTaxRate.Repository, AccSetTaxRate.Service;

constructor TPurOrderDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>;
  FOrderRepo := Self.UoW.GetRepository<TPurOrder, TPurOrderRepository>;
  FRequestDetailRepo := Self.UoW.GetRepository<TPurRequestDetail, TPurRequestDetailRepository>;
  FRequestRepo := Self.UoW.GetRepository<TPurRequest, TPurRequestRepository>;
  Self.PermissionCode := PERMISSION_PUR_ORDER;
end;

destructor TPurOrderDetailService.Destroy;
begin
  inherited;
end;

function TPurOrderDetailService.GetUomCode(AInventoryId: Int64): string;
begin
  Result := TPurOrderDetailRepository(FRepo).GetUomCode(AInventoryId);
end;

function TPurOrderDetailService.GetVatRates: TArray<Currency>;
begin
  Result := TAccSetTaxRateRepository(Self.UoW.GetRepository<TAccSetTaxRate, TAccSetTaxRateRepository>).GetTaxRates;
end;

// Alan adı + "zorunludur" mesajı
class procedure TPurOrderDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
class procedure TPurOrderDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

class procedure TPurOrderDetailService.CheckLine(AEntity: TPurOrderDetail);
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TPurOrderDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TPurOrderDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.UnitPrice < 0 then
    Fail(TLangKeys.TPurOrderDetail.ColUnitPrice, 'Unit Price', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');
  if (AEntity.DiscountRate < 0) or (AEntity.DiscountRate > 100) or (AEntity.VatRate < 0) or (AEntity.VatRate > 100) then
    raise EPurOrderDetailExceptionRateRange.Create;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TPurLookup.CalculateLine(AEntity.Quantity, AEntity.UnitPrice, AEntity.DiscountRate, AEntity.VatRate, LGross, LDiscount, LNet, LVat, LTotal);
  AEntity.GrossAmount := LGross;
  AEntity.DiscountAmount := LDiscount;
  AEntity.NetAmount := LNet;
  AEntity.VatAmount := LVat;
  AEntity.TotalAmount := LTotal;
end;

function TPurOrderDetailService.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
begin
  Result := TPurOrderDetailRepository(FRepo).GetInventoryDefaults(AInventoryId, APrice, ACurrency, ADiscountRate, AVatRate);
end;

procedure TPurOrderDetailService.EnsureDraft(AOrderId: Int64);
var
  LOrder: TPurOrder;
begin
  LOrder := FOrderRepo.FindById(AOrderId, False);
  try
    if not Assigned(LOrder) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AOrderId]));
    if LOrder.Status <> PUR_ORD_DRAFT then
      raise EPurOrderDetailExceptionDraftOnly.Create;
  finally
    LOrder.Free;
  end;
end;

// Sipariş toplamları + bağlı talebin sipariş edilen miktarı / durumu
procedure TPurOrderDetailService.AfterWrite(AOrderId, ARequestDetailId: Int64);
var
  LRequestDetail: TPurRequestDetail;
begin
  TPurOrderRepository(FOrderRepo).RecalculateTotals(AOrderId);
  if ARequestDetailId > 0 then
  begin
    LRequestDetail := FRequestDetailRepo.FindById(ARequestDetailId, False);
    try
      if Assigned(LRequestDetail) then
        TPurRequestRepository(FRequestRepo).RefreshOrderedQuantities(LRequestDetail.PurRequestId);
    finally
      LRequestDetail.Free;
    end;
  end;
end;

procedure TPurOrderDetailService.ValidateBusinessRules(AEntity: TPurOrderDetail; AOperation: TCrudOperation);
var
  LOld: TPurOrderDetail;
  LRequestDetail: TPurRequestDetail;
  LFilter: TFilterCriteria;
  LModel: TPurOrderDetail;
begin
  if AOperation = coDelete then
  begin
    EnsureDraft(AEntity.PurOrderId);
    Exit;
  end;

  if AEntity.PurOrderId <= 0 then
    FailRequired(TLangKeys.TPurOrderDetail.ColPurOrderId, 'Order');
  CheckLine(AEntity);
  TAccSetTaxRateService.CheckDefinedRate(AEntity.VatRate, GetVatRates);
  EnsureDraft(AEntity.PurOrderId);

  if AEntity.PurRequestDetailId > 0 then
  begin
    LRequestDetail := FRequestDetailRepo.FindById(AEntity.PurRequestDetailId, False);
    try
      if Assigned(LRequestDetail) and (LRequestDetail.StkInventoryId <> AEntity.StkInventoryId) then
        raise EPurOrderDetailExceptionInventoryMismatch.Create;
    finally
      LRequestDetail.Free;
    end;
  end;

  // teslim alınan miktar mal kabullerden tutulur
  if AOperation = coInsert then
    AEntity.ReceivedQuantity := 0
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if Assigned(LOld) then
      begin
        AEntity.ReceivedQuantity := LOld.ReceivedQuantity;
        if LOld.PurOrderId <> AEntity.PurOrderId then
          EnsureDraft(LOld.PurOrderId);
      end;
    finally
      LOld.Free;
    end;
  end;

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := TPurOrderDetailRepository(FRepo).NextLineNo(AEntity.PurOrderId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('pur_order_id', '=', TValue.From<Int64>(AEntity.PurOrderId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurOrderDetailExceptionLineUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurOrderDetailService.DoAdd(AEntity: TPurOrderDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  AfterWrite(AEntity.PurOrderId, AEntity.PurRequestDetailId);
end;

procedure TPurOrderDetailService.DoUpdate(AEntity: TPurOrderDetail);
var
  LOld: TPurOrderDetail;
  LOldOrderId, LOldRequestDetailId: Int64;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldOrderId := LOld.PurOrderId;
    LOldRequestDetailId := LOld.PurRequestDetailId;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  AfterWrite(AEntity.PurOrderId, AEntity.PurRequestDetailId);
  if (LOldOrderId <> AEntity.PurOrderId) or (LOldRequestDetailId <> AEntity.PurRequestDetailId) then
    AfterWrite(LOldOrderId, LOldRequestDetailId);
end;

procedure TPurOrderDetailService.DoDelete(AId: Int64);
var
  LEntity: TPurOrderDetail;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
    AfterWrite(LEntity.PurOrderId, LEntity.PurRequestDetailId);
  finally
    LEntity.Free;
  end;
end;

function TPurOrderDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurOrderDetail>;
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

function TPurOrderDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurOrderDetail;
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

procedure TPurOrderDetailService.BusinessInsert(AEntity: TPurOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurOrderDetailService.BusinessUpdate(AEntity: TPurOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurOrderDetailService.BusinessDelete(AEntity: TPurOrderDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurOrderDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPurOrderDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurOrderDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurOrderDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurOrderDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPurOrderDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurOrderDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurOrderDetailService.Add(AEntity: TPurOrderDetail);
begin
  DoAdd(AEntity);
end;

procedure TPurOrderDetailService.Update(AEntity: TPurOrderDetail);
begin
  DoUpdate(AEntity);
end;

procedure TPurOrderDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
