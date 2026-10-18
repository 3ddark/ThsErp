unit SlsDispatch.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, SlsDispatch.Repository, SlsDispatch, SlsDispatch.Exception, SlsDispatchDetail, SlsDispatchDetail.Repository,
  SlsOrder, SlsOrder.Repository, SlsOrderDetail, SlsOrderDetail.Repository, StkInventorySummary, StkInventorySummary.Repository;

type
  // İrsaliye belgesi = başlık + Lines (TDocumentService). Kalem hook'u: stok çıkış hareketi (gerçek id ile); belge
  // hook'u: etkilenen stokların özeti, siparişin sevk miktarları / durumu, irsaliye durumu (faturalardan).
  // Faturalanan kalem silinemez, miktarı faturalanandan aza inemez, stoğu değişemez.
  TSlsDispatchService = class(TDocumentService<TSlsDispatch, TSlsDispatchDetail>)
  private
    FRepo: IRepository<TSlsDispatch>;
    FOrderRepo: IRepository<TSlsOrder>;
    FOrderDetailRepo: IRepository<TSlsOrderDetail>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TSlsDispatch);
    procedure DoUpdate(AEntity: TSlsDispatch);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // e-İrsaliye: senaryo / ETTN / durum + taşıma kuralları (AOld: güncellemede DB'deki kayıt, eklemede nil)
    procedure CheckEDespatch(AEntity, AOld: TSlsDispatch);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TSlsDispatch): TObjectList<TSlsDispatchDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TSlsDispatchDetail>; override;
    function GetLineHeaderId(ALine: TSlsDispatchDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TSlsDispatchDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TSlsDispatchDetail): Integer; override;
    procedure SetLineNo(ALine: TSlsDispatchDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TSlsDispatch; ALine: TSlsDispatchDetail); override;
    procedure CheckLines(AHeader: TSlsDispatch; const ALines: TArray<TSlsDispatchDetail>; AOldLines: TObjectList<TSlsDispatchDetail>); override;
    procedure AfterLineSaved(AHeader: TSlsDispatch; ALine: TSlsDispatchDetail); override;
    procedure AfterDocumentSaved(AHeader: TSlsDispatch; AOldLines: TObjectList<TSlsDispatchDetail>); override;
    procedure PrepareCopyHeader(AHeader: TSlsDispatch); override;
    procedure PrepareCopyLine(AHeader: TSlsDispatch; ALine: TSlsDispatchDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsDispatch; AOperation: TCrudOperation); override;

    // Kalem tutarı (miktar x net fiyat); başlık toplamı aktif kalemlerden
    procedure RecalculateLine(ALine: TSlsDispatchDetail); override;
    procedure RecalculateTotals(AHeader: TSlsDispatch); override;
    // Onaylı siparişin kalan miktarlarından sevk irsaliyesi (stok çıkışı dahil); yeni irsaliye id
    function CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;
    // Senaryo seçilmemişse cariye göre öneri: e-İrsaliye mükellefi -> TEMELIRSALIYE (değilse kağıt irsaliye)
    procedure SuggestEDespatch(ADispatch: TSlsDispatch; AEDespatchUser: Boolean);

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSlsDispatch>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSlsDispatch; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSlsDispatch; override;

    procedure Add(AEntity: TSlsDispatch); override;
    procedure Update(AEntity: TSlsDispatch); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsDispatch; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsDispatch>; override;
    procedure BusinessInsert(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SlsLookup, SlsDispatchDetail.Service, SlsDispatchDetail.Exception, EInvLookup,
  EInvDocument, EInvDocument.Repository, EInvDocument.Service, EInvSeries, EInvSeries.Repository;

constructor TSlsDispatchService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsDispatch, TSlsDispatchRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TSlsDispatchDetail, TSlsDispatchDetailRepository>;
  FOrderRepo := Self.UoW.GetRepository<TSlsOrder, TSlsOrderRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TSlsOrderDetail, TSlsOrderDetailRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_SLS_DISPATCH;
end;

destructor TSlsDispatchService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsDispatchService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Onaylı siparişin kalan miktarları belge olarak bellekte kurulur ve belge kaydıyla yazılır (stok çıkışı kalem
// hook'unda); yeni irsaliye id
function TSlsDispatchService.CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;
var
  LOrder: TSlsOrder;
  LDispatch: TSlsDispatch;
  LLines: TObjectList<TSlsOrderDetail>;
  LLine: TSlsOrderDetail;
  LDetail: TSlsDispatchDetail;
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
        raise ESlsDispatchExceptionOrderStatus.Create;

      LDispatch := TSlsDispatch.Create;
      try
        LDispatch.DispatchDate := Date;
        LDispatch.AccAccountId := LOrder.AccAccountId;
        LDispatch.StkWarehouseId := AWarehouseId;
        LDispatch.SlsOrderId := LOrder.Id;
        LDispatch.Currency := LOrder.Currency;

        LLines := TSlsOrderDetailRepository(FOrderDetailRepo).FindByOrderIds([AOrderId]);
        try
          for LLine in LLines do
          begin
            if LLine.Quantity - LLine.DeliveredQuantity <= 0 then
              Continue;
            LDetail := NewLine(LDispatch);
            LDetail.StkInventoryId := LLine.StkInventoryId;
            LDetail.Quantity := LLine.Quantity - LLine.DeliveredQuantity;
            // iskontolu net satış birim fiyatı (fatura önerisi / stok çıkış tutarı)
            LDetail.UnitPrice := LLine.NetAmount / LLine.Quantity;
            LDetail.SlsOrderDetailId := LLine.Id;
          end;
        finally
          LLines.Free;
        end;
        if Length(ActiveLines(LDispatch)) = 0 then
          raise ESlsDispatchExceptionNothingToDispatch.Create;

        Recalculate(LDispatch);
        BusinessSaveWithDetails(LDispatch, False, APermissionControl);
        Result := LDispatch.Id;
      finally
        LDispatch.Free;
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

function TSlsDispatchService.GetLines(AHeader: TSlsDispatch): TObjectList<TSlsDispatchDetail>;
begin
  Result := AHeader.Lines;
end;

function TSlsDispatchService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TSlsDispatchDetail>;
begin
  Result := TSlsDispatchDetailRepository(FLineRepo).FindByDispatchIds(AIds);
end;

function TSlsDispatchService.GetLineHeaderId(ALine: TSlsDispatchDetail): Int64;
begin
  Result := ALine.SlsDispatchId;
end;

procedure TSlsDispatchService.SetLineHeaderId(ALine: TSlsDispatchDetail; AHeaderId: Int64);
begin
  ALine.SlsDispatchId := AHeaderId;
end;

function TSlsDispatchService.GetLineNo(ALine: TSlsDispatchDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TSlsDispatchService.SetLineNo(ALine: TSlsDispatchDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TSlsDispatchService.RaiseDuplicateLineNo;
begin
  raise ESlsDispatchDetailExceptionLineUnique.Create;
end;

procedure TSlsDispatchService.InitLine(AHeader: TSlsDispatch; ALine: TSlsDispatchDetail);
begin
  ALine.DispatchNo := AHeader.DispatchNo;
  ALine.Currency := AHeader.Currency;
end;

// Alanlar + tutar (tek kalem yoluyla ortak CheckLine); faturalanan kalem kilidi (faturalanan miktar DB'den); sipariş
// kalemi irsaliyenin siparişine ait ve aynı stok; açık sipariş miktarı belgedeki tüm kalemlerin toplamıyla aşılamaz
procedure TSlsDispatchService.CheckLines(AHeader: TSlsDispatch; const ALines: TArray<TSlsDispatchDetail>;
  AOldLines: TObjectList<TSlsDispatchDetail>);
var
  LLine, LOld: TSlsDispatchDetail;
  LOldById: TDictionary<Int64, TSlsDispatchDetail>;
  LQtyByOrderLine, LOrderLineQty, LOldQtyByOrderLine: TDictionary<Int64, Currency>;
  LOrderDetail: TSlsOrderDetail;
  LPair: TPair<Int64, Currency>;
  LOther, LOpen, LQty: Currency;
begin
  LOldById := TDictionary<Int64, TSlsDispatchDetail>.Create;
  LQtyByOrderLine := TDictionary<Int64, Currency>.Create;
  LOrderLineQty := TDictionary<Int64, Currency>.Create;
  LOldQtyByOrderLine := TDictionary<Int64, Currency>.Create;
  try
    for LOld in AOldLines do
    begin
      LOldById.AddOrSetValue(LOld.Id, LOld);
      if LOld.SlsOrderDetailId > 0 then
      begin
        if not LOldQtyByOrderLine.TryGetValue(LOld.SlsOrderDetailId, LQty) then
          LQty := 0;
        LOldQtyByOrderLine.AddOrSetValue(LOld.SlsOrderDetailId, LQty + LOld.Quantity);
      end;
    end;

    // faturalanan kalem silinemez
    for LLine in AHeader.Lines do
      if LLine.Deleted and LOldById.TryGetValue(LLine.Id, LOld) and (LOld.InvoicedQuantity > 0) then
        raise ESlsDispatchDetailExceptionInvoiced.Create;

    for LLine in ALines do
    begin
      TSlsDispatchDetailService.CheckLine(LLine);

      if LOldById.TryGetValue(LLine.Id, LOld) then
      begin
        LLine.InvoicedQuantity := LOld.InvoicedQuantity;
        if (LOld.InvoicedQuantity > 0) and ((LLine.Quantity < LOld.InvoicedQuantity) or (LLine.StkInventoryId <> LOld.StkInventoryId)) then
          raise ESlsDispatchDetailExceptionInvoiced.Create;
      end
      else
        LLine.InvoicedQuantity := 0;

      if LLine.SlsOrderDetailId > 0 then
      begin
        if not LOrderLineQty.ContainsKey(LLine.SlsOrderDetailId) then
        begin
          LOrderDetail := FOrderDetailRepo.FindById(LLine.SlsOrderDetailId, False);
          try
            if not Assigned(LOrderDetail) or (AHeader.SlsOrderId <> LOrderDetail.SlsOrderId) then
              raise ESlsDispatchDetailExceptionOrderMismatch.Create;
            if LOrderDetail.StkInventoryId <> LLine.StkInventoryId then
              raise ESlsDispatchDetailExceptionInventoryMismatch.Create;
            LOrderLineQty.Add(LLine.SlsOrderDetailId, LOrderDetail.Quantity);
          finally
            LOrderDetail.Free;
          end;
        end;
        if not LQtyByOrderLine.TryGetValue(LLine.SlsOrderDetailId, LQty) then
          LQty := 0;
        LQtyByOrderLine.AddOrSetValue(LLine.SlsOrderDetailId, LQty + LLine.Quantity);
      end;
    end;

    // açık sipariş miktarı: sipariş kalemi - (diğer irsaliye / faturalardaki sevk; bu irsaliyenin eski kalemleri hariç)
    for LPair in LQtyByOrderLine do
    begin
      if not LOldQtyByOrderLine.TryGetValue(LPair.Key, LQty) then
        LQty := 0;
      LOther := TSlsDispatchDetailRepository(FLineRepo).DeliveredQuantityOfOrderDetail(LPair.Key, 0, 0) - LQty;
      LOpen := LOrderLineQty[LPair.Key] - LOther;
      if LPair.Value > LOpen then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.OverDelivery,
          'Quantity exceeds the open order quantity (%s).'), [CurrToStr(LOpen)]));
    end;
  finally
    LOldQtyByOrderLine.Free;
    LOrderLineQty.Free;
    LQtyByOrderLine.Free;
    LOldById.Free;
  end;
end;

// Kalem hook'u: stok çıkış hareketi (yeni / güncellenen kalem; silinenin hareketi FK cascade ile gider). Başlıktaki
// ambar / tarih / no değişikliği de tüm kalemler güncellendiği için hareketlere yansır
procedure TSlsDispatchService.AfterLineSaved(AHeader: TSlsDispatch; ALine: TSlsDispatchDetail);
begin
  TSlsDispatchDetailRepository(FLineRepo).UpsertStockTransaction(ALine.Id);
end;

// Belge hook'u: etkilenen (eski + yeni) stokların özeti, siparişin sevk miktarları / durumu, irsaliye durumu
procedure TSlsDispatchService.AfterDocumentSaved(AHeader: TSlsDispatch; AOldLines: TObjectList<TSlsDispatchDetail>);
var
  LInventoryIds: TList<Int64>;
  LLine: TSlsDispatchDetail;
  LId: Int64;
begin
  LInventoryIds := TList<Int64>.Create;
  try
    for LLine in AOldLines do
      if not LInventoryIds.Contains(LLine.StkInventoryId) then
        LInventoryIds.Add(LLine.StkInventoryId);
    for LLine in AHeader.Lines do
      if not LInventoryIds.Contains(LLine.StkInventoryId) then
        LInventoryIds.Add(LLine.StkInventoryId);
    for LId in LInventoryIds do
      TStkInventorySummaryRepository(FSummaryRepo).Recalculate(LId);
  finally
    LInventoryIds.Free;
  end;
  if AHeader.SlsOrderId > 0 then
    TSlsOrderRepository(FOrderRepo).RefreshDeliveredQuantities(AHeader.SlsOrderId);
  TSlsDispatchRepository(FRepo).RefreshInvoiceStatus(AHeader.Id);
  // e-İrsaliye: UBL XML üretilir + şema doğrulaması (kaydı engellemez); kağıt irsaliyede XML kaydı silinir
  TEInvDocumentService.GenerateForDispatch(
    TEInvDocumentRepository(Self.UoW.GetRepository<TEInvDocument, TEInvDocumentRepository>),
    TEInvSeriesRepository(Self.UoW.GetRepository<TEInvSeries, TEInvSeriesRepository>), AHeader.Id);
end;

// Kopya siparişten bağımsızdır (siparişin sevk miktarı iki kez sayılmasın)
procedure TSlsDispatchService.PrepareCopyHeader(AHeader: TSlsDispatch);
begin
  AHeader.DispatchNo := '';
  AHeader.Status := SLS_DSP_WAITING;
  AHeader.SlsOrderId := 0;
  AHeader.OrderNo := '';
  // e-belge kimliği / durumu / numarası kopyalanmaz (yeni ETTN kayıtta üretilir); taşıma bilgisi kalır
  AHeader.EinvUuid := '';
  AHeader.EinvStatus := 0;
  AHeader.EinvNo := '';
  AHeader.DespatchTime := 0;
end;

procedure TSlsDispatchService.PrepareCopyLine(AHeader: TSlsDispatch; ALine: TSlsDispatchDetail);
begin
  inherited;
  ALine.DispatchNo := '';
  ALine.SlsOrderDetailId := 0;
  ALine.OrderNo := '';
  ALine.InvoicedQuantity := 0;
end;

procedure TSlsDispatchService.RecalculateLine(ALine: TSlsDispatchDetail);
begin
  ALine.Amount := TSlsLookup.RoundAmount(ALine.Quantity * ALine.UnitPrice);
end;

procedure TSlsDispatchService.RecalculateTotals(AHeader: TSlsDispatch);
var
  LLine: TSlsDispatchDetail;
begin
  AHeader.TotalAmount := 0;
  for LLine in AHeader.Lines do
    if not LLine.Deleted then
      AHeader.TotalAmount := AHeader.TotalAmount + LLine.Amount;
end;

procedure TSlsDispatchService.ValidateBusinessRules(AEntity: TSlsDispatch; AOperation: TCrudOperation);
var
  LRepo: TSlsDispatchRepository;
  LOld: TSlsDispatch;
  LOrder: TSlsOrder;
  LFilter: TFilterCriteria;
  LModel: TSlsDispatch;
begin
  LRepo := TSlsDispatchRepository(FRepo);
  if AOperation = coDelete then
  begin
    if TEInvLookup.IsEInvLocked(LRepo.EInvStatus(AEntity.Id)) then
      raise ESlsDispatchExceptionEInvLocked.Create;
    if LRepo.InvoicedQuantity(AEntity.Id) > 0 then
      raise ESlsDispatchExceptionHasInvoices.Create;
    Exit;
  end;

  AEntity.DispatchNo := AnsiUpperCase(Trim(AEntity.DispatchNo));
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.DispatchDate <= 0 then
    FailRequired(TLangKeys.TSlsDispatch.ColDispatchDate, 'Delivery Note Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TSlsDispatch.ColAccAccountId, 'Customer');
  if AEntity.StkWarehouseId <= 0 then
    FailRequired(TLangKeys.TSlsDispatch.ColStkWarehouseId, 'Warehouse');

  if AEntity.SlsOrderId > 0 then
  begin
    LOrder := FOrderRepo.FindById(AEntity.SlsOrderId, False);
    try
      if not Assigned(LOrder) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.SlsOrderId]));
      if LOrder.AccAccountId <> AEntity.AccAccountId then
        raise ESlsDispatchExceptionOrderCustomer.Create;
      if (AOperation = coInsert) and not (LOrder.Status in [SLS_ORD_APPROVED, SLS_ORD_PARTIAL]) then
        raise ESlsDispatchExceptionOrderStatus.Create;
      // siparişli irsaliye siparişin para biriminde
      AEntity.Currency := LOrder.Currency;
    finally
      LOrder.Free;
    end;
  end;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    // e-belge durumu servis tarafından tutulur: yeni e-İrsaliye taslak başlar
    AEntity.EinvStatus := 0;
    CheckEDespatch(AEntity, nil);
    AEntity.Status := SLS_DSP_WAITING;   // durum faturalardan (belge hook'u)
    if AEntity.DispatchNo = '' then
      AEntity.DispatchNo := LRepo.NextDocumentNo(SLS_PREFIX_DISPATCH);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if TEInvLookup.IsEInvLocked(LOld.EinvStatus) then
        raise ESlsDispatchExceptionEInvLocked.Create;
      // e-belge durumu ve ETTN formdan değişmez (durum entegrasyonla, ETTN bir kez üretilir)
      AEntity.EinvStatus := LOld.EinvStatus;
      if LOld.EinvUuid <> '' then
        AEntity.EinvUuid := LOld.EinvUuid;
      CheckEDespatch(AEntity, LOld);
      if (LRepo.LineCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or
        (LOld.SlsOrderId <> AEntity.SlsOrderId) or (LOld.Currency <> AEntity.Currency)) then
        raise ESlsDispatchExceptionKeyFieldsLocked.Create;
      AEntity.Status := LOld.Status;
      if AEntity.DispatchNo = '' then
        AEntity.DispatchNo := LOld.DispatchNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('dispatch_no', '=', TValue.From<string>(AEntity.DispatchNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise ESlsDispatchExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

// Kağıt irsaliyede e-belge kimliği yok; e-İrsaliyede senaryo irsaliye türü, ETTN bir kez, fiili sevk saati (boşsa şimdi),
// taşıma: taşıyıcı firma ya da araç + en az bir şoför (GİB). Araç dorse değil, dorseler dorse, aynı dorse / şoför iki kez
// olmaz, yeni seçilen (eskisinden farklı) pasif kayıt reddedilir; bunlar kağıt irsaliyede de geçerlidir, taşıma
// zorunluluğu yalnız e-İrsaliyede.
procedure TSlsDispatchService.CheckEDespatch(AEntity, AOld: TSlsDispatch);
var
  R: TSlsEDespatchRules;

  procedure CheckActive(AActive: Boolean; ANewId, AOldId: Int64; const AKey, ADefault: string);
  begin
    if (ANewId > 0) and (ANewId <> AOldId) and not AActive then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TSlsDispatch.EInvInactive,
        '%s: the selected record is passive.'), [TLocalizationManager.Translate(AKey, ADefault)]));
  end;

