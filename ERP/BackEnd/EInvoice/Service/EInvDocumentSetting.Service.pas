unit EInvDocumentSetting.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvDocumentSetting.Repository, EInvDocumentSetting, EInvDocumentSetting.Exception;

type
  TEInvDocumentSettingService = class(TCrudService<TEInvDocumentSetting>)
  private
    FRepo: IRepository<TEInvDocumentSetting>;

    procedure DoAdd(AEntity: TEInvDocumentSetting);
    procedure DoUpdate(AEntity: TEInvDocumentSetting);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvDocumentSetting; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvDocumentSetting>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvDocumentSetting; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvDocumentSetting; override;

    procedure Add(AEntity: TEInvDocumentSetting); override;
    procedure Update(AEntity: TEInvDocumentSetting); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDocumentSetting; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDocumentSetting>; override;
    procedure BusinessInsert(AEntity: TEInvDocumentSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvDocumentSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvDocumentSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvDocumentSettingService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvDocumentSetting, TEInvDocumentSettingRepository>;
  Self.PermissionCode := PERMISSION_EINV_DOCUMENT_SETTING;
end;

destructor TEInvDocumentSettingService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvDocumentSettingService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvDocumentSettingService.ValidateBusinessRules(AEntity: TEInvDocumentSetting; AOperation: TCrudOperation);
var
  LRepo: TEInvDocumentSettingRepository;
begin
  LRepo := TEInvDocumentSettingRepository(FRepo);
  if AOperation = coDelete then
    Exit;

  AEntity.SenderAlias := Trim(AEntity.SenderAlias);
  if not TEInvLookup.IsValid(elkSeriesScope, AEntity.SeriesScope) then
    FailRequired(TLangKeys.TEInvDocumentSetting.ColSeriesScope, 'Document Type');
  if AEntity.SysApplicationSettingId <= 0 then
    AEntity.SysApplicationSettingId := LRepo.ApplicationSettingId;
  if AEntity.SysApplicationSettingId <= 0 then
    raise EEInvDocumentSettingExceptionNoCompany.Create;
  if (AEntity.EinvSeriesId > 0) and (LRepo.SeriesScopeOf(AEntity.EinvSeriesId) <> AEntity.SeriesScope) then
    raise EEInvDocumentSettingExceptionSeriesScope.Create;
  if LRepo.ScopeExists(AEntity.SysApplicationSettingId, AEntity.SeriesScope,
    TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvDocumentSettingExceptionScopeUnique.Create;
end;

procedure TEInvDocumentSettingService.DoAdd(AEntity: TEInvDocumentSetting);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvDocumentSettingService.DoUpdate(AEntity: TEInvDocumentSetting);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvDocumentSettingService.DoDelete(AId: Int64);
var
  LEntity: TEInvDocumentSetting;
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

function TEInvDocumentSettingService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvDocumentSetting>;
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

function TEInvDocumentSettingService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvDocumentSetting;
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

procedure TEInvDocumentSettingService.BusinessInsert(AEntity: TEInvDocumentSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDocumentSettingService.BusinessUpdate(AEntity: TEInvDocumentSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvDocumentSettingService.BusinessDelete(AEntity: TEInvDocumentSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvDocumentSettingService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvDocumentSettingService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvDocumentSetting>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvDocumentSettingService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvDocumentSetting;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvDocumentSettingService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvDocumentSetting;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvDocumentSettingService.Add(AEntity: TEInvDocumentSetting);
begin
  DoAdd(AEntity);
end;

procedure TEInvDocumentSettingService.Update(AEntity: TEInvDocumentSetting);
begin
  DoUpdate(AEntity);
end;

procedure TEInvDocumentSettingService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
