unit SysPermissionGroup.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  BaseEntity, BaseService, UnitOfWork, SysPermissionGroup.Repository, SysPermissionGroup;

type
  TSysPermissionGroupService = class(TBaseService<TSysPermissionGroup>)
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(const AFilterKey: string): string; override;
    function Find(AFilter: string; ALock: Boolean): TList<TSysPermissionGroup>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysPermissionGroup; override;
    procedure Add(AEntity: TSysPermissionGroup); override;
    procedure Update(AEntity: TSysPermissionGroup); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionGroup; override;
    function BusinessFind(AFilter: string; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionGroup>; override;
    procedure BusinessInsert(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysPermissionGroupService.Create;
begin
  inherited;
end;

destructor TSysPermissionGroupService.Destroy;
begin
  inherited;
end;

function TSysPermissionGroupService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionGroup;
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;
  if AWithBegin then
    Self.UoW.BeginTransaction;
  Result := Self.UoW.SysPermissionGroupRepository.FindById(AId, ALock);
end;

function TSysPermissionGroupService.BusinessFind(AFilter: string; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionGroup>;
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;
  if AWithBegin then
    Self.UoW.BeginTransaction;
  Result := Self.UoW.SysPermissionGroupRepository.Find(AFilter, ALock);
end;

procedure TSysPermissionGroupService.BusinessInsert(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysPermissionGroupRepository.Add(AEntity);

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

procedure TSysPermissionGroupService.BusinessUpdate(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  try
    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysPermissionGroupRepository.Update(AEntity);

    if AWithCommit then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysPermissionGroupService.BusinessDelete(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  try
    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysPermissionGroupRepository.Delete(AEntity);

    if AWithCommit then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysPermissionGroupService.CreateQueryForUI(const AFilterKey: string): string;
begin
  Result := Self.UoW.SysPermissionGroupRepository.CreateQueryForUI(AFilterKey);
end;

function TSysPermissionGroupService.Find(AFilter: string; ALock: Boolean): TList<TSysPermissionGroup>;
begin
  Result := Self.Uow.SysPermissionGroupRepository.Find(AFilter, ALock);
end;

function TSysPermissionGroupService.FindById(AId: Int64; ALock: Boolean): TSysPermissionGroup;
begin
  Result := Self.Uow.SysPermissionGroupRepository.FindById(AId, ALock);
end;

procedure TSysPermissionGroupService.Add(AEntity: TSysPermissionGroup);
begin
  Self.UoW.SysPermissionGroupRepository.Add(AEntity);
end;

procedure TSysPermissionGroupService.Update(AEntity: TSysPermissionGroup);
begin
  Self.UoW.SysPermissionGroupRepository.Update(AEntity);
end;

procedure TSysPermissionGroupService.Delete(AId: Int64);
begin
  Self.UoW.SysPermissionGroupRepository.Delete(AId);
end;

end.

