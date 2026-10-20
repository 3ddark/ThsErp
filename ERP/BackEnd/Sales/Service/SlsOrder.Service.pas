unit SlsOrder.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, SlsOrder.Repository, SlsOrder, SlsOrder.Exception, SlsOrderDetail, SlsOrderDetail.Repository,
  SlsOffer, SlsOffer.Repository, SlsOfferDetail, SlsOfferDetail.Repository;

type
  // Sipariş belgesi = başlık + Lines (TDocumentService: kalem işlemleri, hesap tetikleme, yükleme, tek transaction'lı
  // kayıt + Reload). Başlık taslak dışında da (onaylı / kısmi) değişebilir; kalemler yalnız taslakta.
  TSlsOrderService = class(TDocumentService<TSlsOrder, TSlsOrderDetail>)
  private
    FRepo: IRepository<TSlsOrder>;
    FOfferRepo: IRepository<TSlsOffer>;
    FOfferDetailRepo: IRepository<TSlsOfferDetail>;

    procedure DoAdd(AEntity: TSlsOrder);
    procedure DoUpdate(AEntity: TSlsOrder);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // Kalem kayıtlı hâlinden farklı mı (taslak dışı siparişte kalem değişikliği yasak)
    function LineChanged(ALine, AOld: TSlsOrderDetail): Boolean;
    procedure RefreshOfferIds(const AOfferDetailIds: TArray<Int64>);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TSlsOrder): TObjectList<TSlsOrderDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TSlsOrderDetail>; override;
    function GetLineHeaderId(ALine: TSlsOrderDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TSlsOrderDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TSlsOrderDetail): Integer; override;
    procedure SetLineNo(ALine: TSlsOrderDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TSlsOrder; ALine: TSlsOrderDetail); override;
    procedure CheckLines(AHeader: TSlsOrder; const ALines: TArray<TSlsOrderDetail>; AOldLines: TObjectList<TSlsOrderDetail>); override;
    procedure AfterDocumentSaved(AHeader: TSlsOrder; AOldLines: TObjectList<TSlsOrderDetail>); override;
    procedure PrepareCopyHeader(AHeader: TSlsOrder); override;
    procedure PrepareCopyLine(AHeader: TSlsOrder; ALine: TSlsOrderDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsOrder; AOperation: TCrudOperation); override;
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);

    // Kalem tutarları miktar, fiyat ve oranlardan; başlık toplamları aktif kalemlerden
    procedure RecalculateLine(ALine: TSlsOrderDetail); override;
    procedure RecalculateTotals(AHeader: TSlsOrder); override;
    // Gönderilmiş teklifin kalan miktarlarından taslak sipariş (fiyat / iskonto / KDV tekliften); yeni sipariş id
    function CreateFromOffer(AOfferId: Int64; APermissionControl: Boolean): Int64;
    procedure RefreshOffers(AOrderId: Int64);

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsOrder>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsOrder; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsOrder; override;

    procedure Add(AEntity: TSlsOrder); override;
    procedure Update(AEntity: TSlsOrder); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOrder; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOrder>; override;
    procedure BusinessInsert(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsOrderDetail.Service, SlsOrderDetail.Exception, SlsOfferDetail.Service;

constructor TSlsOrderService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  FOfferRepo := Self.UoW.GetRepository<TSlsOffer, TSlsOfferRepository>;
  FOfferDetailRepo := Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>;
  Self.PermissionCode := PERMISSION_SLS_ORDER;
end;

destructor TSlsOrderService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsOrderService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Elle durum değişikliği (onay / taslağa alma / red / iptal / kapama); kendi açtığı transaction'ı commit eder
procedure TSlsOrderService.ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
var
  LOld: TSlsOrder;
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
      if not TSlsLookup.CanChangeOrderStatus(LOld.Status, ANewStatus) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsOrder.InvalidStatus,
          'Status cannot be changed from "%s" to "%s".'), [TSlsLookup.Text(slkOrderStatus, LOld.Status), TSlsLookup.Text(slkOrderStatus, ANewStatus)]));
      if (ANewStatus = SLS_ORD_APPROVED) and (TSlsOrderRepository(FRepo).LineCount(AId) = 0) then
        raise ESlsOrderExceptionNoLines.Create;
      if (ANewStatus in [SLS_ORD_DRAFT, SLS_ORD_CANCELLED]) and (TSlsOrderRepository(FRepo).DeliveryCount(AId) > 0) then
        raise ESlsOrderExceptionHasDeliveries.Create;
      TSlsOrderRepository(FRepo).SetStatus(AId, ANewStatus);
      // iptal / yeniden açma teklif kalemlerinin siparişe aktarılan miktarını değiştirir
      RefreshOffers(AId);
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

