unit SysApiService.ConfigSource;

// TApiServiceConfigs kaynağı: sys_api_service (firma ayarına bağlı servis kaydı) + gizli bilgilerin çözülmesi. Birim
// yüklenince kendini kaydeder; modüller yalnız ApiService.Config'i kullanır.

interface

uses
  System.SysUtils, ApiService.Config;

type
  TSysApiServiceConfigSource = class(TInterfacedObject, IApiServiceConfigSource)
  public
    function Load(const AKind: string; out AConfig: TApiServiceConfig): Boolean;
  end;

implementation

uses
  FireDAC.Comp.Client, AppContext, SysApiService.Repository, Ths.Globals, Ths.Constants;

function TSysApiServiceConfigSource.Load(const AKind: string; out AConfig: TApiServiceConfig): Boolean;
var
  LConn: TFDConnection;
  LRepo: TSysApiServiceRepository;
  LPasswordEnc, LApiKeyEnc: string;
begin
  AConfig := Default(TApiServiceConfig);
  AConfig.Kind := AKind;
  Result := False;
  if not TAppContext.IsInitialized then
    Exit;
  LConn := TAppContext.Instance.DBConnection;
  if (LConn = nil) or not LConn.Connected then
    Exit;
  LRepo := TSysApiServiceRepository.Create(LConn);
  try
    Result := LRepo.LoadConfig(AKind, AConfig, LPasswordEnc, LApiKeyEnc);
    if not Result then
      Exit;
    if LPasswordEnc <> '' then
      AConfig.Password := DecryptStr(LPasswordEnc, SECURE_KEY);
    if LApiKeyEnc <> '' then
      AConfig.ApiKey := DecryptStr(LApiKeyEnc, SECURE_KEY);
  finally
    LRepo.Free;
  end;
end;

initialization
  TApiServiceConfigs.RegisterSource(TSysApiServiceConfigSource.Create);

end.
