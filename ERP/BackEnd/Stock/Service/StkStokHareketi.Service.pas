unit StkStokHareketi.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, StkStokHareketi.Repository, StkStokHareketi;
type
  TStkStokHareketiService = class(TCrudService<TStkStokHareketi>) private FRepo: IRepository<TStkStokHareketi>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkStokHareketi>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkStokHareketi; override;
    procedure Add(AEntity: TStkStokHareketi); override; procedure Update(AEntity: TStkStokHareketi); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkStokHareketi; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkStokHareketi>; override;
    procedure BusinessInsert(AEntity: TStkStokHareketi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkStokHareketi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkStokHareketi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TStkStokHareketiService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TStkStokHareketi, TStkStokHareketiRepository>; end;
destructor TStkStokHareketiService.Destroy; begin inherited; end;
function TStkStokHareketiService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkStokHareketi>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TStkStokHareketiService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkStokHareketi;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TStkStokHareketiService.BusinessInsert(AEntity: TStkStokHareketi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TStkStokHareketiService.BusinessUpdate(AEntity: TStkStokHareketi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TStkStokHareketiService.BusinessDelete(AEntity: TStkStokHareketi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TStkStokHareketiService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TStkStokHareketiService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkStokHareketi>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TStkStokHareketiService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkStokHareketi;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TStkStokHareketiService.Add(AEntity: TStkStokHareketi); begin FRepo.Add(AEntity); end; procedure TStkStokHareketiService.Update(AEntity: TStkStokHareketi); begin FRepo.Update(AEntity); end;
procedure TStkStokHareketiService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
