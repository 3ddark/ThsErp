unit EmpSection.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpSection.Repository, EmpSection, EmpSection.Exception;

type
  TEmpSectionService = class(TCrudService<TEmpSection>)
  private
    FRepo: IRepository<TEmpSection>;

    procedure DoAdd(AEntity: TEmpSection);
    procedure DoUpdate(AEntity: TEmpSection);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TEmpSection; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpSection; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpSection>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpSection; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpSection; override;

    procedure Add(AEntity: TEmpSection); override;
    procedure Update(AEntity: TEmpSection); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpSection; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpSection>; override;
    procedure BusinessInsert(AEntity: TEmpSection; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpSection; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpSection; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpSectionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpSection, TEmpSectionRepository>;
  Self.PermissionCode := PERMISSION_EMP_SECTION;
end;

destructor TEmpSectionService.Destroy;
begin
  inherited;
end;

procedure TEmpSectionService.ValidateUnique(AEntity: TEmpSection; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpSection;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('section_key', '=', TValue.From<string>(AEntity.SectionKey)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpSectionExceptionSectionKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpSectionService.ValidateBusinessRules(AEntity: TEmpSection; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.SectionKey := Trim(AEntity.SectionKey);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpSectionService.DoAdd(AEntity: TEmpSection);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpSectionService.DoUpdate(AEntity: TEmpSection);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpSectionService.DoDelete(AId: Int64);
var
  LEntity: TEmpSection;
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

function TEmpSectionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpSection>;
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

function TEmpSectionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpSection;
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

procedure TEmpSectionService.BusinessInsert(AEntity: TEmpSection; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpSectionService.BusinessUpdate(AEntity: TEmpSection; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpSectionService.BusinessDelete(AEntity: TEmpSection; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpSectionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpSectionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpSection>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpSectionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpSection;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpSectionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpSection;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpSectionService.Add(AEntity: TEmpSection);
begin
  DoAdd(AEntity);
end;

procedure TEmpSectionService.Update(AEntity: TEmpSection);
begin
  DoUpdate(AEntity);
end;

procedure TEmpSectionService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
