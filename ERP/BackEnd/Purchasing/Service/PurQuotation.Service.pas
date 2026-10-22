unit PurQuotation.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, PurQuotation.Repository, PurQuotation, PurQuotation.Exception, PurQuotationDetail,
  PurQuotationDetail.Repository, PurRequest, PurRequest.Repository, PurRequestDetail, PurRequestDetail.Repository;

type
  // Alış teklifi belgesi = başlık + Lines (TDocumentService). Akış: talepten tedarikçi başına taslak teklif
  // (CreateFromRequest) -> fiyat / koşul girişi -> karşılaştırma -> seçilen teklif onaya gönderilir (talep başına tek
  // seçili teklif) -> onay / red (özel yetki) -> onaylı teklif mevcut sipariş servisiyle siparişe dönüşür (CreateOrder).
  // Başlık ve kalemler yalnız taslakta değişir. Teklif talep miktarlarını değiştirmez (sipariş kalemleri talebe bağlanır).
  TPurQuotationService = class(TDocumentService<TPurQuotation, TPurQuotationDetail>)
  private
    FRepo: IRepository<TPurQuotation>;
    FRequestRepo: IRepository<TPurRequest>;
    FRequestDetailRepo: IRepository<TPurRequestDetail>;

    procedure DoAdd(AEntity: TPurQuotation);
    procedure DoUpdate(AEntity: TPurQuotation);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    function CurrentUserId: Int64;
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TPurQuotation): TObjectList<TPurQuotationDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurQuotationDetail>; override;
    function GetLineHeaderId(ALine: TPurQuotationDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TPurQuotationDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TPurQuotationDetail): Integer; override;
    procedure SetLineNo(ALine: TPurQuotationDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TPurQuotation; ALine: TPurQuotationDetail); override;
    procedure CheckLines(AHeader: TPurQuotation; const ALines: TArray<TPurQuotationDetail>; AOldLines: TObjectList<TPurQuotationDetail>); override;
    procedure PrepareCopyHeader(AHeader: TPurQuotation); override;
    procedure PrepareCopyLine(AHeader: TPurQuotation; ALine: TPurQuotationDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurQuotation; AOperation: TCrudOperation); override;
    // Elle durum değişikliği: onaya gönder / geri çek (güncelleme yetkisi), onay / red / onay iptali (özel yetki);
    // kendi açtığı transaction'ı commit eder
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
    // Kullanıcı bu teklifi onaylayabilir mi (özel yetki): form menüleri için
    function CanApprove: Boolean;

    // Kalem tutarları miktar, fiyat ve oranlardan; başlık toplamları aktif kalemlerden
    procedure RecalculateLine(ALine: TPurQuotationDetail); override;
    procedure RecalculateTotals(AHeader: TPurQuotation); override;
    // Onaylı talebin açık miktarlarından tedarikçi için taslak teklif; yeni teklif id
    function CreateFromRequest(ARequestId, AAccountId: Int64; APermissionControl: Boolean): Int64;
    // Onaylı tekliften taslak satın alma siparişi (fiyat / iskonto / KDV / koşullar tekliften, kalemler talebe bağlı);
    // teklif "siparişe dönüştü" olur ve siparişe bağlanır. Yeni sipariş id
    function CreateOrder(AQuotationId: Int64; APermissionControl: Boolean): Int64;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurQuotation>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurQuotation; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurQuotation; override;

    procedure Add(AEntity: TPurQuotation); override;
    procedure Update(AEntity: TPurQuotation); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurQuotation; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurQuotation>; override;
    procedure BusinessInsert(AEntity: TPurQuotation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurQuotation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurQuotation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, PurQuotationDetail.Service, PurQuotationDetail.Exception,
  PurOrder, PurOrderDetail, PurOrderDetail.Repository, PurOrder.Service,
  AccSetTaxRate, AccSetTaxRate.Repository, AccSetTaxRate.Service;

constructor TPurQuotationService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurQuotation, TPurQuotationRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TPurQuotationDetail, TPurQuotationDetailRepository>;
  FRequestRepo := Self.UoW.GetRepository<TPurRequest, TPurRequestRepository>;
  FRequestDetailRepo := Self.UoW.GetRepository<TPurRequestDetail, TPurRequestDetailRepository>;
  Self.PermissionCode := PERMISSION_PUR_QUOTATION;
end;

destructor TPurQuotationService.Destroy;
begin
  inherited;
end;

{ Belge (TDocumentService) }

function TPurQuotationService.GetLines(AHeader: TPurQuotation): TObjectList<TPurQuotationDetail>;
begin
  Result := AHeader.Lines;
end;

function TPurQuotationService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurQuotationDetail>;
begin
  Result := TPurQuotationDetailRepository(FLineRepo).FindByQuotationIds(AIds);
end;

function TPurQuotationService.GetLineHeaderId(ALine: TPurQuotationDetail): Int64;
begin
  Result := ALine.PurQuotationId;
end;

procedure TPurQuotationService.SetLineHeaderId(ALine: TPurQuotationDetail; AHeaderId: Int64);
begin
  ALine.PurQuotationId := AHeaderId;
end;

function TPurQuotationService.GetLineNo(ALine: TPurQuotationDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TPurQuotationService.SetLineNo(ALine: TPurQuotationDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TPurQuotationService.RaiseDuplicateLineNo;
begin
  raise EPurQuotationDetailExceptionLineUnique.Create;
end;

// Belge no / para birimi (kalem formu: fiyat önerisi, gösterim), teslim tarihi başlıktan
procedure TPurQuotationService.InitLine(AHeader: TPurQuotation; ALine: TPurQuotationDetail);
begin
  ALine.QuotationNo := AHeader.QuotationNo;
  ALine.Currency := AHeader.Currency;
  ALine.DeliveryDate := AHeader.DeliveryDate;
end;

// Alanlar + tutarlar (tek kalem yoluyla ortak CheckLine), KDV tanımlı oranlardan, talep kalemiyle stok / talep uyumu.
// Taslak dışı teklif başlık doğrulamasında (NotEditable) reddedilir; kalemler de onunla kilitlidir
procedure TPurQuotationService.CheckLines(AHeader: TPurQuotation; const ALines: TArray<TPurQuotationDetail>;
  AOldLines: TObjectList<TPurQuotationDetail>);
var
  LRates: TArray<Currency>;
  LLine: TPurQuotationDetail;
  LLineSvc: TPurQuotationDetailService;
begin
  LRates := TAccSetTaxRateRepository(Self.UoW.GetRepository<TAccSetTaxRate, TAccSetTaxRateRepository>).GetTaxRates;
  LLineSvc := TPurQuotationDetailService.Create;
  try
    for LLine in ALines do
    begin
      TPurQuotationDetailService.CheckLine(LLine);
      TAccSetTaxRateService.CheckDefinedRate(LLine.VatRate, LRates);
      LLineSvc.CheckRequestLink(LLine, AHeader.PurRequestId);
    end;
  finally
    LLineSvc.Free;
  end;
end;

procedure TPurQuotationService.PrepareCopyHeader(AHeader: TPurQuotation);
begin
  // kopya: aynı talebe başka tedarikçi teklifi girmek için (tedarikçi değiştirilmeli)
  AHeader.QuotationNo := '';
  AHeader.QuotationDate := Date;
  AHeader.Status := PUR_QUO_DRAFT;
  AHeader.PurOrderId := 0;
  AHeader.OrderNo := '';
  AHeader.ApprovedSysUserId := 0;
  AHeader.ApprovedAt := 0;
  AHeader.ApprovedBy := '';
  if (AHeader.ValidUntil > 0) and (AHeader.ValidUntil < AHeader.QuotationDate) then
    AHeader.ValidUntil := 0;
  if (AHeader.DeliveryDate > 0) and (AHeader.DeliveryDate < AHeader.QuotationDate) then
    AHeader.DeliveryDate := 0;
end;

procedure TPurQuotationService.PrepareCopyLine(AHeader: TPurQuotation; ALine: TPurQuotationDetail);
begin
  inherited;
  ALine.QuotationNo := '';
end;

procedure TPurQuotationService.RecalculateLine(ALine: TPurQuotationDetail);
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TPurLookup.CalculateLine(ALine.Quantity, ALine.UnitPrice, ALine.DiscountRate, ALine.VatRate,
    LGross, LDiscount, LNet, LVat, LTotal);
  ALine.GrossAmount := LGross;
  ALine.DiscountAmount := LDiscount;
  ALine.NetAmount := LNet;
  ALine.VatAmount := LVat;
  ALine.TotalAmount := LTotal;
end;

procedure TPurQuotationService.RecalculateTotals(AHeader: TPurQuotation);
var
  LLine: TPurQuotationDetail;
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

// Alan adı + "zorunludur" mesajı
procedure TPurQuotationService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

function TPurQuotationService.CurrentUserId: Int64;
begin
  if Assigned(TAppContext.Instance.CurrentUser) then
    Result := TAppContext.Instance.CurrentUser.GetUserId
  else
    Result := 0;
end;

function TPurQuotationService.CanApprove: Boolean;
begin
  Result := Self.UoW.IsAuthorized(Self.PermissionCode, ptSpecial, True);
end;

procedure TPurQuotationService.ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
var
  LOld: TPurQuotation;
  LStarted: Boolean;
begin
  LStarted := False;
  try
    // onay kararları (onay / red / onay iptali) özel yetki ister; onaya gönderme / geri çekme güncelleme yetkisi
    if ANewStatus in [PUR_QUO_APPROVED, PUR_QUO_REJECTED] then
      Self.UoW.EnsureAuthorized(Self.PermissionCode, ptSpecial, APermissionControl)
    else
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
      if not TPurLookup.CanChangeQuotationStatus(LOld.Status, ANewStatus) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPurQuotation.InvalidStatus,
          'Status cannot be changed from "%s" to "%s".'),
          [TPurLookup.Text(plkQuotationStatus, LOld.Status), TPurLookup.Text(plkQuotationStatus, ANewStatus)]));
      if (LOld.Status = PUR_QUO_APPROVED) and (ANewStatus = PUR_QUO_DRAFT) then
        Self.UoW.EnsureAuthorized(Self.PermissionCode, ptSpecial, APermissionControl);

      if ANewStatus = PUR_QUO_PENDING then
      begin
        if TPurQuotationRepository(FRepo).LineCount(AId) = 0 then
          raise EPurQuotationExceptionNoLines.Create;
        // talep başına tek seçili teklif
        if (LOld.PurRequestId > 0) and (TPurQuotationRepository(FRepo).SelectedOfRequest(LOld.PurRequestId, AId) > 0) then
          raise EPurQuotationExceptionAlreadySelected.Create;
      end;
      if (ANewStatus = PUR_QUO_DRAFT) and (LOld.PurRequestId > 0) and (LOld.Status = PUR_QUO_NOT_SELECTED) then
        // seçilmeyen teklif yeniden açılırken tedarikçinin talepte başka açık teklifi olmamalı
        if TPurQuotationRepository(FRepo).OpenOfSupplier(LOld.PurRequestId, LOld.AccAccountId, AId) > 0 then
          raise EPurQuotationExceptionSupplierHasQuotation.Create;

      TPurQuotationRepository(FRepo).SetStatus(AId, ANewStatus);
      if ANewStatus = PUR_QUO_APPROVED then
      begin
        TPurQuotationRepository(FRepo).SetApproval(AId, CurrentUserId);
        // talebin diğer açık teklifleri seçilmedi olur
        if LOld.PurRequestId > 0 then
          TPurQuotationRepository(FRepo).MarkOthersNotSelected(LOld.PurRequestId, AId);
      end
      else if LOld.Status = PUR_QUO_APPROVED then
        TPurQuotationRepository(FRepo).SetApproval(AId, 0);
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

