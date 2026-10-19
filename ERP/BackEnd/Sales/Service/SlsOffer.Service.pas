unit SlsOffer.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, SlsOffer.Repository, SlsOffer, SlsOffer.Exception, SlsOfferDetail, SlsOfferDetail.Repository,
  AccAccountAddress, AccAccountAddress.Repository, SysAddress, SysAddress.Repository,
  AccExchangeRate, AccExchangeRate.Repository;

type
  // Teklif belgesi = başlık + Lines (TDocumentService: kalem işlemleri, hesap tetikleme, yükleme, tek transaction'lı
  // kayıt + Reload). Okuma (BusinessFindById, FindById(…, True)) kalemleri de getirir. Domain yalnız veri taşır.
  TSlsOfferService = class(TDocumentService<TSlsOffer, TSlsOfferDetail>)
  private
    FRepo: IRepository<TSlsOffer>;
    FAddressRepo: IRepository<TAccAccountAddress>;
    FSysAddressRepo: IRepository<TSysAddress>;
    FRateRepo: IRepository<TAccExchangeRate>;
    // bu kayıtta yeni id alan adres nesneleri (hata olursa id geri alınır) ve kayıttan sonra silinecek eski adresler
    FNewAddresses: TList<TSysAddress>;
    FPendingAddressDeletes: TList<Int64>;

    procedure DoAdd(AEntity: TSlsOffer);
    procedure DoUpdate(AEntity: TSlsOffer);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // Kaynak cari adresi teklifin müşterisine ait olmalı; dolu adreste şehir zorunlu
    procedure CheckAddresses(AEntity: TSlsOffer);
    // Belgeye ait adresler (başlıktan önce, aynı transaction): boş -> silinir, kayıtlı -> güncellenir, yeni -> eklenir
    procedure SaveAddresses(AHeader: TSlsOffer);
    function SaveAddress(AAddress: TSysAddress; AHeaderId, AOldId: Int64): Int64;
    procedure DeletePendingAddresses;
    procedure LoadAddresses(AHeader: TSlsOffer);
    procedure LoadAddress(AId: Int64; ATarget: TSysAddress);
    // Belge kuru (boşsa teklif tarihinin kuru); rapor kurları yalnız yeni kayıtta otomatik
    procedure CheckRates(AEntity: TSlsOffer; AOperation: TCrudOperation);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TSlsOffer): TObjectList<TSlsOfferDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TSlsOfferDetail>; override;
    function GetLineHeaderId(ALine: TSlsOfferDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TSlsOfferDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TSlsOfferDetail): Integer; override;
    procedure SetLineNo(ALine: TSlsOfferDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TSlsOffer; ALine: TSlsOfferDetail); override;
    procedure CheckLines(AHeader: TSlsOffer; const ALines: TArray<TSlsOfferDetail>; AOldLines: TObjectList<TSlsOfferDetail>); override;
    procedure AfterDocumentSaved(AHeader: TSlsOffer; AOldLines: TObjectList<TSlsOfferDetail>); override;
    procedure BeforeHeaderSaved(AHeader: TSlsOffer); override;
    procedure AfterSaveFailed(AHeader: TSlsOffer); override;
    procedure PrepareCopyHeader(AHeader: TSlsOffer); override;
    procedure PrepareCopyLine(AHeader: TSlsOffer; ALine: TSlsOfferDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsOffer; AOperation: TCrudOperation); override;
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);

    // Cari adresi belgenin adresine kopyalanır (belgedeki adres id'si korunur; AAccountAddressId = 0: adres temizlenir)
    procedure ApplyAccountAddress(AHeader: TSlsOffer; AShipping: Boolean; AAccountAddressId: Int64);
    // Müşteri seçilince önerilen adresler: fatura = BILLING (yoksa birincil / LEGAL / ilk geçerli), teslimat = yalnız
    // SHIPPING (yoksa boş = fatura adresi)
    procedure ApplyDefaultAddresses(AHeader: TSlsOffer);
    // Ana para (muhasebe para birimi) ve 1 ACurrency = ? ana para (ADate gününe kadarki son döviz alış kuru; yoksa 0)
    function GetBaseCurrency: string;
    function GetExchangeRate(const ACurrency: string; ADate: TDate): Currency;

    // Kalem tutarları (brüt / iskonto / net / KDV / toplam) miktar, fiyat ve oranlardan; başlık toplamları aktif kalemlerden
    procedure RecalculateLine(ALine: TSlsOfferDetail); override;
    procedure RecalculateTotals(AHeader: TSlsOffer); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsOffer>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsOffer; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsOffer; override;

    procedure Add(AEntity: TSlsOffer); override;
    procedure Update(AEntity: TSlsOffer); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOffer; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOffer>; override;
    procedure BusinessInsert(AEntity: TSlsOffer; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsOffer; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsOffer; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsOfferDetail.Service, SlsOfferDetail.Exception, SysAddress.Service;

constructor TSlsOfferService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsOffer, TSlsOfferRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>;
  FAddressRepo := Self.UoW.GetRepository<TAccAccountAddress, TAccAccountAddressRepository>;
  FSysAddressRepo := Self.UoW.GetRepository<TSysAddress, TSysAddressRepository>;
  FRateRepo := Self.UoW.GetRepository<TAccExchangeRate, TAccExchangeRateRepository>;
  FNewAddresses := TList<TSysAddress>.Create;
  FPendingAddressDeletes := TList<Int64>.Create;
  Self.PermissionCode := PERMISSION_SLS_OFFER;
end;

destructor TSlsOfferService.Destroy;
begin
  FPendingAddressDeletes.Free;
  FNewAddresses.Free;
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsOfferService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

procedure TSlsOfferService.CheckAddresses(AEntity: TSlsOffer);

  procedure CheckSource(var AAddressId: Int64);
  var
    LSource: TAccAccountAddress;
  begin
    if AAddressId <= 0 then
    begin
      AAddressId := 0;
      Exit;
    end;
    LSource := FAddressRepo.FindById(AAddressId, False);
    try
      if not Assigned(LSource) then
        AAddressId := 0   // cari adresi silinmiş: belgedeki kopya kalır
      else if LSource.AccAccountId <> AEntity.AccAccountId then
        raise ESlsOfferExceptionAddressAccount.Create;
    finally
      LSource.Free;
    end;
  end;

  procedure CheckDetail(AAddress: TSysAddress; const AKey, ADefault: string);
  begin
    TSysAddressService.Normalize(AAddress);
    if not TSysAddressService.IsEmpty(AAddress) and (AAddress.SysCityId <= 0) then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsOffer.AddressCity,
        '%s: a city must be selected.'), [TLocalizationManager.Translate(AKey, ADefault)]));
  end;

