unit EmpPersonAddress.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  EmpPersonAddress.Repository, EmpPersonAddress;

type
  TEmpPersonAddressService = class(TCrudService<TEmpPersonAddress>)
  private
    FRepo: IRepository<TEmpPersonAddress>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpPersonAddress>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpPersonAddress; override;
    procedure Add(AEntity: TEmpPersonAddress); override;
    procedure Update(AEntity: TEmpPersonAddress); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpPersonAddress; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpPersonAddress>; override;
    procedure BusinessInsert(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TEmpPersonAddressService.Create;
begin
  inherited;
  PermissionCode := 1000;
  FRepo := Self.UoW.GetRepository<TEmpPersonAddress, TEmpPersonAddressRepository>;
end;

destructor TEmpPersonAddressService.Destroy;
begin
  inherited;
end;

function TEmpPersonAddressService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpPersonAddress>;
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptRead, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TEmpPersonAddressService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpPersonAddress;
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptRead, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    Result := FRepo.FindById(AId, ALock);
    if (Result = nil) and LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TEmpPersonAddressService.BusinessInsert(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptAddRecord, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Add(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TEmpPersonAddressService.BusinessUpdate(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptUpdate, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Update(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TEmpPersonAddressService.BusinessDelete(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LStartedTx: Boolean;
begin
  if APermissionControl then
    Self.IsAuthorized(ptDelete, APermissionControl);

  LStartedTx := False;
  if AWithBegin and not Self.UoW.InTransaction then
  begin
    Self.UoW.BeginTransaction;
    LStartedTx := True;
  end;

  try
    FRepo.Delete(AEntity);

    if AWithCommit and Self.UoW.InTransaction and (LStartedTx or AWithBegin) then
      Self.UoW.Commit;
  except
    if LStartedTx and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TEmpPersonAddressService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpPersonAddressService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpPersonAddress>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpPersonAddressService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpPersonAddress;
begin
  Result := FRepo.FindById(AId, ALock);
end;

procedure TEmpPersonAddressService.Add(AEntity: TEmpPersonAddress);
begin
  FRepo.Add(AEntity);
end;

procedure TEmpPersonAddressService.Update(AEntity: TEmpPersonAddress);
begin
  FRepo.Update(AEntity);
end;

procedure TEmpPersonAddressService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
