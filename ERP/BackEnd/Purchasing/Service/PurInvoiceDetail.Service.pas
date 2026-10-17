unit PurInvoiceDetail.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurInvoiceDetail.Repository, PurInvoiceDetail, PurInvoiceDetail.Exception, PurInvoice, PurInvoice.Repository, PurReceipt, PurReceipt.Repository, PurReceiptDetail, PurReceiptDetail.Repository, PurOrderDetail, PurOrderDetail.Repository;

type
  TPurInvoiceDetailService = class(TCrudService<TPurInvoiceDetail>)
  private
    FRepo: IRepository<TPurInvoiceDetail>;
    FInvoiceRepo: IRepository<TPurInvoice>;
    FReceiptRepo: IRepository<TPurReceipt>;
    FReceiptDetailRepo: IRepository<TPurReceiptDetail>;
    FOrderDetailRepo: IRepository<TPurOrderDetail>;

    procedure DoAdd(AEntity: TPurInvoiceDetail);
    procedure DoUpdate(AEntity: TPurInvoiceDetail);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    procedure Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurInvoiceDetail; AOperation: TCrudOperation); override;
    function GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
      out ADiscountRate, AVatRate: Currency): Boolean;

    // Satır formu: stok seçilince ölçü birimi ; KDV combo'su tanımlı oranlardan (acc_set_tax_rate)
    function GetUomCode(AInventoryId: Int64): string;
    function GetVatRates: TArray<Currency>;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurInvoiceDetail>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurInvoiceDetail; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurInvoiceDetail; override;

    procedure Add(AEntity: TPurInvoiceDetail); override;
    procedure Update(AEntity: TPurInvoiceDetail); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurInvoiceDetail; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurInvoiceDetail>; override;
    procedure BusinessInsert(AEntity: TPurInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, AccSetTaxRate, AccSetTaxRate.Repository, AccSetTaxRate.Service;

constructor TPurInvoiceDetailService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurInvoiceDetail, TPurInvoiceDetailRepository>;
  FInvoiceRepo := Self.UoW.GetRepository<TPurInvoice, TPurInvoiceRepository>;
  FReceiptRepo := Self.UoW.GetRepository<TPurReceipt, TPurReceiptRepository>;
  FReceiptDetailRepo := Self.UoW.GetRepository<TPurReceiptDetail, TPurReceiptDetailRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>;
  Self.PermissionCode := PERMISSION_PUR_INVOICE;
end;

destructor TPurInvoiceDetailService.Destroy;
begin
  inherited;
end;

function TPurInvoiceDetailService.GetUomCode(AInventoryId: Int64): string;
begin
  Result := TPurOrderDetailRepository(FOrderDetailRepo).GetUomCode(AInventoryId);
end;

function TPurInvoiceDetailService.GetVatRates: TArray<Currency>;
begin
  Result := TAccSetTaxRateRepository(Self.UoW.GetRepository<TAccSetTaxRate, TAccSetTaxRateRepository>).GetTaxRates;
end;

// Alan adı + "zorunludur" mesajı
procedure TPurInvoiceDetailService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Alan adı + mesaj
procedure TPurInvoiceDetailService.Fail(const AKey, ADefault, AMsgKey, AMsgDefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(AMsgKey, AMsgDefault));
end;

function TPurInvoiceDetailService.GetInventoryDefaults(AInventoryId: Int64; out APrice: Currency; out ACurrency: string;
  out ADiscountRate, AVatRate: Currency): Boolean;
begin
  Result := TPurOrderDetailRepository(FOrderDetailRepo).GetInventoryDefaults(AInventoryId, APrice, ACurrency, ADiscountRate, AVatRate);
end;

procedure TPurInvoiceDetailService.ValidateBusinessRules(AEntity: TPurInvoiceDetail; AOperation: TCrudOperation);
var
  LInvoice: TPurInvoice;
  LReceiptDetail: TPurReceiptDetail;
  LReceipt: TPurReceipt;
  LFilter: TFilterCriteria;
  LModel: TPurInvoiceDetail;
  LGross, LDiscount, LNet, LVat, LTotal, LOpen: Currency;
begin
  if AOperation = coDelete then
    Exit;

  AEntity.Description := Trim(AEntity.Description);
  if AEntity.PurInvoiceId <= 0 then
    FailRequired(TLangKeys.TPurInvoiceDetail.ColPurInvoiceId, 'Invoice');
  if AEntity.StkInventoryId <= 0 then
    FailRequired(TLangKeys.TPurInvoiceDetail.ColStkInventoryId, 'Stock Card');
  if AEntity.Quantity <= 0 then
    Fail(TLangKeys.TPurInvoiceDetail.ColQuantity, 'Quantity', TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero');
  if AEntity.UnitPrice < 0 then
    Fail(TLangKeys.TPurInvoiceDetail.ColUnitPrice, 'Unit Price', TLangKeys.TValidation.NegativeValueNotAllowed, 'Negative values are not allowed');
  if (AEntity.DiscountRate < 0) or (AEntity.DiscountRate > 100) or (AEntity.VatRate < 0) or (AEntity.VatRate > 100) then
    raise EPurInvoiceDetailExceptionRateRange.Create;
  // 0 = KDV'siz alış (istisna); diğer oranlar tanımlı oranlardan biri olmalı
  if AEntity.VatRate <> 0 then
    TAccSetTaxRateService.CheckDefinedRate(AEntity.VatRate, GetVatRates);
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TPurLookup.CalculateLine(AEntity.Quantity, AEntity.UnitPrice, AEntity.DiscountRate, AEntity.VatRate, LGross, LDiscount, LNet, LVat, LTotal);
  AEntity.GrossAmount := LGross;
  AEntity.DiscountAmount := LDiscount;
  AEntity.NetAmount := LNet;
  AEntity.VatAmount := LVat;
  AEntity.TotalAmount := LTotal;

  if AEntity.PurReceiptDetailId > 0 then
  begin
    LInvoice := FInvoiceRepo.FindById(AEntity.PurInvoiceId, False);
    LReceiptDetail := FReceiptDetailRepo.FindById(AEntity.PurReceiptDetailId, False);
    LReceipt := nil;
    try
      if not Assigned(LInvoice) or not Assigned(LReceiptDetail) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.PurReceiptDetailId]));
      if LReceiptDetail.StkInventoryId <> AEntity.StkInventoryId then
        raise EPurInvoiceDetailExceptionInventoryMismatch.Create;
      LReceipt := FReceiptRepo.FindById(LReceiptDetail.PurReceiptId, False);
      if not Assigned(LReceipt) or (LReceipt.AccAccountId <> LInvoice.AccAccountId) then
        raise EPurInvoiceDetailExceptionSupplierMismatch.Create;
      LOpen := LReceiptDetail.Quantity - TPurReceiptDetailRepository(FReceiptDetailRepo).InvoicedQuantity(AEntity.PurReceiptDetailId, AEntity.Id);
      if AEntity.Quantity > LOpen then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.OverInvoice,
          'Quantity exceeds the received quantity not yet invoiced (%s).'), [CurrToStr(LOpen)]));
    finally
      LInvoice.Free;
      LReceiptDetail.Free;
      LReceipt.Free;
    end;
  end;

  if AEntity.LineNo <= 0 then
    AEntity.LineNo := TPurInvoiceDetailRepository(FRepo).NextLineNo(AEntity.PurInvoiceId);
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('pur_invoice_id', '=', TValue.From<Int64>(AEntity.PurInvoiceId)));
    LFilter.Add(TFilterCriterion.New('line_no', '=', TValue.From<Integer>(AEntity.LineNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurInvoiceDetailExceptionLineUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurInvoiceDetailService.DoAdd(AEntity: TPurInvoiceDetail);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  TPurInvoiceRepository(FInvoiceRepo).RecalculateTotals(AEntity.PurInvoiceId);
end;

procedure TPurInvoiceDetailService.DoUpdate(AEntity: TPurInvoiceDetail);
var
  LOld: TPurInvoiceDetail;
  LOldInvoiceId: Int64;
begin
  LOld := FRepo.FindById(AEntity.Id, False);
  try
    if not Assigned(LOld) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
    LOldInvoiceId := LOld.PurInvoiceId;
  finally
    LOld.Free;
  end;

  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  TPurInvoiceRepository(FInvoiceRepo).RecalculateTotals(AEntity.PurInvoiceId);
  if LOldInvoiceId <> AEntity.PurInvoiceId then
    TPurInvoiceRepository(FInvoiceRepo).RecalculateTotals(LOldInvoiceId);
end;

procedure TPurInvoiceDetailService.DoDelete(AId: Int64);
var
  LEntity: TPurInvoiceDetail;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
    TPurInvoiceRepository(FInvoiceRepo).RecalculateTotals(LEntity.PurInvoiceId);
  finally
    LEntity.Free;
  end;
end;

function TPurInvoiceDetailService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurInvoiceDetail>;
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

function TPurInvoiceDetailService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurInvoiceDetail;
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

procedure TPurInvoiceDetailService.BusinessInsert(AEntity: TPurInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurInvoiceDetailService.BusinessUpdate(AEntity: TPurInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurInvoiceDetailService.BusinessDelete(AEntity: TPurInvoiceDetail; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurInvoiceDetailService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPurInvoiceDetailService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurInvoiceDetail>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurInvoiceDetailService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurInvoiceDetail;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPurInvoiceDetailService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurInvoiceDetail;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurInvoiceDetailService.Add(AEntity: TPurInvoiceDetail);
begin
  DoAdd(AEntity);
end;

procedure TPurInvoiceDetailService.Update(AEntity: TPurInvoiceDetail);
begin
  DoUpdate(AEntity);
end;

procedure TPurInvoiceDetailService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
