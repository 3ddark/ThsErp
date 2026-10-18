unit SysApiService.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  SysApiService.Repository, SysApiService, SysApiService.Exception;

type
  TSysApiServiceService = class(TCrudService<TSysApiService>)
  private
    FRepo: IRepository<TSysApiService>;

    procedure DoAdd(AEntity: TSysApiService);
    procedure DoUpdate(AEntity: TSysApiService);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
    // düz metin gizli bilgileri şifreler (boş = değişmez)
    procedure EncryptSecrets(AEntity: TSysApiService);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysApiService; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysApiService>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysApiService; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysApiService; override;

    procedure Add(AEntity: TSysApiService); override;
    procedure Update(AEntity: TSysApiService); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysApiService; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysApiService>; override;
    procedure BusinessInsert(AEntity: TSysApiService; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysApiService; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysApiService; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, SysLookup, System.JSON, Ths.Globals, Ths.Constants;

constructor TSysApiServiceService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysApiService, TSysApiServiceRepository>;
  Self.PermissionCode := PERMISSION_SYS_API_SERVICE;
end;

destructor TSysApiServiceService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TSysApiServiceService.EncryptSecrets(AEntity: TSysApiService);
begin
  AEntity.PasswordEnc := '';
  AEntity.ApiKeyEnc := '';
  if AEntity.Password <> '' then
    AEntity.PasswordEnc := EncryptStr(AEntity.Password, SECURE_KEY);
  if AEntity.ApiKey <> '' then
    AEntity.ApiKeyEnc := EncryptStr(AEntity.ApiKey, SECURE_KEY);
end;

procedure TSysApiServiceService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TSysApiServiceService.ValidateBusinessRules(AEntity: TSysApiService; AOperation: TCrudOperation);
var
  LRepo: TSysApiServiceRepository;
  LJson: TJSONValue;
begin
  LRepo := TSysApiServiceRepository(FRepo);
  if AOperation = coDelete then
    Exit;

  AEntity.ServiceKind := LowerCase(Trim(AEntity.ServiceKind));
  AEntity.ProviderCode := AnsiUpperCase(Trim(AEntity.ProviderCode));
  AEntity.BaseUrl := Trim(AEntity.BaseUrl);
  AEntity.Username := Trim(AEntity.Username);
  AEntity.Description := Trim(AEntity.Description);
  AEntity.Options := Trim(AEntity.Options);
  if AEntity.Options = '' then
    AEntity.Options := '{}';
  if not TSysLookup.IsValidServiceKind(AEntity.ServiceKind) then
    raise ESysApiServiceExceptionKindInvalid.Create;
  if not TSysLookup.IsValid(sylApiEnvironment, AEntity.Environment) then
    FailRequired(TLangKeys.TSysApiService.ColEnvironment, 'Environment');
  if AEntity.TimeoutSeconds <= 0 then
    AEntity.TimeoutSeconds := 60;
  if AEntity.TimeoutSeconds > 3600 then
    raise ESysApiServiceExceptionTimeoutRange.Create;
  LJson := TJSONObject.ParseJSONValue(AEntity.Options);
  try
    if not (LJson is TJSONObject) then
      raise ESysApiServiceExceptionOptionsInvalid.Create;
  finally
    LJson.Free;
  end;
  // tek firma ayarı: kayıt ona bağlanır
  if AEntity.SysApplicationSettingId <= 0 then
    AEntity.SysApplicationSettingId := LRepo.ApplicationSettingId;
  if AEntity.SysApplicationSettingId <= 0 then
    raise ESysApiServiceExceptionNoCompany.Create;
  if LRepo.KindExists(AEntity.SysApplicationSettingId, AEntity.ServiceKind,
    TSysLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise ESysApiServiceExceptionKindUnique.Create;
  // gizli bilgiler: yazılan değer şifrelenir; boş = değişmez, "sil" işaretiyle silinir
  EncryptSecrets(AEntity);
end;

procedure TSysApiServiceService.DoAdd(AEntity: TSysApiService);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysApiServiceService.DoUpdate(AEntity: TSysApiService);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysApiServiceService.DoDelete(AId: Int64);
var
  LEntity: TSysApiService;
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

function TSysApiServiceService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysApiService>;
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

function TSysApiServiceService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysApiService;
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

procedure TSysApiServiceService.BusinessInsert(AEntity: TSysApiService; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysApiServiceService.BusinessUpdate(AEntity: TSysApiService; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSysApiServiceService.BusinessDelete(AEntity: TSysApiService; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSysApiServiceService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysApiServiceService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysApiService>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysApiServiceService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysApiService;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysApiServiceService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysApiService;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysApiServiceService.Add(AEntity: TSysApiService);
begin
  DoAdd(AEntity);
end;

procedure TSysApiServiceService.Update(AEntity: TSysApiService);
begin
  DoUpdate(AEntity);
end;

procedure TSysApiServiceService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
