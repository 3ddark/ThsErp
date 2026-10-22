unit AccVoucher.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DocumentService, AccVoucher.Repository, AccVoucher, AccVoucher.Exception, AccVoucherDetail, AccVoucherDetail.Repository;

type
  // Muhasebe fişi = başlık + Lines (TDocumentService: kalem işlemleri, yükleme, tek transaction'lı kayıt + Reload).
  // Kalemler yalnız hareket gören (SON) hesaplara borç ya da alacak; borç toplamı = alacak toplamı > 0. Fiş no ve
  // yevmiye no yeni kayıtta servis verir, toplamlar kalemlerden.
  TAccVoucherService = class(TDocumentService<TAccVoucher, TAccVoucherDetail>)
  private
    FRepo: IRepository<TAccVoucher>;

    procedure DoAdd(AEntity: TAccVoucher);
    procedure DoUpdate(AEntity: TAccVoucher);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TAccVoucher): TObjectList<TAccVoucherDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TAccVoucherDetail>; override;
    function GetLineHeaderId(ALine: TAccVoucherDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TAccVoucherDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TAccVoucherDetail): Integer; override;
    procedure SetLineNo(ALine: TAccVoucherDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TAccVoucher; ALine: TAccVoucherDetail); override;
    procedure CheckLines(AHeader: TAccVoucher; const ALines: TArray<TAccVoucherDetail>; AOldLines: TObjectList<TAccVoucherDetail>); override;
    procedure PrepareCopyHeader(AHeader: TAccVoucher); override;
    procedure PrepareCopyLine(AHeader: TAccVoucher; ALine: TAccVoucherDetail); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccVoucher; AOperation: TCrudOperation); override;

    // Kalemde hesap yok; başlık borç / alacak toplamları aktif kalemlerden
    procedure RecalculateLine(ALine: TAccVoucherDetail); override;
    procedure RecalculateTotals(AHeader: TAccVoucher); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccVoucher>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccVoucher; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccVoucher; override;

    procedure Add(AEntity: TAccVoucher); override;
    procedure Update(AEntity: TAccVoucher); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccVoucher; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccVoucher>; override;
    procedure BusinessInsert(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, AccLookup, AccVoucherDetail.Service;

constructor TAccVoucherService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccVoucher, TAccVoucherRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TAccVoucherDetail, TAccVoucherDetailRepository>;
  Self.PermissionCode := PERMISSION_ACC_VOUCHER;
end;

{ Belge (TDocumentService) }

function TAccVoucherService.GetLines(AHeader: TAccVoucher): TObjectList<TAccVoucherDetail>;
begin
  Result := AHeader.Lines;
end;

function TAccVoucherService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TAccVoucherDetail>;
begin
  Result := TAccVoucherDetailRepository(FLineRepo).FindByVoucherIds(AIds);
end;

function TAccVoucherService.GetLineHeaderId(ALine: TAccVoucherDetail): Int64;
begin
  Result := ALine.AccVoucherId;
end;

procedure TAccVoucherService.SetLineHeaderId(ALine: TAccVoucherDetail; AHeaderId: Int64);
begin
  ALine.AccVoucherId := AHeaderId;
end;

function TAccVoucherService.GetLineNo(ALine: TAccVoucherDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TAccVoucherService.SetLineNo(ALine: TAccVoucherDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TAccVoucherService.RaiseDuplicateLineNo;
begin
  raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TDetailForm.LineNoUnique, 'This line number is already used on the document.'));
end;

// Fiş no (görüntü) ve açıklama başlıktan
procedure TAccVoucherService.InitLine(AHeader: TAccVoucher; ALine: TAccVoucherDetail);
begin
  ALine.VoucherNo := AHeader.VoucherNo;
  ALine.Description := AHeader.Description;
end;

// Alanlar (tek kalem yoluyla ortak CheckLine), yalnız SON hesaplar, en az bir kalem, borç toplamı = alacak toplamı
procedure TAccVoucherService.CheckLines(AHeader: TAccVoucher; const ALines: TArray<TAccVoucherDetail>;
  AOldLines: TObjectList<TAccVoucherDetail>);
var
  LLine: TAccVoucherDetail;
  LSvc: TAccVoucherDetailService;
  LDebit, LCredit: Currency;
begin
  if Length(ALines) = 0 then
    raise EAccVoucherExceptionNoLines.Create;
  LDebit := 0;
  LCredit := 0;
  for LLine in ALines do
  begin
    TAccVoucherDetailService.CheckLine(LLine);
    LDebit := LDebit + LLine.Debit;
    LCredit := LCredit + LLine.Credit;
  end;
  if LDebit <> LCredit then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TAccVoucher.NotBalanced,
      'Debit and credit totals must be equal (difference: %s).'), [FormatFloat('#,##0.00', LDebit - LCredit)]));
  LSvc := TAccVoucherDetailService.Create;
  try
    LSvc.CheckAccounts(ALines);
  finally
    LSvc.Free;
  end;
