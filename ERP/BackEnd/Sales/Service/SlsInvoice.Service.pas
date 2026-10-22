unit SlsInvoice.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, SlsInvoice.Repository, SlsInvoice, SlsInvoice.Exception, SlsInvoiceDetail, SlsInvoiceDetail.Repository,
  SlsDispatch, SlsDispatch.Repository, SlsOrder, SlsOrder.Repository, SlsDispatchDetail, SlsDispatchDetail.Repository,
  SlsOrderDetail, SlsOrderDetail.Repository, StkInventorySummary, StkInventorySummary.Repository;

type
  // Satış faturası belgesi = başlık + Lines (TDocumentService). Kalem hook'u: irsaliyesiz kalemin stok çıkışı; belge
  // hook'u: stok özeti, siparişlerin sevk miktarları, irsaliyelerin durumu. e-Belge (UBL-TR 1.2.1) alanları ve
  // kuralları CheckEInvoice'ta (senaryo / fatura tipi / istisna / tevkifat / GTİP / DİİB / ihracat kap bilgisi).
  TSlsInvoiceService = class(TDocumentService<TSlsInvoice, TSlsInvoiceDetail>)
  private
    FRepo: IRepository<TSlsInvoice>;
    // Belge kaydında e-belge kuralları CheckLines'ta (bellekteki kalemlerle) çalıştı; başlık kuralları tekrar etmez
    FEInvCheckedHeader: TSlsInvoice;
    FDispatchRepo: IRepository<TSlsDispatch>;
    FOrderRepo: IRepository<TSlsOrder>;
    FDispatchDetailRepo: IRepository<TSlsDispatchDetail>;
    FOrderDetailRepo: IRepository<TSlsOrderDetail>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TSlsInvoice);
    procedure DoUpdate(AEntity: TSlsInvoice);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // Yalnız başlık kaydı (BusinessInsert / Update): e-belge kuralları DB'deki kalemlerle
    procedure CheckEInvoiceFromDb(AEntity: TSlsInvoice);
    // Sipariş kurundan / vadesinden fatura başlığı
    procedure ApplyOrderTerms(AInvoice: TSlsInvoice; AOrderId: Int64);
    // İhracat dışındaki faturada cari vergi no (tüzel kişide vergi dairesi de) zorunlu; faturada saklanacak kopyaya bakılır
    procedure CheckPartyTaxInfo(AEntity: TSlsInvoice);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TSlsInvoice): TObjectList<TSlsInvoiceDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TSlsInvoiceDetail>; override;
    function GetLineHeaderId(ALine: TSlsInvoiceDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TSlsInvoiceDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TSlsInvoiceDetail): Integer; override;
    procedure SetLineNo(ALine: TSlsInvoiceDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TSlsInvoice; ALine: TSlsInvoiceDetail); override;
    procedure CheckLines(AHeader: TSlsInvoice; const ALines: TArray<TSlsInvoiceDetail>; AOldLines: TObjectList<TSlsInvoiceDetail>); override;
    procedure AfterLineSaved(AHeader: TSlsInvoice; ALine: TSlsInvoiceDetail); override;
    procedure AfterDocumentSaved(AHeader: TSlsInvoice; AOldLines: TObjectList<TSlsInvoiceDetail>); override;
    procedure PrepareCopyHeader(AHeader: TSlsInvoice); override;
    procedure PrepareCopyLine(AHeader: TSlsInvoice; ALine: TSlsInvoiceDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsInvoice; AOperation: TCrudOperation); override;

    // e-Belge başlığı: senaryo yoksa tip / ETTN / durum boşalır; senaryo varsa durum en az taslak, ETTN üretilir
    class procedure NormalizeEInvHeader(AHeader: TSlsInvoice); static;
    // e-Belge kuralları (belge kaydı + tek kalem yolu ortak). AOldHeader / AOldLines = DB durumu (yeni belgede nil /
    // boş): pasif kod yalnız yeni seçildiğinde reddedilir. AWholeDocument = kalemlerin tamamı verildi ("en az bir
    // kalemde tevkifat" gibi belge geneli kurallar yalnız o zaman)
    class procedure CheckEInvoice(ARepo: TSlsInvoiceRepository; AHeader: TSlsInvoice; const ALines: TArray<TSlsInvoiceDetail>;
      AOldHeader: TSlsInvoice; AOldLines: TObjectList<TSlsInvoiceDetail>; AWholeDocument: Boolean); static;

    // e-Belge alanlarının uygulanabilirliği (kurallar kod listelerinin bayraklarından). Formlar alanları buna göre açar /
    // kapatır; CheckEInvoice aynı kapsamla uygulanamayan alanları temizler ve kuralları denetler.
    class function ScopeFromRules(const R: TSlsEInvRules; AHeader: TSlsInvoice;
      const ALines: TArray<TSlsInvoiceDetail>): TSlsEInvScope; static;
    class function GetEInvScope(ARepo: TSlsInvoiceRepository; AHeader: TSlsInvoice;
      const ALines: TArray<TSlsInvoiceDetail>): TSlsEInvScope; static;
    // Uygulanamayan alanlar boşalır: kağıt faturada ödeme şekli, ihracat dışında teslim / taşıma / gümrük çıkış bilgileri,
    // DİİB istemeyen istisnada DİİB satır kodları, ihracat / GTİP isteyen istisna dışında kalem GTİP + kap bilgisi
    class procedure ClearNotApplicable(const AScope: TSlsEInvScope; AHeader: TSlsInvoice;
      const ALines: TArray<TSlsInvoiceDetail>); static;
    class procedure ClearNotApplicableHeader(const AScope: TSlsEInvScope; AHeader: TSlsInvoice); static;
    // satır formu da kullanır (yalnız kalem alanları; tevkifat burada değil: KDV'siz / izinsiz tevkifat reddedilir)
    class procedure ClearNotApplicableLine(const AScope: TSlsEInvScope; ALine: TSlsInvoiceDetail); static;
    // Detaylı form: bellekteki aktif kalemlerle
    function EInvScope(AHeader: TSlsInvoice): TSlsEInvScope;

    // Senaryo boşsa cariye göre önerir (e-Fatura mükellefi: TEMELFATURA, değilse EARSIVFATURA; tip SATIS)
    procedure SuggestEInv(AInvoice: TSlsInvoice; AEInvoiceUser: Boolean);
    // Senaryo seçilip tip boşsa: IHRACAT -> ISTISNA, diğerleri -> SATIS
    procedure SuggestInvoiceType(AInvoice: TSlsInvoice);

    // Kalem tutarları miktar, fiyat ve oranlardan; başlık toplamları aktif kalemlerden
    procedure RecalculateLine(ALine: TSlsInvoiceDetail); override;
    procedure RecalculateTotals(AHeader: TSlsInvoice); override;
    // İrsaliyenin faturalanmamış miktarlarından satış faturası (fiyat / iskonto / KDV sipariş kaleminden); yeni fatura id
    function CreateFromDispatch(ADispatchId: Int64; APermissionControl: Boolean): Int64;
    // Onaylı siparişin sevk edilmemiş miktarlarından irsaliyeli fatura (stok faturadan, verilen ambardan düşer); yeni fatura id
    function CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsInvoice>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsInvoice; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsInvoice; override;

    procedure Add(AEntity: TSlsInvoice); override;
    procedure Update(AEntity: TSlsInvoice); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsInvoice; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsInvoice>; override;
    procedure BusinessInsert(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsInvoiceDetail.Service, SlsInvoiceDetail.Exception,
  SlsOfferDetail, SlsOfferDetail.Repository, SlsOfferDetail.Service, EInvLookup,
  EInvDocument, EInvDocument.Repository, EInvDocument.Service, EInvSeries, EInvSeries.Repository, AccLookup;

// Alan adı + "zorunludur" (sınıf metotları için)
procedure RaiseRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

// Yeni seçilen (eskisinden farklı) kod pasifse ret
procedure CheckActive(AActive: Boolean; ANewId, AOldId: Int64; const AKey, ADefault: string);
begin
  if (ANewId > 0) and (ANewId <> AOldId) and not AActive then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.EInvInactive,
      '%s: the selected record is passive.'), [TLocalizationManager.Translate(AKey, ADefault)]));
