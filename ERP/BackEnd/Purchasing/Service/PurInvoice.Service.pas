unit PurInvoice.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, PurInvoice.Repository, PurInvoice, PurInvoice.Exception, PurInvoiceDetail, PurInvoiceDetail.Repository,
  PurReceipt, PurReceipt.Repository, PurOrder, PurOrder.Repository, PurReceiptDetail, PurReceiptDetail.Repository,
  PurOrderDetail, PurOrderDetail.Repository;

type
  // Alış faturası belgesi = başlık + Lines (TDocumentService). Stok hareketi mal kabulde; fatura cari borcu
  // vw_acc_account_transaction ile türer. Mal kabul kalemine bağlı kalemde faturalanmamış miktar belge içinde toplanır.
  TPurInvoiceService = class(TDocumentService<TPurInvoice, TPurInvoiceDetail>)
  private
    FRepo: IRepository<TPurInvoice>;
    FReceiptRepo: IRepository<TPurReceipt>;
    FOrderRepo: IRepository<TPurOrder>;
    FReceiptDetailRepo: IRepository<TPurReceiptDetail>;
    FOrderDetailRepo: IRepository<TPurOrderDetail>;

    procedure DoAdd(AEntity: TPurInvoice);
    procedure DoUpdate(AEntity: TPurInvoice);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TPurInvoice): TObjectList<TPurInvoiceDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurInvoiceDetail>; override;
    function GetLineHeaderId(ALine: TPurInvoiceDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TPurInvoiceDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TPurInvoiceDetail): Integer; override;
    procedure SetLineNo(ALine: TPurInvoiceDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TPurInvoice; ALine: TPurInvoiceDetail); override;
    procedure CheckLines(AHeader: TPurInvoice; const ALines: TArray<TPurInvoiceDetail>; AOldLines: TObjectList<TPurInvoiceDetail>); override;
    procedure PrepareCopyHeader(AHeader: TPurInvoice); override;
    procedure PrepareCopyLine(AHeader: TPurInvoice; ALine: TPurInvoiceDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurInvoice; AOperation: TCrudOperation); override;
    // Kalem tutarları miktar, fiyat ve oranlardan; başlık toplamları aktif kalemlerden
    procedure RecalculateLine(ALine: TPurInvoiceDetail); override;
    procedure RecalculateTotals(AHeader: TPurInvoice); override;
    // Mal kabulün faturalanmamış miktarlarından alış faturası (fiyat / iskonto / KDV sipariş kaleminden); yeni fatura id
    function CreateFromReceipt(AReceiptId: Int64; const AInvoiceNo: string; APermissionControl: Boolean): Int64;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurInvoice>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurInvoice; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurInvoice; override;

    procedure Add(AEntity: TPurInvoice); override;
    procedure Update(AEntity: TPurInvoice); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurInvoice; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurInvoice>; override;
    procedure BusinessInsert(AEntity: TPurInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PurLookup, PurInvoiceDetail.Service, PurInvoiceDetail.Exception,
  AccSetTaxRate, AccSetTaxRate.Repository, AccSetTaxRate.Service;

{ Belge (TDocumentService) }

function TPurInvoiceService.GetLines(AHeader: TPurInvoice): TObjectList<TPurInvoiceDetail>;
begin
  Result := AHeader.Lines;
end;

function TPurInvoiceService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPurInvoiceDetail>;
begin
  Result := TPurInvoiceDetailRepository(FLineRepo).FindByInvoiceIds(AIds);
end;

function TPurInvoiceService.GetLineHeaderId(ALine: TPurInvoiceDetail): Int64;
begin
  Result := ALine.PurInvoiceId;
end;

procedure TPurInvoiceService.SetLineHeaderId(ALine: TPurInvoiceDetail; AHeaderId: Int64);
begin
  ALine.PurInvoiceId := AHeaderId;
end;

function TPurInvoiceService.GetLineNo(ALine: TPurInvoiceDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TPurInvoiceService.SetLineNo(ALine: TPurInvoiceDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TPurInvoiceService.RaiseDuplicateLineNo;
begin
  raise EPurInvoiceDetailExceptionLineUnique.Create;
end;

// Belge no / para birimi (kalem formu: fiyat önerisi, gösterim) başlıktan
procedure TPurInvoiceService.InitLine(AHeader: TPurInvoice; ALine: TPurInvoiceDetail);
begin
  ALine.InvoiceNo := AHeader.InvoiceNo;
  ALine.Currency := AHeader.Currency;
end;

// Alanlar + tutarlar (ortak CheckLine), KDV 0 ya da tanımlı oranlardan; mal kabul kalemine bağlı kalemde aynı stok,
// mal kabulün tedarikçisi = fatura tedarikçisi, faturalanmamış miktar belge içinde toplanarak (diğer faturalar; bu
// faturanın eski kalemleri hariç)
procedure TPurInvoiceService.CheckLines(AHeader: TPurInvoice; const ALines: TArray<TPurInvoiceDetail>;
  AOldLines: TObjectList<TPurInvoiceDetail>);
var
  LRates: TArray<Currency>;
  LLine, LOld: TPurInvoiceDetail;
  LQtyByReceiptLine, LReceiptLineQty, LOldQtyByReceiptLine: TDictionary<Int64, Currency>;
  LReceiptDetail: TPurReceiptDetail;
  LReceipt: TPurReceipt;
  LPair: TPair<Int64, Currency>;
  LOther, LOpen, LQty: Currency;
begin
  LRates := TAccSetTaxRateRepository(Self.UoW.GetRepository<TAccSetTaxRate, TAccSetTaxRateRepository>).GetTaxRates;
  LQtyByReceiptLine := TDictionary<Int64, Currency>.Create;
  LReceiptLineQty := TDictionary<Int64, Currency>.Create;
  LOldQtyByReceiptLine := TDictionary<Int64, Currency>.Create;
  try
    for LOld in AOldLines do
      if LOld.PurReceiptDetailId > 0 then
      begin
        if not LOldQtyByReceiptLine.TryGetValue(LOld.PurReceiptDetailId, LQty) then
          LQty := 0;
        LOldQtyByReceiptLine.AddOrSetValue(LOld.PurReceiptDetailId, LQty + LOld.Quantity);
      end;

    for LLine in ALines do
    begin
      TPurInvoiceDetailService.CheckLine(LLine);
      // 0 = KDV'siz alış (istisna); diğer oranlar tanımlı oranlardan biri olmalı
      if LLine.VatRate <> 0 then
        TAccSetTaxRateService.CheckDefinedRate(LLine.VatRate, LRates);

      if LLine.PurReceiptDetailId > 0 then
      begin
        if not LReceiptLineQty.ContainsKey(LLine.PurReceiptDetailId) then
        begin
          LReceiptDetail := FReceiptDetailRepo.FindById(LLine.PurReceiptDetailId, False);
          LReceipt := nil;
          try
            if not Assigned(LReceiptDetail) then
              raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [LLine.PurReceiptDetailId]));
            if LReceiptDetail.StkInventoryId <> LLine.StkInventoryId then
              raise EPurInvoiceDetailExceptionInventoryMismatch.Create;
            LReceipt := FReceiptRepo.FindById(LReceiptDetail.PurReceiptId, False);
            if not Assigned(LReceipt) or (LReceipt.AccAccountId <> AHeader.AccAccountId) then
              raise EPurInvoiceDetailExceptionSupplierMismatch.Create;
            LReceiptLineQty.Add(LLine.PurReceiptDetailId, LReceiptDetail.Quantity);
          finally
            LReceiptDetail.Free;
            LReceipt.Free;
          end;
        end;
        if not LQtyByReceiptLine.TryGetValue(LLine.PurReceiptDetailId, LQty) then
          LQty := 0;
        LQtyByReceiptLine.AddOrSetValue(LLine.PurReceiptDetailId, LQty + LLine.Quantity);
      end;
    end;

    // faturalanmamış miktar: mal kabul kalemi - (diğer faturalardaki miktar; bu faturanın eski kalemleri hariç)
    for LPair in LQtyByReceiptLine do
    begin
      if not LOldQtyByReceiptLine.TryGetValue(LPair.Key, LQty) then
        LQty := 0;
      LOther := TPurReceiptDetailRepository(FReceiptDetailRepo).InvoicedQuantity(LPair.Key, 0) - LQty;
      LOpen := LReceiptLineQty[LPair.Key] - LOther;
      if LPair.Value > LOpen then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.OverInvoice,
          'Quantity exceeds the received quantity not yet invoiced (%s).'), [CurrToStr(LOpen)]));
    end;
  finally
    LOldQtyByReceiptLine.Free;
    LReceiptLineQty.Free;
    LQtyByReceiptLine.Free;
  end;
