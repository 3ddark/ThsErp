unit PrdBomPacketLabour.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrdBomPacketLabour.Repository, PrdBomPacketLabour;

type
  TPrdBomPacketLabourService = class(TCrudService<TPrdBomPacketLabour>)
  private FRepo: IRepository<TPrdBomPacketLabour>;
  public
    constructor Create; destructor Destroy; override;
    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdBomPacketLabour>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdBomPacketLabour; override;
    procedure Add(AEntity: TPrdBomPacketLabour); override; procedure Update(AEntity: TPrdBomPacketLabour); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomPacketLabour; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomPacketLabour>; override;
    procedure BusinessInsert(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrdBomPacketLabourService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TPrdBomPacketLabour, TPrdBomPacketLabourRepository>; end;
destructor TPrdBomPacketLabourService.Destroy; begin inherited; end;

function TPrdBomPacketLabourService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomPacketLabour>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;

function TPrdBomPacketLabourService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomPacketLabour;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;

procedure TPrdBomPacketLabourService.BusinessInsert(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise; end; end; end;

procedure TPrdBomPacketLabourService.BusinessUpdate(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;

procedure TPrdBomPacketLabourService.BusinessDelete(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;

function TPrdBomPacketLabourService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TPrdBomPacketLabourService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrdBomPacketLabour>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TPrdBomPacketLabourService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdBomPacketLabour;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TPrdBomPacketLabourService.Add(AEntity: TPrdBomPacketLabour); begin FRepo.Add(AEntity); end;
procedure TPrdBomPacketLabourService.Update(AEntity: TPrdBomPacketLabour); begin FRepo.Update(AEntity); end;
procedure TPrdBomPacketLabourService.Delete(AId: Int64); begin FRepo.Delete(AId); end;

end.
