unit SysMonth.Service;

interface

uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
     Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
     SysMonth.Repository, SysMonth;

type
  TSysMonthService = class(TCrudService<TSysMonth>)
  private
    FRepo: IRepository<TSysMonth>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysMonth>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysMonth; override;
    procedure Add(AEntity: TSysMonth); override;
    procedure Update(AEntity: TSysMonth); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysMonth; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysMonth>; override;
    procedure BusinessInsert(AEntity: TSysMonth; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysMonth; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysMonth; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysMonthService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysMonth, TSysMonthRepository>;
end;

destructor TSysMonthService.Destroy;
begin
  inherited;
end;

function TSysMonthService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysMonth>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysMonthService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysMonth;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSysMonthService.BusinessInsert(AEntity: TSysMonth; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysMonthService.BusinessUpdate(AEntity: TSysMonth; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysMonthService.BusinessDelete(AEntity: TSysMonth; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysMonthService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysMonthService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysMonth>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else Result := FRepo.Find(AFilter, ALock);
end;

function TSysMonthService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysMonth;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else Result := FRepo.FindById(AId, ALock);
end;

procedure TSysMonthService.Add(AEntity: TSysMonth);
begin
  FRepo.Add(AEntity);
end;

procedure TSysMonthService.Update(AEntity: TSysMonth);
begin
  FRepo.Update(AEntity);
end;

procedure TSysMonthService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
