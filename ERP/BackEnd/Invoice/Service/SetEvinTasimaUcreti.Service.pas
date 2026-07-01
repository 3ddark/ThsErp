unit SetEvinTasimaUcreti.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetEvinTasimaUcreti.Repository, SetEvinTasimaUcreti;

type
  TSetEvinTransportPriceService = class(TCrudService<TSetEvinTransportPrice>)
  private
    FRepo: IRepository<TSetEvinTransportPrice>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetEvinTransportPrice>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetEvinTransportPrice; override;
    procedure Add(AEntity: TSetEvinTransportPrice); override;
    procedure Update(AEntity: TSetEvinTransportPrice); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinTransportPrice; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinTransportPrice>; override;
    procedure BusinessInsert(AEntity: TSetEvinTransportPrice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetEvinTransportPrice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetEvinTransportPrice; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetEvinTransportPriceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetEvinTransportPrice, TSetEvinTransportPriceRepository>;
end;

destructor TSetEvinTransportPriceService.Destroy;
begin
  inherited;
end;

function TSetEvinTransportPriceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinTransportPrice>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinTransportPriceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinTransportPrice;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetEvinTransportPriceService.BusinessInsert(AEntity: TSetEvinTransportPrice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinTransportPriceService.BusinessUpdate(AEntity: TSetEvinTransportPrice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinTransportPriceService.BusinessDelete(AEntity: TSetEvinTransportPrice; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSetEvinTransportPriceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetEvinTransportPriceService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetEvinTransportPrice>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinTransportPriceService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetEvinTransportPrice;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetEvinTransportPriceService.Add(AEntity: TSetEvinTransportPrice);
begin
  FRepo.Add(AEntity);
end;

procedure TSetEvinTransportPriceService.Update(AEntity: TSetEvinTransportPrice);
begin
  FRepo.Update(AEntity);
end;

procedure TSetEvinTransportPriceService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
