unit SetEvinOdemeSekli.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetEvinOdemeSekli.Repository, SetEvinOdemeSekli;

type
  TSetEvinPaymentMethodService = class(TCrudService<TSetEvinPaymentMethod>)
  private
    FRepo: IRepository<TSetEvinPaymentMethod>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetEvinPaymentMethod>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetEvinPaymentMethod; override;
    procedure Add(AEntity: TSetEvinPaymentMethod); override;
    procedure Update(AEntity: TSetEvinPaymentMethod); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinPaymentMethod; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinPaymentMethod>; override;
    procedure BusinessInsert(AEntity: TSetEvinPaymentMethod; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetEvinPaymentMethod; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetEvinPaymentMethod; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetEvinPaymentMethodService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetEvinPaymentMethod, TSetEvinPaymentMethodRepository>;
end;

destructor TSetEvinPaymentMethodService.Destroy;
begin
  inherited;
end;

function TSetEvinPaymentMethodService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinPaymentMethod>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinPaymentMethodService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinPaymentMethod;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetEvinPaymentMethodService.BusinessInsert(AEntity: TSetEvinPaymentMethod; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinPaymentMethodService.BusinessUpdate(AEntity: TSetEvinPaymentMethod; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinPaymentMethodService.BusinessDelete(AEntity: TSetEvinPaymentMethod; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSetEvinPaymentMethodService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetEvinPaymentMethodService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetEvinPaymentMethod>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinPaymentMethodService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetEvinPaymentMethod;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetEvinPaymentMethodService.Add(AEntity: TSetEvinPaymentMethod);
begin
  FRepo.Add(AEntity);
end;

procedure TSetEvinPaymentMethodService.Update(AEntity: TSetEvinPaymentMethod);
begin
  FRepo.Update(AEntity);
end;

procedure TSetEvinPaymentMethodService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
