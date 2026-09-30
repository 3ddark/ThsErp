unit EmpDriverLicenceType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpDriverLicenceType.Repository, EmpDriverLicenceType, EmpDriverLicenceType.Exception;

type
  TEmpDriverLicenseTypeService = class(TCrudService<TEmpDriverLicenseType>)
  private
    FRepo: IRepository<TEmpDriverLicenseType>;

    procedure DoAdd(AEntity: TEmpDriverLicenseType);
    procedure DoUpdate(AEntity: TEmpDriverLicenseType);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TEmpDriverLicenseType; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpDriverLicenseType; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpDriverLicenseType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpDriverLicenseType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpDriverLicenseType; override;

    procedure Add(AEntity: TEmpDriverLicenseType); override;
    procedure Update(AEntity: TEmpDriverLicenseType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpDriverLicenseType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpDriverLicenseType>; override;
    procedure BusinessInsert(AEntity: TEmpDriverLicenseType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpDriverLicenseType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpDriverLicenseType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpDriverLicenseTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpDriverLicenseType, TEmpDriverLicenseTypeRepository>;
  Self.PermissionCode := PERMISSION_EMP_DRIVER_LICENSE_TYPE;
end;

destructor TEmpDriverLicenseTypeService.Destroy;
begin
  inherited;
end;

procedure TEmpDriverLicenseTypeService.ValidateUnique(AEntity: TEmpDriverLicenseType; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpDriverLicenseType;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('license_name', '=', TValue.From<string>(AEntity.LicenseName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpDriverLicenseTypeExceptionLicenseNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpDriverLicenseTypeService.ValidateBusinessRules(AEntity: TEmpDriverLicenseType; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.LicenseName := AnsiUpperCase(Trim(AEntity.LicenseName));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpDriverLicenseTypeService.DoAdd(AEntity: TEmpDriverLicenseType);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpDriverLicenseTypeService.DoUpdate(AEntity: TEmpDriverLicenseType);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpDriverLicenseTypeService.DoDelete(AId: Int64);
var
  LEntity: TEmpDriverLicenseType;
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

function TEmpDriverLicenseTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpDriverLicenseType>;
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

function TEmpDriverLicenseTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpDriverLicenseType;
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

procedure TEmpDriverLicenseTypeService.BusinessInsert(AEntity: TEmpDriverLicenseType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpDriverLicenseTypeService.BusinessUpdate(AEntity: TEmpDriverLicenseType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpDriverLicenseTypeService.BusinessDelete(AEntity: TEmpDriverLicenseType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpDriverLicenseTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpDriverLicenseTypeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpDriverLicenseType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpDriverLicenseTypeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpDriverLicenseType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpDriverLicenseTypeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpDriverLicenseType;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpDriverLicenseTypeService.Add(AEntity: TEmpDriverLicenseType);
begin
  DoAdd(AEntity);
end;

procedure TEmpDriverLicenseTypeService.Update(AEntity: TEmpDriverLicenseType);
begin
  DoUpdate(AEntity);
end;

procedure TEmpDriverLicenseTypeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
