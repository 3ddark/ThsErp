unit SysCountry.Service;

interface

uses
  SysUtils, Classes, Contnrs, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SysCountry.Repository, SysCountry;

type
  TSysCountryService = class(TCrudService<TSysCountry>)
  private
    FRepo: IRepository<TSysCountry>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysCountry>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysCountry; override;
    procedure Add(AEntity: TSysCountry); override;
    procedure Update(AEntity: TSysCountry); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCountry; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCountry>; override;
    procedure BusinessInsert(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysCountryService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysCountry, TSysCountryRepository>;
end;

destructor TSysCountryService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TSysCountryService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysCountry>;
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

function TSysCountryService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysCountry;
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

procedure TSysCountryService.BusinessInsert(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysCountryService.BusinessUpdate(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysCountryService.BusinessDelete(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysCountryService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysCountryService.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysCountry>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysCountryService.FindById(AId: Int64; ALock: Boolean): TSysCountry;
begin
  Result := FRepo.FindById(AId, ALock);
end;

procedure TSysCountryService.Add(AEntity: TSysCountry);
begin
  FRepo.Add(AEntity);
end;

procedure TSysCountryService.Update(AEntity: TSysCountry);
begin
  FRepo.Update(AEntity);
end;

procedure TSysCountryService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.

