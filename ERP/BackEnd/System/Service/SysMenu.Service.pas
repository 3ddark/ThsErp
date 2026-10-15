unit SysMenu.Service;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Rtti, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, UnitOfWork, AppContext, FilterCriterion, Core.Exception, SharedFormTypes,
  SysMenu, SysMenu.Repository, SysMenu.Exception;

type
  TAppExceptionClass = class of EAppException;

  // Menü (sys_menu): bakım ekranı CRUD'u (yetki 1111) + menü ağacı + ekran kodları + kullanıcının menü tercihleri.
  //  - GetMenu: IsActive etkin değerdir (pasif klasörün altındakiler de pasif); her satırın Allowed bayrağı kullanıcının OKUMA yetkisine göre (super user hepsi; yetkisiz satır = herkese
  //    açık). Menüyü okumak için ayrıca yetki gerekmez; ekranlar (TfrmGrid) ve servisler yetkiyi yine denetler.
  //  - Favori / son açılma: oturumdaki kullanıcının kendi tercihi, yetki gerekmez; yalnız ekran (klasör değil) satırları.
  //    Yazma ana bağlantıda yapılır: başka bir ekranın açık transaction'ı varsa onunla birlikte commit / rollback olur.
  //  - Bakım kuralları: kod MMGGSS ve üst klasörü mevcut; klasör action / yetki almaz, ekran action ister; kod / anahtar /
  //    action benzersiz ve eklendikten sonra değişmez; silme yok (kodlar kalıcı) -> pasif yapılır.
  TSysMenuService = class(TCrudService<TSysMenu>)
  private
    FRepo: IRepository<TSysMenu>;
    function MenuRepo: TSysMenuRepository;
    function CurrentUserId: Int64;
    function ScreenId(AMenuCode: Integer): Int64;
    procedure CheckUnique(AEntity: TSysMenu; AOperation: TCrudOperation; const AColumn: string; const AValue: TValue;
      AErrorClass: TAppExceptionClass);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysMenu; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysMenu>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysMenu; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysMenu; override;
    procedure Add(AEntity: TSysMenu); override;
    procedure Update(AEntity: TSysMenu); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysMenu; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysMenu>; override;
    procedure BusinessInsert(AEntity: TSysMenu; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysMenu; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysMenu; AWithBegin, AWithCommit, APermissionControl: Boolean); override;

    function GetMenu: TArray<TSysMenuItem>;
    procedure SetFavorite(AMenuCode: Integer; AValue: Boolean);
    // ekran açıldı: son kullanılanlar + açılma sayısı
    procedure RegisterOpen(AMenuCode: Integer);
  end;

implementation

uses
  SysPermission.Service, SysAccessRight.Service;

constructor TSysMenuService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysMenu, TSysMenuRepository>;
  Self.PermissionCode := PERMISSION_SYS_MENU;
end;

destructor TSysMenuService.Destroy;
begin
  inherited;
end;

function TSysMenuService.MenuRepo: TSysMenuRepository;
begin
  Result := TSysMenuRepository(FRepo);
end;

{ CRUD }

function TSysMenuService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysMenuService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysMenu>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysMenuService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysMenu;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysMenuService.FindOne(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TSysMenu;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysMenuService.Add(AEntity: TSysMenu);
begin
  FRepo.Add(AEntity);
end;

procedure TSysMenuService.Update(AEntity: TSysMenu);
begin
  FRepo.Update(AEntity);
end;

procedure TSysMenuService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

function TSysMenuService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysMenu>;
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

function TSysMenuService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysMenu;
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

procedure TSysMenuService.BusinessInsert(AEntity: TSysMenu; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);
    ValidateAll(AEntity, coInsert);
    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;
    FRepo.Add(AEntity);
    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysMenuService.BusinessUpdate(AEntity: TSysMenu; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);
    ValidateAll(AEntity, coUpdate);
    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;
    FRepo.Update(AEntity);
    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysMenuService.BusinessDelete(AEntity: TSysMenu; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);
    ValidateAll(AEntity, coDelete);
    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;
    FRepo.Delete(AEntity);
    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysMenuService.CheckUnique(AEntity: TSysMenu; AOperation: TCrudOperation; const AColumn: string;
  const AValue: TValue; AErrorClass: TAppExceptionClass);
var
  LFilter: TFilterCriteria;
  LModel: TSysMenu;
begin
  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New(AColumn, '=', AValue));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise AErrorClass.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TSysMenuService.ValidateBusinessRules(AEntity: TSysMenu; AOperation: TCrudOperation);
var
  LOld, LParent: TSysMenu;
  LFilter: TFilterCriteria;
  LParentCode: Integer;
