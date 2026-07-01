unit SetSatSiparisDurum.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetSatSiparisDurum.Repository, SetSatSiparisDurum;

type
  TSetSatSiparisDurumService = class(TCrudService<TSetSatSiparisDurum>)
  private
    FRepo: IRepository<TSetSatSiparisDurum>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetSatSiparisDurum>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetSatSiparisDurum; override;
    procedure Add(AEntity: TSetSatSiparisDurum); override;
    procedure Update(AEntity: TSetSatSiparisDurum); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetSatSiparisDurum; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetSatSiparisDurum>; override;
    procedure BusinessInsert(AEntity: TSetSatSiparisDurum; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetSatSiparisDurum; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetSatSiparisDurum; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetSatSiparisDurumService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetSatSiparisDurum, TSetSatSiparisDurumRepository>;
end;

destructor TSetSatSiparisDurumService.Destroy;
begin
  inherited;
end;

function TSetSatSiparisDurumService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetSatSiparisDurum>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetSatSiparisDurumService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetSatSiparisDurum;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetSatSiparisDurumService.BusinessInsert(AEntity: TSetSatSiparisDurum; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
        Self.UoW.Rollback;
      raise
    end;
  end;
end;

procedure TSetSatSiparisDurumService.BusinessUpdate(AEntity: TSetSatSiparisDurum; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TSetSatSiparisDurumService.BusinessDelete(AEntity: TSetSatSiparisDurum; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

function TSetSatSiparisDurumService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetSatSiparisDurumService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetSatSiparisDurum>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetSatSiparisDurumService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetSatSiparisDurum;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetSatSiparisDurumService.Add(AEntity: TSetSatSiparisDurum);
begin
  FRepo.Add(AEntity);
end;

procedure TSetSatSiparisDurumService.Update(AEntity: TSetSatSiparisDurum);
begin
  FRepo.Update(AEntity);
end;

procedure TSetSatSiparisDurumService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
