unit AccAccountPlan.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  AccAccountPlan.Repository, AccAccountPlan;

type
  TAccAccountPlanService = class(TCrudService<TAccAccountPlan>)
  private
    FRepo: IRepository<TAccAccountPlan>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccAccountPlan>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccAccountPlan; override;
    procedure Add(AEntity: TAccAccountPlan); override;
    procedure Update(AEntity: TAccAccountPlan); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountPlan; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountPlan>; override;
    procedure BusinessInsert(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TAccAccountPlanService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccAccountPlan, TAccAccountPlanRepository>;
end;

destructor TAccAccountPlanService.Destroy;
begin
  inherited;
end;

function TAccAccountPlanService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountPlan>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccAccountPlanService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountPlan;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TAccAccountPlanService.BusinessInsert(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;
    FRepo.Add(AEntity);
    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TAccAccountPlanService.BusinessUpdate(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;
    FRepo.Update(AEntity);
    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TAccAccountPlanService.BusinessDelete(AEntity: TAccAccountPlan; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;
    FRepo.Delete(AEntity);
    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then Self.UoW.Rollback;
      raise;
    end;
  end;
end;

function TAccAccountPlanService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccAccountPlanService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TAccAccountPlan>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TAccAccountPlanService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccAccountPlan;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TAccAccountPlanService.Add(AEntity: TAccAccountPlan);
begin
  FRepo.Add(AEntity);
end;

procedure TAccAccountPlanService.Update(AEntity: TAccAccountPlan);
begin
  FRepo.Update(AEntity);
end;

procedure TAccAccountPlanService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
