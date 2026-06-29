unit SetChFirmaTipleri.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, SetChFirmaTipleri.Repository, SetChFirmaTipleri;
type
  TSetChFirmaTipleriService = class(TCrudService<TSetChFirmaTipleri>) private FRepo: IRepository<TSetChFirmaTipleri>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetChFirmaTipleri>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetChFirmaTipleri; override;
    procedure Add(AEntity: TSetChFirmaTipleri); override; procedure Update(AEntity: TSetChFirmaTipleri); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetChFirmaTipleri; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetChFirmaTipleri>; override;
    procedure BusinessInsert(AEntity: TSetChFirmaTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetChFirmaTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetChFirmaTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TSetChFirmaTipleriService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TSetChFirmaTipleri, TSetChFirmaTipleriRepository>; end;
destructor TSetChFirmaTipleriService.Destroy; begin inherited; end;
function TSetChFirmaTipleriService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetChFirmaTipleri>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TSetChFirmaTipleriService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetChFirmaTipleri;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TSetChFirmaTipleriService.BusinessInsert(AEntity: TSetChFirmaTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TSetChFirmaTipleriService.BusinessUpdate(AEntity: TSetChFirmaTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TSetChFirmaTipleriService.BusinessDelete(AEntity: TSetChFirmaTipleri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TSetChFirmaTipleriService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TSetChFirmaTipleriService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetChFirmaTipleri>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TSetChFirmaTipleriService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetChFirmaTipleri;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TSetChFirmaTipleriService.Add(AEntity: TSetChFirmaTipleri); begin FRepo.Add(AEntity); end; procedure TSetChFirmaTipleriService.Update(AEntity: TSetChFirmaTipleri); begin FRepo.Update(AEntity); end;
procedure TSetChFirmaTipleriService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
