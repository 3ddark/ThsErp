unit SysUser.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork,
  SysUser.Repository, SysUser;

type
  TSysCityService = class(TCrudService<TSysUser>)
  private
    repo: IRepository<TSysUser>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysUser>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysUser; override;
    procedure Add(AEntity: TSysUser); override;
    procedure Update(AEntity: TSysUser); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysUser; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysUser>; override;
    procedure BusinessInsert(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysCityService.Create;
begin
  inherited;
end;

destructor TSysCityService.Destroy;
begin
  inherited;
end;

function TSysCityService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysUser;
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;
  if AWithBegin then
    Self.UoW.BeginTransaction;

  repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  try
    Result := repo.FindById(AId, ALock);
  finally
    (repo as TRepository<TSysUser>).Free;
  end;
end;

function TSysCityService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysUser>;
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;
  if AWithBegin then
    Self.UoW.BeginTransaction;

  repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  try
    Result := repo.Find(AFilter, ALock);
  finally
    (repo as TRepository<TSysUser>).Free;
  end;
end;

procedure TSysCityService.BusinessInsert(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
    try
      repo.Add(AEntity);
    finally
      (repo as TRepository<TSysUser>).Free;
    end;

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

procedure TSysCityService.BusinessUpdate(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  try
    if AWithBegin then
      Self.UoW.BeginTransaction;

    repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
    try
      repo.Update(AEntity);
    finally
      (repo as TRepository<TSysUser>).Free;
    end;

    if AWithCommit then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysCityService.BusinessDelete(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  try
    if AWithBegin then
      Self.UoW.BeginTransaction;

    repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
    try
      repo.Delete(AEntity);
    finally
      (repo as TRepository<TSysUser>).Free;
    end;

    if AWithCommit then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysCityService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  Result := repo.FindAllGridQuery(AFilter);
end;

function TSysCityService.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysUser>;
begin
  repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  try
    Result := repo.Find(AFilter, ALock);
  finally
    (repo as TRepository<TSysUser>).Free;
  end;
end;

function TSysCityService.FindById(AId: Int64; ALock: Boolean): TSysUser;
begin
  repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  try
    Result := repo.FindById(AId, ALock);
  finally
    (repo as TRepository<TSysUser>).Free;
  end;
end;

procedure TSysCityService.Add(AEntity: TSysUser);
begin
  repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  try
    repo.Add(AEntity);
  finally
    (repo as TRepository<TSysUser>).Free;
  end;
end;

procedure TSysCityService.Update(AEntity: TSysUser);
begin
  repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  try
    repo.Update(AEntity);
  finally
    (repo as TRepository<TSysUser>).Free;
  end;
end;

procedure TSysCityService.Delete(AId: Int64);
begin
  repo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  try
    repo.Delete(AId);
  finally
    (repo as TRepository<TSysUser>).Free;
  end;
end;

end.