begin
  if AOperation = coDelete then
    raise ESysMenuExceptionNoDelete.Create;

  AEntity.MenuKey := Trim(AEntity.MenuKey);
  AEntity.ActionName := Trim(AEntity.ActionName);

  if (AEntity.MenuCode < 100000) or (AEntity.MenuCode > 999999) then
    raise ESysMenuExceptionCodeRange.Create;
  if AEntity.IsFolder then
  begin
    if (AEntity.ActionName <> '') or (AEntity.SysPermissionId > 0) then
      raise ESysMenuExceptionFolderRule.Create;
  end
  else if AEntity.ActionName = '' then
    raise ESysMenuExceptionFolderRule.Create;

  if AOperation = coUpdate then
  begin
    LOld := FRepo.FindById(AEntity.Id, False);
    try
      if Assigned(LOld) and ((LOld.MenuCode <> AEntity.MenuCode) or (LOld.MenuKey <> AEntity.MenuKey)
        or (LOld.ActionName <> AEntity.ActionName)) then
        raise ESysMenuExceptionImmutable.Create;
    finally
      LOld.Free;
    end;
  end;

  // üst klasör: modülde yok, grupta modül, ekranda grup
  if AEntity.MenuCode mod 10000 <> 0 then
  begin
    if AEntity.IsFolder then
      LParentCode := AEntity.MenuCode div 10000 * 10000
    else
      LParentCode := AEntity.MenuCode div 100 * 100;
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('menu_code', '=', TValue.From<Integer>(LParentCode)));
      LParent := FRepo.FindOne(LFilter, False);
      try
        if not Assigned(LParent) then
          raise ESysMenuExceptionParentMissing.Create;
      finally
        LParent.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;

  CheckUnique(AEntity, AOperation, 'menu_code', TValue.From<Integer>(AEntity.MenuCode), ESysMenuExceptionCodeUnique);
  CheckUnique(AEntity, AOperation, 'menu_key', TValue.From<string>(AEntity.MenuKey), ESysMenuExceptionKeyUnique);
  if AEntity.ActionName <> '' then
    CheckUnique(AEntity, AOperation, 'action_name', TValue.From<string>(AEntity.ActionName), ESysMenuExceptionActionUnique);
end;

{ menü ağacı + kullanıcı tercihleri }

function TSysMenuService.CurrentUserId: Int64;
begin
  Result := 0;
  if TAppContext.IsInitialized and Assigned(TAppContext.Instance.CurrentUser)
    and Assigned(TAppContext.Instance.CurrentUser.User) then
    Result := TAppContext.Instance.CurrentUser.GetUserId;
  if Result <= 0 then
    raise Exception.Create('No user session');
end;

function TSysMenuService.ScreenId(AMenuCode: Integer): Int64;
begin
  Result := MenuRepo.GetScreenId(AMenuCode);
  if Result <= 0 then
    raise Exception.CreateFmt('Menu screen not found: %d', [AMenuCode]);
end;

procedure TSysMenuService.SetFavorite(AMenuCode: Integer; AValue: Boolean);
begin
  MenuRepo.SetFavorite(CurrentUserId, ScreenId(AMenuCode), AValue);
end;

procedure TSysMenuService.RegisterOpen(AMenuCode: Integer);
begin
  MenuRepo.RegisterOpen(CurrentUserId, ScreenId(AMenuCode));
end;

function TSysMenuService.GetMenu: TArray<TSysMenuItem>;
var
  LSuperUser: Boolean;
  LReadable: TArray<Integer>;
  LSvc: TSysAccessRightService;
  I: Integer;
  LActive: TDictionary<Integer, Boolean>;
  LParentActive: Boolean;

  function CanRead(ACode: Integer): Boolean;
  var
    LCode: Integer;
  begin
    if LSuperUser or (ACode = 0) then
      Exit(True);
    for LCode in LReadable do
      if LCode = ACode then
        Exit(True);
    Result := False;
  end;

begin
  Result := [];
  if not TAppContext.IsInitialized or not Assigned(TAppContext.Instance.CurrentUser) then
    Exit;

  LSuperUser := TAppContext.Instance.CurrentUser.IsSuperUser;
  LReadable := [];
  if not LSuperUser then
  begin
    LSvc := TSysAccessRightService.Create;
    try
      LReadable := LSvc.GetReadablePermissionCodes;
    finally
      LSvc.Free;
    end;
  end;

  Result := MenuRepo.GetItems(TAppContext.Instance.CurrentUser.ActiveLanguage, TAppContext.Instance.CurrentUser.GetUserId);
  // etkin aktiflik: pasif klasörün altındakiler de pasif (satırlar kod sırasında: üst her zaman önce gelir)
  LActive := TDictionary<Integer, Boolean>.Create;
  try
    for I := 0 to High(Result) do
    begin
      if LActive.TryGetValue(Result[I].ParentCode, LParentActive) and not LParentActive then
        Result[I].IsActive := False;
      LActive.AddOrSetValue(Result[I].MenuCode, Result[I].IsActive);
      Result[I].Allowed := CanRead(Result[I].PermissionCode);
    end;
  finally
    LActive.Free;
  end;
end;

end.
