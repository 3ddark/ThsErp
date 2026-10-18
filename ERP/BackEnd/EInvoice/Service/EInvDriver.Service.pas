unit EInvDriver.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvDriver.Repository, EInvDriver, EInvDriver.Exception;

type
  TEInvDriverService = class(TCrudService<TEInvDriver>)
  private
    FRepo: IRepository<TEInvDriver>;

    procedure DoAdd(AEntity: TEInvDriver);
    procedure DoUpdate(AEntity: TEInvDriver);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvDriver; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvDriver>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvDriver; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvDriver; override;

    procedure Add(AEntity: TEInvDriver); override;
    procedure Update(AEntity: TEInvDriver); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDriver; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDriver>; override;
    procedure BusinessInsert(AEntity: TEInvDriver; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvDriver; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvDriver; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvDriverService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvDriver, TEInvDriverRepository>;
  Self.PermissionCode := PERMISSION_EINV_DRIVER;
end;

destructor TEInvDriverService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvDriverService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvDriverService.ValidateBusinessRules(AEntity: TEInvDriver; AOperation: TCrudOperation);
var
  LRepo: TEInvDriverRepository;
begin
  LRepo := TEInvDriverRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvDriverExceptionInUse.Create;
    Exit;
  end;

  AEntity.FirstName := Trim(AEntity.FirstName);
  AEntity.FamilyName := Trim(AEntity.FamilyName);
  AEntity.NationalId := Trim(AEntity.NationalId);
  AEntity.Phone := Trim(AEntity.Phone);
  AEntity.FullName := AEntity.FirstName + ' ' + AEntity.FamilyName;
  if AEntity.FirstName = '' then
    FailRequired(TLangKeys.TEInvDriver.ColFirstName, 'First Name');
  if AEntity.FamilyName = '' then
    FailRequired(TLangKeys.TEInvDriver.ColFamilyName, 'Last Name');
  if not TEInvLookup.IsValidNationalId(AEntity.NationalId) then
    raise EEInvDriverExceptionNationalIdInvalid.Create;
  if LRepo.NationalIdExists(AEntity.NationalId, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvDriverExceptionNationalIdUnique.Create;
end;

procedure TEInvDriverService.DoAdd(AEntity: TEInvDriver);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvDriverService.DoUpdate(AEntity: TEInvDriver);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvDriverService.DoDelete(AId: Int64);
var
  LEntity: TEInvDriver;
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

function TEInvDriverService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDriver>;
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

function TEInvDriverService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDriver;
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

procedure TEInvDriverService.BusinessInsert(AEntity: TEInvDriver; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDriverService.BusinessUpdate(AEntity: TEInvDriver; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDriverService.BusinessDelete(AEntity: TEInvDriver; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvDriverService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvDriverService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvDriver>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvDriverService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvDriver;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvDriverService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvDriver;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvDriverService.Add(AEntity: TEInvDriver);
begin
  DoAdd(AEntity);
end;

procedure TEInvDriverService.Update(AEntity: TEInvDriver);
begin
  DoUpdate(AEntity);
end;

procedure TEInvDriverService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
