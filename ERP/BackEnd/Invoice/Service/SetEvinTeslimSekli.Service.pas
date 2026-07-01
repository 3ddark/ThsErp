unit SetEvinTeslimSekli.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetEvinTeslimSekli.Repository, SetEvinTeslimSekli;

type
  TSetEvinDeliveryTypeService = class(TCrudService<TSetEvinDeliveryType>)
  private
    FRepo: IRepository<TSetEvinDeliveryType>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetEvinDeliveryType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetEvinDeliveryType; override;
    procedure Add(AEntity: TSetEvinDeliveryType); override;
    procedure Update(AEntity: TSetEvinDeliveryType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinDeliveryType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinDeliveryType>; override;
    procedure BusinessInsert(AEntity: TSetEvinDeliveryType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetEvinDeliveryType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetEvinDeliveryType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetEvinDeliveryTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetEvinDeliveryType, TSetEvinDeliveryTypeRepository>;
end;

destructor TSetEvinDeliveryTypeService.Destroy;
begin
  inherited;
end;

function TSetEvinDeliveryTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinDeliveryType>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinDeliveryTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinDeliveryType;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetEvinDeliveryTypeService.BusinessInsert(AEntity: TSetEvinDeliveryType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinDeliveryTypeService.BusinessUpdate(AEntity: TSetEvinDeliveryType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinDeliveryTypeService.BusinessDelete(AEntity: TSetEvinDeliveryType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSetEvinDeliveryTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetEvinDeliveryTypeService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetEvinDeliveryType>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinDeliveryTypeService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetEvinDeliveryType;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetEvinDeliveryTypeService.Add(AEntity: TSetEvinDeliveryType);
begin
  FRepo.Add(AEntity);
end;

procedure TSetEvinDeliveryTypeService.Update(AEntity: TSetEvinDeliveryType);
begin
  FRepo.Update(AEntity);
end;

procedure TSetEvinDeliveryTypeService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
