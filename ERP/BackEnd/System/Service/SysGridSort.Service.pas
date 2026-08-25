unit SysGridSort.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysGridSort.Repository, SysGridSort;

type
  TSysGridSortService = class(TCrudService<TSysGridSort>)
  private
    FRepo: IRepository<TSysGridSort>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysGridSort; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysGridSort>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysGridSort; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysGridSort; override;

    procedure Add(AEntity: TSysGridSort); override;
    procedure Update(AEntity: TSysGridSort); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridSort; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridSort>; override;
    procedure BusinessInsert(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysGridSortService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysGridSort, TSysGridSortRepository>;
end;

destructor TSysGridSortService.Destroy;
begin
  inherited;
end;

function TSysGridSortService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridSort>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSysGridSortService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridSort;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock);
end;

procedure TSysGridSortService.BusinessInsert(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
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

procedure TSysGridSortService.BusinessUpdate(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
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

procedure TSysGridSortService.BusinessDelete(AEntity: TSysGridSort; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);
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

function TSysGridSortService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysGridSortService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSysGridSort>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysGridSortService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysGridSort;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysGridSortService.FindOne(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TSysGridSort;
begin

end;

procedure TSysGridSortService.Add(AEntity: TSysGridSort);
begin
  FRepo.Add(AEntity);
end;

procedure TSysGridSortService.Update(AEntity: TSysGridSort);
begin
  FRepo.Update(AEntity);
end;

procedure TSysGridSortService.ValidateBusinessRules(AEntity: TSysGridSort;
  AOperation: TCrudOperation);
begin
  inherited;

end;

procedure TSysGridSortService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