var
  LId: Int64;
begin
  LId := AEntity.BillingAddressId;
  CheckSource(LId);
  AEntity.BillingAddressId := LId;
  LId := AEntity.ShippingAddressId;
  CheckSource(LId);
  AEntity.ShippingAddressId := LId;
  CheckDetail(AEntity.BillingAddress, TLangKeys.TSlsOffer.ColBillingAddress, 'Billing Address');
  CheckDetail(AEntity.ShippingAddress, TLangKeys.TSlsOffer.ColShippingAddress, 'Shipping Address');
end;

// AHeaderId: başlıktaki id (okunan değer), AOldId: tablodaki id
function TSlsOfferService.SaveAddress(AAddress: TSysAddress; AHeaderId, AOldId: Int64): Int64;
begin
  // adresler yüklenmeden (yalnız başlık) güncellenen belge: kayıtlı adrese dokunulmaz
  if (AAddress.Id <= 0) and (AOldId > 0) and (AHeaderId = AOldId) and TSysAddressService.IsEmpty(AAddress) then
    Exit(AOldId);
  if TSysAddressService.IsEmpty(AAddress) then
  begin
    if AOldId > 0 then
      FPendingAddressDeletes.Add(AOldId);
    AAddress.Id := 0;
    Exit(0);
  end;
  // yalnız bu belgenin kayıtlı adresi güncellenir; başka id (kopya, yeni nesne) yeni kayıt olur
  if (AAddress.Id > 0) and (AAddress.Id = AOldId) then
    FSysAddressRepo.Update(AAddress)
  else
  begin
    AAddress.Id := 0;
    FSysAddressRepo.Add(AAddress);
    FNewAddresses.Add(AAddress);
    if AOldId > 0 then
      FPendingAddressDeletes.Add(AOldId);
  end;
  Result := AAddress.Id;
end;

procedure TSlsOfferService.SaveAddresses(AHeader: TSlsOffer);
var
  LOldBilling, LOldShipping: Int64;
