unit SysUserSetting.Service;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, UnitOfWork, AppContext,
  SysUserSetting, SysUserSetting.Repository;

type
  // Oturumdaki kullanıcının arayüz ayarları (sys_user_setting). Kullanıcının kendi tercihi: yetki gerekmez.
  TSysUserSettingService = class
  private
    FRepo: TSysUserSettingRepository;
    function CurrentUserId: Int64;
  public
    constructor Create;
    destructor Destroy; override;
    // AKeyPrefix ile başlayan ayarlar ('nav.' gibi); oturum yoksa boş
    function GetValues(const AKeyPrefix: string): TDictionary<string, string>;
    procedure SetValue(const AKey, AValue: string);
  end;

implementation

constructor TSysUserSettingService.Create;
begin
  inherited Create;
  FRepo := TSysUserSettingRepository.Create(TUnitOfWork.Instance.Connection);
end;

destructor TSysUserSettingService.Destroy;
begin
  FRepo.Free;
  inherited;
end;

function TSysUserSettingService.CurrentUserId: Int64;
begin
  Result := 0;
  if TAppContext.IsInitialized and Assigned(TAppContext.Instance.CurrentUser)
    and Assigned(TAppContext.Instance.CurrentUser.User) then
    Result := TAppContext.Instance.CurrentUser.GetUserId;
end;

function TSysUserSettingService.GetValues(const AKeyPrefix: string): TDictionary<string, string>;
begin
  if CurrentUserId <= 0 then
    Exit(TDictionary<string, string>.Create);
  Result := FRepo.GetValues(CurrentUserId, AKeyPrefix);
end;

procedure TSysUserSettingService.SetValue(const AKey, AValue: string);
begin
  if CurrentUserId <= 0 then
    raise Exception.Create('No user session');
  FRepo.SetValue(CurrentUserId, AKey, AValue);
end;

end.