procedure TSlsOrderService.RefreshOffers(AOrderId: Int64);
var
  LId: Int64;
begin
  for LId in TSlsOrderRepository(FRepo).OfferIdsOfOrder(AOrderId) do
    TSlsOfferRepository(FOfferRepo).RefreshOrderedQuantities(LId);
end;

// Gönderilmiş teklifin kalan miktarları belge olarak bellekte kurulur ve belge kaydıyla yazılır (tek yol)
function TSlsOrderService.CreateFromOffer(AOfferId: Int64; APermissionControl: Boolean): Int64;
var
  LOffer: TSlsOffer;
  LOrder: TSlsOrder;
  LLines: TObjectList<TSlsOfferDetail>;
  LLine: TSlsOfferDetail;
  LDetail: TSlsOrderDetail;
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

    LOffer := FOfferRepo.FindById(AOfferId, True);
    try
      if not Assigned(LOffer) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AOfferId]));
      if LOffer.Status <> SLS_OFF_SENT then
        raise ESlsOrderExceptionOfferNotSent.Create;

      LOrder := TSlsOrder.Create;
      try
        LOrder.OrderDate := Date;
        LOrder.AccAccountId := LOffer.AccAccountId;
        LOrder.CustomerRefNo := LOffer.CustomerRefNo;
        LOrder.EmpEmployeeId := LOffer.EmpEmployeeId;
        LOrder.Currency := LOffer.Currency;
        LOrder.ExchangeRate := LOffer.ExchangeRate;
        LOrder.PaymentTermDays := LOffer.PaymentTermDays;
        if LOffer.DeliveryDate >= LOrder.OrderDate then
          LOrder.DeliveryDate := LOffer.DeliveryDate;
        LOrder.Description := LOffer.OfferNo;

        LLines := TSlsOfferDetailRepository(FOfferDetailRepo).FindByOfferIds([AOfferId]);
        try
          for LLine in LLines do
          begin
            if LLine.Quantity - LLine.OrderedQuantity <= 0 then
              Continue;
            LDetail := NewLine(LOrder);
            LDetail.StkInventoryId := LLine.StkInventoryId;
            LDetail.Quantity := LLine.Quantity - LLine.OrderedQuantity;
            // teklif fiyatı, iskontosu ve KDV'si
            LDetail.UnitPrice := LLine.UnitPrice;
            LDetail.DiscountRate := LLine.DiscountRate;
            LDetail.VatRate := LLine.VatRate;
            LDetail.Description := LLine.Description;
            LDetail.SlsOfferDetailId := LLine.Id;
          end;
        finally
          LLines.Free;
        end;
        if Length(ActiveLines(LOrder)) = 0 then
          raise ESlsOrderExceptionNothingToOrder.Create;

        Recalculate(LOrder);
        BusinessSaveWithDetails(LOrder, False, APermissionControl);
        Result := LOrder.Id;
      finally
        LOrder.Free;
      end;
    finally
      LOffer.Free;
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

function TSlsOrderService.GetLines(AHeader: TSlsOrder): TObjectList<TSlsOrderDetail>;
begin
  Result := AHeader.Lines;
end;

function TSlsOrderService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TSlsOrderDetail>;
begin
  Result := TSlsOrderDetailRepository(FLineRepo).FindByOrderIds(AIds);
end;

function TSlsOrderService.GetLineHeaderId(ALine: TSlsOrderDetail): Int64;
begin
  Result := ALine.SlsOrderId;
end;

procedure TSlsOrderService.SetLineHeaderId(ALine: TSlsOrderDetail; AHeaderId: Int64);
begin
  ALine.SlsOrderId := AHeaderId;
end;

