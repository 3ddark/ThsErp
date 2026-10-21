unit PurOrder.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, PurOrder.Repository, PurOrder, PurOrder.Exception, PurOrderDetail, PurOrderDetail.Repository,
  PurRequest, PurRequest.Repository, PurRequestDetail, PurRequestDetail.Repository;

type
  // Sipariş belgesi = başlık + Lines (TDocumentService: kalem işlemleri, hesap tetikleme, yükleme, tek transaction'lı
  // kayıt + Reload). Başlık taslak dışında da (onaylı / kısmi) değişebilir; kalemler yalnız taslakta.
  TPurOrderService = class(TDocumentService<TPurOrder, TPurOrderDetail>)
  private
    FRepo: IRepository<TPurOrder>;
    FDetailRepo: IRepository<TPurOrderDetail>;
    FRequestRepo: IRepository<TPurRequest>;
    FRequestDetailRepo: IRepository<TPurRequestDetail>;

    procedure DoAdd(AEntity: TPurOrder);
    procedure DoUpdate(AEntity: TPurOrder);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // Kalem kayıtlı hâlinden farklı mı (taslak dışı siparişte kalem değişikliği yasak)
    function LineChanged(ALine, AOld: TPurOrderDetail): Boolean;
    procedure RefreshRequestIds(const ARequestDetailIds: TArray<Int64>);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TPurOrder): TObjectList<TPurOrderDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurOrderDetail>; override;
    function GetLineHeaderId(ALine: TPurOrderDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TPurOrderDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TPurOrderDetail): Integer; override;
    procedure SetLineNo(ALine: TPurOrderDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TPurOrder; ALine: TPurOrderDetail); override;
    procedure CheckLines(AHeader: TPurOrder; const ALines: TArray<TPurOrderDetail>; AOldLines: TObjectList<TPurOrderDetail>); override;
    procedure AfterDocumentSaved(AHeader: TPurOrder; AOldLines: TObjectList<TPurOrderDetail>); override;
    procedure PrepareCopyHeader(AHeader: TPurOrder); override;
    procedure PrepareCopyLine(AHeader: TPurOrder; ALine: TPurOrderDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurOrder; AOperation: TCrudOperation); override;
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);

    // Kalem tutarları miktar, fiyat ve oranlardan; başlık toplamları aktif kalemlerden
    procedure RecalculateLine(ALine: TPurOrderDetail); override;
    procedure RecalculateTotals(AHeader: TPurOrder); override;
    // Onaylı talebin kalan miktarlarından taslak sipariş; yeni sipariş id
    function CreateFromRequest(ARequestId, AAccountId: Int64; APermissionControl: Boolean): Int64;
    procedure RefreshRequests(AOrderId: Int64);

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurOrder>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurOrder; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurOrder; override;

    procedure Add(AEntity: TPurOrder); override;
    procedure Update(AEntity: TPurOrder); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurOrder; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurOrder>; override;
    procedure BusinessInsert(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, PurOrderDetail.Service, PurOrderDetail.Exception,
  AccSetTaxRate, AccSetTaxRate.Repository, AccSetTaxRate.Service;

constructor TPurOrderService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurOrder, TPurOrderRepository>;
  FDetailRepo := Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := FDetailRepo;
  FRequestRepo := Self.UoW.GetRepository<TPurRequest, TPurRequestRepository>;
  FRequestDetailRepo := Self.UoW.GetRepository<TPurRequestDetail, TPurRequestDetailRepository>;
  Self.PermissionCode := PERMISSION_PUR_ORDER;
end;

{ Belge (TDocumentService) }

function TPurOrderService.GetLines(AHeader: TPurOrder): TObjectList<TPurOrderDetail>;
begin
  Result := AHeader.Lines;
end;

function TPurOrderService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurOrderDetail>;
begin
  Result := TPurOrderDetailRepository(FLineRepo).FindByOrderIds(AIds);
end;

function TPurOrderService.GetLineHeaderId(ALine: TPurOrderDetail): Int64;
begin
  Result := ALine.PurOrderId;
end;

procedure TPurOrderService.SetLineHeaderId(ALine: TPurOrderDetail; AHeaderId: Int64);
begin
  ALine.PurOrderId := AHeaderId;
end;

function TPurOrderService.GetLineNo(ALine: TPurOrderDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TPurOrderService.SetLineNo(ALine: TPurOrderDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TPurOrderService.RaiseDuplicateLineNo;
begin
  raise EPurOrderDetailExceptionLineUnique.Create;
end;

// Belge no / para birimi (kalem formu: fiyat önerisi, gösterim), teslim tarihi başlıktan
procedure TPurOrderService.InitLine(AHeader: TPurOrder; ALine: TPurOrderDetail);
begin
  ALine.OrderNo := AHeader.OrderNo;
  ALine.Currency := AHeader.Currency;
  ALine.DeliveryDate := AHeader.DeliveryDate;
end;

function TPurOrderService.LineChanged(ALine, AOld: TPurOrderDetail): Boolean;
begin
  Result := (ALine.LineNo <> AOld.LineNo) or (ALine.StkInventoryId <> AOld.StkInventoryId) or
    (ALine.Quantity <> AOld.Quantity) or (ALine.UnitPrice <> AOld.UnitPrice) or
    (ALine.DiscountRate <> AOld.DiscountRate) or (ALine.VatRate <> AOld.VatRate) or
    (ALine.DeliveryDate <> AOld.DeliveryDate) or (ALine.PurRequestDetailId <> AOld.PurRequestDetailId) or
    (Trim(ALine.Description) <> AOld.Description);
end;

// Alanlar + tutarlar (tek kalem yoluyla ortak CheckLine), KDV tanımlı oranlardan, talep kalemiyle stok uyumu,
// teslim alınan miktar DB'den (mal kabuller tutar); taslak dışı siparişte kalem eklenemez / silinemez / değişemez
procedure TPurOrderService.CheckLines(AHeader: TPurOrder; const ALines: TArray<TPurOrderDetail>;
  AOldLines: TObjectList<TPurOrderDetail>);
var
  LRates: TArray<Currency>;
  LLine, LOld: TPurOrderDetail;
  LOldById: TDictionary<Int64, TPurOrderDetail>;
  LRequestDetail: TPurRequestDetail;
  LDbOrder: TPurOrder;
  LDraft: Boolean;
begin
  LDraft := True;
  if AHeader.Id > 0 then
  begin
    LDbOrder := FRepo.FindById(AHeader.Id, False);
    try
      LDraft := not Assigned(LDbOrder) or (LDbOrder.Status = PUR_ORD_DRAFT);
    finally
      LDbOrder.Free;
    end;
  end;

  LRates := TAccSetTaxRateRepository(Self.UoW.GetRepository<TAccSetTaxRate, TAccSetTaxRateRepository>).GetTaxRates;
  LOldById := TDictionary<Int64, TPurOrderDetail>.Create;
  try
    for LOld in AOldLines do
      LOldById.AddOrSetValue(LOld.Id, LOld);

    if not LDraft then
      for LLine in AHeader.Lines do
        if (LLine.Id < 0) or LLine.Deleted then
          raise EPurOrderDetailExceptionDraftOnly.Create;

    for LLine in ALines do
    begin
      TPurOrderDetailService.CheckLine(LLine);
      TAccSetTaxRateService.CheckDefinedRate(LLine.VatRate, LRates);
      if LLine.PurRequestDetailId > 0 then
      begin
        LRequestDetail := FRequestDetailRepo.FindById(LLine.PurRequestDetailId, False);
        try
          if Assigned(LRequestDetail) and (LRequestDetail.StkInventoryId <> LLine.StkInventoryId) then
            raise EPurOrderDetailExceptionInventoryMismatch.Create;
        finally
          LRequestDetail.Free;
        end;
      end;

      if LOldById.TryGetValue(LLine.Id, LOld) then
      begin
        if not LDraft and LineChanged(LLine, LOld) then
          raise EPurOrderDetailExceptionDraftOnly.Create;
        LLine.ReceivedQuantity := LOld.ReceivedQuantity;   // mal kabul kalemlerinden tutulur
      end
      else
        LLine.ReceivedQuantity := 0;
    end;
  finally
    LOldById.Free;
  end;
end;

procedure TPurOrderService.RefreshRequestIds(const ARequestDetailIds: TArray<Int64>);
var
  LId: Int64;
begin
  for LId in TPurRequestDetailRepository(FRequestDetailRepo).RequestIdsOfDetails(ARequestDetailIds) do
    TPurRequestRepository(FRequestRepo).RefreshOrderedQuantities(LId);
end;

// Belge hook'u: bağlı (eski + yeni) talep kalemlerinin sipariş edilen miktarı ve talep durumu
procedure TPurOrderService.AfterDocumentSaved(AHeader: TPurOrder; AOldLines: TObjectList<TPurOrderDetail>);
var
  LIds: TList<Int64>;
  LLine: TPurOrderDetail;
begin
  LIds := TList<Int64>.Create;
  try
    for LLine in AOldLines do
      if (LLine.PurRequestDetailId > 0) and not LIds.Contains(LLine.PurRequestDetailId) then
        LIds.Add(LLine.PurRequestDetailId);
    for LLine in AHeader.Lines do
      if (LLine.PurRequestDetailId > 0) and not LIds.Contains(LLine.PurRequestDetailId) then
        LIds.Add(LLine.PurRequestDetailId);
    if LIds.Count > 0 then
      RefreshRequestIds(LIds.ToArray);
  finally
    LIds.Free;
  end;
end;

procedure TPurOrderService.PrepareCopyHeader(AHeader: TPurOrder);
begin
  AHeader.OrderNo := '';
  AHeader.Status := PUR_ORD_DRAFT;
end;

// Kopya kalem talepten bağımsızdır (talebin sipariş edilen miktarı iki kez sayılmasın)
procedure TPurOrderService.PrepareCopyLine(AHeader: TPurOrder; ALine: TPurOrderDetail);
begin
  inherited;
  ALine.OrderNo := '';
  ALine.ReceivedQuantity := 0;
  ALine.PurRequestDetailId := 0;
  ALine.RequestNo := '';
end;

procedure TPurOrderService.RecalculateLine(ALine: TPurOrderDetail);
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

procedure TPurOrderService.RecalculateTotals(AHeader: TPurOrder);
var
  LLine: TPurOrderDetail;
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

destructor TPurOrderService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TPurOrderService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Elle durum değişikliği (onay / taslağa alma / red / iptal / kapama); kendi açtığı transaction'ı commit eder
procedure TPurOrderService.ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);
var
  LOld: TPurOrder;
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
      if not TPurLookup.CanChangeOrderStatus(LOld.Status, ANewStatus) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPurOrder.InvalidStatus,
          'Status cannot be changed from "%s" to "%s".'), [TPurLookup.Text(plkOrderStatus, LOld.Status), TPurLookup.Text(plkOrderStatus, ANewStatus)]));
      if (ANewStatus = PUR_ORD_APPROVED) and (TPurOrderRepository(FRepo).LineCount(AId) = 0) then
        raise EPurOrderExceptionNoLines.Create;
      if (ANewStatus in [PUR_ORD_DRAFT, PUR_ORD_CANCELLED]) and (TPurOrderRepository(FRepo).ReceiptCount(AId) > 0) then
        raise EPurOrderExceptionHasReceipts.Create;
      TPurOrderRepository(FRepo).SetStatus(AId, ANewStatus);
      // iptal / yeniden açma talep kalemlerinin sipariş edilen miktarını değiştirir
      RefreshRequests(AId);
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

