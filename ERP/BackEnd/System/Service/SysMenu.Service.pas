unit SysMenu.Service;

interface

{$I Ths.inc}

uses
  System.SysUtils, UnitOfWork, AppContext,
  SysMenu, SysMenu.Repository;

type
  // Menü ağacı + ekran kodları. Her satırın Allowed bayrağı kullanıcının OKUMA yetkisine göre doldurulur
  // (super user hepsi; yetkisiz satır = herkese açık). Menüyü okumak için ayrıca yetki gerekmez.
  // Not: bu yalnız menü görünürlüğüdür; ekranlar (TfrmGrid) ve servisler yetkiyi ayrıca denetler.
  // Favori / son açılma: oturumdaki kullanıcının kendi tercihi, yetki gerekmez; yalnız ekran (klasör değil) satırları.
  // Yazma ana bağlantıda yapılır: başka bir ekranın açık transaction'ı varsa onunla birlikte commit / rollback olur.
  TSysMenuService = class
  private
    FRepo: TSysMenuRepository;
    function CurrentUserId: Int64;
    function ScreenId(AMenuCode: Integer): Int64;
  public
    constructor Create;
    destructor Destroy; override;
    function GetMenu: TArray<TSysMenuItem>;
    procedure SetFavorite(AMenuCode: Integer; AValue: Boolean);
    // ekran açıldı: son kullanılanlar + açılma sayısı
    procedure RegisterOpen(AMenuCode: Integer);
  end;

implementation

uses
  SysAccessRight.Service;

constructor TSysMenuService.Create;
begin
  inherited Create;
  FRepo := TSysMenuRepository.Create(TUnitOfWork.Instance.Connection);
end;

destructor TSysMenuService.Destroy;
begin
  FRepo.Free;
  inherited;
end;

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
  Result := FRepo.GetScreenId(AMenuCode);
  if Result <= 0 then
    raise Exception.CreateFmt('Menu screen not found: %d', [AMenuCode]);
end;

procedure TSysMenuService.SetFavorite(AMenuCode: Integer; AValue: Boolean);
begin
  FRepo.SetFavorite(CurrentUserId, ScreenId(AMenuCode), AValue);
end;

procedure TSysMenuService.RegisterOpen(AMenuCode: Integer);
begin
  FRepo.RegisterOpen(CurrentUserId, ScreenId(AMenuCode));
end;

function TSysMenuService.GetMenu: TArray<TSysMenuItem>;
var
  LSuperUser: Boolean;
  LReadable: TArray<Integer>;
  LSvc: TSysAccessRightService;
  I: Integer;

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

  Result := FRepo.GetItems(TAppContext.Instance.CurrentUser.ActiveLanguage, TAppContext.Instance.CurrentUser.GetUserId);
  for I := 0 to High(Result) do
    Result[I].Allowed := CanRead(Result[I].PermissionCode);
end;

end.
