unit SetAccTaxRate.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetAccTaxRate.Repository, SetAccTaxRate;

type
  TSetAccTaxRateService = class(TCrudService<TSetAccTaxRate>)
  private
    FRepo: IRepository<TSetAccTaxRate>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetAccTaxRate>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetAccTaxRate; override;
    procedure Add(AEntity: TSetAccTaxRate); override;
    procedure Update(AEntity: TSetAccTaxRate); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetAccTaxRate; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetAccTaxRate>; override;
    procedure BusinessInsert(AEntity: TSetAccTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetAccTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetAccTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetAccTaxRateService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetAccTaxRate, TSetAccTaxRateRepository>;
end;

destructor TSetAccTaxRateService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TSetAccTaxRateService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetAccTaxRate>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetAccTaxRateService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetAccTaxRate;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetAccTaxRateService.BusinessInsert(AEntity: TSetAccTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);

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

procedure TSetAccTaxRateService.BusinessUpdate(AEntity: TSetAccTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);

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

procedure TSetAccTaxRateService.BusinessDelete(AEntity: TSetAccTaxRate; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);

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

function TSetAccTaxRateService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetAccTaxRateService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetAccTaxRate>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetAccTaxRateService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetAccTaxRate;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetAccTaxRateService.Add(AEntity: TSetAccTaxRate);
begin
  FRepo.Add(AEntity);
end;

procedure TSetAccTaxRateService.Update(AEntity: TSetAccTaxRate);
begin
  FRepo.Update(AEntity);
end;

procedure TSetAccTaxRateService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