end;

class procedure TSlsInvoiceService.NormalizeEInvHeader(AHeader: TSlsInvoice);
begin
  AHeader.CustomsDeclarationNo := AnsiUpperCase(Trim(AHeader.CustomsDeclarationNo));
  AHeader.GtbRefNo := AnsiUpperCase(Trim(AHeader.GtbRefNo));
  if AHeader.EinvProfileId <= 0 then
  begin
    // kağıt fatura: e-belge kimliği yok
    AHeader.EinvProfileId := 0;
    AHeader.EinvInvoiceTypeId := 0;
    AHeader.EinvUuid := '';
    AHeader.EinvStatus := 0;
    AHeader.ProfileCode := '';
    AHeader.InvoiceTypeCode := '';
  end
  else
  begin
    if AHeader.EinvStatus <= 0 then
      AHeader.EinvStatus := EINV_STATUS_DRAFT;
    if AHeader.EinvUuid = '' then
      AHeader.EinvUuid := LowerCase(TGUID.NewGuid.ToString.Replace('{', '').Replace('}', ''));
  end;
end;

class function TSlsInvoiceService.ScopeFromRules(const R: TSlsEInvRules; AHeader: TSlsInvoice;
  const ALines: TArray<TSlsInvoiceDetail>): TSlsEInvScope;
var
  LLine: TSlsInvoiceDetail;
  LHasExemption: Boolean;
begin
  Result := Default(TSlsEInvScope);
  for LLine in ALines do
    if not LLine.Deleted and (LLine.VatRate = 0) then
      Result.HasZeroVatLine := True;
  LHasExemption := AHeader.EinvTaxExemptionId > 0;
  Result.IsEDoc := AHeader.EinvProfileId > 0;
  Result.IsExport := Result.IsEDoc and R.RequiresExportInfo;
  Result.ExemptionRequired := Result.IsEDoc and R.RequiresExemption;
  Result.ExemptionNeedsZeroVat := LHasExemption and R.ExemptionRequiresZeroVat;
  Result.ExemptionTypeMismatch := Result.IsEDoc and LHasExemption and (R.ExemptionTypeId > 0) and
    (R.ExemptionTypeId <> AHeader.EinvInvoiceTypeId);
  // %0 KDV'li kalem istisna kodu ister; KDV'li faturada yalnız tipin %0 gerektirmeyen kodları (555, ÖTV, özel matrah)
  Result.ExemptionAvailable := LHasExemption or Result.ExemptionRequired or Result.HasZeroVatLine or
    (Result.IsEDoc and R.TypeHasPlainExemption);
  Result.WithholdingAllowed := (not Result.IsEDoc) or R.RequiresWithholding;
  Result.WithholdingRequired := Result.IsEDoc and R.RequiresWithholding;
  // GİB: SATICIDIBSATIRKOD / ALICIDIBSATIRKOD yalnız İhraç Kayıtlı tipte 702 kodunda kalemde kullanılır
  Result.DiibAllowed := LHasExemption and R.ExemptionRequiresDiib;
  Result.GtipRequired := Result.IsExport or (LHasExemption and R.ExemptionRequiresGtip);
  Result.CustomsLine := Result.GtipRequired;
  Result.PackageRequired := Result.IsExport;
end;

class function TSlsInvoiceService.GetEInvScope(ARepo: TSlsInvoiceRepository; AHeader: TSlsInvoice;
  const ALines: TArray<TSlsInvoiceDetail>): TSlsEInvScope;
var
  R: TSlsEInvRules;
begin
  R := ARepo.ReadEInvRules(AHeader.EinvProfileId, AHeader.EinvInvoiceTypeId, AHeader.EinvTaxExemptionId,
    AHeader.EinvDeliveryTermId, AHeader.EinvTransportModeId, AHeader.EinvPaymentMeansId);
  Result := ScopeFromRules(R, AHeader, ALines);
end;

procedure TSlsInvoiceService.CheckPartyTaxInfo(AEntity: TSlsInvoice);
var
  LTaxpayerType: Integer;
  LTaxOffice, LTaxNo: string;
begin
  if (AEntity.AccAccountId <= 0) or EInvScope(AEntity).IsExport then
    Exit;
  TSlsInvoiceRepository(FRepo).ReadEffectiveParty(AEntity.Id, AEntity.AccAccountId, LTaxpayerType, LTaxOffice, LTaxNo);
  if Trim(LTaxNo) = '' then
    raise ESlsInvoiceExceptionTaxNoRequired.Create;
  if (LTaxpayerType = ACC_TAXPAYER_LEGAL) and (Trim(LTaxOffice) = '') then
    raise ESlsInvoiceExceptionTaxOfficeRequired.Create;
end;

function TSlsInvoiceService.EInvScope(AHeader: TSlsInvoice): TSlsEInvScope;
begin
  Result := GetEInvScope(TSlsInvoiceRepository(FRepo), AHeader, ActiveLines(AHeader));
end;

class procedure TSlsInvoiceService.ClearNotApplicable(const AScope: TSlsEInvScope; AHeader: TSlsInvoice;
  const ALines: TArray<TSlsInvoiceDetail>);
var
  LLine: TSlsInvoiceDetail;
begin
  ClearNotApplicableHeader(AScope, AHeader);
  for LLine in ALines do
    ClearNotApplicableLine(AScope, LLine);
end;

class procedure TSlsInvoiceService.ClearNotApplicableHeader(const AScope: TSlsEInvScope; AHeader: TSlsInvoice);
begin
  if not AScope.IsEDoc then
  begin
    AHeader.EinvPaymentMeansId := 0;
    AHeader.PaymentMeansName := '';
  end;
  if not AScope.IsExport then
  begin
    AHeader.EinvDeliveryTermId := 0;
    AHeader.DeliveryTermCode := '';
    AHeader.EinvTransportModeId := 0;
    AHeader.TransportModeName := '';
    AHeader.CustomsDeclarationNo := '';
    AHeader.GtbRefNo := '';
    AHeader.ActualExportDate := 0;
  end;
end;

class procedure TSlsInvoiceService.ClearNotApplicableLine(const AScope: TSlsEInvScope; ALine: TSlsInvoiceDetail);
begin
  if not AScope.DiibAllowed then
  begin
    ALine.SellerEinvDiibLineId := 0;
    ALine.SellerDiibLineCode := '';
    ALine.BuyerEinvDiibLineId := 0;
    ALine.BuyerDiibLineCode := '';
  end;
  if not AScope.CustomsLine then
  begin
    ALine.EinvGtipId := 0;
    ALine.GtipCode := '';
    ALine.EinvPackagingTypeId := 0;
    ALine.PackagingTypeCode := '';
    ALine.PackageNo := '';
    ALine.PackageQuantity := 0;
    ALine.PackageBrand := '';
  end;
