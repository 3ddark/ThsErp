unit EmpEmployee.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpEmployee.Repository, EmpEmployee;

type
  TEmpEmployeeService = class(TCrudService<TEmpEmployee>)
  private
    FRepo: IRepository<TEmpEmployee>;

    procedure DoAdd(AEntity: TEmpEmployee);
    procedure DoUpdate(AEntity: TEmpEmployee);
    procedure DoDelete(AId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpEmployee; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpEmployee>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpEmployee; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpEmployee; override;

    procedure Add(AEntity: TEmpEmployee); override;
    procedure Update(AEntity: TEmpEmployee); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpEmployee; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpEmployee>; override;
    procedure BusinessInsert(AEntity: TEmpEmployee; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpEmployee; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpEmployee; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EmpLookup;

constructor TEmpEmployeeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpEmployee, TEmpEmployeeRepository>;
  Self.PermissionCode := PERMISSION_EMP_EMPLOYEE;
end;

destructor TEmpEmployeeService.Destroy;
begin
  inherited;
end;

procedure TEmpEmployeeService.ValidateBusinessRules(AEntity: TEmpEmployee; AOperation: TCrudOperation);

  // Required attribute Int64 = 0 değerini boş saymaz; zorunlu FK'lar burada kontrol edilir
  procedure CheckReference(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

  procedure CheckRange(AValue, AMin, AMax: Integer; const AKey, ADefault: string);
  begin
    if (AValue < AMin) or (AValue > AMax) then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEmpOption.RangeError, '%s must be between %d and %d.'),
        [TLocalizationManager.Translate(AKey, ADefault), AMin, AMax]));
  end;

begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Name := Trim(AEntity.Name);
    AEntity.Surname := Trim(AEntity.Surname);
    // full_name her zaman ad + soyad'dan türetilir
    AEntity.FullName := Trim(AEntity.Name + ' ' + AEntity.Surname);

    CheckReference(AEntity.EmpPersonTypeId, TLangKeys.TEmpEmployee.ColPersonType, 'Employee Type');
    CheckReference(AEntity.EmpUnitId, TLangKeys.TEmpEmployee.ColUnitName, 'Unit');
    CheckReference(AEntity.EmpTaskId, TLangKeys.TEmpEmployee.ColTaskName, 'Task');
    if not TEmpLookup.IsValid(elkGender, AEntity.Gender) then
      CheckReference(0, TLangKeys.TEmpEmployee.ColGender, 'Gender');
    if not TEmpLookup.IsValid(elkMaritalStatus, AEntity.MaritalStatus) then
      CheckReference(0, TLangKeys.TEmpEmployee.ColMaritalStatus, 'Marital Status');
    if not TEmpLookup.IsValid(elkMilitaryStatus, AEntity.MilitaryStatus) then
      AEntity.MilitaryStatus := 0;  // opsiyonel: geçersiz değer NULL olarak kaydedilir
    if not TEmpLookup.IsValid(elkBloodType, AEntity.BloodType) then
      AEntity.BloodType := '';
    if not TEmpLookup.IsValid(elkClothingSize, AEntity.ClothingSize) then
      AEntity.ClothingSize := '';
    CheckRange(AEntity.Child, 0, 30, TLangKeys.TEmpEmployee.ColChild, 'Children');
    CheckRange(AEntity.BonusCount, 0, 30, TLangKeys.TEmpEmployee.ColBonusCount, 'Bonus Count');
  end;
end;

procedure TEmpEmployeeService.DoAdd(AEntity: TEmpEmployee);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpEmployeeService.DoUpdate(AEntity: TEmpEmployee);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpEmployeeService.DoDelete(AId: Int64);
var
  LEntity: TEmpEmployee;
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

function TEmpEmployeeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpEmployee>;
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

function TEmpEmployeeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpEmployee;
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

procedure TEmpEmployeeService.BusinessInsert(AEntity: TEmpEmployee; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpEmployeeService.BusinessUpdate(AEntity: TEmpEmployee; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpEmployeeService.BusinessDelete(AEntity: TEmpEmployee; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpEmployeeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpEmployeeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpEmployee>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpEmployeeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpEmployee;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpEmployeeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpEmployee;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpEmployeeService.Add(AEntity: TEmpEmployee);
begin
  DoAdd(AEntity);
end;

procedure TEmpEmployeeService.Update(AEntity: TEmpEmployee);
begin
  DoUpdate(AEntity);
end;

procedure TEmpEmployeeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
