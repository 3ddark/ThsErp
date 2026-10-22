unit PurQuotationDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurQuotationDetail.Repository, PurQuotationDetail, PurQuotationDetail.Exception, PurQuotation, PurQuotation.Repository,
  PurRequestDetail, PurRequestDetail.Repository, PurOrderDetail, PurOrderDetail.Repository;

type
  // Teklif kalemi (tek kalem yolu; belge ekranı kalemleri TPurQuotationService ile yazar). Kalemler yalnız taslak teklifte
  // değişir; tutarlar miktar / fiyat / oranlardan (sipariş kalemiyle aynı hesap)
  TPurQuotationDetailService = class(TCrudService<TPurQuotationDetail>)
  private
    FRepo: IRepository<TPurQuotationDetail>;
    FQuotationRepo: IRepository<TPurQuotation>;
    FRequestDetailRepo: IRepository<TPurRequestDetail>;

    procedure DoAdd(AEntity: TPurQuotationDetail);
    procedure DoUpdate(AEntity: TPurQuotationDetail);
    procedure DoDelete(AId: Int64);

    class procedure FailRequired(const AKey, ADefault: string); static;
    class procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string); static;
    procedure EnsureDraft(AQuotationId: Int64);
    procedure AfterWrite(AQuotationId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    // Kalemin kendi alanları (DB'siz): stok, miktar, fiyat, oranlar + tutarların hesabı. Tek kalem kaydı
    // (ValidateBusinessRules) ve belge kaydı (TPurQuotationService.BusinessSaveWithDetails) ortak kullanır
    class procedure CheckLine(AEntity: TPurQuotationDetail); static;
    // Talep kalemi bağlantısı: aynı stok, teklifin talebine ait (ARequestId 0 = teklif talepsiz)
    procedure CheckRequestLink(AEntity: TPurQuotationDetail; ARequestId: Int64);
    procedure ValidateBusinessRules(AEntity: TPurQuotationDetail; AOperation: TCrudOperation); override;

    // Satır formu: stok kartı varsayılanları (alış fiyatı / iskonto / KDV), ölçü birimi, tanımlı KDV oranları
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;
    function GetUomCode(AInventoryId: Int64): string;
    function GetVatRates: TArray<Currency>;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurQuotationDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurQuotationDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurQuotationDetail; override;

    procedure Add(AEntity: TPurQuotationDetail); override;
    procedure Update(AEntity: TPurQuotationDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurQuotationDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurQuotationDetail>; override;
    procedure BusinessInsert(AEntity: TPurQuotationDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurQuotationDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurQuotationDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, AccSetTaxRate, AccSetTaxRate.Repository, AccSetTaxRate.Service;

constructor TPurQuotationDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurQuotationDetail, TPurQuotationDetailRepository>;
  FQuotationRepo := Self.UoW.GetRepository<TPurQuotation, TPurQuotationRepository>;
  FRequestDetailRepo := Self.UoW.GetRepository<TPurRequestDetail, TPurRequestDetailRepository>;
  Self.PermissionCode := PERMISSION_PUR_QUOTATION;
end;

destructor TPurQuotationDetailService.Destroy;
begin
  inherited;
end;

// stok kartı varsayılanları ve ölçü birimi sipariş kalemiyle aynı kaynaktan (stok kartı)
function TPurQuotationDetailService.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
begin
  Result := TPurOrderDetailRepository(Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>)
    .GetInventoryDefaults(AInventoryId, APrice, ACurrency, ADiscountRate, AVatRate);
end;

function TPurQuotationDetailService.GetUomCode(AInventoryId: Int64): string;
begin
  Result := TPurOrderDetailRepository(Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>).GetUomCode(AInventoryId);
end;

function TPurQuotationDetailService.GetVatRates: TArray<Currency>;
begin
  Result := TAccSetTaxRateRepository(Self.UoW.GetRepository<TAccSetTaxRate, TAccSetTaxRateRepository>).GetTaxRates;
end;

// Alan adı + "zorunludur" mesajı
class procedure TPurQuotationDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
class procedure TPurQuotationDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

class procedure TPurQuotationDetailService.CheckLine(AEntity: TPurQuotationDetail);
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TPurQuotationDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TPurQuotationDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.UnitPrice < 0 then
    Fail(TLangKeys.TPurQuotationDetail.ColUnitPrice, 'Unit Price', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');
  if (AEntity.DiscountRate < 0) or (AEntity.DiscountRate > 100) or (AEntity.VatRate < 0) or (AEntity.VatRate > 100) then
    raise EPurQuotationDetailExceptionRateRange.Create;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TPurLookup.CalculateLine(AEntity.Quantity, AEntity.UnitPrice, AEntity.DiscountRate, AEntity.VatRate, LGross, LDiscount, LNet, LVat, LTotal);
  AEntity.GrossAmount := LGross;
  AEntity.DiscountAmount := LDiscount;
  AEntity.NetAmount := LNet;
  AEntity.VatAmount := LVat;
  AEntity.TotalAmount := LTotal;
end;

procedure TPurQuotationDetailService.CheckRequestLink(AEntity: TPurQuotationDetail; ARequestId: Int64);
var
  LRequestDetail: TPurRequestDetail;
begin
  if AEntity.PurRequestDetailId <= 0 then
    Exit;
  LRequestDetail := FRequestDetailRepo.FindById(AEntity.PurRequestDetailId, False);
  try
    if not Assigned(LRequestDetail) then
      Exit;
    if LRequestDetail.StkInventoryId <> AEntity.StkInventoryId then
      raise EPurQuotationDetailExceptionInventoryMismatch.Create;
    if LRequestDetail.PurRequestId <> ARequestId then
      raise EPurQuotationDetailExceptionRequestMismatch.Create;
  finally
    LRequestDetail.Free;
  end;
end;

procedure TPurQuotationDetailService.EnsureDraft(AQuotationId: Int64);
var
  LQuotation: TPurQuotation;
begin
  LQuotation := FQuotationRepo.FindById(AQuotationId, False);
  try
    if not Assigned(LQuotation) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AQuotationId]));
    if LQuotation.Status <> PUR_QUO_DRAFT then
      raise EPurQuotationDetailExceptionDraftOnly.Create;
  finally
    LQuotation.Free;
  end;
end;

// Teklif toplamları kalemlerden
procedure TPurQuotationDetailService.AfterWrite(AQuotationId: Int64);
begin
  TPurQuotationRepository(FQuotationRepo).RecalculateTotals(AQuotationId);
end;

procedure TPurQuotationDetailService.ValidateBusinessRules(AEntity: TPurQuotationDetail; AOperation: TCrudOperation);
var
  LQuotation: TPurQuotation;
  LFilter: TFilterCriteria;
  LModel: TPurQuotationDetail;
begin
  if AOperation = coDelete then
  begin
    EnsureDraft(AEntity.PurQuotationId);
    Exit;
  end;

  if AEntity.PurQuotationId <= 0 then
    FailRequired(TLangKeys.TPurQuotationDetail.ColPurQuotationId, 'Quotation');
  CheckLine(AEntity);
  TAccSetTaxRateService.CheckDefinedRate(AEntity.VatRate, GetVatRates);
  EnsureDraft(AEntity.PurQuotationId);
  LQuotation := FQuotationRepo.FindById(AEntity.PurQuotationId, False);
  try
    CheckRequestLink(AEntity, LQuotation.PurRequestId);
  finally
    LQuotation.Free;
  end;

  if AOperation = coUpdate then
  begin
    LModel := FRepo.FindById(AEntity.Id, False);
    try
      if Assigned(LModel) and (LModel.PurQuotationId <> AEntity.PurQuotationId) then
        EnsureDraft(LModel.PurQuotationId);
    finally
      LModel.Free;
    end;
  end;

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := TPurQuotationDetailRepository(FRepo).NextLineNo(AEntity.PurQuotationId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('pur_quotation_id', '=', TValue.From<Int64>(AEntity.PurQuotationId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurQuotationDetailExceptionLineUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurQuotationDetailService.DoAdd(AEntity: TPurQuotationDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  AfterWrite(AEntity.PurQuotationId);
end;

procedure TPurQuotationDetailService.DoUpdate(AEntity: TPurQuotationDetail);
var
  LOld: TPurQuotationDetail;
  LOldQuotationId: Int64;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldQuotationId := LOld.PurQuotationId;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  AfterWrite(AEntity.PurQuotationId);
  if LOldQuotationId <> AEntity.PurQuotationId then
    AfterWrite(LOldQuotationId);
end;

procedure TPurQuotationDetailService.DoDelete(AId: Int64);
var
  LEntity: TPurQuotationDetail;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
    AfterWrite(LEntity.PurQuotationId);
  finally
    LEntity.Free;
  end;
end;

function TPurQuotationDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurQuotationDetail>;
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

function TPurQuotationDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurQuotationDetail;
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

procedure TPurQuotationDetailService.BusinessInsert(AEntity: TPurQuotationDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurQuotationDetailService.BusinessUpdate(AEntity: TPurQuotationDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurQuotationDetailService.BusinessDelete(AEntity: TPurQuotationDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurQuotationDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPurQuotationDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurQuotationDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurQuotationDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurQuotationDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPurQuotationDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurQuotationDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurQuotationDetailService.Add(AEntity: TPurQuotationDetail);
begin
  DoAdd(AEntity);
end;

procedure TPurQuotationDetailService.Update(AEntity: TPurQuotationDetail);
begin
  DoUpdate(AEntity);
end;

procedure TPurQuotationDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
