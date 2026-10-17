unit EInvPaymentMeans.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvPaymentMeans.Repository, EInvPaymentMeans, EInvPaymentMeans.Exception;

type
  TEInvPaymentMeansService = class(TCrudService<TEInvPaymentMeans>)
  private
    FRepo: IRepository<TEInvPaymentMeans>;

    procedure DoAdd(AEntity: TEInvPaymentMeans);
    procedure DoUpdate(AEntity: TEInvPaymentMeans);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvPaymentMeans; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvPaymentMeans>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvPaymentMeans; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvPaymentMeans; override;

    procedure Add(AEntity: TEInvPaymentMeans); override;
    procedure Update(AEntity: TEInvPaymentMeans); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvPaymentMeans; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvPaymentMeans>; override;
    procedure BusinessInsert(AEntity: TEInvPaymentMeans; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvPaymentMeans; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvPaymentMeans; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvPaymentMeansService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvPaymentMeans, TEInvPaymentMeansRepository>;
  Self.PermissionCode := PERMISSION_EINV_PAYMENT_MEANS;
end;

destructor TEInvPaymentMeansService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvPaymentMeansService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvPaymentMeansService.ValidateBusinessRules(AEntity: TEInvPaymentMeans; AOperation: TCrudOperation);
var
  LRepo: TEInvPaymentMeansRepository;
begin
  LRepo := TEInvPaymentMeansRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvPaymentMeansExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvPaymentMeans.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvPaymentMeans.ColName, 'Name');

  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvPaymentMeansExceptionCodeUnique.Create;
end;

procedure TEInvPaymentMeansService.DoAdd(AEntity: TEInvPaymentMeans);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvPaymentMeansService.DoUpdate(AEntity: TEInvPaymentMeans);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvPaymentMeansService.DoDelete(AId: Int64);
var
  LEntity: TEInvPaymentMeans;
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

function TEInvPaymentMeansService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvPaymentMeans>;
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

function TEInvPaymentMeansService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvPaymentMeans;
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

procedure TEInvPaymentMeansService.BusinessInsert(AEntity: TEInvPaymentMeans; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvPaymentMeansService.BusinessUpdate(AEntity: TEInvPaymentMeans; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvPaymentMeansService.BusinessDelete(AEntity: TEInvPaymentMeans; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvPaymentMeansService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvPaymentMeansService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvPaymentMeans>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvPaymentMeansService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvPaymentMeans;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvPaymentMeansService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvPaymentMeans;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvPaymentMeansService.Add(AEntity: TEInvPaymentMeans);
begin
  DoAdd(AEntity);
end;

procedure TEInvPaymentMeansService.Update(AEntity: TEInvPaymentMeans);
begin
  DoUpdate(AEntity);
end;

procedure TEInvPaymentMeansService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
