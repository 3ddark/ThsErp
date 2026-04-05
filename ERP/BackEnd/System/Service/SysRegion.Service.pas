unit SysRegion.Service;

interface

uses
  SysUtils, Classes, Contnrs, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SysRegion.Repository, SysRegion;

type
  TSysRegionService = class(TCrudService<TSysRegion>)
  private
    FRepo: IRepository<TSysRegion>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysRegion>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysRegion; override;
    procedure Add(AEntity: TSysRegion); override;
    procedure Update(AEntity: TSysRegion); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysRegion; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysRegion>; override;
    procedure BusinessInsert(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysRegionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysRegion, TSysRegionRepository>;
end;

destructor TSysRegionService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TSysRegionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysRegion>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSysRegionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysRegion;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock);
end;

procedure TSysRegionService.BusinessInsert(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
        Self.UoW.Rollback;
      raise
    end;
  end;
end;

procedure TSysRegionService.BusinessUpdate(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TSysRegionService.BusinessDelete(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

function TSysRegionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysRegionService.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysRegion>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysRegionService.FindById(AId: Int64; ALock: Boolean): TSysRegion;
begin
  Result := FRepo.FindById(AId, ALock);
end;

procedure TSysRegionService.Add(AEntity: TSysRegion);
begin
  FRepo.Add(AEntity);
end;

procedure TSysRegionService.Update(AEntity: TSysRegion);
begin
  FRepo.Update(AEntity);
end;

procedure TSysRegionService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.

