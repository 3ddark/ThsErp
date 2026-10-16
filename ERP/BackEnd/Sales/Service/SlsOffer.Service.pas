unit SlsOffer.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SlsOffer.Repository, SlsOffer, SlsOffer.Exception, SlsOfferDetail, SlsOfferDetail.Repository;

type
  // Teklif belgesi = başlık + Lines. Okuma (BusinessFindById, FindById(…, True)) kalemleri de getirir; kalem
  // işlemleri ve hesaplar bellekte (CreateLine / AddLine / NewLine / RemoveLine / Recalculate); BusinessSaveWithDetails
  // başlık + kalemleri tek transaction'da yazar ve belgeyi yeniden okur. Domain yalnız veri taşır.
  TSlsOfferService = class(TCrudService<TSlsOffer>)
  private
    FRepo: IRepository<TSlsOffer>;
    FLineRepo: IRepository<TSlsOfferDetail>;

    procedure DoAdd(AEntity: TSlsOffer);
    procedure DoUpdate(AEntity: TSlsOffer);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // Kayıt öncesi aktif kalemler: alan kontrolleri + tutarlar, boş satır no'lar, satır no tekilliği
    procedure PrepareLinesForSave(AOffer: TSlsOffer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSlsOffer; AOperation: TCrudOperation); override;
    procedure ChangeStatus(AId: Int64; ANewStatus: SmallInt; APermissionControl: Boolean);

    // ---- Belge: bellekte (DB'ye yazmaz)
    // Yeni kalem nesnesi (listeye eklenmez): sıradaki satır no, başlık referansı, belge no / para birimi (fiyat önerisi)
    function CreateLine(AOffer: TSlsOffer): TSlsOfferDetail;
    // Kalem teklife girer (sahiplenilir, geçici id); kalem ve başlık tutarları hesaplanır
    procedure AddLine(AOffer: TSlsOffer; ALine: TSlsOfferDetail);
    // CreateLine + AddLine (koddan kalem ekleme)
    function NewLine(AOffer: TSlsOffer): TSlsOfferDetail;
    // Yeni kalem listeden çıkar (serbest kalır), kayıtlı kalem kayıtta silinir (Deleted); toplamlar yeniden
    procedure RemoveLine(AOffer: TSlsOffer; ALine: TSlsOfferDetail);
    // Silinmemiş kalemler
    function ActiveLines(AOffer: TSlsOffer): TArray<TSlsOfferDetail>;
    // Kalem tutarları (brüt / iskonto / net / KDV / toplam) miktar, fiyat ve oranlardan
    procedure RecalculateLine(ALine: TSlsOfferDetail);
    // Başlık toplamları aktif kalemlerden
    procedure RecalculateTotals(AOffer: TSlsOffer);
    // Tüm kalemler + başlık toplamları
    procedure Recalculate(AOffer: TSlsOffer);
    // Kopya ile yeni teklif: başlık id / no boş, taslak; silinmişler atılır, kalemler yeni (geçici id)
    procedure PrepareCopy(AEntity: TSlsOffer); override;

    // ---- Belge: DB
    // Tekliflerin kalemleri tek sorguda (her teklifin mevcut Lines'ı boşaltılır)
    procedure LoadLines(const AOffers: TArray<TSlsOffer>);
    // Başlık + kalemler DB'den aynı nesneye (kayıt sonrası gerçek id'ler, stok adları, türeyen değerler)
    procedure Reload(AOffer: TSlsOffer);
    // Başlık + kalemler tek transaction: yetki, başlık kilidi, kalem kontrolleri + tutarlar, başlık kuralları (taslak,
    // belge no …), toplamlar kalemlerden, başlık insert / update, kalemler (DetailList.Save: sil / güncelle / ekle),
    // belge hook'u (siparişe aktarılan miktarlar + durum), AWithCommit ise commit, Reload. Hata: rollback, yeni
    // kalemler geçici id'lerine, yeni başlık id 0'a döner; Deleted işaretleri korunur
    procedure BusinessSaveWithDetails(AEntity: TSlsOffer; AWithCommit, APermissionControl: Boolean); override;

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
  SysPermission.Service, SlsLookup, DetailList, SlsOfferDetail.Service, SlsOfferDetail.Exception;

constructor TSlsOfferService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSlsOffer, TSlsOfferRepository>;
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

{ Belge: bellekte }

