unit SysPermissionGroup.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysPermissionGroup.Repository, SysPermissionGroup, SysPermissionGroup.Exception;

type
  TSysPermissionGroupService = class(TCrudService<TSysPermissionGroup>)
  private
    FRepo: IRepository<TSysPermissionGroup>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysPermissionGroup; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysPermissionGroup>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysPermissionGroup; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysPermissionGroup; override;

    procedure Add(AEntity: TSysPermissionGroup); override;
    procedure Update(AEntity: TSysPermissionGroup); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionGroup; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionGroup>; override;
    procedure BusinessInsert(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysPermissionGroupService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysPermissionGroup, TSysPermissionGroupRepository>;
  Self.PermissionCode := 1;
end;

destructor TSysPermissionGroupService.Destroy;
begin
  inherited;
end;

function TSysPermissionGroupService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermissionGroup>;
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

function TSysPermissionGroupService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermissionGroup;
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

procedure TSysPermissionGroupService.BusinessInsert(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionGroupService.BusinessUpdate(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionGroupService.BusinessDelete(AEntity: TSysPermissionGroup; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysPermissionGroupService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysPermissionGroupService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysPermissionGroup>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionGroupService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysPermissionGroup;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysPermissionGroupService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysPermissionGroup;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysPermissionGroupService.Add(AEntity: TSysPermissionGroup);
begin
  FRepo.Add(AEntity);
end;

procedure TSysPermissionGroupService.Update(AEntity: TSysPermissionGroup);
begin
  FRepo.Update(AEntity);
end;

procedure TSysPermissionGroupService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysPermissionGroupService.ValidateBusinessRules(AEntity: TSysPermissionGroup; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysPermissionGroup;
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('key', '=', TValue.From<string>(AEntity.Key)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      if Assigned(LModel) then
        raise ESysPermissionGroupExceptionKeyUnique.Create;
    finally
      LFilter.Free;
      if Assigned(LModel) then
        LModel.Free;
    end;
  end;
end;

end.
