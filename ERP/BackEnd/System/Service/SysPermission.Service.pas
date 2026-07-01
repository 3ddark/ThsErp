unit SysPermission.Service;

interface

uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
     Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
     SysPermission.Repository, SysPermission;

type
  TSysPermissionService = class(TCrudService<TSysPermission>)
  private
    FRepo: IRepository<TSysPermission>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysPermission>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysPermission; override;
    procedure Add(AEntity: TSysPermission); override;
    procedure Update(AEntity: TSysPermission); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermission; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermission>; override;
    procedure BusinessInsert(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysPermissionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysPermission, TSysPermissionRepository>;
end;

destructor TSysPermissionService.Destroy;
begin
  inherited;
end;

function TSysPermissionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermission>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermission;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSysPermissionService.BusinessInsert(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionService.BusinessUpdate(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionService.BusinessDelete(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysPermissionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysPermissionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysPermission>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysPermission;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else Result := FRepo.FindById(AId, ALock);
end;

procedure TSysPermissionService.Add(AEntity: TSysPermission);
begin
  FRepo.Add(AEntity);
end;

procedure TSysPermissionService.Update(AEntity: TSysPermission);
begin
  FRepo.Update(AEntity);
end;

procedure TSysPermissionService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
