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
  TSysMenuService = class
  private
    FRepo: TSysMenuRepository;
  public
    constructor Create;
    destructor Destroy; override;
    function GetMenu: TArray<TSysMenuItem>;
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

  Result := FRepo.GetItems(TAppContext.Instance.CurrentUser.ActiveLanguage);
  for I := 0 to High(Result) do
    Result[I].Allowed := CanRead(Result[I].PermissionCode);
end;

end.
