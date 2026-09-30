unit EmpLanguage.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EmpLanguage.Repository, EmpLanguage, EmpLanguage.Exception;

type
  TEmpLanguageService = class(TCrudService<TEmpLanguage>)
  private
    FRepo: IRepository<TEmpLanguage>;

    procedure DoAdd(AEntity: TEmpLanguage);
    procedure DoUpdate(AEntity: TEmpLanguage);
    procedure DoDelete(AId: Int64);
    procedure ValidateUnique(AEntity: TEmpLanguage; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEmpLanguage; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEmpLanguage>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEmpLanguage; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEmpLanguage; override;

    procedure Add(AEntity: TEmpLanguage); override;
    procedure Update(AEntity: TEmpLanguage); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpLanguage; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpLanguage>; override;
    procedure BusinessInsert(AEntity: TEmpLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEmpLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEmpLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TEmpLanguageService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEmpLanguage, TEmpLanguageRepository>;
  Self.PermissionCode := PERMISSION_EMP_LANGUAGE;
end;

destructor TEmpLanguageService.Destroy;
begin
  inherited;
end;

procedure TEmpLanguageService.ValidateUnique(AEntity: TEmpLanguage; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TEmpLanguage;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('language_name', '=', TValue.From<string>(AEntity.LanguageName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EEmpLanguageExceptionLanguageNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TEmpLanguageService.ValidateBusinessRules(AEntity: TEmpLanguage; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.LanguageName := Trim(AEntity.LanguageName);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TEmpLanguageService.DoAdd(AEntity: TEmpLanguage);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEmpLanguageService.DoUpdate(AEntity: TEmpLanguage);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEmpLanguageService.DoDelete(AId: Int64);
var
  LEntity: TEmpLanguage;
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

function TEmpLanguageService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEmpLanguage>;
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

function TEmpLanguageService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEmpLanguage;
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

procedure TEmpLanguageService.BusinessInsert(AEntity: TEmpLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpLanguageService.BusinessUpdate(AEntity: TEmpLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEmpLanguageService.BusinessDelete(AEntity: TEmpLanguage; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEmpLanguageService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEmpLanguageService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEmpLanguage>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEmpLanguageService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEmpLanguage;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEmpLanguageService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEmpLanguage;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEmpLanguageService.Add(AEntity: TEmpLanguage);
begin
  DoAdd(AEntity);
end;

procedure TEmpLanguageService.Update(AEntity: TEmpLanguage);
begin
  DoUpdate(AEntity);
end;

procedure TEmpLanguageService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