end;

class procedure TSlsInvoiceService.CheckEInvoice(ARepo: TSlsInvoiceRepository; AHeader: TSlsInvoice;
  const ALines: TArray<TSlsInvoiceDetail>; AOldHeader: TSlsInvoice; AOldLines: TObjectList<TSlsInvoiceDetail>;
  AWholeDocument: Boolean);
var
  R: TSlsEInvRules;
  S: TSlsEInvScope;
  LOld: TSlsInvoice;
  LOldLines: TDictionary<Int64, TSlsInvoiceDetail>;
  LLine, LOldLine: TSlsInvoiceDetail;
  LNo, i: Integer;
  LIsEDoc, LNeedGtip, LNeedDiib, LNeedPackage, LHasWithholding, LActive: Boolean;
  LRate: Currency;
  LCode: string;
  LGtipId: Int64;
  LOldProfileId, LOldTypeId, LOldExemptionId, LOldDeliveryId, LOldTransportId, LOldPaymentId: Int64;

  // Kalemin DİİB satırı: belge sahibi / müşteri, süre, GTİP uyumu (kalem GTİP'i boşsa DİİB satırından)
  procedure CheckDiib(ADiibLineId, AOldDiibLineId: Int64; AHolder: Integer; const AKey, ADefault: string);
  var
    D: TSlsDiibLineInfo;
    LChanged: Boolean;
  begin
    if ADiibLineId <= 0 then
      Exit;
    D := ARepo.ReadDiibLine(ADiibLineId);
    if not D.Found then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADiibLineId]));
    LChanged := ADiibLineId <> AOldDiibLineId;
    CheckActive(D.Active and D.DiibActive, ADiibLineId, AOldDiibLineId, AKey, ADefault);
    if (D.HolderType <> AHolder) or ((AHolder = EINV_DIIB_CUSTOMER) and (D.AccountId <> AHeader.AccAccountId)) then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.DiibHolderMismatch,
        'Line %d: DIIB line %s does not belong to this invoice (holder / customer).'), [LNo, D.LineCode]));
    if LChanged and (D.ValidUntil > 0) and (AHeader.InvoiceDate > D.ValidUntil) then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.DiibExpired,
        'Line %d: the DIIB certificate has expired (%s).'), [LNo, DateToStr(D.ValidUntil)]));
    if LLine.EinvGtipId <= 0 then
    begin
      LLine.EinvGtipId := D.GtipId;
      LLine.GtipCode := D.GtipCode;
    end
    else if LLine.EinvGtipId <> D.GtipId then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.DiibGtipMismatch,
        'Line %d: the GTIP code must match the DIIB line GTIP (%s).'), [LNo, TEInvLookup.FormatGtip(D.GtipCode)]));
  end;

