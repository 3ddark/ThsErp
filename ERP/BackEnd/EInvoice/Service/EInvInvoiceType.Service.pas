unit EInvInvoiceType.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvInvoiceType.Repository, EInvInvoiceType, EInvInvoiceType.Exception;

type
  TEInvInvoiceTypeService = class(TCrudService<TEInvInvoiceType>)
  private
    FRepo: IRepository<TEInvInvoiceType>;

    procedure DoAdd(AEntity: TEInvInvoiceType);
    procedure DoUpdate(AEntity: TEInvInvoiceType);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvInvoiceType; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvInvoiceType>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvInvoiceType; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvInvoiceType; override;

    procedure Add(AEntity: TEInvInvoiceType); override;
    procedure Update(AEntity: TEInvInvoiceType); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvInvoiceType; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvInvoiceType>; override;
    procedure BusinessInsert(AEntity: TEInvInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvInvoiceTypeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvInvoiceType, TEInvInvoiceTypeRepository>;
  Self.PermissionCode := PERMISSION_EINV_INVOICE_TYPE;
end;

destructor TEInvInvoiceTypeService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvInvoiceTypeService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvInvoiceTypeService.ValidateBusinessRules(AEntity: TEInvInvoiceType; AOperation: TCrudOperation);
var
  LRepo: TEInvInvoiceTypeRepository;
begin
  LRepo := TEInvInvoiceTypeRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvInvoiceTypeExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvInvoiceType.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvInvoiceType.ColName, 'Name');

  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvInvoiceTypeExceptionCodeUnique.Create;
end;

procedure TEInvInvoiceTypeService.DoAdd(AEntity: TEInvInvoiceType);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvInvoiceTypeService.DoUpdate(AEntity: TEInvInvoiceType);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvInvoiceTypeService.DoDelete(AId: Int64);
var
  LEntity: TEInvInvoiceType;
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

function TEInvInvoiceTypeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvInvoiceType>;
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

function TEInvInvoiceTypeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvInvoiceType;
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

procedure TEInvInvoiceTypeService.BusinessInsert(AEntity: TEInvInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvInvoiceTypeService.BusinessUpdate(AEntity: TEInvInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvInvoiceTypeService.BusinessDelete(AEntity: TEInvInvoiceType; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvInvoiceTypeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvInvoiceTypeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvInvoiceType>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvInvoiceTypeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvInvoiceType;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvInvoiceTypeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvInvoiceType;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvInvoiceTypeService.Add(AEntity: TEInvInvoiceType);
begin
  DoAdd(AEntity);
end;

procedure TEInvInvoiceTypeService.Update(AEntity: TEInvInvoiceType);
begin
  DoUpdate(AEntity);
end;

procedure TEInvInvoiceTypeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