function TSlsOrderService.GetLineNo(ALine: TSlsOrderDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TSlsOrderService.SetLineNo(ALine: TSlsOrderDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TSlsOrderService.RaiseDuplicateLineNo;
begin
  raise ESlsOrderDetailExceptionLineUnique.Create;
end;

// Belge no / para birimi (kalem formu: fiyat önerisi, gösterim), teslim tarihi başlıktan
procedure TSlsOrderService.InitLine(AHeader: TSlsOrder; ALine: TSlsOrderDetail);
begin
  ALine.OrderNo := AHeader.OrderNo;
  ALine.Currency := AHeader.Currency;
  ALine.DeliveryDate := AHeader.DeliveryDate;
end;

function TSlsOrderService.LineChanged(ALine, AOld: TSlsOrderDetail): Boolean;
begin
  Result := (ALine.LineNo <> AOld.LineNo) or (ALine.StkInventoryId <> AOld.StkInventoryId) or
    (ALine.Quantity <> AOld.Quantity) or (ALine.UnitPrice <> AOld.UnitPrice) or
    (ALine.DiscountRate <> AOld.DiscountRate) or (ALine.VatRate <> AOld.VatRate) or
    (ALine.DeliveryDate <> AOld.DeliveryDate) or (ALine.SlsOfferDetailId <> AOld.SlsOfferDetailId) or
    (Trim(ALine.Description) <> AOld.Description);
end;

// Alanlar + tutarlar (tek kalem yoluyla ortak CheckLine), KDV tanımlı oranlardan, teklif kalemiyle stok uyumu,
// teslim edilen miktar DB'den (irsaliye / fatura tutar); taslak dışı siparişte kalem eklenemez / silinemez / değişemez
procedure TSlsOrderService.CheckLines(AHeader: TSlsOrder; const ALines: TArray<TSlsOrderDetail>;
  AOldLines: TObjectList<TSlsOrderDetail>);
var
  LRates: TArray<Currency>;
  LLine, LOld: TSlsOrderDetail;
  LOldById: TDictionary<Int64, TSlsOrderDetail>;
  LOfferDetail: TSlsOfferDetail;
  LDbOrder: TSlsOrder;
  LDraft: Boolean;
begin
  LDraft := True;
  if AHeader.Id > 0 then
  begin
    LDbOrder := FRepo.FindById(AHeader.Id, False);
    try
      LDraft := not Assigned(LDbOrder) or (LDbOrder.Status = SLS_ORD_DRAFT);
    finally
      LDbOrder.Free;
    end;
  end;

  LRates := TSlsOfferDetailRepository(FOfferDetailRepo).GetVatRates;
  LOldById := TDictionary<Int64, TSlsOrderDetail>.Create;
  try
    for LOld in AOldLines do
      LOldById.AddOrSetValue(LOld.Id, LOld);

    if not LDraft then
      for LLine in AHeader.Lines do
        if (LLine.Id < 0) or LLine.Deleted then
          raise ESlsOrderDetailExceptionDraftOnly.Create;

    for LLine in ALines do
    begin
      TSlsOrderDetailService.CheckLine(LLine);
      TSlsOfferDetailService.CheckVatRate(LLine.VatRate, LRates);
      if LLine.SlsOfferDetailId > 0 then
      begin
        LOfferDetail := FOfferDetailRepo.FindById(LLine.SlsOfferDetailId, False);
        try
          if Assigned(LOfferDetail) and (LOfferDetail.StkInventoryId <> LLine.StkInventoryId) then
            raise ESlsOrderDetailExceptionInventoryMismatch.Create;
        finally
          LOfferDetail.Free;
        end;
      end;

      if LOldById.TryGetValue(LLine.Id, LOld) then
      begin
        if not LDraft and LineChanged(LLine, LOld) then
          raise ESlsOrderDetailExceptionDraftOnly.Create;
        LLine.DeliveredQuantity := LOld.DeliveredQuantity;   // irsaliye / irsaliyeli fatura kalemlerinden tutulur
      end
      else
        LLine.DeliveredQuantity := 0;
    end;
  finally
    LOldById.Free;
  end;
end;

procedure TSlsOrderService.RefreshOfferIds(const AOfferDetailIds: TArray<Int64>);
var
  LId: Int64;
begin
  for LId in TSlsOfferDetailRepository(FOfferDetailRepo).OfferIdsOfDetails(AOfferDetailIds) do
    TSlsOfferRepository(FOfferRepo).RefreshOrderedQuantities(LId);
end;

// Belge hook'u: bağlı (eski + yeni) teklif kalemlerinin siparişe aktarılan miktarı ve teklif durumu
procedure TSlsOrderService.AfterDocumentSaved(AHeader: TSlsOrder; AOldLines: TObjectList<TSlsOrderDetail>);
var
  LIds: TList<Int64>;
  LLine: TSlsOrderDetail;
begin
  LIds := TList<Int64>.Create;
  try
    for LLine in AOldLines do
      if (LLine.SlsOfferDetailId > 0) and not LIds.Contains(LLine.SlsOfferDetailId) then
        LIds.Add(LLine.SlsOfferDetailId);
    for LLine in AHeader.Lines do
      if (LLine.SlsOfferDetailId > 0) and not LIds.Contains(LLine.SlsOfferDetailId) then
        LIds.Add(LLine.SlsOfferDetailId);
    if LIds.Count > 0 then
      RefreshOfferIds(LIds.ToArray);
  finally
    LIds.Free;
  end;
end;

procedure TSlsOrderService.PrepareCopyHeader(AHeader: TSlsOrder);
begin
  AHeader.OrderNo := '';
  AHeader.Status := SLS_ORD_DRAFT;
end;

// Kopya kalem tekliften bağımsızdır (teklifin siparişe aktarılan miktarı iki kez sayılmasın)
procedure TSlsOrderService.PrepareCopyLine(AHeader: TSlsOrder; ALine: TSlsOrderDetail);
begin
  inherited;
  ALine.OrderNo := '';
  ALine.DeliveredQuantity := 0;
  ALine.SlsOfferDetailId := 0;
  ALine.OfferNo := '';
end;

procedure TSlsOrderService.RecalculateLine(ALine: TSlsOrderDetail);
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

procedure TSlsOrderService.RecalculateTotals(AHeader: TSlsOrder);
var
  LLine: TSlsOrderDetail;
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

procedure TSlsOrderService.ValidateBusinessRules(AEntity: TSlsOrder; AOperation: TCrudOperation);
var
  LRepo: TSlsOrderRepository;
  LOld: TSlsOrder;
  LFilter: TFilterCriteria;
  LModel: TSlsOrder;
begin
  LRepo := TSlsOrderRepository(FRepo);
  if AOperation = coDelete then
  begin
    if not (AEntity.Status in [SLS_ORD_DRAFT, SLS_ORD_CANCELLED]) then
      raise ESlsOrderExceptionDeleteStatus.Create;
    if LRepo.DeliveryCount(AEntity.Id) > 0 then
      raise ESlsOrderExceptionHasDeliveries.Create;
    Exit;
  end;

  AEntity.OrderNo := AnsiUpperCase(Trim(AEntity.OrderNo));
  AEntity.CustomerRefNo := Trim(AEntity.CustomerRefNo);
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.OrderDate <= 0 then
    FailRequired(TLangKeys.TSlsOrder.ColOrderDate, 'Order Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TSlsOrder.ColAccAccountId, 'Customer');
  if (AEntity.DeliveryDate > 0) and (AEntity.DeliveryDate < AEntity.OrderDate) then
    raise ESlsOrderExceptionDeliveryDate.Create;
  if (AEntity.PaymentTermDays < 0) or (AEntity.PaymentTermDays > 365) then
    raise ESlsOrderExceptionPaymentTerm.Create;
  if AEntity.ExchangeRate <= 0 then
    AEntity.ExchangeRate := 1;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    // durum ve tutarlar servis tarafından tutulur (tutarlar kalemlerden)
    AEntity.Status := SLS_ORD_DRAFT;
    AEntity.GrossAmount := 0;
    AEntity.DiscountAmount := 0;
    AEntity.NetAmount := 0;
    AEntity.VatAmount := 0;
    AEntity.TotalAmount := 0;
    if AEntity.OrderNo = '' then
      AEntity.OrderNo := LRepo.NextDocumentNo(SLS_PREFIX_ORDER);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if LOld.Status in [SLS_ORD_DELIVERED, SLS_ORD_CANCELLED] then
        raise ESlsOrderExceptionNotEditable.Create;
      if (LRepo.DeliveryCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or (LOld.Currency <> AEntity.Currency)) then
        raise ESlsOrderExceptionKeyFieldsLocked.Create;
      AEntity.Status := LOld.Status;
      AEntity.GrossAmount := LOld.GrossAmount;
      AEntity.DiscountAmount := LOld.DiscountAmount;
      AEntity.NetAmount := LOld.NetAmount;
      AEntity.VatAmount := LOld.VatAmount;
      AEntity.TotalAmount := LOld.TotalAmount;
      if AEntity.OrderNo = '' then
        AEntity.OrderNo := LOld.OrderNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('order_no', '=', TValue.From<string>(AEntity.OrderNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsOrderExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSlsOrderService.DoAdd(AEntity: TSlsOrder);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSlsOrderService.DoUpdate(AEntity: TSlsOrder);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSlsOrderService.DoDelete(AId: Int64);
var
  LEntity: TSlsOrder;
  LOfferIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler cascade silinir; bağlı teklif kalemlerinin siparişe aktarılan miktarı yenilenir
    LOfferIds := TSlsOrderRepository(FRepo).OfferIdsOfOrder(AId);
    FRepo.Delete(LEntity);
    for LId in LOfferIds do
      TSlsOfferRepository(FOfferRepo).RefreshOrderedQuantities(LId);
  finally
    LEntity.Free;
  end;
end;

function TSlsOrderService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsOrder>;
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

function TSlsOrderService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsOrder;
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

procedure TSlsOrderService.BusinessInsert(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOrderService.BusinessUpdate(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsOrderService.BusinessDelete(AEntity: TSlsOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsOrderService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TSlsOrderService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsOrder>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TSlsOrderService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsOrder;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TSlsOrderService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsOrder;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsOrderService.Add(AEntity: TSlsOrder);
begin
  DoAdd(AEntity);
end;

procedure TSlsOrderService.Update(AEntity: TSlsOrder);
begin
  DoUpdate(AEntity);
end;

procedure TSlsOrderService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
