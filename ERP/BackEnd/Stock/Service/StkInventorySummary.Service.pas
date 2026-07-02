unit StkInventorySummary.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, StkInventorySummary.Repository, StkInventorySummary;
type
  TStkInventorySummaryService = class(TCrudService<TStkInventorySummary>) private FRepo: IRepository<TStkInventorySummary>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkInventorySummary>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkInventorySummary; override;
    procedure Add(AEntity: TStkInventorySummary); override; procedure Update(AEntity: TStkInventorySummary); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkInventorySummary; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkInventorySummary>; override;
    procedure BusinessInsert(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TStkInventorySummaryService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TStkInventorySummary, TStkInventorySummaryRepository>; end;
destructor TStkInventorySummaryService.Destroy; begin inherited; end;
function TStkInventorySummaryService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkInventorySummary>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TStkInventorySummaryService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkInventorySummary;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TStkInventorySummaryService.BusinessInsert(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TStkInventorySummaryService.BusinessUpdate(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TStkInventorySummaryService.BusinessDelete(AEntity: TStkInventorySummary; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TStkInventorySummaryService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TStkInventorySummaryService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkInventorySummary>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TStkInventorySummaryService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkInventorySummary;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TStkInventorySummaryService.Add(AEntity: TStkInventorySummary); begin FRepo.Add(AEntity); end; procedure TStkInventorySummaryService.Update(AEntity: TStkInventorySummary); begin FRepo.Update(AEntity); end;
procedure TStkInventorySummaryService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
