unit EInvTaxType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvTaxType.Repository, EInvTaxType, EInvTaxType.Exception;

type
  TEInvTaxTypeService = class(TCrudService<TEInvTaxType>)
  private
    FRepo: IRepository<TEInvTaxType>;

    procedure DoAdd(AEntity: TEInvTaxType);
    procedure DoUpdate(AEntity: TEInvTaxType);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvTaxType; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvTaxType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvTaxType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvTaxType; override;

    procedure Add(AEntity: TEInvTaxType); override;
    procedure Update(AEntity: TEInvTaxType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvTaxType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvTaxType>; override;
    procedure BusinessInsert(AEntity: TEInvTaxType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvTaxType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvTaxType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvTaxTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvTaxType, TEInvTaxTypeRepository>;
  Self.PermissionCode := PERMISSION_EINV_TAX_TYPE;
end;

destructor TEInvTaxTypeService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvTaxTypeService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvTaxTypeService.ValidateBusinessRules(AEntity: TEInvTaxType; AOperation: TCrudOperation);
var
  LRepo: TEInvTaxTypeRepository;
begin
  LRepo := TEInvTaxTypeRepository(FRepo);
  if AOperation = coDelete then
  begin
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvTaxType.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvTaxType.ColName, 'Name');

  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvTaxTypeExceptionCodeUnique.Create;
end;

procedure TEInvTaxTypeService.DoAdd(AEntity: TEInvTaxType);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvTaxTypeService.DoUpdate(AEntity: TEInvTaxType);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvTaxTypeService.DoDelete(AId: Int64);
var
  LEntity: TEInvTaxType;
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

function TEInvTaxTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvTaxType>;
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

function TEInvTaxTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvTaxType;
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

procedure TEInvTaxTypeService.BusinessInsert(AEntity: TEInvTaxType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvTaxTypeService.BusinessUpdate(AEntity: TEInvTaxType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvTaxTypeService.BusinessDelete(AEntity: TEInvTaxType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvTaxTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvTaxTypeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvTaxType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvTaxTypeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvTaxType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvTaxTypeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvTaxType;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvTaxTypeService.Add(AEntity: TEInvTaxType);
begin
  DoAdd(AEntity);
end;

procedure TEInvTaxTypeService.Update(AEntity: TEInvTaxType);
begin
  DoUpdate(AEntity);
end;

procedure TEInvTaxTypeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
