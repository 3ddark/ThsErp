unit SetStkStokTipi.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, SetStkStokTipi.Repository, SetStkStokTipi;
type
  TSetStkStokTipiService = class(TCrudService<TSetStkStokTipi>) private FRepo: IRepository<TSetStkStokTipi>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetStkStokTipi>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetStkStokTipi; override;
    procedure Add(AEntity: TSetStkStokTipi); override; procedure Update(AEntity: TSetStkStokTipi); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkStokTipi; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkStokTipi>; override;
    procedure BusinessInsert(AEntity: TSetStkStokTipi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetStkStokTipi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetStkStokTipi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TSetStkStokTipiService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TSetStkStokTipi, TSetStkStokTipiRepository>; end;
destructor TSetStkStokTipiService.Destroy; begin inherited; end;
function TSetStkStokTipiService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkStokTipi>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TSetStkStokTipiService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkStokTipi;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TSetStkStokTipiService.BusinessInsert(AEntity: TSetStkStokTipi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TSetStkStokTipiService.BusinessUpdate(AEntity: TSetStkStokTipi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TSetStkStokTipiService.BusinessDelete(AEntity: TSetStkStokTipi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TSetStkStokTipiService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TSetStkStokTipiService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetStkStokTipi>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TSetStkStokTipiService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetStkStokTipi;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TSetStkStokTipiService.Add(AEntity: TSetStkStokTipi); begin FRepo.Add(AEntity); end; procedure TSetStkStokTipiService.Update(AEntity: TSetStkStokTipi); begin FRepo.Update(AEntity); end;
procedure TSetStkStokTipiService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