// Onaylı talebin açık miktarları belge olarak bellekte kurulur ve belge kaydıyla yazılır (tek yol)
function TPurQuotationService.CreateFromRequest(ARequestId, AAccountId: Int64; APermissionControl: Boolean): Int64;
var
  LRequest: TPurRequest;
  LQuotation: TPurQuotation;
  LLines: TObjectList<TPurRequestDetail>;
  LLine: TPurRequestDetail;
  LDetail: TPurQuotationDetail;
  LStarted: Boolean;
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
  LLineSvc: TPurQuotationDetailService;
begin
  LStarted := False;
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
    if not Self.UoW.InTransaction then
    begin
      Self.UoW.BeginTransaction;
      LStarted := True;
    end;

    LRequest := FRequestRepo.FindById(ARequestId, True);
    try
      if not Assigned(LRequest) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ARequestId]));
      if LRequest.Status <> PUR_REQ_APPROVED then
        raise EPurQuotationExceptionRequestNotApproved.Create;

      LQuotation := TPurQuotation.Create;
      LLineSvc := TPurQuotationDetailService.Create;
      try
        LQuotation.QuotationDate := Date;
        LQuotation.PurRequestId := ARequestId;
        LQuotation.AccAccountId := AAccountId;
        LQuotation.Currency := TPurQuotationRepository(FRepo).GetDefaultCurrency;
        LQuotation.Description := LRequest.RequestNo;

        LLines := TPurRequestDetailRepository(FRequestDetailRepo).FindByRequestIds([ARequestId]);
        try
          for LLine in LLines do
          begin
            if LLine.Quantity - LLine.OrderedQuantity <= 0 then
              Continue;
            LDetail := NewLine(LQuotation);
            LDetail.StkInventoryId := LLine.StkInventoryId;
            LDetail.Quantity := LLine.Quantity - LLine.OrderedQuantity;
            LDetail.DeliveryDate := LLine.RequiredDate;
            LDetail.Description := LLine.Description;
            LDetail.PurRequestDetailId := LLine.Id;
            if LLineSvc.GetInventoryDefaults(LLine.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
            begin
              // fiyat yalnız teklif para biriminde ise önerilir (tedarikçi fiyatı girilecek)
              if LCurrency = LQuotation.Currency then
                LDetail.UnitPrice := LPrice;
              LDetail.DiscountRate := LDiscount;
              LDetail.VatRate := LVat;
            end;
          end;
        finally
          LLines.Free;
        end;
        if Length(ActiveLines(LQuotation)) = 0 then
          raise EPurQuotationExceptionNothingToQuote.Create;

        Recalculate(LQuotation);
        BusinessSaveWithDetails(LQuotation, False, APermissionControl);
        Result := LQuotation.Id;
      finally
        LLineSvc.Free;
        LQuotation.Free;
      end;
    finally
      LRequest.Free;
    end;

    if LStarted and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

// Sipariş mevcut sipariş servisiyle (aynı transaction, aynı kurallar) yazılır; sipariş kalemleri talep kalemlerine
// bağlandığı için talebin sipariş edilen miktarı / durumu sipariş servisinin belge hook'uyla güncellenir
function TPurQuotationService.CreateOrder(AQuotationId: Int64; APermissionControl: Boolean): Int64;
var
  LQuotation: TPurQuotation;
  LLine: TPurQuotationDetail;
  LOrderSvc: TPurOrderService;
  LOrder: TPurOrder;
  LDetail: TPurOrderDetail;
  LStarted: Boolean;
  LDelivery: TDate;
begin
  LStarted := False;
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);
    if not Self.UoW.InTransaction then
    begin
      Self.UoW.BeginTransaction;
      LStarted := True;
    end;

    LQuotation := FRepo.FindById(AQuotationId, True);
    try
      if not Assigned(LQuotation) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AQuotationId]));
      if LQuotation.Status <> PUR_QUO_APPROVED then
        raise EPurQuotationExceptionNotApproved.Create;
      LoadLines([LQuotation]);

      // termin: teklifin teslim tarihi (geçmişte değilse), yoksa bugün + teslim süresi
      LDelivery := 0;
      if LQuotation.DeliveryDate >= Date then
        LDelivery := LQuotation.DeliveryDate
      else if LQuotation.DeliveryDays > 0 then
        LDelivery := Date + LQuotation.DeliveryDays;

      LOrderSvc := TPurOrderService.Create;
      LOrder := TPurOrder.Create;
      try
        LOrder.OrderDate := Date;
        LOrder.AccAccountId := LQuotation.AccAccountId;
        LOrder.SupplierRefNo := LQuotation.SupplierRefNo;
        LOrder.DeliveryDate := LDelivery;
        LOrder.Currency := LQuotation.Currency;
        LOrder.ExchangeRate := LQuotation.ExchangeRate;
        LOrder.PaymentTermDays := LQuotation.PaymentTermDays;
        LOrder.Description := LQuotation.QuotationNo;
        if LQuotation.RequestNo <> '' then
          LOrder.Description := LOrder.Description + ' / ' + LQuotation.RequestNo;

        for LLine in LQuotation.Lines do
        begin
          LDetail := LOrderSvc.NewLine(LOrder);
          LDetail.StkInventoryId := LLine.StkInventoryId;
          LDetail.Quantity := LLine.Quantity;
          LDetail.UnitPrice := LLine.UnitPrice;
          LDetail.DiscountRate := LLine.DiscountRate;
          LDetail.VatRate := LLine.VatRate;
          if LLine.DeliveryDate >= Date then
            LDetail.DeliveryDate := LLine.DeliveryDate
          else
            LDetail.DeliveryDate := LDelivery;
          LDetail.Description := LLine.Description;
          LDetail.PurRequestDetailId := LLine.PurRequestDetailId;
        end;
        if Length(LOrderSvc.ActiveLines(LOrder)) = 0 then
          raise EPurQuotationExceptionNoLines.Create;

        LOrderSvc.Recalculate(LOrder);
        LOrderSvc.BusinessSaveWithDetails(LOrder, False, APermissionControl);
        Result := LOrder.Id;
        TPurQuotationRepository(FRepo).SetOrder(AQuotationId, Result);
      finally
        LOrder.Free;
        LOrderSvc.Free;
      end;
    finally
      LQuotation.Free;
    end;

    if LStarted and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPurQuotationService.ValidateBusinessRules(AEntity: TPurQuotation; AOperation: TCrudOperation);