begin
  NormalizeEInvHeader(AHeader);
  LOld := AOldHeader;
  if Assigned(LOld) and (LOld.Id <> AHeader.Id) then
    LOld := nil;
  LOldProfileId := 0; LOldTypeId := 0; LOldExemptionId := 0; LOldDeliveryId := 0; LOldTransportId := 0; LOldPaymentId := 0;
  if Assigned(LOld) then
  begin
    LOldProfileId := LOld.EinvProfileId;
    LOldTypeId := LOld.EinvInvoiceTypeId;
    LOldExemptionId := LOld.EinvTaxExemptionId;
    LOldDeliveryId := LOld.EinvDeliveryTermId;
    LOldTransportId := LOld.EinvTransportModeId;
    LOldPaymentId := LOld.EinvPaymentMeansId;
  end;
  LIsEDoc := AHeader.EinvProfileId > 0;
  R := ARepo.ReadEInvRules(AHeader.EinvProfileId, AHeader.EinvInvoiceTypeId, AHeader.EinvTaxExemptionId,
    AHeader.EinvDeliveryTermId, AHeader.EinvTransportModeId, AHeader.EinvPaymentMeansId);
  // formun kapattığı (bu faturada uygulanamayan) alanlar kayda gitmez
  S := ScopeFromRules(R, AHeader, ALines);
  ClearNotApplicable(S, AHeader, ALines);

  // ---- başlık
  if LIsEDoc then
  begin
    if not R.ProfileFound then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AHeader.EinvProfileId]));
    if R.ProfileKind <> EINV_DOC_INVOICE then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.EInvProfileKind,
        'The selected profile is not an invoice profile.'));
    if AHeader.EinvInvoiceTypeId <= 0 then
      RaiseRequired(TLangKeys.TSlsInvoice.ColEinvInvoiceTypeId, 'Invoice Type');
    CheckActive(R.ProfileActive, AHeader.EinvProfileId, LOldProfileId, TLangKeys.TSlsInvoice.ColEinvProfileId, 'e-Document Profile');
    CheckActive(R.TypeActive, AHeader.EinvInvoiceTypeId, LOldTypeId, TLangKeys.TSlsInvoice.ColEinvInvoiceTypeId, 'Invoice Type');
    if R.RequiresExemption and (AHeader.EinvTaxExemptionId <= 0) then
      RaiseRequired(TLangKeys.TSlsInvoice.ColEinvTaxExemptionId, 'Tax Exemption Code');
    if (AHeader.EinvTaxExemptionId > 0) and (R.ExemptionTypeId > 0) and (R.ExemptionTypeId <> AHeader.EinvInvoiceTypeId) then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ExemptionTypeMismatch,
        'Exemption code %s cannot be used with invoice type %s.'), [R.ExemptionCode, R.TypeCode]));
    if R.RequiresExportInfo then
    begin
      if AHeader.EinvDeliveryTermId <= 0 then
        RaiseRequired(TLangKeys.TSlsInvoice.ColEinvDeliveryTermId, 'Delivery Term');
      if not R.DeliveryIsIncoterms then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.DeliveryNotIncoterms,
          'Export invoices need an INCOTERMS delivery term.'));
      if AHeader.EinvTransportModeId <= 0 then
        RaiseRequired(TLangKeys.TSlsInvoice.ColEinvTransportModeId, 'Transport Mode');
    end;
  end;
  CheckActive(R.ExemptionActive, AHeader.EinvTaxExemptionId, LOldExemptionId, TLangKeys.TSlsInvoice.ColEinvTaxExemptionId, 'Tax Exemption Code');
  CheckActive(R.DeliveryActive, AHeader.EinvDeliveryTermId, LOldDeliveryId, TLangKeys.TSlsInvoice.ColEinvDeliveryTermId, 'Delivery Term');
  CheckActive(R.TransportActive, AHeader.EinvTransportModeId, LOldTransportId, TLangKeys.TSlsInvoice.ColEinvTransportModeId, 'Transport Mode');
  CheckActive(R.PaymentActive, AHeader.EinvPaymentMeansId, LOldPaymentId, TLangKeys.TSlsInvoice.ColEinvPaymentMeansId, 'Payment Means');

  // KDV istisnası olan kod (2xx, 3xx, 701 / 702 / 704) KDV'li kalemlere uygulanmaz: faturada en az bir %0 KDV'li kalem
  if S.ExemptionNeedsZeroVat and not S.HasZeroVatLine and (Length(ALines) > 0) then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.ExemptionNeedsZeroVat,
      'Exemption code %s needs at least one line with 0%% VAT.'), [R.ExemptionCode]));

  // ---- kalemler
  LNeedGtip := S.GtipRequired;
  LNeedDiib := S.DiibAllowed;
  LNeedPackage := S.PackageRequired;
  LHasWithholding := False;
  LOldLines := TDictionary<Int64, TSlsInvoiceDetail>.Create;
  try
    if Assigned(AOldLines) then
      for LOldLine in AOldLines do
        LOldLines.AddOrSetValue(LOldLine.Id, LOldLine);

    for i := 0 to High(ALines) do
    begin
      LLine := ALines[i];
      LNo := LLine.LineNo;
      if LNo <= 0 then
        LNo := i + 1;
      if (LLine.Id <= 0) or not LOldLines.TryGetValue(LLine.Id, LOldLine) then
        LOldLine := nil;
      LLine.PackageNo := AnsiUpperCase(Trim(LLine.PackageNo));
      LLine.PackageBrand := Trim(LLine.PackageBrand);

      // tevkifat: oran tanımdan, tutar = KDV x oran
      if LLine.EinvWithholdingId > 0 then
      begin
        if not ARepo.ReadWithholding(LLine.EinvWithholdingId, LRate, LActive, LCode) then
          raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [LLine.EinvWithholdingId]));
        if Assigned(LOldLine) then
          CheckActive(LActive, LLine.EinvWithholdingId, LOldLine.EinvWithholdingId, TLangKeys.TSlsInvoiceDetail.ColEinvWithholdingId, 'Withholding Code')
        else
          CheckActive(LActive, LLine.EinvWithholdingId, 0, TLangKeys.TSlsInvoiceDetail.ColEinvWithholdingId, 'Withholding Code');
        if LIsEDoc and not R.RequiresWithholding then
          raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.WithholdingNotAllowed,
            'Line %d: withholding codes are only allowed on withholding invoice types.'), [LNo]));
        if LLine.VatRate <= 0 then
          raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.WithholdingNoVat,
            'Line %d: a line without VAT cannot have withholding.'), [LNo]));
        LLine.WithholdingRate := LRate;
        LLine.WithholdingCode := LCode;
        LLine.WithholdingAmount := TSlsLookup.RoundAmount(LLine.VatAmount * LRate / 100);
        LHasWithholding := True;
      end
      else
      begin
        LLine.WithholdingRate := 0;
        LLine.WithholdingCode := '';
        LLine.WithholdingAmount := 0;
      end;

      // DİİB satırları: satıcı = firmamızın belgesi, alıcı = faturadaki müşterinin belgesi
      if Assigned(LOldLine) then
      begin
        CheckDiib(LLine.SellerEinvDiibLineId, LOldLine.SellerEinvDiibLineId, EINV_DIIB_OWN,
          TLangKeys.TSlsInvoiceDetail.ColSellerEinvDiibLineId, 'Seller DIIB Line Code');
        CheckDiib(LLine.BuyerEinvDiibLineId, LOldLine.BuyerEinvDiibLineId, EINV_DIIB_CUSTOMER,
          TLangKeys.TSlsInvoiceDetail.ColBuyerEinvDiibLineId, 'Buyer DIIB Line Code');
      end
      else
      begin
        CheckDiib(LLine.SellerEinvDiibLineId, 0, EINV_DIIB_OWN, TLangKeys.TSlsInvoiceDetail.ColSellerEinvDiibLineId, 'Seller DIIB Line Code');
        CheckDiib(LLine.BuyerEinvDiibLineId, 0, EINV_DIIB_CUSTOMER, TLangKeys.TSlsInvoiceDetail.ColBuyerEinvDiibLineId, 'Buyer DIIB Line Code');
      end;

      // GTİP: gerektiğinde boşsa stok kartından
      if LNeedGtip and (LLine.EinvGtipId <= 0) and ARepo.ReadInventoryGtip(LLine.StkInventoryId, LGtipId, LCode) then
      begin
        LLine.EinvGtipId := LGtipId;
        LLine.GtipCode := LCode;
      end;
      if (LLine.EinvGtipId > 0) and ((LOldLine = nil) or (LOldLine.EinvGtipId <> LLine.EinvGtipId)) and
         not ARepo.IsEInvCodeActive('einv_gtip', LLine.EinvGtipId) then
        CheckActive(False, LLine.EinvGtipId, 0, TLangKeys.TSlsInvoiceDetail.ColEinvGtipId, 'GTIP Code');
      if LNeedGtip and (LLine.EinvGtipId <= 0) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.LineGtipRequired,
          'Line %d: GTIP code is required.'), [LNo]));
      if LNeedDiib and (LLine.BuyerEinvDiibLineId <= 0) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.LineDiibRequired,
          'Line %d: the buyer DIIB line code is required.'), [LNo]));

      // ihracat kap bilgisi
      if (LLine.EinvPackagingTypeId > 0) and ((LOldLine = nil) or (LOldLine.EinvPackagingTypeId <> LLine.EinvPackagingTypeId)) and
         not ARepo.IsEInvCodeActive('einv_packaging_type', LLine.EinvPackagingTypeId) then
        CheckActive(False, LLine.EinvPackagingTypeId, 0, TLangKeys.TSlsInvoiceDetail.ColEinvPackagingTypeId, 'Packaging Type');
      if LNeedPackage and ((LLine.EinvPackagingTypeId <= 0) or (LLine.PackageQuantity <= 0)) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.LinePackageRequired,
          'Line %d: packaging type and package quantity are required for export.'), [LNo]));
    end;
  finally
    LOldLines.Free;
  end;

  if AWholeDocument and LIsEDoc and R.RequiresWithholding and not LHasWithholding and (Length(ALines) > 0) then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSlsInvoice.WithholdingRequired,
      'A withholding invoice needs a withholding code on at least one line.'));
end;

constructor TSlsInvoiceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsInvoice, TSlsInvoiceRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TSlsInvoiceDetail, TSlsInvoiceDetailRepository>;
  FDispatchRepo := Self.UoW.GetRepository<TSlsDispatch, TSlsDispatchRepository>;
  FOrderRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FDispatchDetailRepo := Self.UoW.GetRepository<TSlsDispatchDetail, TSlsDispatchDetailRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_SLS_INVOICE;
end;

destructor TSlsInvoiceService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsInvoiceService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TSlsInvoiceService.ApplyOrderTerms(AInvoice: TSlsInvoice; AOrderId: Int64);
var
  LOrder: TSlsOrder;
begin
  if AOrderId <= 0 then
    Exit;
  LOrder := FOrderRepo.FindById(AOrderId, False);
  try
    if Assigned(LOrder) then
    begin
      AInvoice.ExchangeRate := LOrder.ExchangeRate;
      if LOrder.PaymentTermDays > 0 then
        AInvoice.DueDate := AInvoice.InvoiceDate + LOrder.PaymentTermDays;
    end;
  finally
    LOrder.Free;
  end;
end;

