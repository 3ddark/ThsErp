unit EInvIntegrator;

// e-Belge özel entegratör sözleşmesi (sağlayıcıdan bağımsız). Her sağlayıcı (eLogo, ileride QNB eFinans, Uyumsoft ...) kendi
// biriminde IEInvIntegrator'ı uygular ve initialization'da kodunu kaydeder (TEInvIntegrators.RegisterProvider). Hangi
// sağlayıcının kullanılacağı sys_api_service.provider_code'dan gelir (e-Belge Ayarları -> API servisi). Servis katmanı yalnız
// bu birimi bilir; SOAP / REST ayrıntısı sağlayıcı biriminde kalır. Sağlayıcı hataları EEInvIntegratorException ile döner.

interface

uses
  System.SysUtils, System.Generics.Collections, ApiService.Config;

type
  EEInvIntegratorException = class(Exception);

  TEInvDocKind = (edkInvoice, edkArchive, edkDespatch);

  TEInvSendRequest = record
    Kind: TEInvDocKind;
    Uuid: string;              // ETTN
    EInvNo: string;            // GİB belge no
    Xml: string;               // UBL-TR belge (imzasız; entegratör mali mühürle imzalar)
    SenderAlias: string;       // firmanın GB etiketi (e-Arşivde boş)
    ReceiverAlias: string;     // alıcının PK etiketi (e-Arşivde boş)
    ReceiverTaxNo: string;
  end;

  TEInvSendResult = record
    ProviderRef: string;       // sağlayıcının kayıt / zarf numarası
    Message: string;
  end;

  // Uzak durumun uygulamadaki karşılığı (sls_invoice / sls_dispatch.einv_status için servis eşler)
  TEInvRemoteStatus = (ersUnknown, ersProcessing, ersDelivered, ersAccepted, ersRejected, ersFailed, ersCancelled);

  TEInvStatusResult = record
    Status: TEInvRemoteStatus;
    Code: Integer;             // sağlayıcının / GİB'in durum kodu
    Description: string;
  end;

  // GİB mükellef listesi sorgusu: e-Fatura / e-İrsaliye etiketleri (boş liste = o sistemde kayıtlı değil)
  TEInvTaxpayerInfo = record
    Found: Boolean;
    TaxNo: string;
    Title: string;
    InvoicePkAliases: TArray<string>;
    InvoiceGbAliases: TArray<string>;
    DespatchPkAliases: TArray<string>;
    DespatchGbAliases: TArray<string>;
  end;

  IEInvIntegrator = interface
    ['{4E2A9C61-7B3D-4F18-A5E0-9D6C2B8F1A37}']
    // Bağlantı + kimlik doğrulama denemesi; sonuç metni (ör. servis sürümü)
    function TestConnection: string;
    function Send(const ARequest: TEInvSendRequest): TEInvSendResult;
    function QueryStatus(AKind: TEInvDocKind; const AUuid: string): TEInvStatusResult;
    function QueryTaxpayer(const ATaxNo: string): TEInvTaxpayerInfo;
  end;

  TEInvIntegratorFactory = reference to function(const AConfig: TApiServiceConfig): IEInvIntegrator;

  TEInvIntegrators = class
  private
    class var FFactories: TDictionary<string, TEInvIntegratorFactory>;
    class destructor Destroy;
  public
    // AProviderCode: sys_api_service.provider_code (büyük harf; ör. ELOGO)
    class procedure RegisterProvider(const AProviderCode: string; const AFactory: TEInvIntegratorFactory);
    class function IsRegistered(const AProviderCode: string): Boolean;
    class function ProviderCodes: TArray<string>;
    // Kayıtlı değilse EEInvIntegratorException
    class function CreateFor(const AConfig: TApiServiceConfig): IEInvIntegrator;
  end;

implementation

class destructor TEInvIntegrators.Destroy;
begin
  FreeAndNil(FFactories);
end;

class procedure TEInvIntegrators.RegisterProvider(const AProviderCode: string; const AFactory: TEInvIntegratorFactory);
begin
  if not Assigned(FFactories) then
    FFactories := TDictionary<string, TEInvIntegratorFactory>.Create;
  FFactories.AddOrSetValue(UpperCase(Trim(AProviderCode)), AFactory);
end;

class function TEInvIntegrators.IsRegistered(const AProviderCode: string): Boolean;
begin
  Result := Assigned(FFactories) and FFactories.ContainsKey(UpperCase(Trim(AProviderCode)));
end;

class function TEInvIntegrators.ProviderCodes: TArray<string>;
begin
  if Assigned(FFactories) then
    Result := FFactories.Keys.ToArray
  else
    Result := [];
  TArray.Sort<string>(Result);
end;

class function TEInvIntegrators.CreateFor(const AConfig: TApiServiceConfig): IEInvIntegrator;
var
  LFactory: TEInvIntegratorFactory;
begin
  if not Assigned(FFactories) or not FFactories.TryGetValue(UpperCase(Trim(AConfig.ProviderCode)), LFactory) then
    raise EEInvIntegratorException.CreateFmt('Unknown e-document provider "%s" (registered: %s)',
      [AConfig.ProviderCode, string.Join(', ', ProviderCodes)]);
  Result := LFactory(AConfig);
end;

end.
