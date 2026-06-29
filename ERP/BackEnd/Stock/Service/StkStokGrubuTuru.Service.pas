unit StkStokGrubuTuru.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, StkStokGrubuTuru.Repository, StkStokGrubuTuru;
type
  TStkStokGrubuTuruService = class(TCrudService<TStkStokGrubuTuru>) private FRepo: IRepository<TStkStokGrubuTuru>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkStokGrubuTuru>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkStokGrubuTuru; override;
    procedure Add(AEntity: TStkStokGrubuTuru); override; procedure Update(AEntity: TStkStokGrubuTuru); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkStokGrubuTuru; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkStokGrubuTuru>; override;
    procedure BusinessInsert(AEntity: TStkStokGrubuTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkStokGrubuTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkStokGrubuTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TStkStokGrubuTuruService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TStkStokGrubuTuru, TStkStokGrubuTuruRepository>; end;
destructor TStkStokGrubuTuruService.Destroy; begin inherited; end;
function TStkStokGrubuTuruService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkStokGrubuTuru>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TStkStokGrubuTuruService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkStokGrubuTuru;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TStkStokGrubuTuruService.BusinessInsert(AEntity: TStkStokGrubuTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TStkStokGrubuTuruService.BusinessUpdate(AEntity: TStkStokGrubuTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TStkStokGrubuTuruService.BusinessDelete(AEntity: TStkStokGrubuTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TStkStokGrubuTuruService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TStkStokGrubuTuruService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkStokGrubuTuru>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TStkStokGrubuTuruService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkStokGrubuTuru;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TStkStokGrubuTuruService.Add(AEntity: TStkStokGrubuTuru); begin FRepo.Add(AEntity); end; procedure TStkStokGrubuTuruService.Update(AEntity: TStkStokGrubuTuru); begin FRepo.Update(AEntity); end;
procedure TStkStokGrubuTuruService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