begin
  FNewAddresses.Clear;
  FPendingAddressDeletes.Clear;
  TSlsOfferRepository(FRepo).GetSysAddressIds(AHeader.Id, LOldBilling, LOldShipping);
  AHeader.BillingSysAddressId := SaveAddress(AHeader.BillingAddress, AHeader.BillingSysAddressId, LOldBilling);
  AHeader.ShippingSysAddressId := SaveAddress(AHeader.ShippingAddress, AHeader.ShippingSysAddressId, LOldShipping);
end;

// başlık artık eski adreslere bağlı değil
procedure TSlsOfferService.DeletePendingAddresses;
var
  LId: Int64;
begin
  for LId in FPendingAddressDeletes do
    FSysAddressRepo.Delete(LId);
  FPendingAddressDeletes.Clear;
  FNewAddresses.Clear;
end;

procedure TSlsOfferService.LoadAddress(AId: Int64; ATarget: TSysAddress);
var
  LSource: TSysAddress;
begin
  LSource := nil;
  if AId > 0 then
    LSource := FSysAddressRepo.FindById(AId, False);
  if not Assigned(LSource) then
    LSource := TSysAddress.Create;
  try
    TSysAddressService.CopyValues(LSource, ATarget, False);
  finally
    LSource.Free;
  end;
end;

procedure TSlsOfferService.LoadAddresses(AHeader: TSlsOffer);
begin
  LoadAddress(AHeader.BillingSysAddressId, AHeader.BillingAddress);
  LoadAddress(AHeader.ShippingSysAddressId, AHeader.ShippingAddress);
end;

procedure TSlsOfferService.ApplyAccountAddress(AHeader: TSlsOffer; AShipping: Boolean; AAccountAddressId: Int64);
var
  LTarget, LSource: TSysAddress;
  LAccountAddress: TAccAccountAddress;
  LKeepId: Int64;
begin
  if AShipping then
    LTarget := AHeader.ShippingAddress
  else
    LTarget := AHeader.BillingAddress;
  LKeepId := LTarget.Id;
  LSource := nil;
  LAccountAddress := nil;
  try
    if AAccountAddressId > 0 then
    begin
      LAccountAddress := FAddressRepo.FindById(AAccountAddressId, False);
      if Assigned(LAccountAddress) then
      begin
        if LAccountAddress.AccAccountId <> AHeader.AccAccountId then
          raise ESlsOfferExceptionAddressAccount.Create;
        LSource := FSysAddressRepo.FindById(LAccountAddress.SysAddressId, False);
      end;
    end;
    if not Assigned(LSource) then
    begin
      LSource := TSysAddress.Create;
      AAccountAddressId := 0;
    end;
    TSysAddressService.CopyValues(LSource, LTarget, False);
    LTarget.Id := LKeepId;
  finally
    LSource.Free;
    LAccountAddress.Free;
  end;
  if AShipping then
    AHeader.ShippingAddressId := AAccountAddressId
  else
    AHeader.BillingAddressId := AAccountAddressId;
end;

procedure TSlsOfferService.ApplyDefaultAddresses(AHeader: TSlsOffer);
var
  LRepo: TAccAccountAddressRepository;
begin
  LRepo := TAccAccountAddressRepository(FAddressRepo);
  ApplyAccountAddress(AHeader, False, LRepo.FindDocumentDefault(AHeader.AccAccountId, ACC_ADDRESS_BILLING, False));
  ApplyAccountAddress(AHeader, True, LRepo.FindDocumentDefault(AHeader.AccAccountId, ACC_ADDRESS_SHIPPING, True));
end;

function TSlsOfferService.GetBaseCurrency: string;
begin
  Result := TSlsOfferRepository(FRepo).GetDefaultCurrency;
end;

function TSlsOfferService.GetExchangeRate(const ACurrency: string; ADate: TDate): Currency;
begin
  Result := TAccExchangeRateRepository(FRateRepo).GetRate(ACurrency, ADate);
end;

