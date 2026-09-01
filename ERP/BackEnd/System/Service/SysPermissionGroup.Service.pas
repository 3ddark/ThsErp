unit SysPermissionGroup.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysPermissionGroup.Repository, SysPermissionGroup, SysPermissionGroup.Exception;

type
  TSysPermissionGroupService = class(TCrudService<TSysPermissionGroup>)
  private
    FRepo: IRepository<TSysPermissionGroup>;

    procedure DoAdd(AEntity: TSysPermissionGroup);
    procedure DoUpdate(AEntity: TSysPermissionGroup);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysPermissionGroup);
    procedure ValidateUpdate(AEntity: TSysPermissionGroup);
    procedure ValidateDelete(AEntity: TSysPermissionGroup);
    procedure ValidateUniqueUserPermission(AEntity: TSysPermissionGroup; AOperation: TCrudOperation);
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

uses
  SysPermission.Service;

constructor TSysPermissionGroupService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysPermissionGroup, TSysPermissionGroupRepository>;
  Self.PermissionCode := PERMISSION_TEMPLATE;
end;

destructor TSysPermissionGroupService.Destroy;
begin
  inherited;
end;

procedure TSysPermissionGroupService.ValidateInsert(AEntity: TSysPermissionGroup);
begin
  ValidateUniqueUserPermission(AEntity, coInsert);
end;

procedure TSysPermissionGroupService.ValidateUpdate(AEntity: TSysPermissionGroup);
begin
  ValidateUniqueUserPermission(AEntity, coUpdate);
end;

procedure TSysPermissionGroupService.ValidateDelete(AEntity: TSysPermissionGroup);
begin

end;

procedure TSysPermissionGroupService.DoAdd(AEntity: TSysPermissionGroup);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysPermissionGroupService.DoUpdate(AEntity: TSysPermissionGroup);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysPermissionGroupService.DoDelete(AId: Int64);
var
  LEntity: TSysPermissionGroup;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
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

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

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

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

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

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

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
  DoAdd(AEntity)
end;

procedure TSysPermissionGroupService.Update(AEntity: TSysPermissionGroup);
begin
  DoUpdate(AEntity);
end;

procedure TSysPermissionGroupService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

procedure TSysPermissionGroupService.ValidateBusinessRules(AEntity: TSysPermissionGroup; AOperation: TCrudOperation);
begin
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

procedure TSysPermissionGroupService.ValidateUniqueUserPermission(AEntity: TSysPermissionGroup; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysPermissionGroup;
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('permission_group_key', '=', TValue.From<string>(AEntity.PermissionGroupKey)));
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
