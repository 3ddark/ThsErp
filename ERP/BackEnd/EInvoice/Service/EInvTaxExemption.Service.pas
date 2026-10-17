unit EInvTaxExemption.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvTaxExemption.Repository, EInvTaxExemption, EInvTaxExemption.Exception;

type
  TEInvTaxExemptionService = class(TCrudService<TEInvTaxExemption>)
  private
    FRepo: IRepository<TEInvTaxExemption>;

    procedure DoAdd(AEntity: TEInvTaxExemption);
    procedure DoUpdate(AEntity: TEInvTaxExemption);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvTaxExemption; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvTaxExemption>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvTaxExemption; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvTaxExemption; override;

    procedure Add(AEntity: TEInvTaxExemption); override;
    procedure Update(AEntity: TEInvTaxExemption); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvTaxExemption; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvTaxExemption>; override;
    procedure BusinessInsert(AEntity: TEInvTaxExemption; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvTaxExemption; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvTaxExemption; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvTaxExemptionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvTaxExemption, TEInvTaxExemptionRepository>;
  Self.PermissionCode := PERMISSION_EINV_TAX_EXEMPTION;
end;

destructor TEInvTaxExemptionService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvTaxExemptionService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvTaxExemptionService.ValidateBusinessRules(AEntity: TEInvTaxExemption; AOperation: TCrudOperation);
var
  LRepo: TEInvTaxExemptionRepository;
begin
  LRepo := TEInvTaxExemptionRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvTaxExemptionExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvTaxExemption.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvTaxExemption.ColName, 'Name');
  if not TEInvLookup.IsValid(elkExemptionGroup, AEntity.ExemptionGroup) then
    FailRequired(TLangKeys.TEInvTaxExemption.ColExemptionGroup, 'Exemption Group');
  // DİİB satır kodu yalnız GTİP ile birlikte istenir
  if AEntity.RequiresDiib then
    AEntity.RequiresGtip := True;
  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvTaxExemptionExceptionCodeUnique.Create;
end;

procedure TEInvTaxExemptionService.DoAdd(AEntity: TEInvTaxExemption);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvTaxExemptionService.DoUpdate(AEntity: TEInvTaxExemption);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvTaxExemptionService.DoDelete(AId: Int64);
var
  LEntity: TEInvTaxExemption;
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

function TEInvTaxExemptionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvTaxExemption>;
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

function TEInvTaxExemptionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvTaxExemption;
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

procedure TEInvTaxExemptionService.BusinessInsert(AEntity: TEInvTaxExemption; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvTaxExemptionService.BusinessUpdate(AEntity: TEInvTaxExemption; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvTaxExemptionService.BusinessDelete(AEntity: TEInvTaxExemption; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvTaxExemptionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvTaxExemptionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvTaxExemption>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvTaxExemptionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvTaxExemption;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvTaxExemptionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvTaxExemption;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvTaxExemptionService.Add(AEntity: TEInvTaxExemption);
begin
  DoAdd(AEntity);
end;

procedure TEInvTaxExemptionService.Update(AEntity: TEInvTaxExemption);
begin
  DoUpdate(AEntity);
end;

procedure TEInvTaxExemptionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
