unit SysAddress.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysAddress.Repository, SysAddress;

type
  TSysAddressService = class(TCrudService<TSysAddress>)
  private
    FRepo: IRepository<TSysAddress>;

    procedure DoAdd(AEntity: TSysAddress);
    procedure DoUpdate(AEntity: TSysAddress);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysAddress);
    procedure ValidateUpdate(AEntity: TSysAddress);
    procedure ValidateDelete(AEntity: TSysAddress);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysAddress; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysAddress>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysAddress; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysAddress; override;

    procedure Add(AEntity: TSysAddress); override;
    procedure Update(AEntity: TSysAddress); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysAddress; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysAddress>; override;
    procedure BusinessInsert(AEntity: TSysAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TSysAddressService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysAddress, TSysAddressRepository>;
  Self.PermissionCode := PERMISSION_TEMPLATE;
end;

destructor TSysAddressService.Destroy;
begin
  inherited;
end;

procedure TSysAddressService.ValidateInsert(AEntity: TSysAddress);
begin

end;

procedure TSysAddressService.ValidateUpdate(AEntity: TSysAddress);
begin

end;

procedure TSysAddressService.ValidateDelete(AEntity: TSysAddress);
begin

end;

procedure TSysAddressService.DoAdd(AEntity: TSysAddress);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysAddressService.DoUpdate(AEntity: TSysAddress);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysAddressService.DoDelete(AId: Int64);
var
  LEntity: TSysAddress;
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

function TSysAddressService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysAddress>;
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

function TSysAddressService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysAddress;
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

procedure TSysAddressService.BusinessInsert(AEntity: TSysAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysAddressService.BusinessUpdate(AEntity: TSysAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysAddressService.BusinessDelete(AEntity: TSysAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysAddressService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysAddressService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysAddress>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysAddressService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysAddress;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysAddressService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysAddress;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysAddressService.Add(AEntity: TSysAddress);
begin
  DoAdd(AEntity)
end;

procedure TSysAddressService.Update(AEntity: TSysAddress);
begin
  DoUpdate(AEntity)
end;

procedure TSysAddressService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

procedure TSysAddressService.ValidateBusinessRules(AEntity: TSysAddress; AOperation: TCrudOperation);
begin
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

end.
