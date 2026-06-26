unit PrsPerson.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrsPerson.Repository, PrsPerson;

type
  TPrsPersonService = class(TCrudService<TPrsPerson>)
  private
    FRepo: IRepository<TPrsPerson>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrsPerson>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrsPerson; override;
    procedure Add(AEntity: TPrsPerson); override;
    procedure Update(AEntity: TPrsPerson); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrsPerson; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrsPerson>; override;
    procedure BusinessInsert(AEntity: TPrsPerson; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrsPerson; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrsPerson; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrsPersonService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrsPerson, TPrsPersonRepository>;
end;

destructor TPrsPersonService.Destroy;
begin
  inherited;
end;

function TPrsPersonService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrsPerson>;
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

function TPrsPersonService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrsPerson;
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

procedure TPrsPersonService.BusinessInsert(AEntity: TPrsPerson; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrsPersonService.BusinessUpdate(AEntity: TPrsPerson; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrsPersonService.BusinessDelete(AEntity: TPrsPerson; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrsPersonService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrsPersonService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrsPerson>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TPrsPersonService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrsPerson;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TPrsPersonService.Add(AEntity: TPrsPerson);
begin
  FRepo.Add(AEntity);
end;

procedure TPrsPersonService.Update(AEntity: TPrsPerson);
begin
  FRepo.Update(AEntity);
end;

procedure TPrsPersonService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
