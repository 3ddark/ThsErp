unit EInvDiibLine.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvDiibLine.Repository, EInvDiibLine, EInvDiibLine.Exception;

type
  TEInvDiibLineService = class(TCrudService<TEInvDiibLine>)
  private
    FRepo: IRepository<TEInvDiibLine>;

    procedure DoAdd(AEntity: TEInvDiibLine);
    procedure DoUpdate(AEntity: TEInvDiibLine);
    procedure DoDelete(AId: Int64);

    class procedure FailRequired(const AKey, ADefault: string); static;
  public
    constructor Create;
    destructor Destroy; override;

    // Satırın kendi alanları (DB'siz; GTİP / ürün tanımı önceden stok kartından doldurulur). Tek satır kaydı
    // (ValidateBusinessRules) ve belge kaydı (TEInvDiibService.BusinessSaveWithDetails) ortak kullanır
    class procedure CheckLine(AEntity: TEInvDiibLine); static;
    procedure ValidateBusinessRules(AEntity: TEInvDiibLine; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvDiibLine>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvDiibLine; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvDiibLine; override;

    procedure Add(AEntity: TEInvDiibLine); override;
    procedure Update(AEntity: TEInvDiibLine); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDiibLine; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDiibLine>; override;
    procedure BusinessInsert(AEntity: TEInvDiibLine; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvDiibLine; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvDiibLine; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvDiibLineService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvDiibLine, TEInvDiibLineRepository>;
  Self.PermissionCode := PERMISSION_SLS_DIIB;
end;

destructor TEInvDiibLineService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
class procedure TEInvDiibLineService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

class procedure TEInvDiibLineService.CheckLine(AEntity: TEInvDiibLine);
begin
  AEntity.LineCode := AnsiUpperCase(Trim(AEntity.LineCode));
  AEntity.ProductDescription := Trim(AEntity.ProductDescription);
  if AEntity.LineCode = '' then
    FailRequired(TLangKeys.TEInvDiibLine.ColLineCode, 'DIIB Line Code');
  if not TEInvLookup.IsValid(elkDiibLineKind, AEntity.LineKind) then
    FailRequired(TLangKeys.TEInvDiibLine.ColLineKind, 'Line Kind');
  if AEntity.EinvGtipId <= 0 then
    FailRequired(TLangKeys.TEInvDiibLine.ColEinvGtipId, 'GTIP Code');
  if AEntity.ProductDescription = '' then
    FailRequired(TLangKeys.TEInvDiibLine.ColProductDescription, 'DIIB Product Description');
  if AEntity.Quantity < 0 then
    raise EEInvDiibLineExceptionQuantityNegative.Create;
end;


procedure TEInvDiibLineService.ValidateBusinessRules(AEntity: TEInvDiibLine; AOperation: TCrudOperation);
var
  LRepo: TEInvDiibLineRepository;
begin
  LRepo := TEInvDiibLineRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvDiibLineExceptionInUse.Create;
    Exit;
  end;

  if AEntity.EinvDiibId <= 0 then
    FailRequired(TLangKeys.TEInvDiibLine.ColEinvDiibId, 'DIIB No');
  // Stok kartından boş GTİP / ürün tanımı
  if AEntity.StkInventoryId > 0 then
    LRepo.FillFromInventory(AEntity);
  CheckLine(AEntity);
  if AEntity.LineNo <= 0 then
    AEntity.LineNo := LRepo.NextLineNo(AEntity.EinvDiibId);

  if LRepo.LineCodeExists(AEntity.EinvDiibId, AEntity.LineCode, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvDiibLineExceptionLineCodeUnique.Create;
end;

procedure TEInvDiibLineService.DoAdd(AEntity: TEInvDiibLine);
begin
  if AEntity.StkInventoryId > 0 then
    TEInvDiibLineRepository(FRepo).FillFromInventory(AEntity);
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvDiibLineService.DoUpdate(AEntity: TEInvDiibLine);
begin
  if AEntity.StkInventoryId > 0 then
    TEInvDiibLineRepository(FRepo).FillFromInventory(AEntity);
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvDiibLineService.DoDelete(AId: Int64);
var
  LEntity: TEInvDiibLine;
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

function TEInvDiibLineService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDiibLine>;
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

function TEInvDiibLineService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDiibLine;
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

procedure TEInvDiibLineService.BusinessInsert(AEntity: TEInvDiibLine; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDiibLineService.BusinessUpdate(AEntity: TEInvDiibLine; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDiibLineService.BusinessDelete(AEntity: TEInvDiibLine; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvDiibLineService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvDiibLineService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvDiibLine>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvDiibLineService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvDiibLine;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvDiibLineService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvDiibLine;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvDiibLineService.Add(AEntity: TEInvDiibLine);
begin
  DoAdd(AEntity);
end;

procedure TEInvDiibLineService.Update(AEntity: TEInvDiibLine);
begin
  DoUpdate(AEntity);
end;

procedure TEInvDiibLineService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
