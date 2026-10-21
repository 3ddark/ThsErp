unit EInvDiib.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvDiib.Repository, EInvDiib, EInvDiib.Exception,
  DocumentService, EInvDiibLine, EInvDiibLine.Repository;

type
  // DİİB belgesi = başlık + Lines (satırlar; TDocumentService: bellekte, başlıkla tek transaction).
  TEInvDiibService = class(TDocumentService<TEInvDiib, TEInvDiibLine>)
  private
    FRepo: IRepository<TEInvDiib>;

    procedure DoAdd(AEntity: TEInvDiib);
    procedure DoUpdate(AEntity: TEInvDiib);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TEInvDiib): TObjectList<TEInvDiibLine>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TEInvDiibLine>; override;
    function GetLineHeaderId(ALine: TEInvDiibLine): Int64; override;
    procedure SetLineHeaderId(ALine: TEInvDiibLine; AHeaderId: Int64); override;
    function GetLineNo(ALine: TEInvDiibLine): Integer; override;
    procedure SetLineNo(ALine: TEInvDiibLine; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TEInvDiib; ALine: TEInvDiibLine); override;
    procedure CheckLines(AHeader: TEInvDiib; const ALines: TArray<TEInvDiibLine>; AOldLines: TObjectList<TEInvDiibLine>); override;
    procedure PrepareCopyHeader(AHeader: TEInvDiib); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvDiib; AOperation: TCrudOperation); override;
    // Tutar yok: hesap gerekmez
    procedure RecalculateLine(ALine: TEInvDiibLine); override;
    procedure RecalculateTotals(AHeader: TEInvDiib); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvDiib>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvDiib; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvDiib; override;

    procedure Add(AEntity: TEInvDiib); override;
    procedure Update(AEntity: TEInvDiib); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDiib; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDiib>; override;
    procedure BusinessInsert(AEntity: TEInvDiib; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvDiib; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvDiib; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup, EInvDiibLine.Service, EInvDiibLine.Exception;

constructor TEInvDiibService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvDiib, TEInvDiibRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TEInvDiibLine, TEInvDiibLineRepository>;
  Self.PermissionCode := PERMISSION_SLS_DIIB;
end;

{ Belge (TDocumentService) }

function TEInvDiibService.GetLines(AHeader: TEInvDiib): TObjectList<TEInvDiibLine>;
begin
  Result := AHeader.Lines;
end;

function TEInvDiibService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TEInvDiibLine>;
begin
  Result := TEInvDiibLineRepository(FLineRepo).FindByDiibIds(AIds);
end;

function TEInvDiibService.GetLineHeaderId(ALine: TEInvDiibLine): Int64;
begin
  Result := ALine.EinvDiibId;
end;

procedure TEInvDiibService.SetLineHeaderId(ALine: TEInvDiibLine; AHeaderId: Int64);
begin
  ALine.EinvDiibId := AHeaderId;
end;

function TEInvDiibService.GetLineNo(ALine: TEInvDiibLine): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TEInvDiibService.SetLineNo(ALine: TEInvDiibLine; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TEInvDiibService.RaiseDuplicateLineNo;
begin
  raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TDetailForm.LineNoUnique, 'This line number is already used on the document.'));
end;

procedure TEInvDiibService.InitLine(AHeader: TEInvDiib; ALine: TEInvDiibLine);
begin
  ALine.DocumentNo := AHeader.DocumentNo;
  ALine.HolderType := AHeader.HolderType;
  ALine.IsActive := True;
end;

// Satır alanları (stok kartından boş GTİP / ürün tanımı; ortak CheckLine), satır kodu belgede tekil; faturada
// kullanılan satır silinemez
procedure TEInvDiibService.CheckLines(AHeader: TEInvDiib; const ALines: TArray<TEInvDiibLine>; AOldLines: TObjectList<TEInvDiibLine>);
var
  LLine: TEInvDiibLine;
  LCodes: TDictionary<string, Boolean>;
begin
  for LLine in AHeader.Lines do
    if LLine.Deleted and (LLine.Id > 0) and (TEInvDiibLineRepository(FLineRepo).UsageCount(LLine.Id) > 0) then
      raise EEInvDiibLineExceptionInUse.Create;
  LCodes := TDictionary<string, Boolean>.Create;
  try
    for LLine in ALines do
    begin
      if LLine.StkInventoryId > 0 then
        TEInvDiibLineRepository(FLineRepo).FillFromInventory(LLine);
      TEInvDiibLineService.CheckLine(LLine);
      if LCodes.ContainsKey(LLine.LineCode) then
        raise EEInvDiibLineExceptionLineCodeUnique.Create;
      LCodes.Add(LLine.LineCode, True);
    end;
  finally
    LCodes.Free;
  end;
end;

procedure TEInvDiibService.PrepareCopyHeader(AHeader: TEInvDiib);
begin
  // belge no tekil: kopyada yeniden girilir
  AHeader.DocumentNo := '';
end;

procedure TEInvDiibService.RecalculateLine(ALine: TEInvDiibLine);
begin
//
end;

procedure TEInvDiibService.RecalculateTotals(AHeader: TEInvDiib);
begin
//
end;

destructor TEInvDiibService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvDiibService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvDiibService.ValidateBusinessRules(AEntity: TEInvDiib; AOperation: TCrudOperation);
var
  LRepo: TEInvDiibRepository;
begin
  LRepo := TEInvDiibRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsedLineCount(AEntity.Id) > 0 then
      raise EEInvDiibExceptionInUse.Create;
    Exit;
  end;

  AEntity.DocumentNo := AnsiUpperCase(Trim(AEntity.DocumentNo));
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.DocumentNo = '' then
    FailRequired(TLangKeys.TEInvDiib.ColDocumentNo, 'DIIB No');
  if not TEInvLookup.IsValid(elkDiibHolder, AEntity.HolderType) then
    FailRequired(TLangKeys.TEInvDiib.ColHolderType, 'Certificate Holder');

  // Firmamızın belgesinde cari tutulmaz; müşteri belgesinde zorunlu
  if AEntity.HolderType = EINV_DIIB_OWN then
  begin
    AEntity.AccAccountId := 0;
    AEntity.AccountCode := '';
    AEntity.AccountName := '';
  end
  else if AEntity.AccAccountId <= 0 then
    raise EEInvDiibExceptionAccountRequired.Create;

  if (AEntity.IssueDate > 0) and (AEntity.ValidUntil > 0) and (AEntity.ValidUntil < AEntity.IssueDate) then
    raise EEInvDiibExceptionDateRange.Create;

  if LRepo.DocumentNoExists(AEntity.DocumentNo, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvDiibExceptionDocumentNoUnique.Create;
end;

procedure TEInvDiibService.DoAdd(AEntity: TEInvDiib);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvDiibService.DoUpdate(AEntity: TEInvDiib);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvDiibService.DoDelete(AId: Int64);
var
  LEntity: TEInvDiib;
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

function TEInvDiibService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDiib>;
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

function TEInvDiibService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDiib;
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

procedure TEInvDiibService.BusinessInsert(AEntity: TEInvDiib; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDiibService.BusinessUpdate(AEntity: TEInvDiib; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDiibService.BusinessDelete(AEntity: TEInvDiib; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvDiibService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvDiibService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvDiib>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TEInvDiibService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvDiib;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TEInvDiibService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvDiib;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvDiibService.Add(AEntity: TEInvDiib);
begin
  DoAdd(AEntity);
end;

procedure TEInvDiibService.Update(AEntity: TEInvDiib);
begin
  DoUpdate(AEntity);
end;

procedure TEInvDiibService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