function TSlsOfferService.CreateLine(AOffer: TSlsOffer): TSlsOfferDetail;
var
  LLine: TSlsOfferDetail;
  LMax: Integer;
begin
  LMax := 0;
  for LLine in AOffer.Lines do
    if not LLine.Deleted and (LLine.LineNo > LMax) then
      LMax := LLine.LineNo;
  Result := TSlsOfferDetail.Create;
  Result.LineNo := LMax + 1;
  Result.SlsOfferId := AOffer.Id;
  Result.OfferNo := AOffer.OfferNo;
  Result.Currency := AOffer.Currency;
  Result.Header := AOffer;
end;

procedure TSlsOfferService.AddLine(AOffer: TSlsOffer; ALine: TSlsOfferDetail);
begin
  TDetailList.Attach<TSlsOfferDetail>(AOffer.Lines, ALine, AOffer);
  RecalculateLine(ALine);
  RecalculateTotals(AOffer);
end;

function TSlsOfferService.NewLine(AOffer: TSlsOffer): TSlsOfferDetail;
begin
  Result := CreateLine(AOffer);
  AddLine(AOffer, Result);
end;

procedure TSlsOfferService.RemoveLine(AOffer: TSlsOffer; ALine: TSlsOfferDetail);
begin
  TDetailList.Remove<TSlsOfferDetail>(AOffer.Lines, ALine);
  RecalculateTotals(AOffer);
end;

function TSlsOfferService.ActiveLines(AOffer: TSlsOffer): TArray<TSlsOfferDetail>;
begin
  Result := TDetailList.Active<TSlsOfferDetail>(AOffer.Lines);
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

procedure TSlsOfferService.RecalculateTotals(AOffer: TSlsOffer);
var
  LLine: TSlsOfferDetail;
begin
  AOffer.GrossAmount := 0;
  AOffer.DiscountAmount := 0;
  AOffer.NetAmount := 0;
  AOffer.VatAmount := 0;
  AOffer.TotalAmount := 0;
  for LLine in AOffer.Lines do
    if not LLine.Deleted then
    begin
      AOffer.GrossAmount := AOffer.GrossAmount + LLine.GrossAmount;
      AOffer.DiscountAmount := AOffer.DiscountAmount + LLine.DiscountAmount;
      AOffer.NetAmount := AOffer.NetAmount + LLine.NetAmount;
      AOffer.VatAmount := AOffer.VatAmount + LLine.VatAmount;
      AOffer.TotalAmount := AOffer.TotalAmount + LLine.TotalAmount;
    end;
end;

procedure TSlsOfferService.Recalculate(AOffer: TSlsOffer);
var
  LLine: TSlsOfferDetail;
begin
  for LLine in AOffer.Lines do
    if not LLine.Deleted then
      RecalculateLine(LLine);
  RecalculateTotals(AOffer);
end;

procedure TSlsOfferService.PrepareCopy(AEntity: TSlsOffer);
var
  LLine: TSlsOfferDetail;
begin
  inherited;
  AEntity.OfferNo := '';
  AEntity.Status := SLS_OFF_DRAFT;
  TDetailList.MarkAllNew<TSlsOfferDetail>(AEntity.Lines);
  for LLine in AEntity.Lines do
  begin
    LLine.SlsOfferId := 0;
    LLine.OfferNo := '';
    LLine.OrderedQuantity := 0;
    LLine.Header := AEntity;
  end;
  Recalculate(AEntity);
end;

procedure TSlsOfferService.PrepareLinesForSave(AOffer: TSlsOffer);
var
  LLines: TArray<TSlsOfferDetail>;
  LLine: TSlsOfferDetail;
  LMax: Integer;
  LNos: TDictionary<Integer, Boolean>;
  LRates: TArray<Currency>;
begin
  LLines := ActiveLines(AOffer);
  LRates := TSlsOfferDetailRepository(FLineRepo).GetVatRates;
  LMax := 0;
  for LLine in LLines do
  begin
    TSlsOfferDetailService.CheckLine(LLine);   // alanlar + tutarlar
    TSlsOfferDetailService.CheckVatRate(LLine.VatRate, LRates);
    if LLine.Id < 0 then
      LLine.OrderedQuantity := 0;              // siparişe aktarılan miktar sipariş kalemlerinden tutulur
    if LLine.LineNo > LMax then
      LMax := LLine.LineNo;
  end;

  LNos := TDictionary<Integer, Boolean>.Create;
  try
    for LLine in LLines do
    begin
      if LLine.LineNo <= 0 then
      begin
        Inc(LMax);
        LLine.LineNo := LMax;
      end;
      if LNos.ContainsKey(LLine.LineNo) then
        raise ESlsOfferDetailExceptionLineUnique.Create;
      LNos.Add(LLine.LineNo, True);
    end;
  finally
    LNos.Free;
  end;
