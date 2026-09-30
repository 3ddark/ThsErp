unit SysUser.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysUser.Repository, SysUser, SysUser.Exception;

type
  TSysUserService = class(TCrudService<TSysUser>)
  private
    FRepo: IRepository<TSysUser>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysUser; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysUser>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysUser; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysUser; override;

    procedure Add(AEntity: TSysUser); override;
    procedure Update(AEntity: TSysUser); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysUser; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysUser>; override;
    procedure BusinessInsert(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean); override;

    // Yönetici: kullanıcının şifresini sıfırlar (kullanıcı yetkisi 1100, güncelleme hakkı)
    procedure ResetPassword(AUserId: Int64; const ANewPassword: string; APermissionControl: Boolean = True);
    // Oturumdaki kullanıcı kendi şifresini değiştirir (yetki gerekmez, eski şifre doğrulanır)
    procedure ChangeOwnPassword(const AOldPassword, ANewPassword: string);
  end;

implementation

uses
  SysPermission.Service, Password.Helper, LocalizationManager,
  SysAccessRight, SysAccessRight.Repository;

// Şifre kuralını uygular, bcrypt hash döner
function HashNewPassword(const ANewPassword: string): string;
var
  LErrorMsg: string;
begin
  if not TPasswordHelper.ValidatePasswordStrength(ANewPassword, LErrorMsg) then
    raise Exception.Create(LErrorMsg);
  Result := TPasswordHelper.HashPassword(ANewPassword);
end;

constructor TSysUserService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysUser, TSysUserRepository>;
  Self.PermissionCode := PERMISSION_SYS_USER;
end;

destructor TSysUserService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

procedure TSysUserService.ResetPassword(AUserId: Int64; const ANewPassword: string; APermissionControl: Boolean);
var
  LHash: string;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

  LHash := HashNewPassword(ANewPassword);

  if not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  try
    if not TSysUserRepository(FRepo).UpdatePasswordHash(AUserId, LHash) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AUserId]));
    Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysUserService.ChangeOwnPassword(const AOldPassword, ANewPassword: string);
var
  LUserId: Int64;
  LHash: string;
begin
  LUserId := 0;
  if Assigned(TAppContext.Instance.CurrentUser) then
    LUserId := TAppContext.Instance.CurrentUser.GetUserId;
  if LUserId <= 0 then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSecurity.UserNotAuthenticated, 'User is not authenticated.'));

  if not TPasswordHelper.VerifyPassword(AOldPassword, TSysUserRepository(FRepo).GetPasswordHash(LUserId)) then
    raise ESysUserExceptionOldPasswordInvalid.Create;

  LHash := HashNewPassword(ANewPassword);

  if not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  try
    if not TSysUserRepository(FRepo).UpdatePasswordHash(LUserId, LHash) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [LUserId]));
    Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysUserService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysUser>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

function TSysUserService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysUser;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

procedure TSysUserService.BusinessInsert(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LErrorMsg: string;
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    ValidateAll(AEntity, coInsert);

    // Formdan düz metin gelir; DB'ye yalnızca bcrypt hash yazılır
    if not AEntity.UserPassword.StartsWith('$2') then
    begin
      if not TPasswordHelper.ValidatePasswordStrength(AEntity.UserPassword, LErrorMsg) then
        raise Exception.Create(LErrorMsg);
      AEntity.UserPassword := TPasswordHelper.HashPassword(AEntity.UserPassword);
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    // Erişim hakları ekranında tüm yetkiler görünsün: her yetki için tüm haklar false satır
    // (etkin yetkiyi değiştirmez: şablonlar OR false AND NOT false = şablon)
    TSysAccessRightRepository(Self.UoW.GetRepository<TSysAccessRight, TSysAccessRightRepository>)
      .AddAllPermissionsToUser(AEntity.Id);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysUserService.BusinessUpdate(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    ValidateAll(AEntity, coUpdate);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysUserService.BusinessDelete(AEntity: TSysUser; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    ValidateAll(AEntity, coDelete);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

function TSysUserService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysUserService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysUser>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysUserService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysUser;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysUserService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysUser;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysUserService.Add(AEntity: TSysUser);
begin
  FRepo.Add(AEntity);
end;

procedure TSysUserService.Update(AEntity: TSysUser);
begin
  FRepo.Update(AEntity);
end;

procedure TSysUserService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysUserService.ValidateBusinessRules(AEntity: TSysUser; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysUser;
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin
    // Kullanıcı adı standardı: boşluksuz + büyük harf (login ekranı da büyük harfe çevirir)
    AEntity.Username := AnsiUpperCase(Trim(AEntity.Username));

    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('username', '=', TValue.From<string>(AEntity.Username)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise ESysUserExceptionUsernameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

end.

