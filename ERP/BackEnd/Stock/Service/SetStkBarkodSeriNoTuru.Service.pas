unit SetStkBarkodSeriNoTuru.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetStkBarkodSeriNoTuru.Repository, SetStkBarkodSeriNoTuru;

type
  TSetStkBarkodSeriNoTuruService = class(TCrudService<TSetStkBarkodSeriNoTuru>)
  private
    FRepo: IRepository<TSetStkBarkodSeriNoTuru>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetStkBarkodSeriNoTuru>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetStkBarkodSeriNoTuru; override;
    procedure Add(AEntity: TSetStkBarkodSeriNoTuru); override;
    procedure Update(AEntity: TSetStkBarkodSeriNoTuru); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkBarkodSeriNoTuru; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkBarkodSeriNoTuru>; override;
    procedure BusinessInsert(AEntity: TSetStkBarkodSeriNoTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetStkBarkodSeriNoTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetStkBarkodSeriNoTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetStkBarkodSeriNoTuruService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetStkBarkodSeriNoTuru, TSetStkBarkodSeriNoTuruRepository>;
end;

destructor TSetStkBarkodSeriNoTuruService.Destroy;
begin
  inherited;
end;

function TSetStkBarkodSeriNoTuruService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkBarkodSeriNoTuru>;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.Find(AFilter, ALock);
end;

function TSetStkBarkodSeriNoTuruService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkBarkodSeriNoTuru;
begin
  if APermissionControl then Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetStkBarkodSeriNoTuruService.BusinessInsert(AEntity: TSetStkBarkodSeriNoTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Add(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then Self.UoW.Rollback;
      raise
    end;
  end;
end;

procedure TSetStkBarkodSeriNoTuruService.BusinessUpdate(AEntity: TSetStkBarkodSeriNoTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Update(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TSetStkBarkodSeriNoTuruService.BusinessDelete(AEntity: TSetStkBarkodSeriNoTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then Self.UoW.IsAuthorized(ptDelete, APermissionControl);
    if AWithBegin and not Self.UoW.InTransaction then Self.UoW.BeginTransaction;
    FRepo.Delete(AEntity);
    if AWithCommit and Uow.InTransaction then Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then Self.UoW.Rollback;
      raise;
    end;
  end;
end;

function TSetStkBarkodSeriNoTuruService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetStkBarkodSeriNoTuruService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetStkBarkodSeriNoTuru>;
begin
  if AIncludeNestedEntities then Result := FRepo.Find(AFilter, ALock, [ioIncludeAll]) else Result := FRepo.Find(AFilter, ALock);
end;

function TSetStkBarkodSeriNoTuruService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetStkBarkodSeriNoTuru;
begin
  if AIncludeNestedEntities then Result := FRepo.FindById(AId, ALock, [ioIncludeAll]) else Result := FRepo.FindById(AId, ALock);
end;

procedure TSetStkBarkodSeriNoTuruService.Add(AEntity: TSetStkBarkodSeriNoTuru);
begin
  FRepo.Add(AEntity);
end;

procedure TSetStkBarkodSeriNoTuruService.Update(AEntity: TSetStkBarkodSeriNoTuru);
begin
  FRepo.Update(AEntity);
end;

procedure TSetStkBarkodSeriNoTuruService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
