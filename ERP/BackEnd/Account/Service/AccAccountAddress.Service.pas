unit AccAccountAddress.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccAccountAddress.Repository, AccAccountAddress, AccAccountAddress.Exception;

type
  TAccAccountAddressService = class(TCrudService<TAccAccountAddress>)
  private
    FRepo: IRepository<TAccAccountAddress>;

    procedure DoAdd(AEntity: TAccAccountAddress);
    procedure DoUpdate(AEntity: TAccAccountAddress);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TAccAccountAddress);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccAccountAddress; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccAccountAddress>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccAccountAddress; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccAccountAddress; override;

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

uses
  SysPermission.Service;

constructor TAccAccountAddressService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccAccountAddress, TAccAccountAddressRepository>;
  Self.PermissionCode := PERMISSION_ACC_ACCOUNT;
end;

destructor TAccAccountAddressService.Destroy;
begin
  inherited;
end;

procedure TAccAccountAddressService.ValidateRequiredReferences(AEntity: TAccAccountAddress);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.AccAccountId, TLangKeys.TAccAccountAddress.ColAccount, 'Account');
  Check(AEntity.SysAddressId, TLangKeys.TAccAccountAddress.ColAddress, 'Address');
end;

procedure TAccAccountAddressService.ValidateBusinessRules(AEntity: TAccAccountAddress; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.AddressType := Trim(AEntity.AddressType);
    ValidateRequiredReferences(AEntity);
    if (AEntity.ValidFrom > 0) and (AEntity.ValidTo > 0) and (AEntity.ValidTo < AEntity.ValidFrom) then
      raise EAccAccountAddressExceptionValidDateRange.Create;
  end;
end;

procedure TAccAccountAddressService.DoAdd(AEntity: TAccAccountAddress);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TAccAccountAddressService.DoUpdate(AEntity: TAccAccountAddress);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TAccAccountAddressService.DoDelete(AId: Int64);
var
  LEntity: TAccAccountAddress;
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

function TAccAccountAddressService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccountAddress>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TAccAccountAddressService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccountAddress;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccAccountAddressService.BusinessInsert(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccAccountAddressService.BusinessUpdate(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccAccountAddressService.BusinessDelete(AEntity: TAccAccountAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TAccAccountAddressService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccAccountAddressService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccAccountAddress>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TAccAccountAddressService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccAccountAddress;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TAccAccountAddressService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccAccountAddress;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccAccountAddressService.Add(AEntity: TAccAccountAddress);
begin
  DoAdd(AEntity);
end;

procedure TAccAccountAddressService.Update(AEntity: TAccAccountAddress);
begin
  DoUpdate(AEntity);
end;

procedure TAccAccountAddressService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
