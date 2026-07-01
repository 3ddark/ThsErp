unit SysDecimalPlace.Service;

interface

uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
     Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
     SysDecimalPlace.Repository, SysDecimalPlace;

type
  TSysDecimalPlaceService = class(TCrudService<TSysDecimalPlace>)
  private
    FRepo: IRepository<TSysDecimalPlace>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysDecimalPlace>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysDecimalPlace; override;
    procedure Add(AEntity: TSysDecimalPlace); override;
    procedure Update(AEntity: TSysDecimalPlace); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysDecimalPlace; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysDecimalPlace>; override;
    procedure BusinessInsert(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysDecimalPlaceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysDecimalPlace, TSysDecimalPlaceRepository>;
end;

destructor TSysDecimalPlaceService.Destroy;
begin
  inherited;
end;

function TSysDecimalPlaceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysDecimalPlace>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysDecimalPlaceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysDecimalPlace;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSysDecimalPlaceService.BusinessInsert(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysDecimalPlaceService.BusinessUpdate(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysDecimalPlaceService.BusinessDelete(AEntity: TSysDecimalPlace; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysDecimalPlaceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysDecimalPlaceService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysDecimalPlace>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else Result := FRepo.Find(AFilter, ALock);
end;

function TSysDecimalPlaceService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysDecimalPlace;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else Result := FRepo.FindById(AId, ALock);
end;

procedure TSysDecimalPlaceService.Add(AEntity: TSysDecimalPlace);
begin
  FRepo.Add(AEntity);
end;

procedure TSysDecimalPlaceService.Update(AEntity: TSysDecimalPlace);
begin
  FRepo.Update(AEntity);
end;

procedure TSysDecimalPlaceService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