// İrsaliyenin faturalanmamış miktarları belge olarak bellekte kurulur ve belge kaydıyla yazılır; yeni fatura id
function TSlsInvoiceService.CreateFromDispatch(ADispatchId: Int64; APermissionControl: Boolean): Int64;
var
  LDispatch: TSlsDispatch;
  LInvoice: TSlsInvoice;
  LLines: TObjectList<TSlsDispatchDetail>;
  LLine: TSlsDispatchDetail;
  LOrderDetail: TSlsOrderDetail;
  LDetail: TSlsInvoiceDetail;
  LStarted: Boolean;
  LOpen, LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  LStarted := False;
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
    if not Self.UoW.InTransaction then
    begin
      Self.UoW.BeginTransaction;
      LStarted := True;
    end;

    LDispatch := FDispatchRepo.FindById(ADispatchId, True);
    try
      if not Assigned(LDispatch) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADispatchId]));

      LInvoice := TSlsInvoice.Create;
      try
        LInvoice.InvoiceDate := Date;
        LInvoice.AccAccountId := LDispatch.AccAccountId;
        LInvoice.Currency := LDispatch.Currency;
        LInvoice.Description := LDispatch.DispatchNo;
        ApplyOrderTerms(LInvoice, LDispatch.SlsOrderId);

        LLines := TSlsDispatchDetailRepository(FDispatchDetailRepo).FindByDispatchIds([ADispatchId]);
        try
          for LLine in LLines do
          begin
            LOpen := LLine.Quantity - LLine.InvoicedQuantity;
            if LOpen <= 0 then
              Continue;
            LDetail := NewLine(LInvoice);
            LDetail.StkInventoryId := LLine.StkInventoryId;
            LDetail.Quantity := LOpen;
            LDetail.SlsDispatchDetailId := LLine.Id;
            LDetail.UnitPrice := LLine.UnitPrice;
            LDetail.Description := LLine.Description;
            LOrderDetail := nil;
            if LLine.SlsOrderDetailId > 0 then
              LOrderDetail := FOrderDetailRepo.FindById(LLine.SlsOrderDetailId, False);
            try
              if Assigned(LOrderDetail) then
              begin
                // sipariş fiyatı, iskontosu ve KDV'si
                LDetail.UnitPrice := LOrderDetail.UnitPrice;
                LDetail.DiscountRate := LOrderDetail.DiscountRate;
                LDetail.VatRate := LOrderDetail.VatRate;
              end
              else if TSlsOrderDetailRepository(FOrderDetailRepo).GetInventoryDefaults(LLine.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
                LDetail.VatRate := LVat;
            finally
              LOrderDetail.Free;
            end;
          end;
        finally
          LLines.Free;
        end;
        if Length(ActiveLines(LInvoice)) = 0 then
          raise ESlsInvoiceExceptionNothingToInvoice.Create;

        Recalculate(LInvoice);
        BusinessSaveWithDetails(LInvoice, False, APermissionControl);
        Result := LInvoice.Id;
      finally
        LInvoice.Free;
      end;
    finally
      LDispatch.Free;
    end;

    if LStarted and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

// Onaylı siparişin sevk edilmemiş miktarları irsaliyeli fatura olarak bellekte kurulur (stok faturadan, verilen
// ambardan düşer) ve belge kaydıyla yazılır; yeni fatura id
function TSlsInvoiceService.CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;
var
  LOrder: TSlsOrder;
  LInvoice: TSlsInvoice;
  LLines: TObjectList<TSlsOrderDetail>;
  LLine: TSlsOrderDetail;
  LDetail: TSlsInvoiceDetail;
  LStarted: Boolean;
begin
  LStarted := False;
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
      if not (LOrder.Status in [SLS_ORD_APPROVED, SLS_ORD_PARTIAL]) then
        raise ESlsInvoiceExceptionOrderStatus.Create;

      LInvoice := TSlsInvoice.Create;
      try
        LInvoice.InvoiceDate := Date;
        LInvoice.AccAccountId := LOrder.AccAccountId;
        LInvoice.StkWarehouseId := AWarehouseId;
        LInvoice.Currency := LOrder.Currency;
        LInvoice.Description := LOrder.OrderNo;
        ApplyOrderTerms(LInvoice, LOrder.Id);

        LLines := TSlsOrderDetailRepository(FOrderDetailRepo).FindByOrderIds([AOrderId]);
        try
          for LLine in LLines do
          begin
            if LLine.Quantity - LLine.DeliveredQuantity <= 0 then
              Continue;
            LDetail := NewLine(LInvoice);
            LDetail.StkInventoryId := LLine.StkInventoryId;
            LDetail.Quantity := LLine.Quantity - LLine.DeliveredQuantity;
            LDetail.UnitPrice := LLine.UnitPrice;
            LDetail.DiscountRate := LLine.DiscountRate;
            LDetail.VatRate := LLine.VatRate;
            LDetail.Description := LLine.Description;
            LDetail.SlsOrderDetailId := LLine.Id;
          end;
        finally
          LLines.Free;
        end;
        if Length(ActiveLines(LInvoice)) = 0 then
          raise ESlsInvoiceExceptionNothingToInvoice.Create;

        Recalculate(LInvoice);
        BusinessSaveWithDetails(LInvoice, False, APermissionControl);
        Result := LInvoice.Id;
      finally
        LInvoice.Free;
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
end;

{ Belge (TDocumentService) }

function TSlsInvoiceService.GetLines(AHeader: TSlsInvoice): TObjectList<TSlsInvoiceDetail>;
begin
  Result := AHeader.Lines;
end;

function TSlsInvoiceService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TSlsInvoiceDetail>;
begin
  Result := TSlsInvoiceDetailRepository(FLineRepo).FindByInvoiceIds(AIds);
end;

function TSlsInvoiceService.GetLineHeaderId(ALine: TSlsInvoiceDetail): Int64;
begin
  Result := ALine.SlsInvoiceId;
end;

procedure TSlsInvoiceService.SetLineHeaderId(ALine: TSlsInvoiceDetail; AHeaderId: Int64);
begin
  ALine.SlsInvoiceId := AHeaderId;
end;

function TSlsInvoiceService.GetLineNo(ALine: TSlsInvoiceDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TSlsInvoiceService.SetLineNo(ALine: TSlsInvoiceDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TSlsInvoiceService.RaiseDuplicateLineNo;
begin
  raise ESlsInvoiceDetailExceptionLineUnique.Create;
end;

procedure TSlsInvoiceService.InitLine(AHeader: TSlsInvoice; ALine: TSlsInvoiceDetail);
begin
  ALine.InvoiceNo := AHeader.InvoiceNo;
  ALine.Currency := AHeader.Currency;
  ALine.AccAccountId := AHeader.AccAccountId;
end;

// Senaryo seçilmemişse cariye göre öneri: e-Fatura mükellefi -> TEMELFATURA, değilse EARSIVFATURA; tip SATIS
procedure TSlsInvoiceService.SuggestEInv(AInvoice: TSlsInvoice; AEInvoiceUser: Boolean);
var
  LRepo: TSlsInvoiceRepository;
  LCode: string;
begin
  if AInvoice.EinvProfileId > 0 then
    Exit;
  LRepo := TSlsInvoiceRepository(FRepo);
  if AEInvoiceUser then
    LCode := EINV_PROFILE_BASIC
  else
    LCode := EINV_PROFILE_ARCHIVE;
  AInvoice.EinvProfileId := LRepo.EInvIdByCode('einv_profile', LCode);
  if AInvoice.EinvProfileId <= 0 then
    Exit;
  AInvoice.ProfileCode := LCode;
  if AInvoice.EinvInvoiceTypeId <= 0 then
  begin
    AInvoice.EinvInvoiceTypeId := LRepo.EInvIdByCode('einv_invoice_type', EINV_TYPE_SALES);
    if AInvoice.EinvInvoiceTypeId > 0 then
      AInvoice.InvoiceTypeCode := EINV_TYPE_SALES;
  end;
end;

// Senaryo seçilip tip boşsa öneri: ihracat senaryosu istisna faturasıdır (GİB: IHRACAT -> ISTISNA, 3xx kodu)
procedure TSlsInvoiceService.SuggestInvoiceType(AInvoice: TSlsInvoice);
var
  LRepo: TSlsInvoiceRepository;
  LCode: string;
begin
  if (AInvoice.EinvProfileId <= 0) or (AInvoice.EinvInvoiceTypeId > 0) then
    Exit;
  LRepo := TSlsInvoiceRepository(FRepo);
  if AInvoice.ProfileCode = EINV_PROFILE_EXPORT then
    LCode := EINV_TYPE_EXEMPTION
  else
    LCode := EINV_TYPE_SALES;
  AInvoice.EinvInvoiceTypeId := LRepo.EInvIdByCode('einv_invoice_type', LCode);
  if AInvoice.EinvInvoiceTypeId > 0 then
    AInvoice.InvoiceTypeCode := LCode;
end;

// Alanlar + tutarlar (tek kalem yoluyla ortak CheckLine), KDV tanımlı oranlardan; irsaliyeli kalem: aynı stok, aynı
// müşteri, faturalanmamış sevk miktarı; irsaliyesiz kalem: fatura ambarı zorunlu (stok düşer), siparişliyse aynı stok,
// aynı müşteri, yeni kalemde onaylı sipariş, açık sipariş miktarı. Miktar sınırları belgedeki tüm kalemlerin toplamıyla
procedure TSlsInvoiceService.CheckLines(AHeader: TSlsInvoice; const ALines: TArray<TSlsInvoiceDetail>;
  AOldLines: TObjectList<TSlsInvoiceDetail>);

  procedure AddQty(ADict: TDictionary<Int64, Currency>; AKey: Int64; AQty: Currency);
  var
    LQty: Currency;
  begin
    if not ADict.TryGetValue(AKey, LQty) then
      LQty := 0;
    ADict.AddOrSetValue(AKey, LQty + AQty);
  end;

  function QtyOf(ADict: TDictionary<Int64, Currency>; AKey: Int64): Currency;
  begin
    if not ADict.TryGetValue(AKey, Result) then
      Result := 0;
  end;

var
  LRates: TArray<Currency>;
  LLine, LOld: TSlsInvoiceDetail;
  LOldDsp, LOldOrd, LDsp, LOrd, LDspQty, LOrdQty: TDictionary<Int64, Currency>;
  LDspInv, LOrdInv: TDictionary<Int64, Int64>;
  LDispatchDetail: TSlsDispatchDetail;
  LDispatch: TSlsDispatch;
  LOrderDetail: TSlsOrderDetail;
  LOrder: TSlsOrder;
  LPair: TPair<Int64, Currency>;
  LOpen: Currency;
  LOldHeader: TSlsInvoice;
begin
  LRates := TSlsOfferDetailRepository(Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>).GetVatRates;
  LOldDsp := TDictionary<Int64, Currency>.Create;
  LOldOrd := TDictionary<Int64, Currency>.Create;
  LDsp := TDictionary<Int64, Currency>.Create;
  LOrd := TDictionary<Int64, Currency>.Create;
  LDspQty := TDictionary<Int64, Currency>.Create;
  LOrdQty := TDictionary<Int64, Currency>.Create;
  LDspInv := TDictionary<Int64, Int64>.Create;
  LOrdInv := TDictionary<Int64, Int64>.Create;
  try
    for LOld in AOldLines do
      if LOld.SlsDispatchDetailId > 0 then
        AddQty(LOldDsp, LOld.SlsDispatchDetailId, LOld.Quantity)
      else if LOld.SlsOrderDetailId > 0 then
        AddQty(LOldOrd, LOld.SlsOrderDetailId, LOld.Quantity);

    for LLine in ALines do
    begin
      TSlsInvoiceDetailService.CheckLine(LLine);
      // %0 KDV yalnız istisna kodlu faturada (e-belgede KDV'siz kalem istisna / muafiyet kodu ister)
      if not ((LLine.VatRate = 0) and (AHeader.EinvTaxExemptionId > 0)) then
        TSlsOfferDetailService.CheckVatRate(LLine.VatRate, LRates);

      if LLine.SlsDispatchDetailId > 0 then
      begin
        if not LDspInv.ContainsKey(LLine.SlsDispatchDetailId) then
        begin
          LDispatchDetail := FDispatchDetailRepo.FindById(LLine.SlsDispatchDetailId, False);
          LDispatch := nil;
          try
            if not Assigned(LDispatchDetail) then
              raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [LLine.SlsDispatchDetailId]));
            LDispatch := FDispatchRepo.FindById(LDispatchDetail.SlsDispatchId, False);
            if not Assigned(LDispatch) or (LDispatch.AccAccountId <> AHeader.AccAccountId) then
              raise ESlsInvoiceDetailExceptionCustomerMismatch.Create;
            LDspInv.Add(LLine.SlsDispatchDetailId, LDispatchDetail.StkInventoryId);
            LDspQty.Add(LLine.SlsDispatchDetailId, LDispatchDetail.Quantity);
          finally
            LDispatchDetail.Free;
            LDispatch.Free;
          end;
        end;
        if LDspInv[LLine.SlsDispatchDetailId] <> LLine.StkInventoryId then
          raise ESlsInvoiceDetailExceptionInventoryMismatch.Create;
        AddQty(LDsp, LLine.SlsDispatchDetailId, LLine.Quantity);
      end
      else
      begin
        // irsaliyesiz kalem faturanın ambarından stok düşer
        if AHeader.StkWarehouseId <= 0 then
          raise ESlsInvoiceDetailExceptionWarehouseRequired.Create;
        if LLine.SlsOrderDetailId > 0 then
        begin
          if not LOrdInv.ContainsKey(LLine.SlsOrderDetailId) then
          begin
            LOrderDetail := FOrderDetailRepo.FindById(LLine.SlsOrderDetailId, False);
            LOrder := nil;
            try
              if not Assigned(LOrderDetail) then
                raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [LLine.SlsOrderDetailId]));
              LOrder := FOrderRepo.FindById(LOrderDetail.SlsOrderId, False);
              if not Assigned(LOrder) or (LOrder.AccAccountId <> AHeader.AccAccountId) then
                raise ESlsInvoiceDetailExceptionCustomerMismatch.Create;
              if (LLine.Id < 0) and not (LOrder.Status in [SLS_ORD_APPROVED, SLS_ORD_PARTIAL]) then
                raise ESlsInvoiceDetailExceptionOrderStatus.Create;
              LOrdInv.Add(LLine.SlsOrderDetailId, LOrderDetail.StkInventoryId);
              LOrdQty.Add(LLine.SlsOrderDetailId, LOrderDetail.Quantity);
            finally
              LOrderDetail.Free;
              LOrder.Free;
            end;
          end;
          if LOrdInv[LLine.SlsOrderDetailId] <> LLine.StkInventoryId then
            raise ESlsInvoiceDetailExceptionInventoryMismatch.Create;
          AddQty(LOrd, LLine.SlsOrderDetailId, LLine.Quantity);
        end;
      end;
    end;

    // faturalanmamış sevk miktarı: irsaliye kalemi - (diğer faturalar; bu faturanın eski kalemleri hariç)
    for LPair in LDsp do
    begin
      LOpen := LDspQty[LPair.Key] -
        (TSlsDispatchDetailRepository(FDispatchDetailRepo).InvoicedQuantity(LPair.Key, 0) - QtyOf(LOldDsp, LPair.Key));
      if LPair.Value > LOpen then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.OverInvoice,
          'Quantity exceeds the delivered quantity not yet invoiced (%s).'), [CurrToStr(LOpen)]));
    end;
    // açık sipariş miktarı: sipariş kalemi - (irsaliyeler + diğer faturalar; bu faturanın eski kalemleri hariç)
    for LPair in LOrd do
    begin
      LOpen := LOrdQty[LPair.Key] -
        (TSlsDispatchDetailRepository(FDispatchDetailRepo).DeliveredQuantityOfOrderDetail(LPair.Key, 0, 0) - QtyOf(LOldOrd, LPair.Key));
      if LPair.Value > LOpen then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.OverDelivery,
          'Quantity exceeds the open order quantity (%s).'), [CurrToStr(LOpen)]));
    end;

    // e-Belge: senaryo / tip / istisna / tevkifat / GTİP / DİİB / kap bilgisi (eski başlık: pasif kod yalnız yeni seçimde)
    FEInvCheckedHeader := nil;
    LOldHeader := nil;
    if AHeader.Id > 0 then
      LOldHeader := FRepo.FindById(AHeader.Id, False);
    try
      CheckEInvoice(TSlsInvoiceRepository(FRepo), AHeader, ALines, LOldHeader, AOldLines, True);
    finally
      LOldHeader.Free;
    end;
    FEInvCheckedHeader := AHeader;
  finally
    LOrdInv.Free;
    LDspInv.Free;
    LOrdQty.Free;
    LDspQty.Free;
    LOrd.Free;
    LDsp.Free;
    LOldOrd.Free;
    LOldDsp.Free;
  end;