end;

// Kopya mal kabulden bağımsızdır (mal kabulün faturalanan miktarı iki kez sayılmasın); fatura no tedarikçinin
// belgesinden yeniden girilir
procedure TPurInvoiceService.PrepareCopyHeader(AHeader: TPurInvoice);
begin
  AHeader.InvoiceNo := '';
end;

procedure TPurInvoiceService.PrepareCopyLine(AHeader: TPurInvoice; ALine: TPurInvoiceDetail);
begin
  inherited;
  ALine.InvoiceNo := '';
  ALine.PurReceiptDetailId := 0;
  ALine.ReceiptNo := '';
end;

procedure TPurInvoiceService.RecalculateLine(ALine: TPurInvoiceDetail);
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

procedure TPurInvoiceService.RecalculateTotals(AHeader: TPurInvoice);
var
  LLine: TPurInvoiceDetail;
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

constructor TPurInvoiceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurInvoice, TPurInvoiceRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TPurInvoiceDetail, TPurInvoiceDetailRepository>;
  FReceiptRepo := Self.UoW.GetRepository<TPurReceipt, TPurReceiptRepository>;
  FOrderRepo := Self.UoW.GetRepository<TPurOrder, TPurOrderRepository>;
  FReceiptDetailRepo := Self.UoW.GetRepository<TPurReceiptDetail, TPurReceiptDetailRepository>;
  FOrderDetailRepo := Self.UoW.GetRepository<TPurOrderDetail, TPurOrderDetailRepository>;
  Self.PermissionCode := PERMISSION_PUR_INVOICE;