end;

// Kopya: yeni fiş no ve yevmiye no kayıtta verilir
procedure TAccVoucherService.PrepareCopyHeader(AHeader: TAccVoucher);
begin
  AHeader.VoucherNo := '';
  AHeader.JournalNo := 0;
end;

procedure TAccVoucherService.PrepareCopyLine(AHeader: TAccVoucher; ALine: TAccVoucherDetail);
begin
  inherited;
  ALine.VoucherNo := '';
end;

procedure TAccVoucherService.RecalculateLine(ALine: TAccVoucherDetail);
begin
//
end;

procedure TAccVoucherService.RecalculateTotals(AHeader: TAccVoucher);
var
  LLine: TAccVoucherDetail;
begin
  AHeader.TotalDebit := 0;
  AHeader.TotalCredit := 0;
  for LLine in AHeader.Lines do
    if not LLine.Deleted then
    begin
      AHeader.TotalDebit := AHeader.TotalDebit + LLine.Debit;
      AHeader.TotalCredit := AHeader.TotalCredit + LLine.Credit;
    end;
end;

destructor TAccVoucherService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TAccVoucherService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TAccVoucherService.ValidateBusinessRules(AEntity: TAccVoucher; AOperation: TCrudOperation);
var
  LRepo: TAccVoucherRepository;
  LOld: TAccVoucher;
  LFilter: TFilterCriteria;
  LModel: TAccVoucher;
begin
  LRepo := TAccVoucherRepository(FRepo);
  if AOperation = coDelete then
    Exit;

  AEntity.VoucherNo := AnsiUpperCase(Trim(AEntity.VoucherNo));
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.VoucherDate <= 0 then
    FailRequired(TLangKeys.TAccVoucher.ColVoucherDate, 'Voucher Date');
  if not TAccLookup.IsValid(alkVoucherType, AEntity.VoucherType) then
    FailRequired(TLangKeys.TAccVoucher.ColVoucherType, 'Voucher Type');

  if AOperation = coInsert then
  begin
    // toplamlar kalemlerden, yevmiye no sıradaki
    AEntity.TotalDebit := 0;
    AEntity.TotalCredit := 0;
    AEntity.JournalNo := LRepo.NextJournalNo;
    if AEntity.VoucherNo = '' then
      AEntity.VoucherNo := LRepo.NextDocumentNo(ACC_PREFIX_VOUCHER);
  end
  else
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if not Assigned(LOld) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AEntity.Id]));
      AEntity.JournalNo := LOld.JournalNo;
      AEntity.TotalDebit := LOld.TotalDebit;
      AEntity.TotalCredit := LOld.TotalCredit;
      if AEntity.VoucherNo = '' then
        AEntity.VoucherNo := LOld.VoucherNo;
    finally
      LOld.Free;
    end;
  end;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('voucher_no', '=', TValue.From<string>(AEntity.VoucherNo)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EAccVoucherExceptionNoUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TAccVoucherService.DoAdd(AEntity: TAccVoucher);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccVoucherService.DoUpdate(AEntity: TAccVoucher);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccVoucherService.DoDelete(AId: Int64);
var
  LEntity: TAccVoucher;
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

function TAccVoucherService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccVoucher>;
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

function TAccVoucherService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccVoucher;
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

procedure TAccVoucherService.BusinessInsert(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccVoucherService.BusinessUpdate(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccVoucherService.BusinessDelete(AEntity: TAccVoucher; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccVoucherService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalemler de (tek sorguda)
function TAccVoucherService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccVoucher>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TAccVoucherService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccVoucher;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TAccVoucherService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccVoucher;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccVoucherService.Add(AEntity: TAccVoucher);
begin
  DoAdd(AEntity);
end;

procedure TAccVoucherService.Update(AEntity: TAccVoucher);
begin
  DoUpdate(AEntity);
end;

procedure TAccVoucherService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
