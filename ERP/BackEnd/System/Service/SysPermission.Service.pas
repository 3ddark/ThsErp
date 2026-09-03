unit SysPermission.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysPermission.Repository, SysPermission, SysPermission.Exception,
  SysAccessRight.Service;

const
  PERMISSION_TEMPLATE       = 1;
  PERMISSION_SYS_CITY       = 1000;
  PERMISSION_SYS_COUNTRY    = 1001;
  PERMISSION_SYS_REGION     = 1002;

type
  TSysPermissionService = class(TCrudService<TSysPermission>)
  private
    FRepo: IRepository<TSysPermission>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysPermission; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysPermission>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysPermission; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysPermission; override;

    procedure Add(AEntity: TSysPermission); override;
    procedure Update(AEntity: TSysPermission); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermission; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermission>; override;
    procedure BusinessInsert(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysPermissionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysPermission, TSysPermissionRepository>;
  Self.PermissionCode := PERMISSION_TEMPLATE;
end;

destructor TSysPermissionService.Destroy;
begin
  inherited;
end;

function TSysPermissionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermission>;
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

function TSysPermissionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermission;
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

procedure TSysPermissionService.BusinessInsert(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LSvc: TSysAccessRightService;
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    ValidateAll(AEntity, coInsert);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    //add permission to all user with false permission
    LSvc := TSysAccessRightService.Create;
    try
      LSvc.AddPermissionToAllUser(AEntity.Id, False, False);
    finally
      LSvc.Free;
    end;

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

procedure TSysPermissionService.BusinessUpdate(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysPermissionService.BusinessDelete(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysPermissionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysPermissionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysPermission>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysPermission;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysPermissionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysPermission;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysPermissionService.Add(AEntity: TSysPermission);
begin
  FRepo.Add(AEntity);
end;

procedure TSysPermissionService.Update(AEntity: TSysPermission);
begin
  FRepo.Update(AEntity);
end;

procedure TSysPermissionService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysPermissionService.ValidateBusinessRules(AEntity: TSysPermission; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysPermission;
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
      try
        if Assigned(LModel) then
          raise ESysPermissionExceptionKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

end.
