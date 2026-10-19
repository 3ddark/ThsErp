unit DocumentService;

// Belge (başlık + kalem listesi) servis tabanı. Domain yalnız veri taşır (başlıkta Lines, kalem TDetailEntity); kalem
// işlemleri, hesaplar ve kayıt burada + alt sınıfta. Durum tek listede (DetailList): Id > 0 güncelle, Deleted sil,
// Id < 0 ekle. Alt sınıf belgeye özgü parçaları verir: kalem listesi / FK / satır no erişimi, kalemlerin okunması,
// kalem ve başlık hesabı, kalem kuralları, kalem hook'u (gerçek id ile, ör. stok hareketi), belge hook'u (etkilenen
// kayıt başına bir kez, ör. stok özeti / bağlı belge miktarları; eski kalemler parametre olarak gelir), kopya.
//
// BusinessSaveWithDetails: yetki (ekle / güncelle) -> transaction (yoksa) -> başlık kilidi -> eski kalemler ->
// kalem kuralları + tutarlar (CheckLines) -> boş satır no'lar + tekillik -> ValidateAll(başlık) -> RecalculateTotals ->
// başlık insert / update -> TDetailList.Save (sil / güncelle / ekle) + AfterLineSaved -> AfterDocumentSaved ->
// AWithCommit ise commit -> Reload. Hata: rollback, yeni kalemler geçici id'lerine, yeni başlık 0'a; Deleted korunur.

interface

uses
  System.SysUtils, System.Generics.Collections,
  Entity, Repository, Service, DetailList, SharedFormTypes, LocalizationManager;