end;

// Kalem hook'u: irsaliyesiz kalem stok çıkışı (faturanın ambarından), irsaliyeye bağlanan kalemin hareketi silinir
procedure TSlsInvoiceService.AfterLineSaved(AHeader: TSlsInvoice; ALine: TSlsInvoiceDetail);
begin
  if ALine.SlsDispatchDetailId <= 0 then
    TSlsInvoiceDetailRepository(FLineRepo).UpsertStockTransaction(ALine.Id)
  else
    TSlsInvoiceDetailRepository(FLineRepo).DeleteStockTransaction(ALine.Id);
end;

// Belge hook'u (eski + yeni): irsaliyesiz kalemlerin stok özeti, siparişli kalemlerin siparişlerinin sevk miktarları,
// irsaliyeli kalemlerin irsaliyelerinin durumu (bekliyor / kapandı)
procedure TSlsInvoiceService.AfterDocumentSaved(AHeader: TSlsInvoice; AOldLines: TObjectList<TSlsInvoiceDetail>);
var
  LInventoryIds, LOrderDetailIds, LDispatchDetailIds: TList<Int64>;

  procedure Collect(ALine: TSlsInvoiceDetail);
  begin
    if ALine.SlsDispatchDetailId > 0 then
    begin
      if not LDispatchDetailIds.Contains(ALine.SlsDispatchDetailId) then
        LDispatchDetailIds.Add(ALine.SlsDispatchDetailId);
    end
    else
    begin
      if not LInventoryIds.Contains(ALine.StkInventoryId) then
        LInventoryIds.Add(ALine.StkInventoryId);
      if (ALine.SlsOrderDetailId > 0) and not LOrderDetailIds.Contains(ALine.SlsOrderDetailId) then
        LOrderDetailIds.Add(ALine.SlsOrderDetailId);
    end;
  end;