procedure TSlsOfferService.CheckRates(AEntity: TSlsOffer; AOperation: TCrudOperation);
begin
  if AEntity.Currency = '' then
    AEntity.Currency := AEntity.BaseCurrency;
  if SameText(AEntity.Currency, AEntity.BaseCurrency) then
    AEntity.ExchangeRate := 1
  else if AEntity.ExchangeRate <= 0 then
  begin
    AEntity.ExchangeRate := GetExchangeRate(AEntity.Currency, AEntity.OfferDate);
    if AEntity.ExchangeRate <= 0 then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsOffer.NoExchangeRate,
        'No exchange rate for %s on %s; enter the rate manually.'), [AEntity.Currency, DateToStr(AEntity.OfferDate)]));
  end;
  // rapor kurları (kur tablosunda yoksa boş); güncellemede kullanıcının değeri (değişiklik yoksa kayıt değişmez)
  if AOperation <> coInsert then
    Exit;
  if AEntity.UsdRate <= 0 then
    AEntity.UsdRate := GetExchangeRate('USD', AEntity.OfferDate);
  if AEntity.EurRate <= 0 then
    AEntity.EurRate := GetExchangeRate('EUR', AEntity.OfferDate);
end;


// Elle durum değişikliği (onay / taslağa alma / red / iptal / kapama); kendi açtığı transaction'ı commit eder
procedure TSlsOfferService.ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
var
  LOld: TSlsOffer;
  LStarted: Boolean;
begin
  LStarted := False;
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);
    if not Self.UoW.InTransaction then
    begin
      Self.UoW.BeginTransaction;
      LStarted := True;
    end;

    LOld := FRepo.FindById(AId, True);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));
      if not TSlsLookup.CanChangeOfferStatus(LOld.Status, ANewStatus) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsOffer.InvalidStatus,
          'Status cannot be changed from "%s" to "%s".'), [TSlsLookup.Text(slkOfferStatus, LOld.Status), TSlsLookup.Text(slkOfferStatus, ANewStatus)]));
      if (ANewStatus = SLS_OFF_SENT) and (TSlsOfferRepository(FRepo).LineCount(AId) = 0) then
        raise ESlsOfferExceptionNoLines.Create;
      if (ANewStatus in [SLS_OFF_DRAFT, SLS_OFF_REJECTED]) and (TSlsOfferRepository(FRepo).OrderedTotal(AId) > 0) then
        raise ESlsOfferExceptionHasOrders.Create;
      TSlsOfferRepository(FRepo).SetStatus(AId, ANewStatus);
    finally
      LOld.Free;
    end;

    if LStarted and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

{ Belge (TDocumentService) }

function TSlsOfferService.GetLines(AHeader: TSlsOffer): TObjectList<TSlsOfferDetail>;
begin
  Result := AHeader.Lines;
end;

function TSlsOfferService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TSlsOfferDetail>;
begin
  Result := TSlsOfferDetailRepository(FLineRepo).FindByOfferIds(AIds);
end;

function TSlsOfferService.GetLineHeaderId(ALine: TSlsOfferDetail): Int64;
begin
  Result := ALine.SlsOfferId;
end;

procedure TSlsOfferService.SetLineHeaderId(ALine: TSlsOfferDetail; AHeaderId: Int64);
begin
  ALine.SlsOfferId := AHeaderId;
end;

