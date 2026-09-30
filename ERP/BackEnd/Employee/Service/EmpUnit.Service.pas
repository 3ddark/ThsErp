unit EmpUnit.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpUnit.Repository, EmpUnit, EmpUnit.Exception;

type
  TEmpUnitService = class(TCrudService<TEmpUnit>)
  private
    FRepo: IRepository<TEmpUnit>;

    procedure DoAdd(AEntity: TEmpUnit);
    procedure DoUpdate(AEntity: TEmpUnit);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TEmpUnit);
    procedure ValidateUnique(AEntity: TEmpUnit; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpUnit; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpUnit>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpUnit; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpUnit; override;

    procedure Add(AEntity: TEmpUnit); override;
    procedure Update(AEntity: TEmpUnit); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpUnit; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpUnit>; override;
    procedure BusinessInsert(AEntity: TEmpUnit; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpUnit; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpUnit; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpUnitService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpUnit, TEmpUnitRepository>;
  Self.PermissionCode := PERMISSION_EMP_UNIT;
end;

destructor TEmpUnitService.Destroy;
begin
  inherited;
end;

procedure TEmpUnitService.ValidateRequiredReferences(AEntity: TEmpUnit);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.EmpSectionId, TLangKeys.TEmpUnit.ColSection, 'Section');
end;

procedure TEmpUnitService.ValidateUnique(AEntity: TEmpUnit; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpUnit;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('unit_key', '=', TValue.From<string>(AEntity.UnitKey)));
      LFilter.Add(TFilterCriterion.New('emp_section_id', '=', TValue.From<Int64>(AEntity.EmpSectionId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpUnitExceptionUnitKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpUnitService.ValidateBusinessRules(AEntity: TEmpUnit; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.UnitKey := Trim(AEntity.UnitKey);
    ValidateRequiredReferences(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpUnitService.DoAdd(AEntity: TEmpUnit);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpUnitService.DoUpdate(AEntity: TEmpUnit);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpUnitService.DoDelete(AId: Int64);
var
  LEntity: TEmpUnit;
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

function TEmpUnitService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpUnit>;
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

function TEmpUnitService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpUnit;
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

procedure TEmpUnitService.BusinessInsert(AEntity: TEmpUnit; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpUnitService.BusinessUpdate(AEntity: TEmpUnit; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpUnitService.BusinessDelete(AEntity: TEmpUnit; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpUnitService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpUnitService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpUnit>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpUnitService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpUnit;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpUnitService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpUnit;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpUnitService.Add(AEntity: TEmpUnit);
begin
  DoAdd(AEntity);
end;

procedure TEmpUnitService.Update(AEntity: TEmpUnit);
begin
  DoUpdate(AEntity);
end;

procedure TEmpUnitService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