var
  LRepo: TPurQuotationRepository;
  LOld: TPurQuotation;
  LFilter: TFilterCriteria;
  LModel: TPurQuotation;
  LRequest: TPurRequest;
begin
  LRepo := TPurQuotationRepository(FRepo);
  if AOperation = coDelete then
  begin
    if not (AEntity.Status in [PUR_QUO_DRAFT, PUR_QUO_REJECTED, PUR_QUO_NOT_SELECTED]) then
      raise EPurQuotationExceptionDeleteStatus.Create;
    Exit;
  end;

  AEntity.QuotationNo := AnsiUpperCase(Trim(AEntity.QuotationNo));
  AEntity.SupplierRefNo := Trim(AEntity.SupplierRefNo);
  AEntity.PaymentTerms := Trim(AEntity.PaymentTerms);
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.QuotationDate <= 0 then
    FailRequired(TLangKeys.TPurQuotation.ColQuotationDate, 'Quotation Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TPurQuotation.ColAccAccountId, 'Supplier');
  if (AEntity.ValidUntil > 0) and (AEntity.ValidUntil < AEntity.QuotationDate) then
    raise EPurQuotationExceptionValidUntil.Create;
  if (AEntity.DeliveryDate > 0) and (AEntity.DeliveryDate < AEntity.QuotationDate) then
    raise EPurQuotationExceptionDeliveryDate.Create;
  if (AEntity.DeliveryDays < 0) or (AEntity.DeliveryDays > 999) then
    raise EPurQuotationExceptionDeliveryDays.Create;
  if (AEntity.PaymentTermDays < 0) or (AEntity.PaymentTermDays > 365) then
    raise EPurQuotationExceptionPaymentTerm.Create;
  if AEntity.ExchangeRate <= 0 then
    AEntity.ExchangeRate := 1;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  // talep onaylı olmalı (taslak / reddedilen talebe teklif girilmez); tedarikçinin talepte tek açık teklifi
  if AEntity.PurRequestId > 0 then
  begin
    LRequest := FRequestRepo.FindById(AEntity.PurRequestId, False);
    try
      if not Assigned(LRequest) or not (LRequest.Status in [PUR_REQ_APPROVED, PUR_REQ_ORDERED]) then
        raise EPurQuotationExceptionRequestNotApproved.Create;
      AEntity.RequestNo := LRequest.RequestNo;
    finally
      LRequest.Free;
    end;
    if LRepo.OpenOfSupplier(AEntity.PurRequestId, AEntity.AccAccountId, AEntity.Id) > 0 then
      raise EPurQuotationExceptionSupplierHasQuotation.Create;
  end;

  if AOperation = coInsert then
  begin
    // durum, onay, sipariş bağı ve tutarlar servis tarafından tutulur (tutarlar kalemlerden)
    AEntity.Status := PUR_QUO_DRAFT;
    AEntity.PurOrderId := 0;
    AEntity.ApprovedSysUserId := 0;
    AEntity.ApprovedAt := 0;
    AEntity.GrossAmount := 0;
    AEntity.DiscountAmount := 0;
    AEntity.NetAmount := 0;
    AEntity.VatAmount := 0;
    AEntity.TotalAmount := 0;
    if AEntity.QuotationNo = '' then
      AEntity.QuotationNo := LRepo.NextDocumentNo(PUR_PREFIX_QUOTATION);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if LOld.Status <> PUR_QUO_DRAFT then
        raise EPurQuotationExceptionNotEditable.Create;
      AEntity.Status := LOld.Status;
      AEntity.PurOrderId := LOld.PurOrderId;
      AEntity.ApprovedSysUserId := LOld.ApprovedSysUserId;
      AEntity.ApprovedAt := LOld.ApprovedAt;
      AEntity.GrossAmount := LOld.GrossAmount;
      AEntity.DiscountAmount := LOld.DiscountAmount;
      AEntity.NetAmount := LOld.NetAmount;
      AEntity.VatAmount := LOld.VatAmount;
      AEntity.TotalAmount := LOld.TotalAmount;
      if AEntity.QuotationNo = '' then
        AEntity.QuotationNo := LOld.QuotationNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('quotation_no', '=', TValue.From<string>(AEntity.QuotationNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurQuotationExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurQuotationService.DoAdd(AEntity: TPurQuotation);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurQuotationService.DoUpdate(AEntity: TPurQuotation);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPurQuotationService.DoDelete(AId: Int64);
var
  LEntity: TPurQuotation;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    // kalemler cascade silinir
    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TPurQuotationService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurQuotation>;
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

function TPurQuotationService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurQuotation;
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

procedure TPurQuotationService.BusinessInsert(AEntity: TPurQuotation; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurQuotationService.BusinessUpdate(AEntity: TPurQuotation; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurQuotationService.BusinessDelete(AEntity: TPurQuotation; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurQuotationService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TPurQuotationService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurQuotation>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TPurQuotationService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurQuotation;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TPurQuotationService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurQuotation;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurQuotationService.Add(AEntity: TPurQuotation);
begin
  DoAdd(AEntity);
end;

procedure TPurQuotationService.Update(AEntity: TPurQuotation);
begin
  DoUpdate(AEntity);
end;

procedure TPurQuotationService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
