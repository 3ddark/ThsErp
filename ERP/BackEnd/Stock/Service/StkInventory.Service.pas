unit StkInventory.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, StkInventory.Repository, StkInventory;
type
  TStkInventoryService = class(TCrudService<TStkInventory>) private FRepo: IRepository<TStkInventory>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkInventory>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkInventory; override;
    procedure Add(AEntity: TStkInventory); override; procedure Update(AEntity: TStkInventory); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkInventory; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkInventory>; override;
    procedure BusinessInsert(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TStkInventoryService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TStkInventory, TStkInventoryRepository>; end;
destructor TStkInventoryService.Destroy; begin inherited; end;
function TStkInventoryService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkInventory>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TStkInventoryService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkInventory;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TStkInventoryService.BusinessInsert(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TStkInventoryService.BusinessUpdate(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TStkInventoryService.BusinessDelete(AEntity: TStkInventory; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TStkInventoryService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TStkInventoryService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkInventory>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TStkInventoryService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkInventory;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TStkInventoryService.Add(AEntity: TStkInventory); begin FRepo.Add(AEntity); end; procedure TStkInventoryService.Update(AEntity: TStkInventory); begin FRepo.Update(AEntity); end;
procedure TStkInventoryService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
