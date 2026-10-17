unit EInvGtip.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvGtip.Repository, EInvGtip, EInvGtip.Exception;

type
  TEInvGtipService = class(TCrudService<TEInvGtip>)
  private
    FRepo: IRepository<TEInvGtip>;

    procedure DoAdd(AEntity: TEInvGtip);
    procedure DoUpdate(AEntity: TEInvGtip);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvGtip; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvGtip>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvGtip; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvGtip; override;

    procedure Add(AEntity: TEInvGtip); override;
    procedure Update(AEntity: TEInvGtip); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvGtip; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvGtip>; override;
    procedure BusinessInsert(AEntity: TEInvGtip; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvGtip; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvGtip; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvGtipService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvGtip, TEInvGtipRepository>;
  Self.PermissionCode := PERMISSION_STK_GTIP;
end;

destructor TEInvGtipService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvGtipService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvGtipService.ValidateBusinessRules(AEntity: TEInvGtip; AOperation: TCrudOperation);
var
  LRepo: TEInvGtipRepository;
begin
  LRepo := TEInvGtipRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvGtipExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := TEInvLookup.NormalizeGtip(AEntity.Code);
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvGtip.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvGtip.ColName, 'Name');

  if not TEInvLookup.IsValidGtip(AEntity.Code) then
    raise EEInvGtipExceptionCodeInvalid.Create;
  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvGtipExceptionCodeUnique.Create;
end;

procedure TEInvGtipService.DoAdd(AEntity: TEInvGtip);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvGtipService.DoUpdate(AEntity: TEInvGtip);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvGtipService.DoDelete(AId: Int64);
var
  LEntity: TEInvGtip;
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

function TEInvGtipService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvGtip>;
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

function TEInvGtipService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvGtip;
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

procedure TEInvGtipService.BusinessInsert(AEntity: TEInvGtip; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvGtipService.BusinessUpdate(AEntity: TEInvGtip; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvGtipService.BusinessDelete(AEntity: TEInvGtip; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvGtipService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvGtipService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvGtip>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvGtipService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvGtip;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvGtipService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvGtip;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvGtipService.Add(AEntity: TEInvGtip);
begin
  DoAdd(AEntity);
end;

procedure TEInvGtipService.Update(AEntity: TEInvGtip);
begin
  DoUpdate(AEntity);
end;

procedure TEInvGtipService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
