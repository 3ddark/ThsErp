unit SetStkUrunTipleri.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, SetStkUrunTipleri.Repository, SetStkUrunTipleri;
type
  TSetStkUrunTipleriService = class(TCrudService<TSetStkUrunTipleri>) private FRepo: IRepository<TSetStkUrunTipleri>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetStkUrunTipleri>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetStkUrunTipleri; override;
    procedure Add(AEntity: TSetStkUrunTipleri); override; procedure Update(AEntity: TSetStkUrunTipleri); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkUrunTipleri; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkUrunTipleri>; override;
    procedure BusinessInsert(AEntity: TSetStkUrunTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetStkUrunTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetStkUrunTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TSetStkUrunTipleriService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TSetStkUrunTipleri, TSetStkUrunTipleriRepository>; end;
destructor TSetStkUrunTipleriService.Destroy; begin inherited; end;
function TSetStkUrunTipleriService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkUrunTipleri>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TSetStkUrunTipleriService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkUrunTipleri;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TSetStkUrunTipleriService.BusinessInsert(AEntity: TSetStkUrunTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TSetStkUrunTipleriService.BusinessUpdate(AEntity: TSetStkUrunTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TSetStkUrunTipleriService.BusinessDelete(AEntity: TSetStkUrunTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TSetStkUrunTipleriService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TSetStkUrunTipleriService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetStkUrunTipleri>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TSetStkUrunTipleriService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetStkUrunTipleri;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TSetStkUrunTipleriService.Add(AEntity: TSetStkUrunTipleri); begin FRepo.Add(AEntity); end; procedure TSetStkUrunTipleriService.Update(AEntity: TSetStkUrunTipleri); begin FRepo.Update(AEntity); end;
procedure TSetStkUrunTipleriService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
