unit SlsOfferDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SlsOfferDetail.Repository, SlsOfferDetail, SlsOfferDetail.Exception, SlsOffer, SlsOffer.Repository, SlsOrderDetail, SlsOrderDetail.Repository;

type
  TSlsOfferDetailService = class(TCrudService<TSlsOfferDetail>)
  private
    FRepo: IRepository<TSlsOfferDetail>;
    FOfferRepo: IRepository<TSlsOffer>;
    FOrderDetailRepo: IRepository<TSlsOrderDetail>;

    procedure DoAdd(AEntity: TSlsOfferDetail);
    procedure DoUpdate(AEntity: TSlsOfferDetail);
    procedure DoDelete(AId: Int64);

    class procedure FailRequired(const AKey, ADefault: string); static;
    class procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string); static;
    procedure EnsureDraft(AOfferId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    // Kalemin kendi alanları (DB'siz): stok, miktar, fiyat, oranlar + tutarların hesabı. Tek kalem kaydı
    // (ValidateBusinessRules) ve belge kaydı (TSlsOfferService.BusinessSaveWithDetails) ortak kullanır
    class procedure CheckLine(AEntity: TSlsOfferDetail); static;
    // KDV oranı tanımlı oranlardan biri olmalı (acc_set_tax_rate; tanım yoksa kontrol edilmez)
    class procedure CheckVatRate(ARate: Currency; const ARates: TArray<Currency>); static;
    function GetVatRates: TArray<Currency>;
    function GetUomCode(AInventoryId: Int64): string;
    procedure ValidateBusinessRules(AEntity: TSlsOfferDetail; AOperation: TCrudOperation); override;
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsOfferDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsOfferDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsOfferDetail; override;

    procedure Add(AEntity: TSlsOfferDetail); override;
    procedure Update(AEntity: TSlsOfferDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOfferDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOfferDetail>; override;
    procedure BusinessInsert(AEntity: TSlsOfferDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsOfferDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsOfferDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup;

constructor TSlsOfferDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>;
  FOfferRepo := Self.UoW.GetRepository<TSlsOffer, TSlsOfferRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  Self.PermissionCode := PERMISSION_SLS_OFFER;
end;

destructor TSlsOfferDetailService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
class procedure TSlsOfferDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
class procedure TSlsOfferDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

function TSlsOfferDetailService.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
begin
  Result := TSlsOrderDetailRepository(FOrderDetailRepo).GetInventoryDefaults(AInventoryId, APrice, ACurrency, ADiscountRate, AVatRate);
end;

procedure TSlsOfferDetailService.EnsureDraft(AOfferId: Int64);
var
  LOffer: TSlsOffer;
begin
  LOffer := FOfferRepo.FindById(AOfferId, False);
  try
    if not Assigned(LOffer) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AOfferId]));
    if LOffer.Status <> SLS_OFF_DRAFT then
      raise ESlsOfferDetailExceptionDraftOnly.Create;
  finally
    LOffer.Free;
  end;
end;

