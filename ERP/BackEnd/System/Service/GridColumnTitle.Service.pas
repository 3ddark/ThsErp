unit GridColumnTitle.Service;

interface

uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
     Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
     GridColumnTitle.Repository, GridColumnTitle;

type
  TGridColumnTitleService = class(TCrudService<TGridColumnTitle>)
  private
    FRepo: IRepository<TGridColumnTitle>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TGridColumnTitle>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TGridColumnTitle; override;
    procedure Add(AEntity: TGridColumnTitle); override;
    procedure Update(AEntity: TGridColumnTitle); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TGridColumnTitle; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TGridColumnTitle>; override;
    procedure BusinessInsert(AEntity: TGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TGridColumnTitleService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TGridColumnTitle, TGridColumnTitleRepository>;
end;

destructor TGridColumnTitleService.Destroy;
begin
  inherited;
end;

function TGridColumnTitleService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TGridColumnTitle>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TGridColumnTitleService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TGridColumnTitle;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TGridColumnTitleService.BusinessInsert(AEntity: TGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TGridColumnTitleService.BusinessUpdate(AEntity: TGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TGridColumnTitleService.BusinessDelete(AEntity: TGridColumnTitle; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TGridColumnTitleService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TGridColumnTitleService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TGridColumnTitle>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else Result := FRepo.Find(AFilter, ALock);
end;

function TGridColumnTitleService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TGridColumnTitle;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else Result := FRepo.FindById(AId, ALock);
end;

procedure TGridColumnTitleService.Add(AEntity: TGridColumnTitle);
begin
  FRepo.Add(AEntity);
end;

procedure TGridColumnTitleService.Update(AEntity: TGridColumnTitle);
begin
  FRepo.Update(AEntity);
end;

procedure TGridColumnTitleService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
