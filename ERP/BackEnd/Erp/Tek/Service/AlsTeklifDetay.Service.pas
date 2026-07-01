unit AlsTeklifDetay.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  AlsTeklifDetay.Repository, AlsTeklifDetay;

type
  TAlsTeklifDetayService = class(TCrudService<TAlsTeklifDetay>)
  private
    FRepo: IRepository<TAlsTeklifDetay>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAlsTeklifDetay>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAlsTeklifDetay; override;
    procedure Add(AEntity: TAlsTeklifDetay); override;
    procedure Update(AEntity: TAlsTeklifDetay); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAlsTeklifDetay; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAlsTeklifDetay>; override;
    procedure BusinessInsert(AEntity: TAlsTeklifDetay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAlsTeklifDetay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAlsTeklifDetay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TAlsTeklifDetayService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAlsTeklifDetay, TAlsTeklifDetayRepository>;
end;

destructor TAlsTeklifDetayService.Destroy;
begin
  inherited;
end;

function TAlsTeklifDetayService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAlsTeklifDetay>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TAlsTeklifDetayService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAlsTeklifDetay;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TAlsTeklifDetayService.BusinessInsert(AEntity: TAlsTeklifDetay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAlsTeklifDetayService.BusinessUpdate(AEntity: TAlsTeklifDetay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAlsTeklifDetayService.BusinessDelete(AEntity: TAlsTeklifDetay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAlsTeklifDetayService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAlsTeklifDetayService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TAlsTeklifDetay>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TAlsTeklifDetayService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TAlsTeklifDetay;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TAlsTeklifDetayService.Add(AEntity: TAlsTeklifDetay);
begin
  FRepo.Add(AEntity);
end;

procedure TAlsTeklifDetayService.Update(AEntity: TAlsTeklifDetay);
begin
  FRepo.Update(AEntity);
end;

procedure TAlsTeklifDetayService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
