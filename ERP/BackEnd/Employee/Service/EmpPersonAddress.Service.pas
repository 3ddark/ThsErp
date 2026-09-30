unit EmpPersonAddress.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpPersonAddress.Repository, EmpPersonAddress, EmpPersonAddress.Exception;

type
  TEmpPersonAddressService = class(TCrudService<TEmpPersonAddress>)
  private
    FRepo: IRepository<TEmpPersonAddress>;

    procedure DoAdd(AEntity: TEmpPersonAddress);
    procedure DoUpdate(AEntity: TEmpPersonAddress);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TEmpPersonAddress);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpPersonAddress; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpPersonAddress>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpPersonAddress; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpPersonAddress; override;

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

uses
  SysPermission.Service;

constructor TEmpPersonAddressService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpPersonAddress, TEmpPersonAddressRepository>;
  Self.PermissionCode := PERMISSION_EMP_EMPLOYEE;
end;

destructor TEmpPersonAddressService.Destroy;
begin
  inherited;
end;

procedure TEmpPersonAddressService.ValidateRequiredReferences(AEntity: TEmpPersonAddress);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.EmpEmployeeId, TLangKeys.TEmpPersonAddress.ColEmployee, 'Employee');
  Check(AEntity.SysAddressId, TLangKeys.TEmpPersonAddress.ColAddress, 'Address');
end;

procedure TEmpPersonAddressService.ValidateBusinessRules(AEntity: TEmpPersonAddress; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.AddressType := Trim(AEntity.AddressType);
    ValidateRequiredReferences(AEntity);
    if (AEntity.ValidFrom > 0) and (AEntity.ValidTo > 0) and (AEntity.ValidTo < AEntity.ValidFrom) then
      raise EEmpPersonAddressExceptionValidDateRange.Create;
  end;
end;

procedure TEmpPersonAddressService.DoAdd(AEntity: TEmpPersonAddress);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpPersonAddressService.DoUpdate(AEntity: TEmpPersonAddress);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpPersonAddressService.DoDelete(AId: Int64);
var
  LEntity: TEmpPersonAddress;
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

function TEmpPersonAddressService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpPersonAddress>;
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

function TEmpPersonAddressService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpPersonAddress;
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

procedure TEmpPersonAddressService.BusinessInsert(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpPersonAddressService.BusinessUpdate(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpPersonAddressService.BusinessDelete(AEntity: TEmpPersonAddress; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpPersonAddressService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpPersonAddress;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpPersonAddressService.Add(AEntity: TEmpPersonAddress);
begin
  DoAdd(AEntity);
end;

procedure TEmpPersonAddressService.Update(AEntity: TEmpPersonAddress);
begin
  DoUpdate(AEntity);
end;

procedure TEmpPersonAddressService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