class procedure TSlsOfferDetailService.CheckLine(AEntity: TSlsOfferDetail);
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TSlsOfferDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TSlsOfferDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.UnitPrice < 0 then
    Fail(TLangKeys.TSlsOfferDetail.ColUnitPrice, 'Unit Price', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');
  if (AEntity.DiscountRate < 0) or (AEntity.DiscountRate > 100) or (AEntity.VatRate < 0) or (AEntity.VatRate > 100) then
    raise ESlsOfferDetailExceptionRateRange.Create;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TSlsLookup.CalculateLine(AEntity.Quantity, AEntity.UnitPrice, AEntity.DiscountRate, AEntity.VatRate, LGross, LDiscount, LNet, LVat, LTotal);
  AEntity.GrossAmount := LGross;
  AEntity.DiscountAmount := LDiscount;
  AEntity.NetAmount := LNet;
  AEntity.VatAmount := LVat;
  AEntity.TotalAmount := LTotal;
end;

class procedure TSlsOfferDetailService.CheckVatRate(ARate: Currency; const ARates: TArray<Currency>);
var
  LRate: Currency;
begin
  if Length(ARates) = 0 then
    Exit;
  for LRate in ARates do
    if LRate = ARate then
      Exit;
  raise ESlsOfferDetailExceptionVatRate.Create;
end;

function TSlsOfferDetailService.GetVatRates: TArray<Currency>;
begin
  Result := TSlsOfferDetailRepository(FRepo).GetVatRates;
end;

function TSlsOfferDetailService.GetUomCode(AInventoryId: Int64): string;
begin
  Result := TSlsOfferDetailRepository(FRepo).GetUomCode(AInventoryId);
end;

procedure TSlsOfferDetailService.ValidateBusinessRules(AEntity: TSlsOfferDetail; AOperation: TCrudOperation);
var
  LOld: TSlsOfferDetail;
  LFilter: TFilterCriteria;
  LModel: TSlsOfferDetail;
begin
  if AOperation = coDelete then
  begin
    EnsureDraft(AEntity.SlsOfferId);
    Exit;
  end;

  if AEntity.SlsOfferId <= 0 then
    FailRequired(TLangKeys.TSlsOfferDetail.ColSlsOfferId, 'Offer');
  CheckLine(AEntity);
  CheckVatRate(AEntity.VatRate, GetVatRates);
  EnsureDraft(AEntity.SlsOfferId);

  // siparişe aktarılan miktar sipariş kalemlerinden tutulur
  if AOperation = coInsert then
    AEntity.OrderedQuantity := 0
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if Assigned(LOld) then
      begin
        AEntity.OrderedQuantity := LOld.OrderedQuantity;
        if LOld.SlsOfferId <> AEntity.SlsOfferId then
          EnsureDraft(LOld.SlsOfferId);
      end;
    finally
      LOld.Free;
    end;
  end;

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := TSlsOfferDetailRepository(FRepo).NextLineNo(AEntity.SlsOfferId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('sls_offer_id', '=', TValue.From<Int64>(AEntity.SlsOfferId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsOfferDetailExceptionLineUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsOfferDetailService.DoAdd(AEntity: TSlsOfferDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  TSlsOfferRepository(FOfferRepo).RecalculateTotals(AEntity.SlsOfferId);
end;

procedure TSlsOfferDetailService.DoUpdate(AEntity: TSlsOfferDetail);
var
  LOld: TSlsOfferDetail;
  LOldOfferId: Int64;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldOfferId := LOld.SlsOfferId;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  TSlsOfferRepository(FOfferRepo).RecalculateTotals(AEntity.SlsOfferId);
  if LOldOfferId <> AEntity.SlsOfferId then
    TSlsOfferRepository(FOfferRepo).RecalculateTotals(LOldOfferId);
end;

procedure TSlsOfferDetailService.DoDelete(AId: Int64);
var
  LEntity: TSlsOfferDetail;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
    TSlsOfferRepository(FOfferRepo).RecalculateTotals(LEntity.SlsOfferId);
  finally
    LEntity.Free;
  end;
end;

function TSlsOfferDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOfferDetail>;
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

function TSlsOfferDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOfferDetail;
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

procedure TSlsOfferDetailService.BusinessInsert(AEntity: TSlsOfferDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOfferDetailService.BusinessUpdate(AEntity: TSlsOfferDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOfferDetailService.BusinessDelete(AEntity: TSlsOfferDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsOfferDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSlsOfferDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsOfferDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSlsOfferDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsOfferDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSlsOfferDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsOfferDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsOfferDetailService.Add(AEntity: TSlsOfferDetail);
begin
  DoAdd(AEntity);
end;

procedure TSlsOfferDetailService.Update(AEntity: TSlsOfferDetail);
begin
  DoUpdate(AEntity);
end;

procedure TSlsOfferDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
