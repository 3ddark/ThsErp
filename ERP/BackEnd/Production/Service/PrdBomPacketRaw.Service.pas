unit PrdBomPacketRaw.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrdBomPacketRaw.Repository, PrdBomPacketRaw;

type
  TPrdBomPacketRawService = class(TCrudService<TPrdBomPacketRaw>)
  private FRepo: IRepository<TPrdBomPacketRaw>;
  public
    constructor Create; destructor Destroy; override;
    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdBomPacketRaw>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdBomPacketRaw; override;
    procedure Add(AEntity: TPrdBomPacketRaw); override; procedure Update(AEntity: TPrdBomPacketRaw); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomPacketRaw; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomPacketRaw>; override;
    procedure BusinessInsert(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrdBomPacketRawService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TPrdBomPacketRaw, TPrdBomPacketRawRepository>; end;
destructor TPrdBomPacketRawService.Destroy; begin inherited; end;

function TPrdBomPacketRawService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomPacketRaw>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;

function TPrdBomPacketRawService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomPacketRaw;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;

procedure TPrdBomPacketRawService.BusinessInsert(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise; end; end; end;

procedure TPrdBomPacketRawService.BusinessUpdate(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;

procedure TPrdBomPacketRawService.BusinessDelete(AEntity: TPrdBomPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;

function TPrdBomPacketRawService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TPrdBomPacketRawService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrdBomPacketRaw>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TPrdBomPacketRawService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdBomPacketRaw;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TPrdBomPacketRawService.Add(AEntity: TPrdBomPacketRaw); begin FRepo.Add(AEntity); end;
procedure TPrdBomPacketRawService.Update(AEntity: TPrdBomPacketRaw); begin FRepo.Update(AEntity); end;
procedure TPrdBomPacketRawService.Delete(AId: Int64); begin FRepo.Delete(AId); end;

end.
