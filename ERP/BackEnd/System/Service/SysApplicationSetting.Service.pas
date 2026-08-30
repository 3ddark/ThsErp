unit SysApplicationSetting.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysApplicationSetting.Repository, SysApplicationSetting, SysApplicationSetting.Exception;

type
  TSysApplicationSettingService = class(TCrudService<TSysApplicationSetting>)
  private
    FRepo: IRepository<TSysApplicationSetting>;

    procedure DoAdd(AEntity: TSysApplicationSetting);
    procedure DoUpdate(AEntity: TSysApplicationSetting);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysApplicationSetting);
    procedure ValidateUpdate(AEntity: TSysApplicationSetting);
    procedure ValidateDelete(AEntity: TSysApplicationSetting);
    procedure ValidateMustContainOneRecord(AEntity: TSysApplicationSetting; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysApplicationSetting; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysApplicationSetting>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysApplicationSetting; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysApplicationSetting; override;

    procedure Add(AEntity: TSysApplicationSetting); override;
    procedure Update(AEntity: TSysApplicationSetting); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysApplicationSetting; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysApplicationSetting>; override;
    procedure BusinessInsert(AEntity: TSysApplicationSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysApplicationSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysApplicationSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TSysApplicationSettingService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysApplicationSetting, TSysApplicationSettingRepository>;
  Self.PermissionCode := PERMISSION_TEMPLATE;
end;

destructor TSysApplicationSettingService.Destroy;
begin
  inherited;
end;

procedure TSysApplicationSettingService.ValidateInsert(AEntity: TSysApplicationSetting);
begin
  ValidateMustContainOneRecord(AEntity, coInsert);
end;

procedure TSysApplicationSettingService.ValidateUpdate(AEntity: TSysApplicationSetting);
begin
  ValidateMustContainOneRecord(AEntity, coUpdate);
end;

procedure TSysApplicationSettingService.ValidateDelete(AEntity: TSysApplicationSetting);
begin
  ValidateMustContainOneRecord(AEntity, coDelete);
end;

procedure TSysApplicationSettingService.ValidateMustContainOneRecord(AEntity: TSysApplicationSetting; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysApplicationSetting;
begin
  LFilter := TFilterCriteria.Create;
  try
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)))
    else if AOperation = coDelete then
      raise ESysApplicationSettingExceptionMustContainOnlyOneRecord.Create;

    LModel := FRepo.FindOne(LFilter, False);
    if Assigned(LModel) then
      raise ESysApplicationSettingExceptionMustContainOnlyOneRecord.Create;
  finally
    LFilter.Free;
    LModel.Free;
  end;
end;

procedure TSysApplicationSettingService.DoAdd(AEntity: TSysApplicationSetting);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysApplicationSettingService.DoUpdate(AEntity: TSysApplicationSetting);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysApplicationSettingService.DoDelete(AId: Int64);
var
  LEntity: TSysApplicationSetting;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.CreateFmt('Record not found: %d', [AId]);

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TSysApplicationSettingService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysApplicationSetting>;
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

function TSysApplicationSettingService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysApplicationSetting;
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

procedure TSysApplicationSettingService.BusinessInsert(AEntity: TSysApplicationSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysApplicationSettingService.BusinessUpdate(AEntity: TSysApplicationSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysApplicationSettingService.BusinessDelete(AEntity: TSysApplicationSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysApplicationSettingService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysApplicationSettingService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysApplicationSetting>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysApplicationSettingService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysApplicationSetting;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysApplicationSettingService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysApplicationSetting;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysApplicationSettingService.Add(AEntity: TSysApplicationSetting);
begin
  DoAdd(AEntity)
end;

procedure TSysApplicationSettingService.Update(AEntity: TSysApplicationSetting);
begin
  DoUpdate(AEntity)
end;

procedure TSysApplicationSettingService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

procedure TSysApplicationSettingService.ValidateBusinessRules(AEntity: TSysApplicationSetting; AOperation: TCrudOperation);
begin
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

end.
