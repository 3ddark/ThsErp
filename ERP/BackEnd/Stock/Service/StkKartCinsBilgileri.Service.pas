unit StkKartCinsBilgileri.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, StkKartCinsBilgileri.Repository, StkKartCinsBilgileri;
type
  TStkKartCinsBilgileriService = class(TCrudService<TStkKartCinsBilgileri>) private FRepo: IRepository<TStkKartCinsBilgileri>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkKartCinsBilgileri>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkKartCinsBilgileri; override;
    procedure Add(AEntity: TStkKartCinsBilgileri); override; procedure Update(AEntity: TStkKartCinsBilgileri); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkKartCinsBilgileri; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkKartCinsBilgileri>; override;
    procedure BusinessInsert(AEntity: TStkKartCinsBilgileri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkKartCinsBilgileri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkKartCinsBilgileri; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TStkKartCinsBilgileriService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TStkKartCinsBilgileri, TStkKartCinsBilgileriRepository>; end;
destructor TStkKartCinsBilgileriService.Destroy; begin inherited; end;
function TStkKartCinsBilgileriService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkKartCinsBilgileri>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TStkKartCinsBilgileriService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkKartCinsBilgileri;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TStkKartCinsBilgileriService.BusinessInsert(AEntity: TStkKartCinsBilgileri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TStkKartCinsBilgileriService.BusinessUpdate(AEntity: TStkKartCinsBilgileri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TStkKartCinsBilgileriService.BusinessDelete(AEntity: TStkKartCinsBilgileri; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TStkKartCinsBilgileriService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TStkKartCinsBilgileriService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkKartCinsBilgileri>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TStkKartCinsBilgileriService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkKartCinsBilgileri;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TStkKartCinsBilgileriService.Add(AEntity: TStkKartCinsBilgileri); begin FRepo.Add(AEntity); end; procedure TStkKartCinsBilgileriService.Update(AEntity: TStkKartCinsBilgileri); begin FRepo.Update(AEntity); end;
procedure TStkKartCinsBilgileriService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
