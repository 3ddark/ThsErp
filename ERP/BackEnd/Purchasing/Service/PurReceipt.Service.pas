unit PurReceipt.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, PurReceipt.Repository, PurReceipt, PurReceipt.Exception, PurReceiptDetail, PurReceiptDetail.Repository,
  PurOrder, PurOrder.Repository, PurOrderDetail, PurOrderDetail.Repository,
  StkInventorySummary, StkInventorySummary.Repository;

type
  // Mal kabul belgesi = başlık + Lines (TDocumentService). Kalem başına stok giriş hareketi (kalem hook'u); belge
  // başına stok özeti + siparişin teslim alınan miktarları (belge hook'u). Faturalanan kalem silinemez / azaltılamaz.
  TPurReceiptService = class(TDocumentService<TPurReceipt, TPurReceiptDetail>)
  private
    FRepo: IRepository<TPurReceipt>;
    FOrderRepo: IRepository<TPurOrder>;
    FOrderDetailRepo: IRepository<TPurOrderDetail>;
    FSummaryRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TPurReceipt);
    procedure DoUpdate(AEntity: TPurReceipt);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TPurReceipt): TObjectList<TPurReceiptDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurReceiptDetail>; override;
    function GetLineHeaderId(ALine: TPurReceiptDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TPurReceiptDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TPurReceiptDetail): Integer; override;
    procedure SetLineNo(ALine: TPurReceiptDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TPurReceipt; ALine: TPurReceiptDetail); override;
    procedure CheckLines(AHeader: TPurReceipt; const ALines: TArray<TPurReceiptDetail>; AOldLines: TObjectList<TPurReceiptDetail>); override;
    procedure AfterLineSaved(AHeader: TPurReceipt; ALine: TPurReceiptDetail); override;
    procedure AfterDocumentSaved(AHeader: TPurReceipt; AOldLines: TObjectList<TPurReceiptDetail>); override;
    procedure PrepareCopyHeader(AHeader: TPurReceipt); override;
    procedure PrepareCopyLine(AHeader: TPurReceipt; ALine: TPurReceiptDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurReceipt; AOperation: TCrudOperation); override;
    // Kalem tutarı (miktar x birim maliyet); başlıkta tutulan toplam yok (view toplar)
    procedure RecalculateLine(ALine: TPurReceiptDetail); override;
    procedure RecalculateTotals(AHeader: TPurReceipt); override;
    // Aktif kalemlerin tutar toplamı (ekranda gösterim)
    function TotalAmount(AHeader: TPurReceipt): Currency;
    // Onaylı siparişin kalan miktarlarından mal kabul (stok girişi dahil); yeni mal kabul id
    function CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurReceipt>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurReceipt; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurReceipt; override;

    procedure Add(AEntity: TPurReceipt); override;
    procedure Update(AEntity: TPurReceipt); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurReceipt; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurReceipt>; override;
    procedure BusinessInsert(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, PurReceiptDetail.Service, PurReceiptDetail.Exception, SysDecimalPlace.Cache;

constructor TPurReceiptService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurReceipt, TPurReceiptRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TPurReceiptDetail, TPurReceiptDetailRepository>;
  FOrderRepo := Self.UoW.GetRepository<TPurOrder, TPurOrderRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>;
  FSummaryRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_PUR_RECEIPT;
end;

{ Belge (TDocumentService) }

function TPurReceiptService.GetLines(AHeader: TPurReceipt): TObjectList<TPurReceiptDetail>;
begin
  Result := AHeader.Lines;
end;

function TPurReceiptService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurReceiptDetail>;
begin
  Result := TPurReceiptDetailRepository(FLineRepo).FindByReceiptIds(AIds);
end;

function TPurReceiptService.GetLineHeaderId(ALine: TPurReceiptDetail): Int64;
begin
  Result := ALine.PurReceiptId;
end;

procedure TPurReceiptService.SetLineHeaderId(ALine: TPurReceiptDetail; AHeaderId: Int64);
begin
  ALine.PurReceiptId := AHeaderId;
end;

function TPurReceiptService.GetLineNo(ALine: TPurReceiptDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TPurReceiptService.SetLineNo(ALine: TPurReceiptDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TPurReceiptService.RaiseDuplicateLineNo;
begin
  raise EPurReceiptDetailExceptionLineUnique.Create;
end;

// Belge no / para birimi (kalem formu: maliyet önerisi, gösterim) başlıktan
procedure TPurReceiptService.InitLine(AHeader: TPurReceipt; ALine: TPurReceiptDetail);
begin
  ALine.ReceiptNo := AHeader.ReceiptNo;
  ALine.Currency := AHeader.Currency;
end;

// Alanlar + tutar (ortak CheckLine); faturalanan kalem silinemez / faturalanandan aza indirilemez / stoğu değişemez;
// sipariş kalemi mal kabulün siparişine ait + aynı stok; açık sipariş miktarı belge içinde toplanarak (diğer mal
// kabullerdeki teslimler hariç bu belgenin eski kalemleri)
procedure TPurReceiptService.CheckLines(AHeader: TPurReceipt; const ALines: TArray<TPurReceiptDetail>;
  AOldLines: TObjectList<TPurReceiptDetail>);
var
  LLine, LOld: TPurReceiptDetail;
  LOldById: TDictionary<Int64, TPurReceiptDetail>;
  LQtyByOrderLine, LOrderLineQty, LOldQtyByOrderLine: TDictionary<Int64, Currency>;
  LOrderDetail: TPurOrderDetail;
  LPair: TPair<Int64, Currency>;
  LOther, LOpen, LQty: Currency;
begin
  LOldById := TDictionary<Int64, TPurReceiptDetail>.Create;
  LQtyByOrderLine := TDictionary<Int64, Currency>.Create;
  LOrderLineQty := TDictionary<Int64, Currency>.Create;
  LOldQtyByOrderLine := TDictionary<Int64, Currency>.Create;
  try
    for LOld in AOldLines do
    begin
      LOldById.AddOrSetValue(LOld.Id, LOld);
      if LOld.PurOrderDetailId > 0 then
      begin
        if not LOldQtyByOrderLine.TryGetValue(LOld.PurOrderDetailId, LQty) then
          LQty := 0;
        LOldQtyByOrderLine.AddOrSetValue(LOld.PurOrderDetailId, LQty + LOld.Quantity);
      end;
    end;

    // faturalanan kalem silinemez
    for LLine in AHeader.Lines do
      if LLine.Deleted and LOldById.TryGetValue(LLine.Id, LOld) and (LOld.InvoicedQuantity > 0) then
        raise EPurReceiptDetailExceptionInvoiced.Create;

    for LLine in ALines do
    begin
      TPurReceiptDetailService.CheckLine(LLine);

      if LOldById.TryGetValue(LLine.Id, LOld) then
      begin
        LLine.InvoicedQuantity := LOld.InvoicedQuantity;
        if (LOld.InvoicedQuantity > 0) and ((LLine.Quantity < LOld.InvoicedQuantity) or (LLine.StkInventoryId <> LOld.StkInventoryId)) then
          raise EPurReceiptDetailExceptionInvoiced.Create;
      end
      else
        LLine.InvoicedQuantity := 0;

      if LLine.PurOrderDetailId > 0 then
      begin
        if not LOrderLineQty.ContainsKey(LLine.PurOrderDetailId) then
        begin
          LOrderDetail := FOrderDetailRepo.FindById(LLine.PurOrderDetailId, False);
          try
            if not Assigned(LOrderDetail) or (AHeader.PurOrderId <> LOrderDetail.PurOrderId) then
              raise EPurReceiptDetailExceptionOrderMismatch.Create;
            if LOrderDetail.StkInventoryId <> LLine.StkInventoryId then
              raise EPurReceiptDetailExceptionInventoryMismatch.Create;
            LOrderLineQty.Add(LLine.PurOrderDetailId, LOrderDetail.Quantity);
          finally
            LOrderDetail.Free;
          end;
        end;
        if not LQtyByOrderLine.TryGetValue(LLine.PurOrderDetailId, LQty) then
          LQty := 0;
        LQtyByOrderLine.AddOrSetValue(LLine.PurOrderDetailId, LQty + LLine.Quantity);
      end;
    end;

    // açık sipariş miktarı: sipariş kalemi - (diğer mal kabullerdeki teslim; bu belgenin eski kalemleri hariç)
    for LPair in LQtyByOrderLine do
    begin
      if not LOldQtyByOrderLine.TryGetValue(LPair.Key, LQty) then
        LQty := 0;
      LOther := TPurReceiptDetailRepository(FLineRepo).ReceivedQuantityOfOrderDetail(LPair.Key, 0) - LQty;
      LOpen := LOrderLineQty[LPair.Key] - LOther;
      if LPair.Value > LOpen then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.OverReceipt,
          'Quantity exceeds the open order quantity (%s).'), [CurrToStr(LOpen)]));
    end;
  finally
    LOldQtyByOrderLine.Free;
    LOrderLineQty.Free;
    LQtyByOrderLine.Free;
    LOldById.Free;
  end;
