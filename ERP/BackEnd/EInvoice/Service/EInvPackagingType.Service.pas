unit EInvPackagingType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvPackagingType.Repository, EInvPackagingType, EInvPackagingType.Exception;

type
  TEInvPackagingTypeService = class(TCrudService<TEInvPackagingType>)
  private
    FRepo: IRepository<TEInvPackagingType>;

    procedure DoAdd(AEntity: TEInvPackagingType);
    procedure DoUpdate(AEntity: TEInvPackagingType);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvPackagingType; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvPackagingType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvPackagingType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvPackagingType; override;

    procedure Add(AEntity: TEInvPackagingType); override;
    procedure Update(AEntity: TEInvPackagingType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvPackagingType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvPackagingType>; override;
    procedure BusinessInsert(AEntity: TEInvPackagingType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvPackagingType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvPackagingType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvPackagingTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvPackagingType, TEInvPackagingTypeRepository>;
  Self.PermissionCode := PERMISSION_EINV_PACKAGING_TYPE;
end;

destructor TEInvPackagingTypeService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvPackagingTypeService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvPackagingTypeService.ValidateBusinessRules(AEntity: TEInvPackagingType; AOperation: TCrudOperation);
var
  LRepo: TEInvPackagingTypeRepository;
begin
  LRepo := TEInvPackagingTypeRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvPackagingTypeExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvPackagingType.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvPackagingType.ColName, 'Name');

  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvPackagingTypeExceptionCodeUnique.Create;
end;

procedure TEInvPackagingTypeService.DoAdd(AEntity: TEInvPackagingType);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvPackagingTypeService.DoUpdate(AEntity: TEInvPackagingType);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvPackagingTypeService.DoDelete(AId: Int64);
var
  LEntity: TEInvPackagingType;
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

function TEInvPackagingTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvPackagingType>;
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

function TEInvPackagingTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvPackagingType;
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

procedure TEInvPackagingTypeService.BusinessInsert(AEntity: TEInvPackagingType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvPackagingTypeService.BusinessUpdate(AEntity: TEInvPackagingType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvPackagingTypeService.BusinessDelete(AEntity: TEInvPackagingType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvPackagingTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvPackagingTypeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvPackagingType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvPackagingTypeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvPackagingType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvPackagingTypeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvPackagingType;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvPackagingTypeService.Add(AEntity: TEInvPackagingType);
begin
  DoAdd(AEntity);
end;

procedure TEInvPackagingTypeService.Update(AEntity: TEInvPackagingType);
begin
  DoUpdate(AEntity);
end;

procedure TEInvPackagingTypeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