type
  TDocumentService<TH: TEntity, constructor; TL: TDetailEntity, constructor> = class(TCrudService<TH>)
  protected
    // alt sınıf constructor'ında atanır (UoW.GetRepository)
    FHeaderRepo: IRepository<TH>;
    FLineRepo: IRepository<TL>;

    // ---- belge yapısı (alt sınıf)
    function GetLines(AHeader: TH): TObjectList<TL>; virtual; abstract;
    // Başlıkların kalemleri tek sorguda, başlık + satır no sırasıyla (repository'nin elle yazılmış sorgusu)
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TL>; virtual; abstract;
    function GetLineHeaderId(ALine: TL): Int64; virtual; abstract;
    procedure SetLineHeaderId(ALine: TL; AHeaderId: Int64); virtual; abstract;
    function GetLineNo(ALine: TL): Integer; virtual; abstract;
    procedure SetLineNo(ALine: TL; ANo: Integer); virtual; abstract;
    procedure RaiseDuplicateLineNo; virtual; abstract;

    // ---- kayıt adımları (alt sınıf, isteğe bağlı)
    // Yeni kalemin ön değerleri (satır no ve başlık referansı tabanda): belge no, para birimi … (view alanları)
    procedure InitLine(AHeader: TH; ALine: TL); virtual;
    // Aktif kalemlerin kuralları + tutarları (DB okuyabilir, tek seferde: ör. KDV oranları); hata yükseltir.
    // AOldLines: kaydın öncesindeki DB hâli (yeni belgede boş) — ör. durum kilidinde kalem değişti mi, DB'de tutulan
    // türeyen değerler (teslim edilen miktar)
    procedure CheckLines(AHeader: TH; const ALines: TArray<TL>; AOldLines: TObjectList<TL>); virtual;
    // Kalem yazıldıktan sonra (eklenen / güncellenen, gerçek id ile): ör. stok hareketi
    procedure AfterLineSaved(AHeader: TH; ALine: TL); virtual;
    // Tüm kalemler yazıldıktan sonra bir kez; AOldLines kaydın öncesindeki DB hâli (yeni belgede boş): etkilenen
    // eski + yeni kayıtlar (stok, bağlı belge) yeniden hesaplanır
    procedure AfterDocumentSaved(AHeader: TH; AOldLines: TObjectList<TL>); virtual;
    // Başlık yazılmadan hemen önce (kurallar + toplamlar sonrası, aynı transaction): başlığın sahip olduğu bağlı
    // kayıtlar (ör. belgeye ait adres) yazılır ve FK'leri başlığa konur
    procedure BeforeHeaderSaved(AHeader: TH); virtual;
    // Kayıt geri alındı: BeforeHeaderSaved'in bellekte verdiği id'ler geri alınır (yeniden denemede yeni kayıt olurlar)
    procedure AfterSaveFailed(AHeader: TH); virtual;
    // Kopya ile yeni belge: başlığa özgü alanlar (no, durum …) ve kalemlerin bağlı alanları (taban: id'ler)
    procedure PrepareCopyHeader(AHeader: TH); virtual;
    procedure PrepareCopyLine(AHeader: TH; ALine: TL); virtual;
  public
    // ---- bellekte (DB'ye yazmaz)
    // Yeni kalem (listeye eklenmez): sıradaki satır no, başlık referansı, InitLine
    function CreateLine(AHeader: TH): TL;
    // Kalem belgeye girer (sahiplenilir, geçici id); kalem ve başlık tutarları hesaplanır
    procedure AddLine(AHeader: TH; ALine: TL);
    // CreateLine + AddLine (koddan kalem ekleme)
    function NewLine(AHeader: TH): TL;
    // Yeni kalem listeden çıkar (serbest kalır), kayıtlı kalem kayıtta silinir (Deleted); toplamlar yeniden
    procedure RemoveLine(AHeader: TH; ALine: TL);
    function ActiveLines(AHeader: TH): TArray<TL>;
    // Kalem tutarları / başlık toplamları (alt sınıf): yalnız hesap, kontrol yok
    procedure RecalculateLine(ALine: TL); virtual; abstract;
    procedure RecalculateTotals(AHeader: TH); virtual; abstract;
    // Aktif kalemler + başlık toplamları
    procedure Recalculate(AHeader: TH);
    // Kopya ile yeni belge: başlık id 0 + PrepareCopyHeader; silinmişler atılır, kalemler yeni (geçici id)
    procedure PrepareCopy(AEntity: TH); override;

    // ---- DB
    // Başlıkların kalemleri tek sorguda (her başlığın mevcut listesi boşaltılır)
    procedure LoadLines(const AHeaders: TArray<TH>);
    // Başlık + kalemler DB'den aynı nesneye (kayıt sonrası gerçek id'ler, view alanları, türeyen değerler)
    procedure Reload(AHeader: TH);
    procedure BusinessSaveWithDetails(AEntity: TH; AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

{ TDocumentService<TH, TL> }

procedure TDocumentService<TH, TL>.InitLine(AHeader: TH; ALine: TL);
begin
//
end;

procedure TDocumentService<TH, TL>.CheckLines(AHeader: TH; const ALines: TArray<TL>; AOldLines: TObjectList<TL>);
begin
//
end;

procedure TDocumentService<TH, TL>.AfterLineSaved(AHeader: TH; ALine: TL);
begin
//
end;

procedure TDocumentService<TH, TL>.AfterDocumentSaved(AHeader: TH; AOldLines: TObjectList<TL>);
begin
//
end;

procedure TDocumentService<TH, TL>.BeforeHeaderSaved(AHeader: TH);
begin
//
end;

procedure TDocumentService<TH, TL>.AfterSaveFailed(AHeader: TH);
begin
//
end;

procedure TDocumentService<TH, TL>.PrepareCopyHeader(AHeader: TH);
begin
//
end;

procedure TDocumentService<TH, TL>.PrepareCopyLine(AHeader: TH; ALine: TL);
begin
  SetLineHeaderId(ALine, 0);
end;

function TDocumentService<TH, TL>.CreateLine(AHeader: TH): TL;
var
  LLine: TL;
  LMax: Integer;
begin
  LMax := 0;
  for LLine in GetLines(AHeader) do
    if not LLine.Deleted and (GetLineNo(LLine) > LMax) then
      LMax := GetLineNo(LLine);
  Result := TL.Create;
  SetLineNo(Result, LMax + 1);
  SetLineHeaderId(Result, AHeader.Id);
  Result.HeaderEntity := AHeader;
  InitLine(AHeader, Result);
end;

procedure TDocumentService<TH, TL>.AddLine(AHeader: TH; ALine: TL);
begin
  TDetailList.Attach<TL>(GetLines(AHeader), ALine, AHeader);
  RecalculateLine(ALine);
  RecalculateTotals(AHeader);
end;

function TDocumentService<TH, TL>.NewLine(AHeader: TH): TL;
begin
  Result := CreateLine(AHeader);
  AddLine(AHeader, Result);
end;

procedure TDocumentService<TH, TL>.RemoveLine(AHeader: TH; ALine: TL);
begin
  TDetailList.Remove<TL>(GetLines(AHeader), ALine);
  RecalculateTotals(AHeader);
end;

function TDocumentService<TH, TL>.ActiveLines(AHeader: TH): TArray<TL>;
begin
  Result := TDetailList.Active<TL>(GetLines(AHeader));
end;

procedure TDocumentService<TH, TL>.Recalculate(AHeader: TH);
var
  LLine: TL;
begin
  for LLine in GetLines(AHeader) do
    if not LLine.Deleted then
      RecalculateLine(LLine);
  RecalculateTotals(AHeader);
end;

procedure TDocumentService<TH, TL>.PrepareCopy(AEntity: TH);
var
  LLine: TL;
begin
  inherited;
  PrepareCopyHeader(AEntity);
  TDetailList.MarkAllNew<TL>(GetLines(AEntity));
  for LLine in GetLines(AEntity) do
  begin
    LLine.HeaderEntity := AEntity;
    PrepareCopyLine(AEntity, LLine);
  end;
  Recalculate(AEntity);
end;

procedure TDocumentService<TH, TL>.LoadLines(const AHeaders: TArray<TH>);
var
  LHeader: TH;
  LById: TDictionary<Int64, TH>;
  LIds: TArray<Int64>;
  LList: TObjectList<TL>;
  LLine: TL;
  n: Integer;
begin
  LById := TDictionary<Int64, TH>.Create;
  try
    SetLength(LIds, Length(AHeaders));
    n := 0;
    for LHeader in AHeaders do
    begin
      GetLines(LHeader).Clear;
      if (LHeader.Id > 0) and not LById.ContainsKey(LHeader.Id) then
      begin
        LById.Add(LHeader.Id, LHeader);
        LIds[n] := LHeader.Id;
        Inc(n);
      end;
    end;
    SetLength(LIds, n);
    if n = 0 then
      Exit;

    LList := FindLinesByHeaderIds(LIds);
    try
      // nesneler başlıkların listelerine geçer
      LList.OwnsObjects := False;
      for LLine in LList do
        if LById.TryGetValue(GetLineHeaderId(LLine), LHeader) then
        begin
          LLine.HeaderEntity := LHeader;
          GetLines(LHeader).Add(LLine);
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

procedure TDocumentService<TH, TL>.Reload(AHeader: TH);
var
  LFresh: TH;
begin
  LFresh := FHeaderRepo.FindById(AHeader.Id, False);
  try
    if not Assigned(LFresh) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AHeader.Id]));
    CopyEntityValues(LFresh, AHeader);   // başlığın basit alanları (kalem listesi nesne özelliği, kopyalanmaz)
  finally
    LFresh.Free;
  end;
  LoadLines([AHeader]);
