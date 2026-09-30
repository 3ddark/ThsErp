unit StkInventorySummary.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  StkInventorySummary.Repository, StkInventorySummary;

type
  TStkInventorySummaryService = class(TCrudService<TStkInventorySummary>)
  private
    FRepo: IRepository<TStkInventorySummary>;

    procedure DoAdd(AEntity: TStkInventorySummary);
    procedure DoUpdate(AEntity: TStkInventorySummary);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TStkInventorySummary);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TStkInventorySummary; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkInventorySummary>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkInventorySummary; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TStkInventorySummary; override;

    procedure Add(AEntity: TStkInventorySummary); override;
    procedure Update(AEntity: TStkInventorySummary); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkInventorySummary; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkInventorySummary>; override;
    procedure BusinessInsert(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TStkInventorySummaryService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>;
  Self.PermissionCode := PERMISSION_STK_INVENTORY_SUMMARY;
end;

destructor TStkInventorySummaryService.Destroy;
begin
  inherited;
end;

procedure TStkInventorySummaryService.ValidateRequiredReferences(AEntity: TStkInventorySummary);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.StkInventoryId, TLangKeys.TStkInventorySummary.ColInventory, 'Stock Card');
end;

procedure TStkInventorySummaryService.ValidateBusinessRules(AEntity: TStkInventorySummary; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.LastBuyCurrency := Trim(AEntity.LastBuyCurrency);
    ValidateRequiredReferences(AEntity);
  end;
end;

procedure TStkInventorySummaryService.DoAdd(AEntity: TStkInventorySummary);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TStkInventorySummaryService.DoUpdate(AEntity: TStkInventorySummary);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TStkInventorySummaryService.DoDelete(AId: Int64);
var
  LEntity: TStkInventorySummary;
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

function TStkInventorySummaryService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkInventorySummary>;
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

function TStkInventorySummaryService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkInventorySummary;
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

procedure TStkInventorySummaryService.BusinessInsert(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkInventorySummaryService.BusinessUpdate(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkInventorySummaryService.BusinessDelete(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TStkInventorySummaryService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TStkInventorySummaryService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TStkInventorySummary>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TStkInventorySummaryService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TStkInventorySummary;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TStkInventorySummaryService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkInventorySummary;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TStkInventorySummaryService.Add(AEntity: TStkInventorySummary);
begin
  DoAdd(AEntity);
end;

procedure TStkInventorySummaryService.Update(AEntity: TStkInventorySummary);
begin
  DoUpdate(AEntity);
end;

procedure TStkInventorySummaryService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