end;

{ Belge: DB }

procedure TSlsOfferService.LoadLines(const AOffers: TArray<TSlsOffer>);
var
  LOffer: TSlsOffer;
  LById: TDictionary<Int64, TSlsOffer>;
  LIds: TArray<Int64>;
  LList: TObjectList<TSlsOfferDetail>;
  LLine: TSlsOfferDetail;
  n: Integer;
begin
  LById := TDictionary<Int64, TSlsOffer>.Create;
  try
    SetLength(LIds, Length(AOffers));
    n := 0;
    for LOffer in AOffers do
    begin
      LOffer.Lines.Clear;
      if (LOffer.Id > 0) and not LById.ContainsKey(LOffer.Id) then
      begin
        LById.Add(LOffer.Id, LOffer);
        LIds[n] := LOffer.Id;
        Inc(n);
      end;
    end;
    SetLength(LIds, n);
    if n = 0 then
      Exit;

    LList := TSlsOfferDetailRepository(FLineRepo).FindByOfferIds(LIds);
    try
      // nesneler tekliflerin Lines listelerine geçer
      LList.OwnsObjects := False;
      for LLine in LList do
        if LById.TryGetValue(LLine.SlsOfferId, LOffer) then
        begin
          LLine.Header := LOffer;
          LOffer.Lines.Add(LLine);
        end
        else
          LLine.Free;
    finally
      LList.Free;
    end;
  finally
    LById.Free;
  end;
end;

procedure TSlsOfferService.Reload(AOffer: TSlsOffer);
var
  LFresh: TSlsOffer;
begin
  LFresh := FRepo.FindById(AOffer.Id, False);
  try
    if not Assigned(LFresh) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AOffer.Id]));
    CopyEntityValues(LFresh, AOffer);   // başlığın basit alanları (Lines nesne özelliği, kopyalanmaz)
  finally
    LFresh.Free;
  end;
  LoadLines([AOffer]);
end;

procedure TSlsOfferService.BusinessSaveWithDetails(AEntity: TSlsOffer; AWithCommit, APermissionControl: Boolean);
var
  LIsNew: Boolean;
  LLog: TDetailSaveLog;
  LLocked: TSlsOffer;
  LOffer: TSlsOffer;
begin
  LIsNew := AEntity.Id <= 0;
  LOffer := AEntity;
  LLog := TDetailSaveLog.Create;
  try
    try
      if LIsNew then
        Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl)
      else
        Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

      // güncellemede incelemeden (kayıt kilidi) açık kalan transaction kullanılır
      if not Self.UoW.InTransaction then
        Self.UoW.BeginTransaction;

      if not LIsNew then
      begin
        LLocked := FRepo.FindById(AEntity.Id, True);
        try
          if not Assigned(LLocked) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
        finally
          LLocked.Free;
        end;
      end;

      PrepareLinesForSave(AEntity);
      if LIsNew then
        ValidateAll(AEntity, coInsert)
      else
        ValidateAll(AEntity, coUpdate);   // taslak dışı teklif reddedilir (kalemler dahil)
      // ValidateBusinessRules tutarları sıfırlar / DB'den alır: belge kaydında toplamlar kalemlerden
      RecalculateTotals(AEntity);

      if LIsNew then
        FRepo.Add(AEntity)
      else
        FRepo.Update(AEntity);

      TDetailList.Save<TSlsOfferDetail>(AEntity.Lines, FLineRepo,
        procedure(ALine: TSlsOfferDetail)
        begin
          ALine.SlsOfferId := LOffer.Id;
        end,
        LLog);

      // belge hook'u: siparişe aktarılan miktarlar ve otomatik durum (taslakta etkisiz, tutarlılık için)
      TSlsOfferRepository(FRepo).RefreshOrderedQuantities(AEntity.Id);

      if AWithCommit and Self.UoW.InTransaction then
        Self.UoW.Commit;
    except
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      LLog.Revert;
      if LIsNew then
        AEntity.Id := 0;
      raise;
    end;
  finally
    LLog.Free;
  end;

  Reload(AEntity);
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