end;

procedure TDocumentService<TH, TL>.BusinessSaveWithDetails(AEntity: TH; AWithCommit, APermissionControl: Boolean);
var
  LIsNew: Boolean;
  LLog: TDetailSaveLog;
  LLocked: TH;
  LHeader: TH;
  LOldLines: TObjectList<TL>;
  LLines: TArray<TL>;
  LLine: TL;
  LMax: Integer;
  LNos: TDictionary<Integer, Boolean>;
begin
  LIsNew := AEntity.Id <= 0;
  LHeader := AEntity;
  LOldLines := nil;
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

      if LIsNew then
        LOldLines := TObjectList<TL>.Create(True)
      else
      begin
        LLocked := FHeaderRepo.FindById(AEntity.Id, True);
        try
          if not Assigned(LLocked) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
        finally
          LLocked.Free;
        end;
        LOldLines := FindLinesByHeaderIds([AEntity.Id]);
      end;

      // kalemler: kurallar + tutarlar, boş satır no'lar, satır no tekilliği (DB'ye gitmeden)
      LLines := ActiveLines(AEntity);
      CheckLines(AEntity, LLines, LOldLines);
      LMax := 0;
      for LLine in LLines do
        if GetLineNo(LLine) > LMax then
          LMax := GetLineNo(LLine);
      LNos := TDictionary<Integer, Boolean>.Create;
      try
        for LLine in LLines do
        begin
          if GetLineNo(LLine) <= 0 then
          begin
            Inc(LMax);
            SetLineNo(LLine, LMax);
          end;
          if LNos.ContainsKey(GetLineNo(LLine)) then
            RaiseDuplicateLineNo;
          LNos.Add(GetLineNo(LLine), True);
        end;
      finally
        LNos.Free;
      end;

      // başlık kuralları (belge no, durum …); ValidateBusinessRules tutarları sıfırlayabilir: toplamlar kalemlerden
      if LIsNew then
        ValidateAll(AEntity, coInsert)
      else
        ValidateAll(AEntity, coUpdate);
      RecalculateTotals(AEntity);
      BeforeHeaderSaved(AEntity);

      if LIsNew then
        FHeaderRepo.Add(AEntity)
      else
        FHeaderRepo.Update(AEntity);

      TDetailList.Save<TL>(GetLines(AEntity), FLineRepo,
        procedure(ALine: TL)
        begin
          SetLineHeaderId(ALine, LHeader.Id);
        end,
        LLog,
        procedure(ALine: TL)
        begin
          AfterLineSaved(LHeader, ALine);
        end);

      AfterDocumentSaved(AEntity, LOldLines);

      if AWithCommit and Self.UoW.InTransaction then
        Self.UoW.Commit;
    except
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      LLog.Revert;
      AfterSaveFailed(AEntity);
      if LIsNew then
        AEntity.Id := 0;
      raise;
    end;
  finally
    LOldLines.Free;
    LLog.Free;
  end;

  Reload(AEntity);
end;

end.