var
  LLine: TSlsInvoiceDetail;
  LId: Int64;
begin
  LInventoryIds := TList<Int64>.Create;
  LOrderDetailIds := TList<Int64>.Create;
  LDispatchDetailIds := TList<Int64>.Create;
  try
    for LLine in AOldLines do
      Collect(LLine);
    for LLine in AHeader.Lines do
      Collect(LLine);
    for LId in LInventoryIds do
      TStkInventorySummaryRepository(FSummaryRepo).Recalculate(LId);
    if LOrderDetailIds.Count > 0 then
      for LId in TSlsOrderDetailRepository(FOrderDetailRepo).OrderIdsOfDetails(LOrderDetailIds.ToArray) do
        TSlsOrderRepository(FOrderRepo).RefreshDeliveredQuantities(LId);
    if LDispatchDetailIds.Count > 0 then
      for LId in TSlsDispatchDetailRepository(FDispatchDetailRepo).DispatchIdsOfDetails(LDispatchDetailIds.ToArray) do
        TSlsDispatchRepository(FDispatchRepo).RefreshInvoiceStatus(LId);
  finally
    LDispatchDetailIds.Free;
    LOrderDetailIds.Free;
    LInventoryIds.Free;
  end;
  // e-belge: UBL XML üretilir + şema doğrulaması (kaydı engellemez); kağıt faturada XML kaydı silinir
  TEInvDocumentService.GenerateForInvoice(
    TEInvDocumentRepository(Self.UoW.GetRepository<TEInvDocument, TEInvDocumentRepository>),
    TEInvSeriesRepository(Self.UoW.GetRepository<TEInvSeries, TEInvSeriesRepository>), AHeader.Id);
end;

procedure TSlsInvoiceService.PrepareCopyHeader(AHeader: TSlsInvoice);
begin
  AHeader.InvoiceNo := '';
  // e-belge kimliği, durumu ve gümrük çıkış bilgileri kopyalanmaz (yeni ETTN kayıtta üretilir)
  AHeader.EinvUuid := '';
  AHeader.EinvStatus := 0;
  AHeader.CustomsDeclarationNo := '';
  AHeader.GtbRefNo := '';
  AHeader.ActualExportDate := 0;
end;

// Kopya kalem irsaliye / siparişten bağımsızdır (sevk / fatura miktarları iki kez sayılmasın); stok faturadan düşer
procedure TSlsInvoiceService.PrepareCopyLine(AHeader: TSlsInvoice; ALine: TSlsInvoiceDetail);
begin
  inherited;
  ALine.InvoiceNo := '';
  ALine.SlsDispatchDetailId := 0;
  ALine.DispatchNo := '';
  ALine.SlsOrderDetailId := 0;
  ALine.OrderNo := '';
end;

procedure TSlsInvoiceService.RecalculateLine(ALine: TSlsInvoiceDetail);
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
  if ALine.EinvWithholdingId > 0 then
    ALine.WithholdingAmount := TSlsLookup.RoundAmount(LVat * ALine.WithholdingRate / 100)
  else
    ALine.WithholdingAmount := 0;
end;

procedure TSlsInvoiceService.RecalculateTotals(AHeader: TSlsInvoice);
var
  LLine: TSlsInvoiceDetail;
