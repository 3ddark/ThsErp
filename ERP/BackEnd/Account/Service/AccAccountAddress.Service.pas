unit AccAccountAddress.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  AccAccountAddress.Repository, AccAccountAddress;

type
  TAccAccountAddressService = class(TCrudService<TAccAccountAddress>)
  private
    FRepo: IRepository<TAccAccountAddress>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccAccountAddress>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccAccountAddress; override;
    procedure Add(AEntity: TAccAccountAddress); override;
    procedure Update(AEntity: TAccAccountAddress); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountAddress; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountAddress>; override;
    procedure BusinessInsert(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TAccAccountAddressService.Create;
begin
  inherited;
  PermissionCode := 1200; // Choose a distinct permission code for AccAccountAddress
  FRepo := Self.UoW.GetRepository<TAccAccountAddress, TAccAccountAddressRepository>;
end;

destructor TAccAccountAddressService.Destroy;
begin
  inherited;
end;

function TAccAccountAddressService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountAddress>;
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

function TAccAccountAddressService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountAddress;
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

procedure TAccAccountAddressService.BusinessInsert(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccAccountAddressService.BusinessUpdate(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TAccAccountAddressService.BusinessDelete(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TAccAccountAddressService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccAccountAddressService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TAccAccountAddress>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccAccountAddressService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccAccountAddress;
begin
  Result := FRepo.FindById(AId, ALock);
end;

procedure TAccAccountAddressService.Add(AEntity: TAccAccountAddress);
begin
  FRepo.Add(AEntity);
end;

procedure TAccAccountAddressService.Update(AEntity: TAccAccountAddress);
begin
  FRepo.Update(AEntity);
end;

procedure TAccAccountAddressService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