var
  LBase: TSlsDispatch;
begin
  // ikinci dorse / şoför, birinci boşsa birinciye kayar (DB CHECK)
  if (AEntity.Trailer1EinvVehicleId <= 0) and (AEntity.Trailer2EinvVehicleId > 0) then
  begin
    AEntity.Trailer1EinvVehicleId := AEntity.Trailer2EinvVehicleId;
    AEntity.Trailer2EinvVehicleId := 0;
  end;
  if (AEntity.Driver1EinvDriverId <= 0) and (AEntity.Driver2EinvDriverId > 0) then
  begin
    AEntity.Driver1EinvDriverId := AEntity.Driver2EinvDriverId;
    AEntity.Driver2EinvDriverId := 0;
  end;
  if (AEntity.Trailer2EinvVehicleId > 0) and (AEntity.Trailer2EinvVehicleId = AEntity.Trailer1EinvVehicleId) then
    raise ESlsDispatchExceptionTrailerDuplicate.Create;
  if (AEntity.Driver2EinvDriverId > 0) and (AEntity.Driver2EinvDriverId = AEntity.Driver1EinvDriverId) then
    raise ESlsDispatchExceptionDriverDuplicate.Create;

  R := TSlsDispatchRepository(FRepo).ReadEDespatchRules(AEntity);
  // eklemede karşılaştırma tabanı boş kayıt (tüm seçimler yeni sayılır)
  if Assigned(AOld) then
    LBase := AOld
  else
    LBase := TSlsDispatch.Create;
  try
  if (AEntity.EinvVehicleId > 0) and R.VehicleIsTrailer then
    raise ESlsDispatchExceptionVehicleIsTrailer.Create;
  if ((AEntity.Trailer1EinvVehicleId > 0) and not R.Trailer1IsTrailer) or
     ((AEntity.Trailer2EinvVehicleId > 0) and not R.Trailer2IsTrailer) then
    raise ESlsDispatchExceptionTrailerNotTrailer.Create;
    CheckActive(R.ProfileActive, AEntity.EinvProfileId, LBase.EinvProfileId, TLangKeys.TSlsDispatch.ColEinvProfileId, 'Profile');
    CheckActive(R.VehicleActive, AEntity.EinvVehicleId, LBase.EinvVehicleId, TLangKeys.TSlsDispatch.ColEinvVehicleId, 'Vehicle Plate');
    CheckActive(R.Trailer1Active, AEntity.Trailer1EinvVehicleId, LBase.Trailer1EinvVehicleId, TLangKeys.TSlsDispatch.ColTrailer1EinvVehicleId, 'Trailer 1');
    CheckActive(R.Trailer2Active, AEntity.Trailer2EinvVehicleId, LBase.Trailer2EinvVehicleId, TLangKeys.TSlsDispatch.ColTrailer2EinvVehicleId, 'Trailer 2');
    CheckActive(R.Driver1Active, AEntity.Driver1EinvDriverId, LBase.Driver1EinvDriverId, TLangKeys.TSlsDispatch.ColDriver1EinvDriverId, 'Driver 1');
    CheckActive(R.Driver2Active, AEntity.Driver2EinvDriverId, LBase.Driver2EinvDriverId, TLangKeys.TSlsDispatch.ColDriver2EinvDriverId, 'Driver 2');
  finally
    if LBase <> AOld then
      LBase.Free;
  end;

  if AEntity.EinvProfileId <= 0 then
  begin
    // kağıt irsaliye: e-belge kimliği yok
    AEntity.EinvProfileId := 0;
    AEntity.EinvUuid := '';
    AEntity.EinvStatus := 0;
    AEntity.ProfileCode := '';
    Exit;
  end;

  if R.ProfileKind <> EINV_DOC_DESPATCH then
    raise ESlsDispatchExceptionEInvProfileKind.Create;
  AEntity.ProfileCode := R.ProfileCode;
  if AEntity.EinvStatus <= 0 then
    AEntity.EinvStatus := EINV_STATUS_DRAFT;
  if AEntity.EinvUuid = '' then
    AEntity.EinvUuid := LowerCase(TGUID.NewGuid.ToString.Replace('{', '').Replace('}', ''));
  if AEntity.DespatchTime <= 0 then
    AEntity.DespatchTime := Frac(Now);
  if (AEntity.CarrierAccAccountId <= 0) and ((AEntity.EinvVehicleId <= 0) or (AEntity.Driver1EinvDriverId <= 0)) then
    raise ESlsDispatchExceptionTransportRequired.Create;
