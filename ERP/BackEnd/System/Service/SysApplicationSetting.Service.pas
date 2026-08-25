unit SysApplicationSetting.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysApplicationSetting.Repository, SysApplicationSetting;

type
  TSysApplicationSettingService = class(TCrudService<TSysApplicationSetting>)
  private
    FRepo: IRepository<TSysApplicationSetting>;
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

constructor TSysApplicationSettingService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysApplicationSetting, TSysApplicationSettingRepository>;
  Self.PermissionCode := 1;
end;

destructor TSysApplicationSettingService.Destroy;
begin
  inherited;
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

procedure TSysApplicationSettingService.BusinessUpdate(AEntity: TSysApplicationSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysApplicationSettingService.BusinessDelete(AEntity: TSysApplicationSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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
  FRepo.Add(AEntity);
end;

procedure TSysApplicationSettingService.Update(AEntity: TSysApplicationSetting);
begin
  FRepo.Update(AEntity);
end;

procedure TSysApplicationSettingService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysApplicationSettingService.ValidateBusinessRules(AEntity: TSysApplicationSetting; AOperation: TCrudOperation);
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin

  end;
end;

end.
