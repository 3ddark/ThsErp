unit SetEvinPaketTipi.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetEvinPaketTipi.Repository, SetEvinPaketTipi;

type
  TSetEvinPacketTypeService = class(TCrudService<TSetEvinPacketType>)
  private
    FRepo: IRepository<TSetEvinPacketType>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetEvinPacketType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetEvinPacketType; override;
    procedure Add(AEntity: TSetEvinPacketType); override;
    procedure Update(AEntity: TSetEvinPacketType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinPacketType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinPacketType>; override;
    procedure BusinessInsert(AEntity: TSetEvinPacketType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetEvinPacketType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetEvinPacketType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetEvinPacketTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetEvinPacketType, TSetEvinPacketTypeRepository>;
end;

destructor TSetEvinPacketTypeService.Destroy;
begin
  inherited;
end;

function TSetEvinPacketTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinPacketType>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinPacketTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinPacketType;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetEvinPacketTypeService.BusinessInsert(AEntity: TSetEvinPacketType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinPacketTypeService.BusinessUpdate(AEntity: TSetEvinPacketType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinPacketTypeService.BusinessDelete(AEntity: TSetEvinPacketType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSetEvinPacketTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetEvinPacketTypeService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetEvinPacketType>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinPacketTypeService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetEvinPacketType;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetEvinPacketTypeService.Add(AEntity: TSetEvinPacketType);
begin
  FRepo.Add(AEntity);
end;

procedure TSetEvinPacketTypeService.Update(AEntity: TSetEvinPacketType);
begin
  FRepo.Update(AEntity);
end;

procedure TSetEvinPacketTypeService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
