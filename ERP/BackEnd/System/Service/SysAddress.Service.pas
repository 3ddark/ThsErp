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

constructor TSysAddressService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysAddress, TSysAddressRepository>;
  Self.PermissionCode := 1;
end;

destructor TSysAddressService.Destroy;
begin
  inherited;
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

procedure TSysAddressService.BusinessUpdate(AEntity: TSysAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysAddressService.BusinessDelete(AEntity: TSysAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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
  FRepo.Add(AEntity);
end;

procedure TSysAddressService.Update(AEntity: TSysAddress);
begin
  FRepo.Update(AEntity);
end;

procedure TSysAddressService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysAddressService.ValidateBusinessRules(AEntity: TSysAddress; AOperation: TCrudOperation);
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin

  end;
end;


end.
