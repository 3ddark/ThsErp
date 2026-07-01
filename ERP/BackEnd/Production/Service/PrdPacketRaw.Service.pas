unit PrdPacketRaw.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrdPacketRaw.Repository, PrdPacketRaw;

type
  TPrdPacketRawService = class(TCrudService<TPrdPacketRaw>)
  private FRepo: IRepository<TPrdPacketRaw>;
  public
    constructor Create; destructor Destroy; override;
    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdPacketRaw>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdPacketRaw; override;
    procedure Add(AEntity: TPrdPacketRaw); override; procedure Update(AEntity: TPrdPacketRaw); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketRaw; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketRaw>; override;
    procedure BusinessInsert(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrdPacketRawService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TPrdPacketRaw, TPrdPacketRawRepository>; end;
destructor TPrdPacketRawService.Destroy; begin inherited; end;

function TPrdPacketRawService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketRaw>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;

function TPrdPacketRawService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketRaw;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;

procedure TPrdPacketRawService.BusinessInsert(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise; end; end; end;

procedure TPrdPacketRawService.BusinessUpdate(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;

procedure TPrdPacketRawService.BusinessDelete(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;

function TPrdPacketRawService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TPrdPacketRawService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrdPacketRaw>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TPrdPacketRawService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdPacketRaw;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TPrdPacketRawService.Add(AEntity: TPrdPacketRaw); begin FRepo.Add(AEntity); end;
procedure TPrdPacketRawService.Update(AEntity: TPrdPacketRaw); begin FRepo.Update(AEntity); end;
procedure TPrdPacketRawService.Delete(AId: Int64); begin FRepo.Delete(AId); end;

end.
