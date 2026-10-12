unit PurInvoice.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurInvoice.Repository, PurInvoice, PurInvoice.Exception, PurReceipt, PurReceipt.Repository, PurOrder, PurOrder.Repository, PurReceiptDetail, PurReceiptDetail.Repository, PurOrderDetail, PurOrderDetail.Repository;

type
  TPurInvoiceService = class(TCrudService<TPurInvoice>)
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
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurInvoice; AOperation: TCrudOperation); override;
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
  SysPermission.Service, PurLookup, PurInvoiceDetail, PurInvoiceDetail.Service;

constructor TPurInvoiceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurInvoice, TPurInvoiceRepository>;
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


function TPurInvoiceService.CreateFromReceipt(AReceiptId: Int64; const AInvoiceNo: string; APermissionControl: Boolean): Int64;
var
  LReceipt: TPurReceipt;
  LOrder: TPurOrder;
  LInvoice: TPurInvoice;
  LLines: TList<TPurReceiptDetail>;
  LLine: TPurReceiptDetail;
  LOrderDetail: TPurOrderDetail;
  LDetail: TPurInvoiceDetail;
  LDetailSvc: TPurInvoiceDetailService;
  LReceiptDetailRepo: TPurReceiptDetailRepository;
  LFilter: TFilterCriteria;
  LStarted: Boolean;
  LOpen, LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
  LCount: Integer;
begin
  LStarted := False;
  LDetailSvc := TPurInvoiceDetailService.Create;
  try
    try
      Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
      if not Self.UoW.InTransaction then
      begin
        Self.UoW.BeginTransaction;
        LStarted := True;
      end;

      LReceiptDetailRepo := TPurReceiptDetailRepository(FReceiptDetailRepo);
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
          DoAdd(LInvoice);
          Result := LInvoice.Id;

          LCount := 0;
          LFilter := TFilterCriteria.Create;
          try
            LFilter.Add(TFilterCriterion.New('pur_receipt_id', '=', TValue.From<Int64>(AReceiptId)));
            LLines := LReceiptDetailRepo.Find(LFilter, False);
            try
              for LLine in LLines do
              begin
                LOpen := LLine.Quantity - LReceiptDetailRepo.InvoicedQuantity(LLine.Id, 0);
                if LOpen <= 0 then
                  Continue;
                LDetail := TPurInvoiceDetail.Create;
                try
                  LDetail.PurInvoiceId := LInvoice.Id;
                  LDetail.StkInventoryId := LLine.StkInventoryId;
                  LDetail.Quantity := LOpen;
                  LDetail.PurReceiptDetailId := LLine.Id;
                  LDetail.UnitPrice := LLine.UnitPrice;
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
                  LDetailSvc.Add(LDetail);
                  Inc(LCount);
                finally
                  LDetail.Free;
                end;
              end;
            finally
              LLines.Free;
            end;
          finally
            LFilter.Free;
          end;
          if LCount = 0 then
            raise EPurInvoiceExceptionNothingToInvoice.Create;
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
  finally
    LDetailSvc.Free;
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
    Result := FRepo.FindById(AId, ALock);
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

function TPurInvoiceService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurInvoice>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurInvoiceService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurInvoice;
begin
  Result := FRepo.FindById(AId, ALock);
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
