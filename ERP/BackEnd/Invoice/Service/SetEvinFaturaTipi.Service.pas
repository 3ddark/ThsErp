unit SetEvinFaturaTipi.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetEvinFaturaTipi.Repository, SetEvinFaturaTipi;

type
  TSetEvinInvoiceTypeService = class(TCrudService<TSetEvinInvoiceType>)
  private
    FRepo: IRepository<TSetEvinInvoiceType>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetEvinInvoiceType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetEvinInvoiceType; override;
    procedure Add(AEntity: TSetEvinInvoiceType); override;
    procedure Update(AEntity: TSetEvinInvoiceType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinInvoiceType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinInvoiceType>; override;
    procedure BusinessInsert(AEntity: TSetEvinInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetEvinInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetEvinInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetEvinInvoiceTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetEvinInvoiceType, TSetEvinInvoiceTypeRepository>;
end;

destructor TSetEvinInvoiceTypeService.Destroy;
begin
  inherited;
end;

function TSetEvinInvoiceTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetEvinInvoiceType>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinInvoiceTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetEvinInvoiceType;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetEvinInvoiceTypeService.BusinessInsert(AEntity: TSetEvinInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinInvoiceTypeService.BusinessUpdate(AEntity: TSetEvinInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetEvinInvoiceTypeService.BusinessDelete(AEntity: TSetEvinInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSetEvinInvoiceTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetEvinInvoiceTypeService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetEvinInvoiceType>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetEvinInvoiceTypeService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetEvinInvoiceType;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetEvinInvoiceTypeService.Add(AEntity: TSetEvinInvoiceType);
begin
  FRepo.Add(AEntity);
end;

procedure TSetEvinInvoiceTypeService.Update(AEntity: TSetEvinInvoiceType);
begin
  FRepo.Update(AEntity);
end;

procedure TSetEvinInvoiceTypeService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
