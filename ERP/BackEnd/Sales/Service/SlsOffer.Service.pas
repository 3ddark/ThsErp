unit SlsOffer.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, SlsOffer.Repository, SlsOffer, SlsOffer.Exception, SlsOfferDetail, SlsOfferDetail.Repository;

type
  // Teklif belgesi = başlık + Lines (TDocumentService: kalem işlemleri, hesap tetikleme, yükleme, tek transaction'lı
  // kayıt + Reload). Okuma (BusinessFindById, FindById(…, True)) kalemleri de getirir. Domain yalnız veri taşır.
  TSlsOfferService = class(TDocumentService<TSlsOffer, TSlsOfferDetail>)
  private
    FRepo: IRepository<TSlsOffer>;

    procedure DoAdd(AEntity: TSlsOffer);
    procedure DoUpdate(AEntity: TSlsOffer);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
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
    procedure PrepareCopyHeader(AHeader: TSlsOffer); override;
    procedure PrepareCopyLine(AHeader: TSlsOffer; ALine: TSlsOfferDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsOffer; AOperation: TCrudOperation); override;
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);

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
  SysPermission.Service, SlsLookup, SlsOfferDetail.Service, SlsOfferDetail.Exception;

constructor TSlsOfferService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsOffer, TSlsOfferRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TSlsOfferDetail, TSlsOfferDetailRepository>;
  Self.PermissionCode := PERMISSION_SLS_OFFER;
end;

destructor TSlsOfferService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSlsOfferService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
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
  TSlsOfferRepository(FRepo).RefreshOrderedQuantities(AHeader.Id);
end;

procedure TSlsOfferService.PrepareCopyHeader(AHeader: TSlsOffer);
begin
  AHeader.OfferNo := '';
  AHeader.Status := SLS_OFF_DRAFT;
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
  if AEntity.ExchangeRate <= 0 then
    AEntity.ExchangeRate := 1;
  if AEntity.Currency = '' then
    AEntity.Currency := LRepo.GetDefaultCurrency;

  if AOperation = coInsert then
  begin
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
    finally
      LOld.Free;
    end;
  end;

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
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSlsOfferService.DoUpdate(AEntity: TSlsOffer);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
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
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TSlsOfferService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSlsOffer;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
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
