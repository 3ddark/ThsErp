unit SetChFirmaTuru.Service;
interface
uses SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client, Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes, SetChFirmaTuru.Repository, SetChFirmaTuru;
type
  TSetChFirmaTuruService = class(TCrudService<TSetChFirmaTuru>) private FRepo: IRepository<TSetChFirmaTuru>;
  public constructor Create; destructor Destroy; override; function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetChFirmaTuru>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetChFirmaTuru; override;
    procedure Add(AEntity: TSetChFirmaTuru); override; procedure Update(AEntity: TSetChFirmaTuru); override; procedure Delete(AId: Int64); override;
    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetChFirmaTuru; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetChFirmaTuru>; override;
    procedure BusinessInsert(AEntity: TSetChFirmaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetChFirmaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetChFirmaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;
implementation
constructor TSetChFirmaTuruService.Create; begin inherited; FRepo := Self.UoW.GetRepository<TSetChFirmaTuru, TSetChFirmaTuruRepository>; end;
destructor TSetChFirmaTuruService.Destroy; begin inherited; end;
function TSetChFirmaTuruService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetChFirmaTuru>;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.Find(AFilter, ALock); end;
function TSetChFirmaTuruService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetChFirmaTuru;
begin if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; Result := FRepo.FindById(AId, ALock, [ioIncludeAll]); end;
procedure TSetChFirmaTuruService.BusinessInsert(AEntity: TSetChFirmaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Add(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Uow.InTransaction then Self.UoW.Rollback; raise end; end; end;
procedure TSetChFirmaTuruService.BusinessUpdate(AEntity: TSetChFirmaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Update(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
procedure TSetChFirmaTuruService.BusinessDelete(AEntity: TSetChFirmaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin try if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl); if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction; FRepo.Delete(AEntity); if AWithCommit and Uow.InTransaction then Self.UoW.Commit; except on E: Exception do begin if Self.UoW.InTransaction then Self.UoW.Rollback; raise; end; end; end;
function TSetChFirmaTuruService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin Result := FRepo.FindAllGridQuery(AFilter); end;
function TSetChFirmaTuruService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetChFirmaTuru>;
begin if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock); end;
function TSetChFirmaTuruService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetChFirmaTuru;
begin if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock); end;
procedure TSetChFirmaTuruService.Add(AEntity: TSetChFirmaTuru); begin FRepo.Add(AEntity); end; procedure TSetChFirmaTuruService.Update(AEntity: TSetChFirmaTuru); begin FRepo.Update(AEntity); end;
procedure TSetChFirmaTuruService.Delete(AId: Int64); begin FRepo.Delete(AId); end;
end.
