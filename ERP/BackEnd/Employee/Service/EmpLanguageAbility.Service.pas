unit EmpLanguageAbility.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpLanguageAbility.Repository, EmpLanguageAbility, EmpLanguageAbility.Exception;

type
  TEmpLanguageAbilityService = class(TCrudService<TEmpLanguageAbility>)
  private
    FRepo: IRepository<TEmpLanguageAbility>;

    procedure DoAdd(AEntity: TEmpLanguageAbility);
    procedure DoUpdate(AEntity: TEmpLanguageAbility);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TEmpLanguageAbility);
    procedure ValidateUnique(AEntity: TEmpLanguageAbility; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpLanguageAbility; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpLanguageAbility>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpLanguageAbility; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpLanguageAbility; override;

    procedure Add(AEntity: TEmpLanguageAbility); override;
    procedure Update(AEntity: TEmpLanguageAbility); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpLanguageAbility; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpLanguageAbility>; override;
    procedure BusinessInsert(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpLanguageAbilityService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpLanguageAbility, TEmpLanguageAbilityRepository>;
  Self.PermissionCode := PERMISSION_EMP_EMPLOYEE;
end;

destructor TEmpLanguageAbilityService.Destroy;
begin
  inherited;
end;

procedure TEmpLanguageAbilityService.ValidateRequiredReferences(AEntity: TEmpLanguageAbility);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.EmpEmployeeId, TLangKeys.TEmpLanguageAbility.ColEmployee, 'Employee');
  Check(AEntity.EmpLanguageId, TLangKeys.TEmpLanguageAbility.ColLanguageName, 'Language');
  Check(AEntity.ReadLevel, TLangKeys.TEmpLanguageAbility.ColReadLevel, 'Reading');
  Check(AEntity.WriteLevel, TLangKeys.TEmpLanguageAbility.ColWriteLevel, 'Writing');
  Check(AEntity.SpeakLevel, TLangKeys.TEmpLanguageAbility.ColSpeakLevel, 'Speaking');
end;

procedure TEmpLanguageAbilityService.ValidateUnique(AEntity: TEmpLanguageAbility; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpLanguageAbility;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('emp_employee_id', '=', TValue.From<Int64>(AEntity.EmpEmployeeId)));
      LFilter.Add(TFilterCriterion.New('emp_language_id', '=', TValue.From<Int64>(AEntity.EmpLanguageId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpLanguageAbilityExceptionEmployeeLanguageUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpLanguageAbilityService.ValidateBusinessRules(AEntity: TEmpLanguageAbility; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    ValidateRequiredReferences(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpLanguageAbilityService.DoAdd(AEntity: TEmpLanguageAbility);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpLanguageAbilityService.DoUpdate(AEntity: TEmpLanguageAbility);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpLanguageAbilityService.DoDelete(AId: Int64);
var
  LEntity: TEmpLanguageAbility;
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

function TEmpLanguageAbilityService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpLanguageAbility>;
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

function TEmpLanguageAbilityService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpLanguageAbility;
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

procedure TEmpLanguageAbilityService.BusinessInsert(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpLanguageAbilityService.BusinessUpdate(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpLanguageAbilityService.BusinessDelete(AEntity: TEmpLanguageAbility; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpLanguageAbilityService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpLanguageAbilityService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpLanguageAbility>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpLanguageAbilityService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpLanguageAbility;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpLanguageAbilityService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpLanguageAbility;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpLanguageAbilityService.Add(AEntity: TEmpLanguageAbility);
begin
  DoAdd(AEntity);
end;

procedure TEmpLanguageAbilityService.Update(AEntity: TEmpLanguageAbility);
begin
  DoUpdate(AEntity);
end;

procedure TEmpLanguageAbilityService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
