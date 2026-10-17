unit EInvTransportMode.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvTransportMode.Repository, EInvTransportMode, EInvTransportMode.Exception;

type
  TEInvTransportModeService = class(TCrudService<TEInvTransportMode>)
  private
    FRepo: IRepository<TEInvTransportMode>;

    procedure DoAdd(AEntity: TEInvTransportMode);
    procedure DoUpdate(AEntity: TEInvTransportMode);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvTransportMode; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvTransportMode>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvTransportMode; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvTransportMode; override;

    procedure Add(AEntity: TEInvTransportMode); override;
    procedure Update(AEntity: TEInvTransportMode); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvTransportMode; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvTransportMode>; override;
    procedure BusinessInsert(AEntity: TEInvTransportMode; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvTransportMode; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvTransportMode; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvTransportModeService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvTransportMode, TEInvTransportModeRepository>;
  Self.PermissionCode := PERMISSION_EINV_TRANSPORT_MODE;
end;

destructor TEInvTransportModeService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvTransportModeService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvTransportModeService.ValidateBusinessRules(AEntity: TEInvTransportMode; AOperation: TCrudOperation);
var
  LRepo: TEInvTransportModeRepository;
begin
  LRepo := TEInvTransportModeRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvTransportModeExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvTransportMode.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvTransportMode.ColName, 'Name');

  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvTransportModeExceptionCodeUnique.Create;
end;

procedure TEInvTransportModeService.DoAdd(AEntity: TEInvTransportMode);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvTransportModeService.DoUpdate(AEntity: TEInvTransportMode);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvTransportModeService.DoDelete(AId: Int64);
var
  LEntity: TEInvTransportMode;
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

function TEInvTransportModeService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvTransportMode>;
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

function TEInvTransportModeService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvTransportMode;
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

procedure TEInvTransportModeService.BusinessInsert(AEntity: TEInvTransportMode; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvTransportModeService.BusinessUpdate(AEntity: TEInvTransportMode; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvTransportModeService.BusinessDelete(AEntity: TEInvTransportMode; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvTransportModeService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvTransportModeService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvTransportMode>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvTransportModeService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvTransportMode;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvTransportModeService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvTransportMode;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvTransportModeService.Add(AEntity: TEInvTransportMode);
begin
  DoAdd(AEntity);
end;

procedure TEInvTransportModeService.Update(AEntity: TEInvTransportMode);
begin
  DoUpdate(AEntity);
end;

procedure TEInvTransportModeService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
