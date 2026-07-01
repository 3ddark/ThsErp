unit SysDay.Service;

interface

uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
     Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
     SysDay.Repository, SysDay;

type
  TSysDayService = class(TCrudService<TSysDay>)
  private
    FRepo: IRepository<TSysDay>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysDay>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysDay; override;
    procedure Add(AEntity: TSysDay); override;
    procedure Update(AEntity: TSysDay); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysDay; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysDay>; override;
    procedure BusinessInsert(AEntity: TSysDay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysDay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysDay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysDayService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysDay, TSysDayRepository>;
end;

destructor TSysDayService.Destroy;
begin
  inherited;
end;

function TSysDayService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysDay>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysDayService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysDay;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSysDayService.BusinessInsert(AEntity: TSysDay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysDayService.BusinessUpdate(AEntity: TSysDay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysDayService.BusinessDelete(AEntity: TSysDay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysDayService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysDayService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysDay>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else Result := FRepo.Find(AFilter, ALock);
end;

function TSysDayService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysDay;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else Result := FRepo.FindById(AId, ALock);
end;

procedure TSysDayService.Add(AEntity: TSysDay);
begin
  FRepo.Add(AEntity);
end;

procedure TSysDayService.Update(AEntity: TSysDay);
begin
  FRepo.Update(AEntity);
end;

procedure TSysDayService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
