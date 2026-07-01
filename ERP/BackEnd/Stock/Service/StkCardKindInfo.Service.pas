unit StkCardKindInfo.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, StkCardKindInfo.Repository, StkCardKindInfo;
type
  TStkCardKindInfoService = class(TCrudService<TStkCardKindInfo>) private FRepo: IRepository<TStkCardKindInfo>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TStkCardKindInfo>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TStkCardKindInfo; override;
    procedure Add(AEntity: TStkCardKindInfo); override; procedure Update(AEntity: TStkCardKindInfo); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkCardKindInfo; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkCardKindInfo>; override;
    procedure BusinessInsert(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TStkCardKindInfoService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TStkCardKindInfo, TStkCardKindInfoRepository>; end;
destructor TStkCardKindInfoService.Destroy; begin inherited; end;
function TStkCardKindInfoService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TStkCardKindInfo>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TStkCardKindInfoService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TStkCardKindInfo;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TStkCardKindInfoService.BusinessInsert(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TStkCardKindInfoService.BusinessUpdate(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TStkCardKindInfoService.BusinessDelete(AEntity: TStkCardKindInfo; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TStkCardKindInfoService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TStkCardKindInfoService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TStkCardKindInfo>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TStkCardKindInfoService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TStkCardKindInfo;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TStkCardKindInfoService.Add(AEntity: TStkCardKindInfo); begin FRepo.Add(AEntity); end; procedure TStkCardKindInfoService.Update(AEntity: TStkCardKindInfo); begin FRepo.Update(AEntity); end;
procedure TStkCardKindInfoService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
