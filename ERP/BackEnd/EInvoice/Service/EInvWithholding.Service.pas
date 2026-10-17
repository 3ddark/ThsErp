unit EInvWithholding.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvWithholding.Repository, EInvWithholding, EInvWithholding.Exception;

type
  TEInvWithholdingService = class(TCrudService<TEInvWithholding>)
  private
    FRepo: IRepository<TEInvWithholding>;

    procedure DoAdd(AEntity: TEInvWithholding);
    procedure DoUpdate(AEntity: TEInvWithholding);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvWithholding; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvWithholding>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvWithholding; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvWithholding; override;

    procedure Add(AEntity: TEInvWithholding); override;
    procedure Update(AEntity: TEInvWithholding); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvWithholding; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvWithholding>; override;
    procedure BusinessInsert(AEntity: TEInvWithholding; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvWithholding; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvWithholding; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvWithholdingService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvWithholding, TEInvWithholdingRepository>;
  Self.PermissionCode := PERMISSION_EINV_WITHHOLDING;
end;

destructor TEInvWithholdingService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvWithholdingService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvWithholdingService.ValidateBusinessRules(AEntity: TEInvWithholding; AOperation: TCrudOperation);
var
  LRepo: TEInvWithholdingRepository;
begin
  LRepo := TEInvWithholdingRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvWithholdingExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvWithholding.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvWithholding.ColName, 'Name');
  if (AEntity.Rate <= 0) or (AEntity.Rate > 100) then
    raise EEInvWithholdingExceptionRateRange.Create;
  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvWithholdingExceptionCodeUnique.Create;
end;

procedure TEInvWithholdingService.DoAdd(AEntity: TEInvWithholding);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvWithholdingService.DoUpdate(AEntity: TEInvWithholding);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvWithholdingService.DoDelete(AId: Int64);
var
  LEntity: TEInvWithholding;
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

function TEInvWithholdingService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvWithholding>;
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

function TEInvWithholdingService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvWithholding;
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

procedure TEInvWithholdingService.BusinessInsert(AEntity: TEInvWithholding; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvWithholdingService.BusinessUpdate(AEntity: TEInvWithholding; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvWithholdingService.BusinessDelete(AEntity: TEInvWithholding; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvWithholdingService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvWithholdingService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvWithholding>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvWithholdingService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvWithholding;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvWithholdingService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvWithholding;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvWithholdingService.Add(AEntity: TEInvWithholding);
begin
  DoAdd(AEntity);
end;

procedure TEInvWithholdingService.Update(AEntity: TEInvWithholding);
begin
  DoUpdate(AEntity);
end;

procedure TEInvWithholdingService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
