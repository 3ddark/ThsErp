unit SetAccOwnershipType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetAccOwnershipType.Repository, SetAccOwnershipType;

type
  TSetAccOwnershipTypeService = class(TCrudService<TSetAccOwnershipType>)
  private
    FRepo: IRepository<TSetAccOwnershipType>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetAccOwnershipType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetAccOwnershipType; override;
    procedure Add(AEntity: TSetAccOwnershipType); override;
    procedure Update(AEntity: TSetAccOwnershipType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetAccOwnershipType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetAccOwnershipType>; override;
    procedure BusinessInsert(AEntity: TSetAccOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetAccOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetAccOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetAccOwnershipTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetAccOwnershipType, TSetAccOwnershipTypeRepository>;
end;

destructor TSetAccOwnershipTypeService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TSetAccOwnershipTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetAccOwnershipType>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetAccOwnershipTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetAccOwnershipType;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetAccOwnershipTypeService.BusinessInsert(AEntity: TSetAccOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);

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

procedure TSetAccOwnershipTypeService.BusinessUpdate(AEntity: TSetAccOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);

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

procedure TSetAccOwnershipTypeService.BusinessDelete(AEntity: TSetAccOwnershipType; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);

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

function TSetAccOwnershipTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetAccOwnershipTypeService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetAccOwnershipType>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetAccOwnershipTypeService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetAccOwnershipType;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetAccOwnershipTypeService.Add(AEntity: TSetAccOwnershipType);
begin
  FRepo.Add(AEntity);
end;

procedure TSetAccOwnershipTypeService.Update(AEntity: TSetAccOwnershipType);
begin
  FRepo.Update(AEntity);
end;

procedure TSetAccOwnershipTypeService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