end;

// Kalem hook'u: stok giriş hareketi (yeni / güncellenen kalem; silinenin hareketi FK cascade ile gider). Başlıktaki
// ambar / tarih / no değişikliği de tüm kalemler güncellendiği için hareketlere yansır
procedure TPurReceiptService.AfterLineSaved(AHeader: TPurReceipt; ALine: TPurReceiptDetail);
begin
  TPurReceiptDetailRepository(FLineRepo).UpsertStockTransaction(ALine.Id);
end;

// Belge hook'u: etkilenen (eski + yeni) stokların özeti, siparişin teslim alınan miktarları / durumu
procedure TPurReceiptService.AfterDocumentSaved(AHeader: TPurReceipt; AOldLines: TObjectList<TPurReceiptDetail>);
var
  LInventoryIds: TList<Int64>;
  LLine: TPurReceiptDetail;
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
  if AHeader.PurOrderId > 0 then
    TPurOrderRepository(FOrderRepo).RefreshReceivedQuantities(AHeader.PurOrderId);
end;

// Kopya siparişten bağımsızdır (siparişin teslim alınan miktarı iki kez sayılmasın)
procedure TPurReceiptService.PrepareCopyHeader(AHeader: TPurReceipt);
begin
  AHeader.ReceiptNo := '';
  AHeader.PurOrderId := 0;
  AHeader.OrderNo := '';
