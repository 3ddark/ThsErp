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

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysRegion; APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysRegion; APermissionControl: Boolean); override;
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

procedure TSysRegionService.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.SysRegionRepository.Find(AFilter, ALock);
  except
    raise;
  end;
end;

procedure TSysRegionService.BusinessInsert(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if Self.UoW.SysRegionRepository.ExistsByField(AEntity.RegionName.FieldName, AEntity.RegionName.Value) then
      Exit;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysRegionRepository.Add(AEntity);

    if AWithCommit and Uow.Connection.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.Connection.InTransaction then
        Self.UoW.Rollback;
      raise
    end;
  end;
end;

procedure TSysRegionService.BusinessUpdate(AEntity: TSysRegion; APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.BeginTransaction;
    Self.UoW.SysRegionRepository.Update(AEntity);
    Self.UoW.Commit;
  except
    on E: Exception do
    begin
      Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TSysRegionService.BusinessDelete(AEntity: TSysRegion; APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.BeginTransaction;
    Self.UoW.SysRegionRepository.Delete(AEntity.Id.Value);
    Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.Connection.InTransaction then
        Self.UoW.Rollback;
      raise
    end;
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

