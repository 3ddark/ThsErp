unit ApiService.Config;

// Dış servis (API) bağlantı ayarlarının okunduğu gevşek bağlı uç: modüller (e-Fatura, e-İrsaliye, ileride SMS / döviz kuru
// ...) yalnız servis türü koduyla TApiServiceConfigs.Get çağırır; ayarın nereden geldiğini bilmez. Kaynak (IApiServiceConfigSource)
// uygulama tarafından kaydedilir (bu uygulamada SysApiService.ConfigSource: sys_api_service tablosu). Bağımlılık yok:
// framework olarak tek başına paylaşılabilir.

interface

uses
  System.SysUtils, System.JSON;

const
  API_ENV_TEST = 1;
  API_ENV_LIVE = 2;

type
  TApiServiceConfig = record
    Found: Boolean;              // servis türü için kayıt var
    Active: Boolean;
    Kind: string;                // servis türü kodu (einvoice, earchive, edespatch ...)
    ProviderCode: string;        // sağlayıcı / entegratör kodu
    Environment: Integer;        // API_ENV_TEST / API_ENV_LIVE
    BaseUrl: string;
    Username: string;
    Password: string;            // çözülmüş
    ApiKey: string;              // çözülmüş
    TimeoutSeconds: Integer;
    Options: string;             // sağlayıcıya özel ayarlar (JSON nesnesi)
    function IsTest: Boolean;
    // Options içindeki metin değer (yoksa ADefault)
    function Option(const AName: string; const ADefault: string = ''): string;
  end;

  IApiServiceConfigSource = interface
    ['{6C0B6D9E-2B47-4F64-9A2C-3E8F1B7D5A10}']
    function Load(const AKind: string; out AConfig: TApiServiceConfig): Boolean;
  end;

  TApiServiceConfigs = class
  private
    class var FSource: IApiServiceConfigSource;
  public
    class procedure RegisterSource(const ASource: IApiServiceConfigSource);
    // Kaynak yoksa / kayıt yoksa Found = False
    class function Get(const AKind: string): TApiServiceConfig;
  end;

implementation

function TApiServiceConfig.IsTest: Boolean;
begin
  Result := Environment <> API_ENV_LIVE;
end;

function TApiServiceConfig.Option(const AName, ADefault: string): string;
var
  LJson: TJSONValue;
  LValue: TJSONValue;
begin
  Result := ADefault;
  if Trim(Options) = '' then
    Exit;
  LJson := TJSONObject.ParseJSONValue(Options);
  try
    if LJson is TJSONObject then
    begin
      LValue := TJSONObject(LJson).GetValue(AName);
      if Assigned(LValue) and not (LValue is TJSONNull) then
        Result := LValue.Value;
    end;
  finally
    LJson.Free;
  end;
end;

class procedure TApiServiceConfigs.RegisterSource(const ASource: IApiServiceConfigSource);
begin
  FSource := ASource;
end;

class function TApiServiceConfigs.Get(const AKind: string): TApiServiceConfig;
begin
  Result := Default(TApiServiceConfig);
  Result.Kind := AKind;
  if Assigned(FSource) and FSource.Load(AKind, Result) then
    Result.Found := True;
end;

end.
