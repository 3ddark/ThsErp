unit SysLanguage.Service;

interface

uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
     Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
     SysLanguage.Repository, SysLanguage;

type
  TSysLanguageService = class(TCrudService<TSysLanguage>)
  private
    FRepo: IRepository<TSysLanguage>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysLanguage>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysLanguage; override;
    procedure Add(AEntity: TSysLanguage); override;
    procedure Update(AEntity: TSysLanguage); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysLanguage; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysLanguage>; override;
    procedure BusinessInsert(AEntity: TSysLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysLanguageService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysLanguage, TSysLanguageRepository>;
end;

destructor TSysLanguageService.Destroy;
begin
  inherited;
end;

function TSysLanguageService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysLanguage>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysLanguageService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysLanguage;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSysLanguageService.BusinessInsert(AEntity: TSysLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysLanguageService.BusinessUpdate(AEntity: TSysLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysLanguageService.BusinessDelete(AEntity: TSysLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysLanguageService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysLanguageService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysLanguage>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else Result := FRepo.Find(AFilter, ALock);
end;

function TSysLanguageService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysLanguage;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else Result := FRepo.FindById(AId, ALock);
end;

procedure TSysLanguageService.Add(AEntity: TSysLanguage);
begin
  FRepo.Add(AEntity);
end;

procedure TSysLanguageService.Update(AEntity: TSysLanguage);
begin
  FRepo.Update(AEntity);
end;

procedure TSysLanguageService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
