unit SetPrsTransportation.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetPrsTransportation.Repository, SetPrsTransportation;

type
  TSetPrsTransportationService = class(TCrudService<TSetPrsTransportation>)
  private
    FRepo: IRepository<TSetPrsTransportation>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetPrsTransportation>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetPrsTransportation; override;
    procedure Add(AEntity: TSetPrsTransportation); override;
    procedure Update(AEntity: TSetPrsTransportation); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetPrsTransportation; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetPrsTransportation>; override;
    procedure BusinessInsert(AEntity: TSetPrsTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetPrsTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetPrsTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetPrsTransportationService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetPrsTransportation, TSetPrsTransportationRepository>;
end;

destructor TSetPrsTransportationService.Destroy;
begin
  inherited;
end;

function TSetPrsTransportationService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetPrsTransportation>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetPrsTransportationService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetPrsTransportation;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetPrsTransportationService.BusinessInsert(AEntity: TSetPrsTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
      //CheckPermission if not throw exception
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

procedure TSetPrsTransportationService.BusinessUpdate(AEntity: TSetPrsTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
      //CheckPermission if not throw exception
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

procedure TSetPrsTransportationService.BusinessDelete(AEntity: TSetPrsTransportation; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);
      //CheckPermission if not throw exception
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

function TSetPrsTransportationService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetPrsTransportationService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetPrsTransportation>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetPrsTransportationService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetPrsTransportation;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetPrsTransportationService.Add(AEntity: TSetPrsTransportation);
begin
  FRepo.Add(AEntity);
end;

procedure TSetPrsTransportationService.Update(AEntity: TSetPrsTransportation);
begin
  FRepo.Update(AEntity);
end;

procedure TSetPrsTransportationService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
