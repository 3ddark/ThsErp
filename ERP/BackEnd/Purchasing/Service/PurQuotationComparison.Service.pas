unit PurQuotationComparison.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PurQuotationComparison.Repository, PurQuotationComparison, PurQuotationComparison.Exception;

type
  // Salt okunur karşılaştırma listesi (teklif yetkisi)
  TPurQuotationComparisonService = class(TCrudService<TPurQuotationComparison>)
  private
    FRepo: IRepository<TPurQuotationComparison>;

    procedure DoAdd(AEntity: TPurQuotationComparison);
    procedure DoUpdate(AEntity: TPurQuotationComparison);
    procedure DoDelete(AId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPurQuotationComparison; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPurQuotationComparison>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPurQuotationComparison; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPurQuotationComparison; override;

    procedure Add(AEntity: TPurQuotationComparison); override;
    procedure Update(AEntity: TPurQuotationComparison); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurQuotationComparison; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurQuotationComparison>; override;
    procedure BusinessInsert(AEntity: TPurQuotationComparison; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPurQuotationComparison; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPurQuotationComparison; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TPurQuotationComparisonService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPurQuotationComparison, TPurQuotationComparisonRepository>;
  Self.PermissionCode := PERMISSION_PUR_QUOTATION;
end;

destructor TPurQuotationComparisonService.Destroy;
begin
  inherited;
end;

procedure TPurQuotationComparisonService.ValidateBusinessRules(AEntity: TPurQuotationComparison; AOperation: TCrudOperation);
begin
  raise EPurQuotationComparisonExceptionReadOnly.Create;
end;

procedure TPurQuotationComparisonService.DoAdd(AEntity: TPurQuotationComparison);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPurQuotationComparisonService.DoUpdate(AEntity: TPurQuotationComparison);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPurQuotationComparisonService.DoDelete(AId: Int64);
var
  LEntity: TPurQuotationComparison;
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

function TPurQuotationComparisonService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPurQuotationComparison>;
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

function TPurQuotationComparisonService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPurQuotationComparison;
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

procedure TPurQuotationComparisonService.BusinessInsert(AEntity: TPurQuotationComparison; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurQuotationComparisonService.BusinessUpdate(AEntity: TPurQuotationComparison; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPurQuotationComparisonService.BusinessDelete(AEntity: TPurQuotationComparison; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPurQuotationComparisonService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPurQuotationComparisonService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPurQuotationComparison>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPurQuotationComparisonService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPurQuotationComparison;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPurQuotationComparisonService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPurQuotationComparison;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPurQuotationComparisonService.Add(AEntity: TPurQuotationComparison);
begin
  DoAdd(AEntity);
end;

procedure TPurQuotationComparisonService.Update(AEntity: TPurQuotationComparison);
begin
  DoUpdate(AEntity);
end;

procedure TPurQuotationComparisonService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