begin
  AHeader.GrossAmount := 0;
  AHeader.DiscountAmount := 0;
  AHeader.NetAmount := 0;
  AHeader.VatAmount := 0;
  AHeader.TotalAmount := 0;
  AHeader.WithholdingAmount := 0;
  for LLine in AHeader.Lines do
    if not LLine.Deleted then
    begin
      AHeader.GrossAmount := AHeader.GrossAmount + LLine.GrossAmount;
      AHeader.DiscountAmount := AHeader.DiscountAmount + LLine.DiscountAmount;
      AHeader.NetAmount := AHeader.NetAmount + LLine.NetAmount;
      AHeader.VatAmount := AHeader.VatAmount + LLine.VatAmount;
      AHeader.TotalAmount := AHeader.TotalAmount + LLine.TotalAmount;
      AHeader.WithholdingAmount := AHeader.WithholdingAmount + LLine.WithholdingAmount;
    end;
  // tevkifatlı faturada alıcı KDV'nin tevkif edilen kısmını öder; cari borç = toplam - tevkifat
  AHeader.PayableAmount := AHeader.TotalAmount - AHeader.WithholdingAmount;
end;

procedure TSlsInvoiceService.ValidateBusinessRules(AEntity: TSlsInvoice; AOperation: TCrudOperation);
var
  LRepo: TSlsInvoiceRepository;
  LOld: TSlsInvoice;
  LFilter: TFilterCriteria;
  LModel: TSlsInvoice;
begin
  LRepo := TSlsInvoiceRepository(FRepo);
  if AOperation = coDelete then
  begin
    if TEInvLookup.IsEInvLocked(AEntity.EinvStatus) then
      raise ESlsInvoiceExceptionEInvLocked.Create;
    Exit;
  end;

  AEntity.InvoiceNo := AnsiUpperCase(Trim(AEntity.InvoiceNo));
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.InvoiceDate <= 0 then
    FailRequired(TLangKeys.TSlsInvoice.ColInvoiceDate, 'Invoice Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TSlsInvoice.ColAccAccountId, 'Customer');
  if (AEntity.DueDate > 0) and (AEntity.DueDate < AEntity.InvoiceDate) then
    raise ESlsInvoiceExceptionDueDate.Create;
  if AEntity.ExchangeRate <= 0 then
    AEntity.ExchangeRate := 1;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    AEntity.GrossAmount := 0;
    AEntity.DiscountAmount := 0;
    AEntity.NetAmount := 0;
    AEntity.VatAmount := 0;
    AEntity.TotalAmount := 0;
    AEntity.WithholdingAmount := 0;
    // durum servis tarafından tutulur: yeni e-belge taslak başlar
    AEntity.EinvStatus := 0;
    if AEntity.InvoiceNo = '' then
      AEntity.InvoiceNo := LRepo.NextDocumentNo(SLS_PREFIX_INVOICE);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if TEInvLookup.IsEInvLocked(LOld.EinvStatus) then
        raise ESlsInvoiceExceptionEInvLocked.Create;
      // e-belge durumu ve ETTN formdan değişmez (durum entegrasyonla, ETTN bir kez üretilir)
      AEntity.EinvStatus := LOld.EinvStatus;
      if LOld.EinvUuid <> '' then
        AEntity.EinvUuid := LOld.EinvUuid;
      if (LRepo.LineCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or (LOld.Currency <> AEntity.Currency)) then
        raise ESlsInvoiceExceptionKeyFieldsLocked.Create;
      // irsaliyesiz kalem stoktan düşer: ambar boşaltılamaz
      if (AEntity.StkWarehouseId <= 0) and (LRepo.StockLineCount(AEntity.Id) > 0) then
        raise ESlsInvoiceExceptionWarehouseRequired.Create;
      AEntity.GrossAmount := LOld.GrossAmount;
      AEntity.DiscountAmount := LOld.DiscountAmount;
      AEntity.NetAmount := LOld.NetAmount;
      AEntity.VatAmount := LOld.VatAmount;
      AEntity.TotalAmount := LOld.TotalAmount;
      AEntity.WithholdingAmount := LOld.WithholdingAmount;
      if AEntity.InvoiceNo = '' then
        AEntity.InvoiceNo := LOld.InvoiceNo;
    finally
      LOld.Free;
    end;
  end;

  // e-Belge: belge kaydında CheckLines'ta bellekteki kalemlerle çalıştı; yalnız başlık kaydında DB kalemleriyle
  if FEInvCheckedHeader = AEntity then
    NormalizeEInvHeader(AEntity)
  else
    CheckEInvoiceFromDb(AEntity);
  FEInvCheckedHeader := nil;

  CheckPartyTaxInfo(AEntity);

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('invoice_no', '=', TValue.From<string>(AEntity.InvoiceNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsInvoiceExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsInvoiceService.CheckEInvoiceFromDb(AEntity: TSlsInvoice);
var
  LOld: TSlsInvoice;
  LLines: TObjectList<TSlsInvoiceDetail>;
begin
  LOld := nil;
  if AEntity.Id > 0 then
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    LLines := FindLinesByHeaderIds([AEntity.Id]);
  end
  else
    LLines := TObjectList<TSlsInvoiceDetail>.Create(True);
  try
    CheckEInvoice(TSlsInvoiceRepository(FRepo), AEntity, LLines.ToArray, LOld, LLines, False);
  finally
    LLines.Free;
    LOld.Free;
  end;
end;

procedure TSlsInvoiceService.DoAdd(AEntity: TSlsInvoice);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSlsInvoiceService.DoUpdate(AEntity: TSlsInvoice);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  // tarih / ambar değişikliği irsaliyesiz kalemlerin stok hareketlerine yansır
  TSlsInvoiceRepository(FRepo).SyncStockTransactions(AEntity.Id);
end;

procedure TSlsInvoiceService.DoDelete(AId: Int64);
var
  LEntity: TSlsInvoice;
  LInventoryIds, LOrderIds, LDispatchIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler ve stok hareketleri cascade silinir; stok özeti ve sipariş sevk miktarları yenilenir
    LInventoryIds := TSlsInvoiceRepository(FRepo).StockInventoryIdsOfInvoice(AId);
    LOrderIds := TSlsInvoiceRepository(FRepo).OrderIdsOfInvoice(AId);
    LDispatchIds := TSlsInvoiceRepository(FRepo).DispatchIdsOfInvoice(AId);
    FRepo.Delete(LEntity);
    for LId in LDispatchIds do
      TSlsDispatchRepository(FDispatchRepo).RefreshInvoiceStatus(LId);
    for LId in LInventoryIds do
      TStkInventorySummaryRepository(FSummaryRepo).Recalculate(LId);
    for LId in LOrderIds do
      TSlsOrderRepository(FOrderRepo).RefreshDeliveredQuantities(LId);
  finally
    LEntity.Free;
  end;
end;

function TSlsInvoiceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsInvoice>;
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

function TSlsInvoiceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsInvoice;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    // belge: başlık + kalemler
    Result := FRepo.FindById(AId, ALock);
    if Assigned(Result) then
      LoadLines([Result]);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSlsInvoiceService.BusinessInsert(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsInvoiceService.BusinessUpdate(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsInvoiceService.BusinessDelete(AEntity: TSlsInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsInvoiceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TSlsInvoiceService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsInvoice>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TSlsInvoiceService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsInvoice;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TSlsInvoiceService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsInvoice;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsInvoiceService.Add(AEntity: TSlsInvoice);
begin
  DoAdd(AEntity);
end;

procedure TSlsInvoiceService.Update(AEntity: TSlsInvoice);
begin
  DoUpdate(AEntity);
end;

procedure TSlsInvoiceService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
