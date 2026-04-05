unit SysCity.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SysCity.Repository, SysCity;

type
  TSysCityService = class(TCrudService<TSysCity>)
  private
    FRepo: IRepository<TSysCity>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysCity>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysCity; override;
    procedure Add(AEntity: TSysCity); override;
    procedure Update(AEntity: TSysCity); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCity; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCity>; override;
    procedure BusinessInsert(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysCityService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysCity, TSysCityRepository>;
end;

destructor TSysCityService.Destroy;
begin
  inherited;
end;

function TSysCityService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCity>;
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

function TSysCityService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCity;
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

procedure TSysCityService.BusinessInsert(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysCityService.BusinessUpdate(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysCityService.BusinessDelete(AEntity: TSysCity; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysCityService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
//var LTableName: string;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
//  Result := FRepo.FindAllGridQuery(AFilter);
//  LTableName := GetTableName(T);
//  Result := TFDQuery.Create(nil);
//  Result.Connection := Self.UoW.Connection;
//  Result.SQL.Text := 'SELECT * FROM vw_sys_cities WHERE 1=1 ';
end;

function TSysCityService.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysCity>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysCityService.FindById(AId: Int64; ALock: Boolean): TSysCity;
begin
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSysCityService.Add(AEntity: TSysCity);
begin
  FRepo.Add(AEntity);
end;

procedure TSysCityService.Update(AEntity: TSysCity);
begin
  FRepo.Update(AEntity);
end;

procedure TSysCityService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.

