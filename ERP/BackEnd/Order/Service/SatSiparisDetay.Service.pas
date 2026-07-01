unit SatSiparisDetay.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SatSiparisDetay.Repository, SatSiparisDetay;

type
  TSatSiparisDetayService = class(TCrudService<TSatSiparisDetay>)
  private
    FRepo: IRepository<TSatSiparisDetay>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSatSiparisDetay>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSatSiparisDetay; override;
    procedure Add(AEntity: TSatSiparisDetay); override;
    procedure Update(AEntity: TSatSiparisDetay); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSatSiparisDetay; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSatSiparisDetay>; override;
    procedure BusinessInsert(AEntity: TSatSiparisDetay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSatSiparisDetay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSatSiparisDetay; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSatSiparisDetayService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSatSiparisDetay, TSatSiparisDetayRepository>;
end;

destructor TSatSiparisDetayService.Destroy;
begin
  inherited;
end;

function TSatSiparisDetayService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSatSiparisDetay>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSatSiparisDetayService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSatSiparisDetay;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSatSiparisDetayService.BusinessInsert(AEntity: TSatSiparisDetay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSatSiparisDetayService.BusinessUpdate(AEntity: TSatSiparisDetay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSatSiparisDetayService.BusinessDelete(AEntity: TSatSiparisDetay; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSatSiparisDetayService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSatSiparisDetayService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSatSiparisDetay>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSatSiparisDetayService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSatSiparisDetay;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSatSiparisDetayService.Add(AEntity: TSatSiparisDetay);
begin
  FRepo.Add(AEntity);
end;

procedure TSatSiparisDetayService.Update(AEntity: TSatSiparisDetay);
begin
  FRepo.Update(AEntity);
end;

procedure TSatSiparisDetayService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
