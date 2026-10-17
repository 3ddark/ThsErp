unit EInvDeliveryTerm.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvDeliveryTerm.Repository, EInvDeliveryTerm, EInvDeliveryTerm.Exception;

type
  TEInvDeliveryTermService = class(TCrudService<TEInvDeliveryTerm>)
  private
    FRepo: IRepository<TEInvDeliveryTerm>;

    procedure DoAdd(AEntity: TEInvDeliveryTerm);
    procedure DoUpdate(AEntity: TEInvDeliveryTerm);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvDeliveryTerm; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvDeliveryTerm>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvDeliveryTerm; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvDeliveryTerm; override;

    procedure Add(AEntity: TEInvDeliveryTerm); override;
    procedure Update(AEntity: TEInvDeliveryTerm); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDeliveryTerm; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDeliveryTerm>; override;
    procedure BusinessInsert(AEntity: TEInvDeliveryTerm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvDeliveryTerm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvDeliveryTerm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvDeliveryTermService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvDeliveryTerm, TEInvDeliveryTermRepository>;
  Self.PermissionCode := PERMISSION_EINV_DELIVERY_TERM;
end;

destructor TEInvDeliveryTermService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvDeliveryTermService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvDeliveryTermService.ValidateBusinessRules(AEntity: TEInvDeliveryTerm; AOperation: TCrudOperation);
var
  LRepo: TEInvDeliveryTermRepository;
begin
  LRepo := TEInvDeliveryTermRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvDeliveryTermExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvDeliveryTerm.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvDeliveryTerm.ColName, 'Name');

  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvDeliveryTermExceptionCodeUnique.Create;
end;

procedure TEInvDeliveryTermService.DoAdd(AEntity: TEInvDeliveryTerm);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvDeliveryTermService.DoUpdate(AEntity: TEInvDeliveryTerm);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvDeliveryTermService.DoDelete(AId: Int64);
var
  LEntity: TEInvDeliveryTerm;
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

function TEInvDeliveryTermService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDeliveryTerm>;
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

function TEInvDeliveryTermService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDeliveryTerm;
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

procedure TEInvDeliveryTermService.BusinessInsert(AEntity: TEInvDeliveryTerm; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDeliveryTermService.BusinessUpdate(AEntity: TEInvDeliveryTerm; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDeliveryTermService.BusinessDelete(AEntity: TEInvDeliveryTerm; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvDeliveryTermService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvDeliveryTermService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvDeliveryTerm>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvDeliveryTermService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvDeliveryTerm;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvDeliveryTermService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvDeliveryTerm;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvDeliveryTermService.Add(AEntity: TEInvDeliveryTerm);
begin
  DoAdd(AEntity);
end;

procedure TEInvDeliveryTermService.Update(AEntity: TEInvDeliveryTerm);
begin
  DoUpdate(AEntity);
end;

procedure TEInvDeliveryTermService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
