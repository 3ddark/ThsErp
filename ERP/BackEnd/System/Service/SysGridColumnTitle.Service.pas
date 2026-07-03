unit SysGridColumnTitle.Service;

interface

uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
     Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
     SysGridColumnTitle.Repository, SysGridColumnTitle;

type
  TSysGridColumnTitleService = class(TCrudService<TSysGridColumnTitle>)
  private
    FRepo: IRepository<TSysGridColumnTitle>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysGridColumnTitle>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysGridColumnTitle; override;
    procedure Add(AEntity: TSysGridColumnTitle); override;
    procedure Update(AEntity: TSysGridColumnTitle); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridColumnTitle; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridColumnTitle>; override;
    procedure BusinessInsert(AEntity: TSysGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysGridColumnTitleService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysGridColumnTitle, TSysGridColumnTitleRepository>;
end;

destructor TSysGridColumnTitleService.Destroy;
begin
  inherited;
end;

function TSysGridColumnTitleService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridColumnTitle>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysGridColumnTitleService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridColumnTitle;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSysGridColumnTitleService.BusinessInsert(AEntity: TSysGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Add(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin if Uow.InTransaction then Self.UoW.Rollback; raise; end;
  end;
end;

procedure TSysGridColumnTitleService.BusinessUpdate(AEntity: TSysGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Update(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end;
  end;
end;

procedure TSysGridColumnTitleService.BusinessDelete(AEntity: TSysGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Delete(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end;
  end;
end;

function TSysGridColumnTitleService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysGridColumnTitleService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysGridColumnTitle>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else Result := FRepo.Find(AFilter, ALock);
end;

function TSysGridColumnTitleService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysGridColumnTitle;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else Result := FRepo.FindById(AId, ALock);
end;

procedure TSysGridColumnTitleService.Add(AEntity: TSysGridColumnTitle);
begin
  FRepo.Add(AEntity);
end;

procedure TSysGridColumnTitleService.Update(AEntity: TSysGridColumnTitle);
begin
  FRepo.Update(AEntity);
end;

procedure TSysGridColumnTitleService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
