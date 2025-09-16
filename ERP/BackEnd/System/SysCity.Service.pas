unit SysCity.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  BaseEntity, BaseService, UnitOfWork, SysCity.Repository, SysCity;

type
  TSysCityService = class(TBaseService<TSysCity>)
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(const AFilterKey: string): string; override;
    function Find(AFilter: string; ALock: Boolean): TList<TSysCity>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysCity; override;
    procedure Add(AEntity: TSysCity); override;
    procedure Update(AEntity: TSysCity); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCity; override;
    function BusinessFind(AFilter: string; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCity>; override;
    procedure BusinessInsert(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
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

function TSysCityService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCity;
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;
  if AWithBegin then
    Self.UoW.BeginTransaction;
  Result := Self.UoW.SysCityRepository.FindById(AId, ALock);
end;

function TSysCityService.BusinessFind(AFilter: string; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCity>;
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;
  if AWithBegin then
    Self.UoW.BeginTransaction;
  Result := Self.UoW.SysCityRepository.Find(AFilter, ALock);
end;

procedure TSysCityService.BusinessInsert(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysCityRepository.Add(AEntity);

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

procedure TSysCityService.BusinessUpdate(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  try
    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysCityRepository.Update(AEntity);

    if AWithCommit then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysCityService.BusinessDelete(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  try
    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysCityRepository.Delete(AEntity);

    if AWithCommit then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysCityService.CreateQueryForUI(const AFilterKey: string): string;
begin
  Result := Self.UoW.SysCityRepository.CreateQueryForUI(AFilterKey);
end;

function TSysCityService.Find(AFilter: string; ALock: Boolean): TList<TSysCity>;
begin
  Result := Self.Uow.SysCityRepository.Find(AFilter, ALock);
end;

function TSysCityService.FindById(AId: Int64; ALock: Boolean): TSysCity;
begin
  Result := Self.Uow.SysCityRepository.FindById(AId, ALock);
end;

procedure TSysCityService.Add(AEntity: TSysCity);
begin
  Self.UoW.SysCityRepository.Add(AEntity);
end;

procedure TSysCityService.Update(AEntity: TSysCity);
begin
  Self.UoW.SysCityRepository.Update(AEntity);
end;

procedure TSysCityService.Delete(AId: Int64);
begin
  Self.UoW.SysCityRepository.Delete(AId);
end;

end.

