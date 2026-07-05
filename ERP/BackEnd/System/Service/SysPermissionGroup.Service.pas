unit SysPermissionGroup.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SysPermissionGroup.Repository, SysPermissionGroup;

type
  TSysPermissionGroupService = class(TCrudService<TSysPermissionGroup>)
  private
    FRepo: IRepository<TSysPermissionGroup>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysPermissionGroup>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysPermissionGroup; override;
    procedure Add(AEntity: TSysPermissionGroup); override;
    procedure Update(AEntity: TSysPermissionGroup); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionGroup; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionGroup>; override;
    procedure BusinessInsert(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysPermissionGroupService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysPermissionGroup, TSysPermissionGroupRepository>;
end;

destructor TSysPermissionGroupService.Destroy;
begin
  inherited;
end;

function TSysPermissionGroupService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionGroup>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionGroupService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionGroup;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSysPermissionGroupService.BusinessInsert(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Add(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin if Uow.InTransaction then Self.UoW.Rollback; raise; end;
  end;
end;

procedure TSysPermissionGroupService.BusinessUpdate(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Update(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end;
  end;
end;

procedure TSysPermissionGroupService.BusinessDelete(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Delete(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end;
  end;
end;

function TSysPermissionGroupService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysPermissionGroupService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysPermissionGroup>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionGroupService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysPermissionGroup;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else Result := FRepo.FindById(AId, ALock);
end;

procedure TSysPermissionGroupService.Add(AEntity: TSysPermissionGroup);
begin
  FRepo.Add(AEntity);
end;

procedure TSysPermissionGroupService.Update(AEntity: TSysPermissionGroup);
begin
  FRepo.Update(AEntity);
end;

procedure TSysPermissionGroupService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
