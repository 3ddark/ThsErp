unit StkKindFamily.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, StkKindFamily.Repository, StkKindFamily;
type
  TStkKindFamilyService = class(TCrudService<TStkKindFamily>) private FRepo: IRepository<TStkKindFamily>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkKindFamily>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkKindFamily; override;
    procedure Add(AEntity: TStkKindFamily); override; procedure Update(AEntity: TStkKindFamily); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkKindFamily; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkKindFamily>; override;
    procedure BusinessInsert(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TStkKindFamilyService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TStkKindFamily, TStkKindFamilyRepository>; end;
destructor TStkKindFamilyService.Destroy; begin inherited; end;
function TStkKindFamilyService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkKindFamily>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TStkKindFamilyService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkKindFamily;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TStkKindFamilyService.BusinessInsert(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TStkKindFamilyService.BusinessUpdate(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TStkKindFamilyService.BusinessDelete(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TStkKindFamilyService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TStkKindFamilyService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkKindFamily>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TStkKindFamilyService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkKindFamily;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TStkKindFamilyService.Add(AEntity: TStkKindFamily); begin FRepo.Add(AEntity); end; procedure TStkKindFamilyService.Update(AEntity: TStkKindFamily); begin FRepo.Update(AEntity); end;
procedure TStkKindFamilyService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
