unit SysRegion.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  BaseEntity, BaseService, UnitOfWork, SysRegion.Repository, SysRegion;

type
  TSysRegionService = class(TBaseService<TSysRegion>)
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(const AFilterKey: string): string; override;
    function Find(AFilter: string; ALock: Boolean): TList<TSysRegion>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysRegion; override;
    procedure Add(AEntity: TSysRegion); override;
    procedure Update(AEntity: TSysRegion); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysRegion; override;
    function BusinessFind(AFilter: string; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysRegion>; override;
    procedure BusinessInsert(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysRegionService.Create;
begin
  inherited;
end;

destructor TSysRegionService.Destroy;
begin
  inherited;
end;

function TSysRegionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysRegion;
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;
  if AWithBegin then
    Self.UoW.BeginTransaction;
  Result := Self.UoW.SysRegionRepository.FindById(AId, ALock);
end;

function TSysRegionService.BusinessFind(AFilter: string; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysRegion>;
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;
  if AWithBegin then
    Self.UoW.BeginTransaction;
  Result := Self.UoW.SysRegionRepository.Find(AFilter, ALock);
end;

procedure TSysRegionService.BusinessInsert(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysRegionRepository.Add(AEntity);

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
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  try
    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysRegionRepository.Update(AEntity);

    if AWithCommit then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysRegionService.BusinessDelete(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  try
    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysRegionRepository.Delete(AEntity);

    if AWithCommit then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysRegionService.CreateQueryForUI(const AFilterKey: string): string;
begin
  Result := Self.UoW.SysRegionRepository.CreateQueryForUI(AFilterKey);
end;

function TSysRegionService.Find(AFilter: string; ALock: Boolean): TList<TSysRegion>;
begin
  Result := Self.Uow.SysRegionRepository.Find(AFilter, ALock);
end;

function TSysRegionService.FindById(AId: Int64; ALock: Boolean): TSysRegion;
begin
  Result := Self.Uow.SysRegionRepository.FindById(AId, ALock);
end;

procedure TSysRegionService.Add(AEntity: TSysRegion);
begin
  Self.UoW.SysRegionRepository.Add(AEntity);
end;

procedure TSysRegionService.Update(AEntity: TSysRegion);
begin
  Self.UoW.SysRegionRepository.Update(AEntity);
end;

procedure TSysRegionService.Delete(AId: Int64);
begin
  Self.UoW.SysRegionRepository.Delete(AId);
end;

end.

