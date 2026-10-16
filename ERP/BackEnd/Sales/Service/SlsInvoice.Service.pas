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
  // hook'u: stok özeti, siparişlerin sevk miktarları, irsaliyelerin durumu. Durum modeli ve e-Fatura alanları
  // resmi dokümanlarla eklenecek.
  TSlsInvoiceService = class(TDocumentService<TSlsInvoice, TSlsInvoiceDetail>)
  private
    FRepo: IRepository<TSlsInvoice>;
    FDispatchRepo: IRepository<TSlsDispatch>;
    FOrderRepo: IRepository<TSlsOrder>;
    FDispatchDetailRepo: IRepository<TSlsDispatchDetail>;
    FOrderDetailRepo: IRepository<TSlsOrderDetail>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TSlsInvoice);
    procedure DoUpdate(AEntity: TSlsInvoice);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // Sipariş kurundan / vadesinden fatura başlığı
    procedure ApplyOrderTerms(AInvoice: TSlsInvoice; AOrderId: Int64);
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
  SlsOfferDetail, SlsOfferDetail.Repository, SlsOfferDetail.Service;

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
end;

procedure TSlsInvoiceService.PrepareCopyHeader(AHeader: TSlsInvoice);
begin
  AHeader.InvoiceNo := '';
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

procedure TSlsInvoiceService.ValidateBusinessRules(AEntity: TSlsInvoice; AOperation: TCrudOperation);
var
  LRepo: TSlsInvoiceRepository;
  LOld: TSlsInvoice;
  LFilter: TFilterCriteria;
  LModel: TSlsInvoice;
begin
  LRepo := TSlsInvoiceRepository(FRepo);
  if AOperation = coDelete then
    Exit;

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
    if AEntity.InvoiceNo = '' then
      AEntity.InvoiceNo := LRepo.NextDocumentNo(SLS_PREFIX_INVOICE);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
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
      if AEntity.InvoiceNo = '' then
        AEntity.InvoiceNo := LOld.InvoiceNo;
    finally
      LOld.Free;
    end;
  end;

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
