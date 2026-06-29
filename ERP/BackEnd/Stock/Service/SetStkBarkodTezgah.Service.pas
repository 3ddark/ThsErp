unit SetStkBarkodTezgah.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetStkBarkodTezgah.Repository, SetStkBarkodTezgah;

type
  TSetStkBarkodTezgahService = class(TCrudService<TSetStkBarkodTezgah>)
  private
    FRepo: IRepository<TSetStkBarkodTezgah>;
  public
    constructor Create; destructor Destroy; override;
    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetStkBarkodTezgah>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetStkBarkodTezgah; override;
    procedure Add(AEntity: TSetStkBarkodTezgah); override;
    procedure Update(AEntity: TSetStkBarkodTezgah); override;
    procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkBarkodTezgah; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkBarkodTezgah>; override;
    procedure BusinessInsert(AEntity: TSetStkBarkodTezgah; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetStkBarkodTezgah; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetStkBarkodTezgah; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetStkBarkodTezgahService.Create;
begin inherited; FRepo := Self.UoW.GetRepository<TSetStkBarkodTezgah, TSetStkBarkodTezgahRepository>; end;
destructor TSetStkBarkodTezgahService.Destroy; begin inherited; end;

function TSetStkBarkodTezgahService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkBarkodTezgah>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSetStkBarkodTezgahService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkBarkodTezgah;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetStkBarkodTezgahService.BusinessInsert(AEntity: TSetStkBarkodTezgah; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;

procedure TSetStkBarkodTezgahService.BusinessUpdate(AEntity: TSetStkBarkodTezgah; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;

procedure TSetStkBarkodTezgahService.BusinessDelete(AEntity: TSetStkBarkodTezgah; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;

function TSetStkBarkodTezgahService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;

function TSetStkBarkodTezgahService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetStkBarkodTezgah>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;

function TSetStkBarkodTezgahService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetStkBarkodTezgah;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;

procedure TSetStkBarkodTezgahService.Add(AEntity: TSetStkBarkodTezgah); begin FRepo.Add(AEntity); end;
procedure TSetStkBarkodTezgahService.Update(AEntity: TSetStkBarkodTezgah); begin FRepo.Update(AEntity); end;
procedure TSetStkBarkodTezgahService.Delete(AId: Int64); begin FRepo.Delete(AId); end;

end.
