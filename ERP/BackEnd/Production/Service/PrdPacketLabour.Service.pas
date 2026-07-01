unit PrdPacketLabour.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  PrdPacketLabour.Repository, PrdPacketLabour;

type
  TPrdPacketLabourService = class(TCrudService<TPrdPacketLabour>)
  private
    FRepo: IRepository<TPrdPacketLabour>;
  public
    constructor Create; destructor Destroy; override;
    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdPacketLabour>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdPacketLabour; override;
    procedure Add(AEntity: TPrdPacketLabour); override;
    procedure Update(AEntity: TPrdPacketLabour); override;
    procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketLabour; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketLabour>; override;
    procedure BusinessInsert(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TPrdPacketLabourService.Create;
begin
  inherited; FRepo := Self.UoW.GetRepository<TPrdPacketLabour, TPrdPacketLabourRepository>;
end;

destructor TPrdPacketLabourService.Destroy; begin inherited; end;

function TPrdPacketLabourService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketLabour>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdPacketLabourService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketLabour;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TPrdPacketLabourService.BusinessInsert(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Add(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise; end; end;
end;

procedure TPrdPacketLabourService.BusinessUpdate(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Update(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end;
end;

procedure TPrdPacketLabourService.BusinessDelete(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Delete(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end;
end;

function TPrdPacketLabourService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TPrdPacketLabourService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TPrdPacketLabour>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TPrdPacketLabourService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdPacketLabour;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TPrdPacketLabourService.Add(AEntity: TPrdPacketLabour); begin FRepo.Add(AEntity); end;
procedure TPrdPacketLabourService.Update(AEntity: TPrdPacketLabour); begin FRepo.Update(AEntity); end;
procedure TPrdPacketLabourService.Delete(AId: Int64); begin FRepo.Delete(AId); end;

end.
