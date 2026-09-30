unit EmpPersonType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpPersonType.Repository, EmpPersonType, EmpPersonType.Exception;

type
  TEmpPersonTypeService = class(TCrudService<TEmpPersonType>)
  private
    FRepo: IRepository<TEmpPersonType>;

    procedure DoAdd(AEntity: TEmpPersonType);
    procedure DoUpdate(AEntity: TEmpPersonType);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TEmpPersonType; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpPersonType; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpPersonType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpPersonType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpPersonType; override;

    procedure Add(AEntity: TEmpPersonType); override;
    procedure Update(AEntity: TEmpPersonType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpPersonType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpPersonType>; override;
    procedure BusinessInsert(AEntity: TEmpPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpPersonTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpPersonType, TEmpPersonTypeRepository>;
  Self.PermissionCode := PERMISSION_EMP_PERSON_TYPE;
end;

destructor TEmpPersonTypeService.Destroy;
begin
  inherited;
end;

procedure TEmpPersonTypeService.ValidateUnique(AEntity: TEmpPersonType; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpPersonType;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('person_type_key', '=', TValue.From<string>(AEntity.PersonTypeKey)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpPersonTypeExceptionPersonTypeKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpPersonTypeService.ValidateBusinessRules(AEntity: TEmpPersonType; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.PersonTypeKey := Trim(AEntity.PersonTypeKey);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpPersonTypeService.DoAdd(AEntity: TEmpPersonType);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpPersonTypeService.DoUpdate(AEntity: TEmpPersonType);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpPersonTypeService.DoDelete(AId: Int64);
var
  LEntity: TEmpPersonType;
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

function TEmpPersonTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpPersonType>;
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

function TEmpPersonTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpPersonType;
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

procedure TEmpPersonTypeService.BusinessInsert(AEntity: TEmpPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpPersonTypeService.BusinessUpdate(AEntity: TEmpPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpPersonTypeService.BusinessDelete(AEntity: TEmpPersonType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpPersonTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpPersonTypeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpPersonType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpPersonTypeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpPersonType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpPersonTypeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpPersonType;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpPersonTypeService.Add(AEntity: TEmpPersonType);
begin
  DoAdd(AEntity);
end;

procedure TEmpPersonTypeService.Update(AEntity: TEmpPersonType);
begin
  DoUpdate(AEntity);
end;

procedure TEmpPersonTypeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