end;

procedure TSlsDispatchService.SuggestEDespatch(ADispatch: TSlsDispatch; AEDespatchUser: Boolean);
begin
  if (ADispatch.EinvProfileId > 0) or not AEDespatchUser then
    Exit;
  ADispatch.EinvProfileId := TSlsDispatchRepository(FRepo).EInvProfileIdByCode(EINV_PROFILE_DESPATCH);
  if ADispatch.EinvProfileId > 0 then
    ADispatch.ProfileCode := EINV_PROFILE_DESPATCH;
end;

procedure TSlsDispatchService.DoAdd(AEntity: TSlsDispatch);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSlsDispatchService.DoUpdate(AEntity: TSlsDispatch);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  // tarih / ambar değişikliği stok hareketlerine yansır
  TSlsDispatchRepository(FRepo).SyncStockTransactions(AEntity.Id);
end;

procedure TSlsDispatchService.DoDelete(AId: Int64);
var
  LEntity: TSlsDispatch;
  LInventoryIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler ve stok hareketleri cascade silinir; stok özeti ve sipariş sevk miktarları yenilenir
    LInventoryIds := TSlsDispatchRepository(FRepo).InventoryIdsOfDispatch(AId);
    FRepo.Delete(LEntity);
    for LId in LInventoryIds do
      TStkInventorySummaryRepository(FSummaryRepo).Recalculate(LId);
    if LEntity.SlsOrderId > 0 then
      TSlsOrderRepository(FOrderRepo).RefreshDeliveredQuantities(LEntity.SlsOrderId);
  finally
    LEntity.Free;
  end;
end;

function TSlsDispatchService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSlsDispatch>;
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

function TSlsDispatchService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSlsDispatch;
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

procedure TSlsDispatchService.BusinessInsert(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsDispatchService.BusinessUpdate(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSlsDispatchService.BusinessDelete(AEntity: TSlsDispatch; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSlsDispatchService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TSlsDispatchService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSlsDispatch>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TSlsDispatchService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsDispatch;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TSlsDispatchService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSlsDispatch;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSlsDispatchService.Add(AEntity: TSlsDispatch);
begin
  DoAdd(AEntity);
end;

procedure TSlsDispatchService.Update(AEntity: TSlsDispatch);
begin
  DoUpdate(AEntity);
end;

procedure TSlsDispatchService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