end;

destructor TPurInvoiceService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TPurInvoiceService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


// Mal kabulün faturalanmamış miktarları belge olarak bellekte kurulur ve belge kaydıyla yazılır (tek yol)
function TPurInvoiceService.CreateFromReceipt(AReceiptId: Int64; const AInvoiceNo: string; APermissionControl: Boolean): Int64;
var
  LReceipt: TPurReceipt;
  LOrder: TPurOrder;
  LInvoice: TPurInvoice;
  LLines: TObjectList<TPurReceiptDetail>;
  LLine: TPurReceiptDetail;
  LOrderDetail: TPurOrderDetail;
  LDetail: TPurInvoiceDetail;
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

    LReceipt := FReceiptRepo.FindById(AReceiptId, True);
    try
      if not Assigned(LReceipt) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AReceiptId]));

      LInvoice := TPurInvoice.Create;
      try
        LInvoice.InvoiceNo := AInvoiceNo;
        if LInvoice.InvoiceNo = '' then
          LInvoice.InvoiceNo := LReceipt.WaybillNo;
        if LInvoice.InvoiceNo = '' then
          LInvoice.InvoiceNo := LReceipt.ReceiptNo;
        LInvoice.InvoiceDate := Date;
        LInvoice.AccAccountId := LReceipt.AccAccountId;
        LInvoice.Currency := LReceipt.Currency;
        LInvoice.Description := LReceipt.ReceiptNo;
        if LReceipt.PurOrderId > 0 then
        begin
          LOrder := FOrderRepo.FindById(LReceipt.PurOrderId, False);
          try
            if Assigned(LOrder) then
            begin
              LInvoice.ExchangeRate := LOrder.ExchangeRate;
              LInvoice.DueDate := LInvoice.InvoiceDate + LOrder.PaymentTermDays;
            end;
          finally
            LOrder.Free;
          end;
        end;

        LLines := TPurReceiptDetailRepository(FReceiptDetailRepo).FindByReceiptIds([AReceiptId]);
        try
          for LLine in LLines do
          begin
            LOpen := LLine.Quantity - LLine.InvoicedQuantity;
            if LOpen <= 0 then
              Continue;
            LDetail := NewLine(LInvoice);
            LDetail.StkInventoryId := LLine.StkInventoryId;
            LDetail.Quantity := LOpen;
            LDetail.PurReceiptDetailId := LLine.Id;
            LDetail.UnitPrice := LLine.UnitPrice;
            LDetail.Description := LLine.Description;
            LOrderDetail := nil;
            if LLine.PurOrderDetailId > 0 then
              LOrderDetail := FOrderDetailRepo.FindById(LLine.PurOrderDetailId, False);
            try
              if Assigned(LOrderDetail) then
              begin
                // sipariş fiyatı, iskontosu ve KDV'si
                LDetail.UnitPrice := LOrderDetail.UnitPrice;
                LDetail.DiscountRate := LOrderDetail.DiscountRate;
                LDetail.VatRate := LOrderDetail.VatRate;
              end
              else if TPurOrderDetailRepository(FOrderDetailRepo).GetInventoryDefaults(LLine.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
                LDetail.VatRate := LVat;
            finally
              LOrderDetail.Free;
            end;
          end;
        finally
          LLines.Free;
        end;
        if Length(ActiveLines(LInvoice)) = 0 then
          raise EPurInvoiceExceptionNothingToInvoice.Create;

        Recalculate(LInvoice);
        BusinessSaveWithDetails(LInvoice, False, APermissionControl);
        Result := LInvoice.Id;
      finally
        LInvoice.Free;
      end;
    finally
      LReceipt.Free;
    end;

    if LStarted and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPurInvoiceService.ValidateBusinessRules(AEntity: TPurInvoice; AOperation: TCrudOperation);
var
  LRepo: TPurInvoiceRepository;
  LOld: TPurInvoice;
  LFilter: TFilterCriteria;
  LModel: TPurInvoice;
begin
  LRepo := TPurInvoiceRepository(FRepo);
  if AOperation = coDelete then
    Exit;

  AEntity.InvoiceNo := AnsiUpperCase(Trim(AEntity.InvoiceNo));
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Currency := Trim(AEntity.Currency);
  if AEntity.InvoiceNo = '' then
    FailRequired(TLangKeys.TPurInvoice.ColInvoiceNo, 'Invoice No');
  if AEntity.InvoiceDate <= 0 then
    FailRequired(TLangKeys.TPurInvoice.ColInvoiceDate, 'Invoice Date');
  if AEntity.AccAccountId <= 0 then
    FailRequired(TLangKeys.TPurInvoice.ColAccAccountId, 'Supplier');
  if (AEntity.DueDate > 0) and (AEntity.DueDate < AEntity.InvoiceDate) then
    raise EPurInvoiceExceptionDueDate.Create;
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
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      if (LRepo.LineCount(AEntity.Id) > 0) and ((LOld.AccAccountId <> AEntity.AccAccountId) or (LOld.Currency <> AEntity.Currency)) then
        raise EPurInvoiceExceptionKeyFieldsLocked.Create;
      AEntity.GrossAmount := LOld.GrossAmount;
      AEntity.DiscountAmount := LOld.DiscountAmount;
      AEntity.NetAmount := LOld.NetAmount;
      AEntity.VatAmount := LOld.VatAmount;
      AEntity.TotalAmount := LOld.TotalAmount;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('acc_account_id', '=', TValue.From<Int64>(AEntity.AccAccountId)));
    LFilter.Add(TFilterCriterion.New('invoice_no', '=', TValue.From<string>(AEntity.InvoiceNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EPurInvoiceExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPurInvoiceService.DoAdd(AEntity: TPurInvoice);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurInvoiceService.DoUpdate(AEntity: TPurInvoice);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPurInvoiceService.DoDelete(AId: Int64);
var
  LEntity: TPurInvoice;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TPurInvoiceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurInvoice>;
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

function TPurInvoiceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurInvoice;
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

procedure TPurInvoiceService.BusinessInsert(AEntity: TPurInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurInvoiceService.BusinessUpdate(AEntity: TPurInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurInvoiceService.BusinessDelete(AEntity: TPurInvoice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurInvoiceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TPurInvoiceService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurInvoice>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TPurInvoiceService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurInvoice;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TPurInvoiceService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurInvoice;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurInvoiceService.Add(AEntity: TPurInvoice);
begin
  DoAdd(AEntity);
end;

procedure TPurInvoiceService.Update(AEntity: TPurInvoice);
begin
  DoUpdate(AEntity);
end;

procedure TPurInvoiceService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
