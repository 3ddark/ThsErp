unit SysRegion.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysRegion.Repository, SysRegion, SysRegion.Exception;

type
  TSysRegionService = class(TCrudService<TSysRegion>)
  private
    FRepo: IRepository<TSysRegion>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysRegion; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysRegion>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysRegion; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysRegion; override;

    procedure Add(AEntity: TSysRegion); override;
    procedure Update(AEntity: TSysRegion); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysRegion; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysRegion>; override;
    procedure BusinessInsert(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysRegionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysRegion, TSysRegionRepository>;
  Self.PermissionCode := 1;
end;

destructor TSysRegionService.Destroy;
begin
  inherited;
end;

function TSysRegionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysRegion>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

function TSysRegionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysRegion;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

procedure TSysRegionService.BusinessInsert(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    ValidateAll(AEntity, coInsert);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysRegionService.BusinessUpdate(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    ValidateAll(AEntity, coUpdate);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysRegionService.BusinessDelete(AEntity: TSysRegion; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    ValidateAll(AEntity, coDelete);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

function TSysRegionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysRegionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysRegion>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysRegionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysRegion;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysRegionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysRegion;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysRegionService.Add(AEntity: TSysRegion);
begin
  FRepo.Add(AEntity);
end;

procedure TSysRegionService.Update(AEntity: TSysRegion);
begin
  FRepo.Update(AEntity);
end;

procedure TSysRegionService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysRegionService.ValidateBusinessRules(AEntity: TSysRegion; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysRegion;
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('name', '=', TValue.From<string>(AEntity.RegionName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      if Assigned(LModel) then
        raise ESysRegionExceptionNameUnique.Create;
    finally
      LFilter.Free;
      if Assigned(LModel) then
        LModel.Free;
    end;
  end;
end;

end.

