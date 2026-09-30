unit EmpDriverLicence.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpDriverLicence.Repository, EmpDriverLicence, EmpDriverLicence.Exception;

type
  TEmpDriverLicenceService = class(TCrudService<TEmpDriverLicence>)
  private
    FRepo: IRepository<TEmpDriverLicence>;

    procedure DoAdd(AEntity: TEmpDriverLicence);
    procedure DoUpdate(AEntity: TEmpDriverLicence);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TEmpDriverLicence);
    procedure ValidateUnique(AEntity: TEmpDriverLicence; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpDriverLicence; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpDriverLicence>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpDriverLicence; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpDriverLicence; override;

    procedure Add(AEntity: TEmpDriverLicence); override;
    procedure Update(AEntity: TEmpDriverLicence); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpDriverLicence; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpDriverLicence>; override;
    procedure BusinessInsert(AEntity: TEmpDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpDriverLicenceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpDriverLicence, TEmpDriverLicenceRepository>;
  Self.PermissionCode := PERMISSION_EMP_EMPLOYEE;
end;

destructor TEmpDriverLicenceService.Destroy;
begin
  inherited;
end;

procedure TEmpDriverLicenceService.ValidateRequiredReferences(AEntity: TEmpDriverLicence);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.EmpEmployeeId, TLangKeys.TEmpDriverAbility.ColEmployee, 'Employee');
  Check(AEntity.EmpDriverLicenseTypeId, TLangKeys.TEmpDriverAbility.ColLicenseName, 'License Class');
end;

procedure TEmpDriverLicenceService.ValidateUnique(AEntity: TEmpDriverLicence; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpDriverLicence;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('emp_employee_id', '=', TValue.From<Int64>(AEntity.EmpEmployeeId)));
      LFilter.Add(TFilterCriterion.New('emp_driver_license_type_id', '=', TValue.From<Int64>(AEntity.EmpDriverLicenseTypeId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpDriverLicenceExceptionEmployeeLicenseUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpDriverLicenceService.ValidateBusinessRules(AEntity: TEmpDriverLicence; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    ValidateRequiredReferences(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpDriverLicenceService.DoAdd(AEntity: TEmpDriverLicence);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpDriverLicenceService.DoUpdate(AEntity: TEmpDriverLicence);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpDriverLicenceService.DoDelete(AId: Int64);
var
  LEntity: TEmpDriverLicence;
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

function TEmpDriverLicenceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpDriverLicence>;
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

function TEmpDriverLicenceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpDriverLicence;
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

procedure TEmpDriverLicenceService.BusinessInsert(AEntity: TEmpDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpDriverLicenceService.BusinessUpdate(AEntity: TEmpDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpDriverLicenceService.BusinessDelete(AEntity: TEmpDriverLicence; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpDriverLicenceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpDriverLicenceService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpDriverLicence>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpDriverLicenceService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpDriverLicence;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpDriverLicenceService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpDriverLicence;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpDriverLicenceService.Add(AEntity: TEmpDriverLicence);
begin
  DoAdd(AEntity);
end;

procedure TEmpDriverLicenceService.Update(AEntity: TEmpDriverLicence);
begin
  DoUpdate(AEntity);
end;

procedure TEmpDriverLicenceService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
