unit PrsDriverLicence.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrsDriverLicence.Repository, PrsDriverLicence;

type
  TPrsDriverLicenceService = class(TCrudService<TPrsDriverLicence>)
  private
    FRepo: IRepository<TPrsDriverLicence>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrsDriverLicence>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrsDriverLicence; override;
    procedure Add(AEntity: TPrsDriverLicence); override;
    procedure Update(AEntity: TPrsDriverLicence); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrsDriverLicence; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrsDriverLicence>; override;
    procedure BusinessInsert(AEntity: TPrsDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrsDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrsDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrsDriverLicenceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrsDriverLicence, TPrsDriverLicenceRepository>;
end;

destructor TPrsDriverLicenceService.Destroy;
begin
  inherited;
end;

function TPrsDriverLicenceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrsDriverLicence>;
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

function TPrsDriverLicenceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrsDriverLicence;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TPrsDriverLicenceService.BusinessInsert(AEntity: TPrsDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrsDriverLicenceService.BusinessUpdate(AEntity: TPrsDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrsDriverLicenceService.BusinessDelete(AEntity: TPrsDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrsDriverLicenceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrsDriverLicenceService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrsDriverLicence>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TPrsDriverLicenceService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrsDriverLicence;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TPrsDriverLicenceService.Add(AEntity: TPrsDriverLicence);
begin
  FRepo.Add(AEntity);
end;

procedure TPrsDriverLicenceService.Update(AEntity: TPrsDriverLicence);
begin
  FRepo.Update(AEntity);
end;

procedure TPrsDriverLicenceService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