end;

procedure TPurReceiptService.PrepareCopyLine(AHeader: TPurReceipt; ALine: TPurReceiptDetail);
begin
  inherited;
  ALine.ReceiptNo := '';
  ALine.PurOrderDetailId := 0;
  ALine.OrderNo := '';
  ALine.InvoicedQuantity := 0;
end;

procedure TPurReceiptService.RecalculateLine(ALine: TPurReceiptDetail);
begin
  ALine.Amount := TDecimalPlaces.RoundTo(ALine.Quantity * ALine.UnitPrice, 2);
end;

procedure TPurReceiptService.RecalculateTotals(AHeader: TPurReceipt);
begin
//
end;

function TPurReceiptService.TotalAmount(AHeader: TPurReceipt): Currency;
var
  LLine: TPurReceiptDetail;
begin
  Result := 0;
  for LLine in AHeader.Lines do
    if not LLine.Deleted then
      Result := Result + LLine.Amount;
end;

destructor TPurReceiptService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TPurReceiptService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Onaylı siparişin kalan miktarları belge olarak bellekte kurulur ve belge kaydıyla yazılır (tek yol; stok girişi dahil)
function TPurReceiptService.CreateFromOrder(AOrderId, AWarehouseId: Int64; APermissionControl: Boolean): Int64;
var
  LOrder: TPurOrder;
  LReceipt: TPurReceipt;
  LLines: TObjectList<TPurOrderDetail>;
  LLine: TPurOrderDetail;
  LDetail: TPurReceiptDetail;
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
      if not (LOrder.Status in [PUR_ORD_APPROVED, PUR_ORD_PARTIAL]) then
        raise EPurReceiptExceptionOrderStatus.Create;

      LReceipt := TPurReceipt.Create;
      try
        LReceipt.ReceiptDate := Date;
        LReceipt.AccAccountId := LOrder.AccAccountId;
        LReceipt.StkWarehouseId := AWarehouseId;
        LReceipt.PurOrderId := LOrder.Id;
        LReceipt.Currency := LOrder.Currency;

        LLines := TPurOrderDetailRepository(FOrderDetailRepo).FindByOrderIds([AOrderId]);
        try
          for LLine in LLines do
          begin
            if LLine.Quantity - LLine.ReceivedQuantity <= 0 then
              Continue;
            LDetail := NewLine(LReceipt);
            LDetail.StkInventoryId := LLine.StkInventoryId;
            LDetail.Quantity := LLine.Quantity - LLine.ReceivedQuantity;
            // stok maliyeti: iskontolu net birim fiyat
            LDetail.UnitPrice := LLine.NetAmount / LLine.Quantity;
            LDetail.Description := LLine.Description;
            LDetail.PurOrderDetailId := LLine.Id;
          end;
        finally
          LLines.Free;
        end;
        if Length(ActiveLines(LReceipt)) = 0 then
          raise EPurReceiptExceptionNothingToReceive.Create;

        Recalculate(LReceipt);
        BusinessSaveWithDetails(LReceipt, False, APermissionControl);
        Result := LReceipt.Id;
      finally
        LReceipt.Free;
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