function TSlsOfferService.GetLineNo(ALine: TSlsOfferDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TSlsOfferService.SetLineNo(ALine: TSlsOfferDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TSlsOfferService.RaiseDuplicateLineNo;
begin
  raise ESlsOfferDetailExceptionLineUnique.Create;
end;

// Kalem formunun fiyat önerisi / gösterimi için belge no ve para birimi
procedure TSlsOfferService.InitLine(AHeader: TSlsOffer; ALine: TSlsOfferDetail);
begin
  ALine.OfferNo := AHeader.OfferNo;
  ALine.Currency := AHeader.Currency;
end;

// Alanlar + tutarlar (tek kalem yoluyla ortak CheckLine), KDV tanımlı oranlardan
procedure TSlsOfferService.CheckLines(AHeader: TSlsOffer; const ALines: TArray<TSlsOfferDetail>; AOldLines: TObjectList<TSlsOfferDetail>);
var
  LLine: TSlsOfferDetail;
  LRates: TArray<Currency>;
begin
  LRates := TSlsOfferDetailRepository(FLineRepo).GetVatRates;
  for LLine in ALines do
  begin
    TSlsOfferDetailService.CheckLine(LLine);
    TSlsOfferDetailService.CheckVatRate(LLine.VatRate, LRates);
    if LLine.Id < 0 then
      LLine.OrderedQuantity := 0;   // siparişe aktarılan miktar sipariş kalemlerinden tutulur
  end;
end;

// Belge hook'u: siparişe aktarılan miktarlar ve otomatik durum (taslakta etkisiz, tutarlılık için)
procedure TSlsOfferService.AfterDocumentSaved(AHeader: TSlsOffer; AOldLines: TObjectList<TSlsOfferDetail>);
begin
  DeletePendingAddresses;
  TSlsOfferRepository(FRepo).RefreshOrderedQuantities(AHeader.Id);
end;

procedure TSlsOfferService.BeforeHeaderSaved(AHeader: TSlsOffer);
begin
  SaveAddresses(AHeader);
end;

// yalnız bu kayıtta id verilen adres nesneleri (başlığın nesneleri) yeni kayıt olarak geri döner
procedure TSlsOfferService.AfterSaveFailed(AHeader: TSlsOffer);
begin
  if FNewAddresses.Contains(AHeader.BillingAddress) then
    AHeader.BillingAddress.Id := 0;
  if FNewAddresses.Contains(AHeader.ShippingAddress) then
    AHeader.ShippingAddress.Id := 0;
  FNewAddresses.Clear;
  FPendingAddressDeletes.Clear;
end;

// kopya belge kendi adres kayıtlarını alır; kurlar yeni belgenin tarihinden (servis kayıtta doldurur)
procedure TSlsOfferService.PrepareCopyHeader(AHeader: TSlsOffer);
begin
  AHeader.OfferNo := '';
  AHeader.Status := SLS_OFF_DRAFT;
  AHeader.BillingSysAddressId := 0;
  AHeader.ShippingSysAddressId := 0;
  AHeader.BillingAddress.Id := 0;
  AHeader.ShippingAddress.Id := 0;
end;

procedure TSlsOfferService.PrepareCopyLine(AHeader: TSlsOffer; ALine: TSlsOfferDetail);
begin
  inherited;
  ALine.OfferNo := '';
  ALine.OrderedQuantity := 0;
end;

procedure TSlsOfferService.RecalculateLine(ALine: TSlsOfferDetail);
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TSlsLookup.CalculateLine(ALine.Quantity, ALine.UnitPrice, ALine.DiscountRate, ALine.VatRate,
    LGross, LDiscount, LNet, LVat, LTotal);
  ALine.GrossAmount := LGross;
  ALine.DiscountAmount := LDiscount;
  ALine.NetAmount := LNet;
  ALine.VatAmount := LVat;
  ALine.TotalAmount := LTotal;
end;

procedure TSlsOfferService.RecalculateTotals(AHeader: TSlsOffer);
var
  LLine: TSlsOfferDetail;
begin
  AHeader.GrossAmount := 0;
  AHeader.DiscountAmount := 0;
  AHeader.NetAmount := 0;
  AHeader.VatAmount := 0;
  AHeader.TotalAmount := 0;
  for LLine in AHeader.Lines do
    if not LLine.Deleted then
    begin
      AHeader.GrossAmount := AHeader.GrossAmount + LLine.GrossAmount;
      AHeader.DiscountAmount := AHeader.DiscountAmount + LLine.DiscountAmount;
      AHeader.NetAmount := AHeader.NetAmount + LLine.NetAmount;
      AHeader.VatAmount := AHeader.VatAmount + LLine.VatAmount;
      AHeader.TotalAmount := AHeader.TotalAmount + LLine.TotalAmount;
    end;
end;

procedure TSlsOfferService.ValidateBusinessRules(AEntity: TSlsOffer; AOperation: TCrudOperation);
var
  LRepo: TSlsOfferRepository;
  LOld: TSlsOffer;
  LFilter: TFilterCriteria;
  LModel: TSlsOffer;
begin
  LRepo := TSlsOfferRepository(FRepo);
  if AOperation = coDelete then
  begin
    if not (AEntity.Status in [SLS_OFF_DRAFT, SLS_OFF_REJECTED]) then
      raise ESlsOfferExceptionDraftOnly.Create;
    if LRepo.OrderedTotal(AEntity.Id) > 0 then
      raise ESlsOfferExceptionHasOrders.Create;
    Exit;
  end;

  AEntity.OfferNo := AnsiUpperCase(Trim(AEntity.OfferNo));
  AEntity.CustomerRefNo := Trim(AEntity.CustomerRefNo);
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.OfferDate <= 0 then
    FailRequired(TLangKeys.TSlsOffer.ColOfferDate, 'Offer Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TSlsOffer.ColAccAccountId, 'Customer');
  if (AEntity.ValidUntil > 0) and (AEntity.ValidUntil < AEntity.OfferDate) then
    raise ESlsOfferExceptionValidUntil.Create;
  if (AEntity.PaymentTermDays < 0) or (AEntity.PaymentTermDays > 365) then
    raise ESlsOfferExceptionPaymentTerm.Create;
  CheckAddresses(AEntity);

  if AOperation = coInsert then
  begin
    AEntity.BaseCurrency := LRepo.GetDefaultCurrency;
    // durum ve tutarlar servis tarafından tutulur (tutarlar kalemlerden)
    AEntity.Status := SLS_OFF_DRAFT;
    AEntity.GrossAmount := 0;
    AEntity.DiscountAmount := 0;
    AEntity.NetAmount := 0;
    AEntity.VatAmount := 0;
    AEntity.TotalAmount := 0;
    if AEntity.OfferNo = '' then
      AEntity.OfferNo := LRepo.NextDocumentNo(SLS_PREFIX_OFFER);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if LOld.Status <> SLS_OFF_DRAFT then
        raise ESlsOfferExceptionDraftOnly.Create;
      AEntity.Status := LOld.Status;
      AEntity.GrossAmount := LOld.GrossAmount;
      AEntity.DiscountAmount := LOld.DiscountAmount;
      AEntity.NetAmount := LOld.NetAmount;
      AEntity.VatAmount := LOld.VatAmount;
      AEntity.TotalAmount := LOld.TotalAmount;
      if AEntity.OfferNo = '' then
        AEntity.OfferNo := LOld.OfferNo;
      // ana para teklif açılırkenki muhasebe para birimi
      AEntity.BaseCurrency := LOld.BaseCurrency;
    finally
      LOld.Free;
    end;
  end;
  CheckRates(AEntity, AOperation);

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('offer_no', '=', TValue.From<string>(AEntity.OfferNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsOfferExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsOfferService.DoAdd(AEntity: TSlsOffer);
begin
  try
    ValidateAll(AEntity, coInsert);
    SaveAddresses(AEntity);
    FRepo.Add(AEntity);
    DeletePendingAddresses;
  except
    AfterSaveFailed(AEntity);
    raise;
  end;
end;

procedure TSlsOfferService.DoUpdate(AEntity: TSlsOffer);
begin
  try
    ValidateAll(AEntity, coUpdate);
    SaveAddresses(AEntity);
    FRepo.Update(AEntity);
    DeletePendingAddresses;
  except
    AfterSaveFailed(AEntity);
    raise;
  end;
end;

procedure TSlsOfferService.DoDelete(AId: Int64);
var
  LEntity: TSlsOffer;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
    // belgeye ait adresler teklifle birlikte silinir
    if LEntity.BillingSysAddressId > 0 then
      FSysAddressRepo.Delete(LEntity.BillingSysAddressId);
    if LEntity.ShippingSysAddressId > 0 then
      FSysAddressRepo.Delete(LEntity.ShippingSysAddressId);
  finally
    LEntity.Free;
  end;
end;

function TSlsOfferService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOffer>;
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

function TSlsOfferService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOffer;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    // belge: başlık + kalemler + adresler
    Result := FRepo.FindById(AId, ALock);
    if Assigned(Result) then
    begin
      LoadLines([Result]);
      LoadAddresses(Result);
    end;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSlsOfferService.BusinessInsert(AEntity: TSlsOffer; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOfferService.BusinessUpdate(AEntity: TSlsOffer; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOfferService.BusinessDelete(AEntity: TSlsOffer; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsOfferService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TSlsOfferService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsOffer>;
var
  LOffer: TSlsOffer;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
  begin
    LoadLines(Result.ToArray);
    for LOffer in Result do
      LoadAddresses(LOffer);
  end;
end;

function TSlsOfferService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsOffer;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
  begin
    LoadLines([Result]);
    LoadAddresses(Result);
  end;
end;

function TSlsOfferService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsOffer;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsOfferService.Add(AEntity: TSlsOffer);
begin
  DoAdd(AEntity);
end;

procedure TSlsOfferService.Update(AEntity: TSlsOffer);
begin
  DoUpdate(AEntity);
end;

procedure TSlsOfferService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