procedure TPurOrderService.RefreshRequests(AOrderId: Int64);
var
  LId: Int64;
begin
  for LId in TPurOrderRepository(FRepo).RequestIdsOfOrder(AOrderId) do
    TPurRequestRepository(FRequestRepo).RefreshOrderedQuantities(LId);
end;

// Onaylı talebin kalan miktarları belge olarak bellekte kurulur ve belge kaydıyla yazılır (tek yol)
function TPurOrderService.CreateFromRequest(ARequestId, AAccountId: Int64; APermissionControl: Boolean): Int64;
var
  LRequest: TPurRequest;
  LOrder: TPurOrder;
  LLines: TObjectList<TPurRequestDetail>;
  LLine: TPurRequestDetail;
  LDetail: TPurOrderDetail;
  LStarted: Boolean;
  LPrice, LDiscount, LVat: Currency;
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

    LRequest := FRequestRepo.FindById(ARequestId, True);
    try
      if not Assigned(LRequest) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ARequestId]));
      if LRequest.Status <> PUR_REQ_APPROVED then
        raise EPurOrderExceptionRequestNotApproved.Create;

      LOrder := TPurOrder.Create;
      try
        LOrder.OrderDate := Date;
        LOrder.AccAccountId := AAccountId;
        LOrder.Currency := TPurOrderRepository(FRepo).GetDefaultCurrency;
        LOrder.Description := LRequest.RequestNo;

        LLines := TPurRequestDetailRepository(FRequestDetailRepo).FindByRequestIds([ARequestId]);
        try
          for LLine in LLines do
          begin
            if LLine.Quantity - LLine.OrderedQuantity <= 0 then
              Continue;
            LDetail := NewLine(LOrder);
            LDetail.StkInventoryId := LLine.StkInventoryId;
            LDetail.Quantity := LLine.Quantity - LLine.OrderedQuantity;
            LDetail.DeliveryDate := LLine.RequiredDate;
            LDetail.Description := LLine.Description;
            LDetail.PurRequestDetailId := LLine.Id;
            if TPurOrderDetailRepository(FDetailRepo).GetInventoryDefaults(LLine.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
            begin
              // fiyat yalnız sipariş para biriminde ise önerilir
              if LCurrency = LOrder.Currency then
                LDetail.UnitPrice := LPrice;
              LDetail.DiscountRate := LDiscount;
              LDetail.VatRate := LVat;
            end;
          end;
        finally
          LLines.Free;
        end;
        if Length(ActiveLines(LOrder)) = 0 then
          raise EPurOrderExceptionNothingToOrder.Create;

        Recalculate(LOrder);
        BusinessSaveWithDetails(LOrder, False, APermissionControl);
        Result := LOrder.Id;
      finally
        LOrder.Free;
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

procedure TPurOrderService.ValidateBusinessRules(AEntity: TPurOrder; AOperation: TCrudOperation);
var
  LRepo: TPurOrderRepository;
  LOld: TPurOrder;
  LFilter: TFilterCriteria;
  LModel: TPurOrder;
begin
  LRepo := TPurOrderRepository(FRepo);
  if AOperation = coDelete then
  begin
    if not (AEntity.Status in [PUR_ORD_DRAFT, PUR_ORD_CANCELLED]) then
      raise EPurOrderExceptionDeleteStatus.Create;
    if LRepo.ReceiptCount(AEntity.Id) > 0 then
      raise EPurOrderExceptionHasReceipts.Create;
    Exit;
  end;

  AEntity.OrderNo := AnsiUpperCase(Trim(AEntity.OrderNo));
  AEntity.SupplierRefNo := Trim(AEntity.SupplierRefNo);
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.OrderDate <= 0 then
    FailRequired(TLangKeys.TPurOrder.ColOrderDate, 'Order Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TPurOrder.ColAccAccountId, 'Supplier');
  if (AEntity.DeliveryDate > 0) and (AEntity.DeliveryDate < AEntity.OrderDate) then
    raise EPurOrderExceptionDeliveryDate.Create;
  if (AEntity.PaymentTermDays < 0) or (AEntity.PaymentTermDays > 365) then
    raise EPurOrderExceptionPaymentTerm.Create;
  if AEntity.ExchangeRate <= 0 then
    AEntity.ExchangeRate := 1;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    // durum ve tutarlar servis tarafından tutulur (tutarlar kalemlerden)
    AEntity.Status := PUR_ORD_DRAFT;
    AEntity.GrossAmount := 0;
    AEntity.DiscountAmount := 0;
    AEntity.NetAmount := 0;
    AEntity.VatAmount := 0;
    AEntity.TotalAmount := 0;
    if AEntity.OrderNo = '' then
      AEntity.OrderNo := LRepo.NextDocumentNo(PUR_PREFIX_ORDER);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if LOld.Status in [PUR_ORD_RECEIVED, PUR_ORD_CANCELLED] then
        raise EPurOrderExceptionNotEditable.Create;
      if (LRepo.ReceiptCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or (LOld.Currency <> AEntity.Currency)) then
        raise EPurOrderExceptionKeyFieldsLocked.Create;
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
        raise EPurOrderExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurOrderService.DoAdd(AEntity: TPurOrder);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurOrderService.DoUpdate(AEntity: TPurOrder);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPurOrderService.DoDelete(AId: Int64);
var
  LEntity: TPurOrder;
  LRequestIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler cascade silinir; bağlı talep kalemlerinin sipariş miktarı yenilenir
    LRequestIds := TPurOrderRepository(FRepo).RequestIdsOfOrder(AId);
    FRepo.Delete(LEntity);
    for LId in LRequestIds do
      TPurRequestRepository(FRequestRepo).RefreshOrderedQuantities(LId);
  finally
    LEntity.Free;
  end;
end;

function TPurOrderService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurOrder>;
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

function TPurOrderService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurOrder;
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

procedure TPurOrderService.BusinessInsert(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurOrderService.BusinessUpdate(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurOrderService.BusinessDelete(AEntity: TPurOrder; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurOrderService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TPurOrderService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurOrder>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TPurOrderService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurOrder;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TPurOrderService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurOrder;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurOrderService.Add(AEntity: TPurOrder);
begin
  DoAdd(AEntity);
end;

procedure TPurOrderService.Update(AEntity: TPurOrder);
begin
  DoUpdate(AEntity);
end;

procedure TPurOrderService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