procedure TPurReceiptService.ValidateBusinessRules(AEntity: TPurReceipt; AOperation: TCrudOperation);
var
  LRepo: TPurReceiptRepository;
  LOld: TPurReceipt;
  LOrder: TPurOrder;
  LFilter: TFilterCriteria;
  LModel: TPurReceipt;
begin
  LRepo := TPurReceiptRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.InvoicedQuantity(AEntity.Id) > 0 then
      raise EPurReceiptExceptionHasInvoices.Create;
    Exit;
  end;

  AEntity.ReceiptNo := AnsiUpperCase(Trim(AEntity.ReceiptNo));
  AEntity.WaybillNo := AnsiUpperCase(Trim(AEntity.WaybillNo));
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.ReceiptDate <= 0 then
    FailRequired(TLangKeys.TPurReceipt.ColReceiptDate, 'Receipt Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TPurReceipt.ColAccAccountId, 'Supplier');
  if AEntity.StkWarehouseId <= 0 then
    FailRequired(TLangKeys.TPurReceipt.ColStkWarehouseId, 'Warehouse');

  if AEntity.PurOrderId > 0 then
  begin
    LOrder := FOrderRepo.FindById(AEntity.PurOrderId, False);
    try
      if not Assigned(LOrder) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.PurOrderId]));
      if LOrder.AccAccountId <> AEntity.AccAccountId then
        raise EPurReceiptExceptionOrderSupplier.Create;
      if (AOperation = coInsert) and not (LOrder.Status in [PUR_ORD_APPROVED, PUR_ORD_PARTIAL]) then
        raise EPurReceiptExceptionOrderStatus.Create;
      // siparişli mal kabul siparişin para biriminde
      AEntity.Currency := LOrder.Currency;
    finally
      LOrder.Free;
    end;
  end;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
    if AEntity.ReceiptNo = '' then
      AEntity.ReceiptNo := LRepo.NextDocumentNo(PUR_PREFIX_RECEIPT);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if (LRepo.LineCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or
        (LOld.PurOrderId <> AEntity.PurOrderId) or (LOld.Currency <> AEntity.Currency)) then
        raise EPurReceiptExceptionKeyFieldsLocked.Create;
      if AEntity.ReceiptNo = '' then
        AEntity.ReceiptNo := LOld.ReceiptNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('receipt_no', '=', TValue.From<string>(AEntity.ReceiptNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurReceiptExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurReceiptService.DoAdd(AEntity: TPurReceipt);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurReceiptService.DoUpdate(AEntity: TPurReceipt);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  // tarih / ambar değişikliği stok hareketlerine yansır
  TPurReceiptRepository(FRepo).SyncStockTransactions(AEntity.Id);
end;

procedure TPurReceiptService.DoDelete(AId: Int64);
var
  LEntity: TPurReceipt;
  LInventoryIds: TArray<Int64>;
  LId: Int64;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    // kalemler ve stok hareketleri cascade silinir; stok özeti ve sipariş teslim miktarları yenilenir
    LInventoryIds := TPurReceiptRepository(FRepo).InventoryIdsOfReceipt(AId);
    FRepo.Delete(LEntity);
    for LId in LInventoryIds do
      TStkInventorySummaryRepository(FSummaryRepo).Recalculate(LId);
    if LEntity.PurOrderId > 0 then
      TPurOrderRepository(FOrderRepo).RefreshReceivedQuantities(LEntity.PurOrderId);
  finally
    LEntity.Free;
  end;
end;

function TPurReceiptService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurReceipt>;
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

function TPurReceiptService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurReceipt;
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

procedure TPurReceiptService.BusinessInsert(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurReceiptService.BusinessUpdate(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurReceiptService.BusinessDelete(AEntity: TPurReceipt; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurReceiptService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TPurReceiptService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurReceipt>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TPurReceiptService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurReceipt;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TPurReceiptService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurReceipt;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurReceiptService.Add(AEntity: TPurReceipt);
begin
  DoAdd(AEntity);
end;

procedure TPurReceiptService.Update(AEntity: TPurReceipt);
begin
  DoUpdate(AEntity);
end;

procedure TPurReceiptService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
