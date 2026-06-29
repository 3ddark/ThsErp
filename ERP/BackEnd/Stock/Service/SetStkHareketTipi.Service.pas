unit SetStkHareketTipi.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetStkHareketTipi.Repository, SetStkHareketTipi;

type
  TSetStkHareketTipiService = class(TCrudService<TSetStkHareketTipi>)
  private FRepo: IRepository<TSetStkHareketTipi>;
  public constructor Create; destructor Destroy; override;
    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetStkHareketTipi>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetStkHareketTipi; override;
    procedure Add(AEntity: TSetStkHareketTipi); override; procedure Update(AEntity: TSetStkHareketTipi); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkHareketTipi; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkHareketTipi>; override;
    procedure BusinessInsert(AEntity: TSetStkHareketTipi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetStkHareketTipi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetStkHareketTipi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation
constructor TSetStkHareketTipiService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TSetStkHareketTipi, TSetStkHareketTipiRepository>; end;
destructor TSetStkHareketTipiService.Destroy; begin inherited; end;
function TSetStkHareketTipiService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkHareketTipi>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TSetStkHareketTipiService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkHareketTipi;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TSetStkHareketTipiService.BusinessInsert(AEntity: TSetStkHareketTipi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TSetStkHareketTipiService.BusinessUpdate(AEntity: TSetStkHareketTipi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TSetStkHareketTipiService.BusinessDelete(AEntity: TSetStkHareketTipi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TSetStkHareketTipiService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TSetStkHareketTipiService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetStkHareketTipi>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TSetStkHareketTipiService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetStkHareketTipi;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TSetStkHareketTipiService.Add(AEntity: TSetStkHareketTipi); begin FRepo.Add(AEntity); end;
procedure TSetStkHareketTipiService.Update(AEntity: TSetStkHareketTipi); begin FRepo.Update(AEntity); end;
procedure TSetStkHareketTipiService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
