unit EInvIntegrator.ELogo;

// eLogo (Logo Yazılım) PostBoxService: SOAP 1.1, canlı https://pb.elogo.com.tr/PostBoxService.svc (test ortamı
// pb-demo.elogo.com.tr de yanıt veriyor; adres sys_api_service.base_url'den gelir). Sağlayıcı kodu: ELOGO.
// Her işlem kendi oturumunu açar: Login -> işlem -> Logout. Belge <ETTN>.xml olarak ZIP'lenir, ZIP base64 + MD5 ile
// SendDocument'e gider. Eleman adları / ad alanları / sırası WSDL'den (DataContract: alfabetik sıra).
// paramList anahtarları WSDL'de tanımlı değil (eLogo web servis kılavuzu); sys_api_service.options ile değiştirilebilir:
//   doc_type       DOCUMENTTYPE değeri (yoksa belge türüne göre EINVOICE / EARCHIVE / DESPATCHADVICE)
//   send_params    SendDocument paramList şablonu, ';' ile ayrılmış; yer tutucular {doctype} {alias} {sender_alias}
//                  {uuid} {taxno}; değeri boş kalan yer tutuculu öğe gönderilmez (varsayılan DOCUMENTTYPE={doctype};ALIAS={alias})
//   status_params  GetDocumentStatus paramList şablonu (varsayılan DOCUMENTTYPE={doctype})
//   app_str, source, version   Login alanları (varsayılan app_str = ThsErp)

interface

uses
  System.SysUtils, ApiService.Config, EInvIntegrator;

const
  ELOGO_PROVIDER_CODE = 'ELOGO';

type
  TELogoIntegrator = class(TInterfacedObject, IEInvIntegrator)
  private
    FConfig: TApiServiceConfig;
    FSession: string;
    function DocType(AKind: TEInvDocKind): string;
    function BuildParamList(const ATemplate: string; const AValues: array of string): string;
    procedure Login;
    procedure Logout;
  public
    constructor Create(const AConfig: TApiServiceConfig);
    destructor Destroy; override;

    // Kimlik bilgisi gerektirmeyen erişim denemesi (Ping -> "OK")
    class function Ping(const AUrl: string; ATimeoutSeconds: Integer): string; static;
    // GİB zarf durum kodu -> uygulama durumu
    class function MapStatus(ACode: Integer; AIsCancel: Boolean): TEInvRemoteStatus; static;

    function TestConnection: string;
    function Send(const ARequest: TEInvSendRequest): TEInvSendResult;
    function QueryStatus(AKind: TEInvDocKind; const AUuid: string): TEInvStatusResult;
    function QueryTaxpayer(const ATaxNo: string): TEInvTaxpayerInfo;
  end;

implementation

uses
  System.Classes, System.Zip, System.Hash, System.NetEncoding, Xml.XMLIntf, Soap.Client;

const
  NS_TNS = 'http://tempuri.org/';
  NS_EF  = 'http://schemas.datacontract.org/2004/07/eFaturaWebService';
  NS_ARR = 'http://schemas.microsoft.com/2003/10/Serialization/Arrays';
  ACTION_PREFIX = 'http://tempuri.org/IPostBoxService/';
  DEFAULT_SEND_PARAMS = 'DOCUMENTTYPE={doctype};ALIAS={alias}';
  DEFAULT_STATUS_PARAMS = 'DOCUMENTTYPE={doctype}';

function E(const AText: string): string;
begin
  Result := TSoapClient.Escape(AText);
end;

constructor TELogoIntegrator.Create(const AConfig: TApiServiceConfig);
begin
  inherited Create;
  FConfig := AConfig;
end;

destructor TELogoIntegrator.Destroy;
begin
  try
    Logout;
  except
    // oturum kapatılamadı: sunucu zaman aşımıyla düşürür
  end;
  inherited;
end;

class function TELogoIntegrator.Ping(const AUrl: string; ATimeoutSeconds: Integer): string;
var
  LSoap: TSoapClient;
begin
  LSoap := TSoapClient.Create(AUrl, ATimeoutSeconds);
  try
    Result := TSoapClient.Text(LSoap.Call(ACTION_PREFIX + 'Ping', '<Ping xmlns="' + NS_TNS + '"/>'), 'PingResult');
  finally
    LSoap.Free;
  end;
end;

// GİB zarf durum kodları: 1000 kuyrukta, 1100 işleniyor, 1200 işlendi (hedefe iletiliyor), 1220 hedeften yanıt bekleniyor,
// 1300 başarıyla tamamlandı; diğer 11xx / 12xx kodları hata. Ticari faturanın kabul / red yanıtı zarf durumunda yoktur
class function TELogoIntegrator.MapStatus(ACode: Integer; AIsCancel: Boolean): TEInvRemoteStatus;
begin
  if AIsCancel then
    Exit(ersCancelled);
  case ACode of
    1300:
      Result := ersDelivered;
    1000, 1100, 1200, 1220:
      Result := ersProcessing;
    1001..1099, 1101..1199, 1201..1219, 1221..1299:
      Result := ersFailed;
  else
    Result := ersUnknown;
  end;
end;

function TELogoIntegrator.DocType(AKind: TEInvDocKind): string;
begin
  Result := FConfig.Option('doc_type');
  if Result <> '' then
    Exit;
  case AKind of
    edkArchive: Result := 'EARCHIVE';
    edkDespatch: Result := 'DESPATCHADVICE';
  else
    Result := 'EINVOICE';
  end;
end;

// AValues: yer tutucu adı / değer çiftleri ('doctype', 'EINVOICE', 'alias', 'urn:mail:...' ...)
function TELogoIntegrator.BuildParamList(const ATemplate: string; const AValues: array of string): string;
var
  LItem, LText: string;
  I: Integer;
  LEmpty: Boolean;
begin
  Result := '<paramList xmlns:b="' + NS_ARR + '">';
  for LItem in ATemplate.Split([';']) do
  begin
    LText := Trim(LItem);
    if LText = '' then
      Continue;
    LEmpty := False;
    I := 0;
    while I < High(AValues) do
    begin
      if LText.Contains('{' + AValues[I] + '}') then
      begin
        LEmpty := LEmpty or (AValues[I + 1] = '');
        LText := LText.Replace('{' + AValues[I] + '}', AValues[I + 1]);
      end;
      Inc(I, 2);
    end;
    if not LEmpty then
      Result := Result + '<b:string>' + E(LText) + '</b:string>';
  end;
  Result := Result + '</paramList>';
end;

// eLogo hataları SOAP Fault olarak döner (detail: ResultType, ör. resultCode 10003 / errorCode -1 "Geçersiz kullanıcı adı veya
// şifre"; pb-demo ile doğrulandı) -> TSoapClient ESoapException yükseltir. Fault'suz yanıtta ResultType yine denetlenir:
// errorCode < 0 ya da resultCode > 1 hata sayılır
procedure CheckResult(AResponse: IXMLNode; const AResultName, AOperation: string);
var
  LResult: IXMLNode;
begin
  LResult := TSoapClient.Find(AResponse, AResultName);
  if not Assigned(LResult) then
    raise EEInvIntegratorException.CreateFmt('eLogo %s: result not found in response', [AOperation]);
  if (StrToIntDef(TSoapClient.Text(LResult, 'errorCode'), 0) < 0) or
    (StrToIntDef(TSoapClient.Text(LResult, 'resultCode'), 0) > 1) then
    raise EEInvIntegratorException.CreateFmt('eLogo %s: %s (error %s)', [AOperation,
      TSoapClient.Text(LResult, 'resultMsg'), TSoapClient.Text(LResult, 'errorCode')]);
end;

procedure TELogoIntegrator.Login;
var
  LSoap: TSoapClient;
  LResponse: IXMLNode;
begin
  if FSession <> '' then
    Exit;
  if (FConfig.Username = '') or (FConfig.Password = '') then
    raise EEInvIntegratorException.Create('eLogo: user name / password is not set in the integration service');
  LSoap := TSoapClient.Create(FConfig.BaseUrl, FConfig.TimeoutSeconds);
  try
    LResponse := LSoap.Call(ACTION_PREFIX + 'Login',
      '<Login xmlns="' + NS_TNS + '"><login xmlns:a="' + NS_EF + '">' +
      '<a:appStr>' + E(FConfig.Option('app_str', 'ThsErp')) + '</a:appStr>' +
      '<a:passWord>' + E(FConfig.Password) + '</a:passWord>' +
      '<a:source>' + E(FConfig.Option('source')) + '</a:source>' +
      '<a:userName>' + E(FConfig.Username) + '</a:userName>' +
      '<a:version>' + E(FConfig.Option('version')) + '</a:version>' +
      '</login></Login>');
    if not SameText(TSoapClient.Text(LResponse, 'LoginResult'), 'true') then
      raise EEInvIntegratorException.Create('eLogo Login: user name or password rejected');
    FSession := TSoapClient.Text(LResponse, 'sessionID');
    if FSession = '' then
      raise EEInvIntegratorException.Create('eLogo Login: no session id');
  finally
    LSoap.Free;
  end;
end;

procedure TELogoIntegrator.Logout;
var
  LSoap: TSoapClient;
begin
  if FSession = '' then
    Exit;
  LSoap := TSoapClient.Create(FConfig.BaseUrl, FConfig.TimeoutSeconds);
  try
    LSoap.Call(ACTION_PREFIX + 'Logout', '<Logout xmlns="' + NS_TNS + '"><sessionID>' + E(FSession) + '</sessionID></Logout>');
  finally
    FSession := '';
    LSoap.Free;
  end;
end;

function TELogoIntegrator.TestConnection: string;
begin
  Result := 'Ping: ' + Ping(FConfig.BaseUrl, FConfig.TimeoutSeconds);
  Login;
  Logout;
  Result := Result + ', Login: OK';
end;

function TELogoIntegrator.Send(const ARequest: TEInvSendRequest): TEInvSendResult;
var
  LSoap: TSoapClient;
  LResponse: IXMLNode;
  LZipStream: TBytesStream;
  LZip: TZipFile;
  LZipBytes: TBytes;
  LBase64: TBase64Encoding;
  LMd5: THashMD5;
  LData, LHash: string;
begin
  Result := Default(TEInvSendResult);
  if ARequest.Uuid = '' then
    raise EEInvIntegratorException.Create('eLogo SendDocument: document UUID is empty');

  // <ETTN>.xml -> <ETTN>.zip
  LZipStream := TBytesStream.Create;
  try
    LZip := TZipFile.Create;
    try
      LZip.Open(LZipStream, zmWrite);
      LZip.Add(TEncoding.UTF8.GetBytes(ARequest.Xml), ARequest.Uuid + '.xml');
      LZip.Close;
    finally
      LZip.Free;
    end;
    LZipBytes := Copy(LZipStream.Bytes, 0, LZipStream.Size);
  finally
    LZipStream.Free;
  end;
  LMd5 := THashMD5.Create;
  LMd5.Update(LZipBytes);
  LHash := LMd5.HashAsString;
  LBase64 := TBase64Encoding.Create(0);
  try
    LData := LBase64.EncodeBytesToString(LZipBytes);
  finally
    LBase64.Free;
  end;

  Login;
  LSoap := TSoapClient.Create(FConfig.BaseUrl, FConfig.TimeoutSeconds);
  try
    LResponse := LSoap.Call(ACTION_PREFIX + 'SendDocument',
      '<SendDocument xmlns="' + NS_TNS + '">' +
      '<sessionID>' + E(FSession) + '</sessionID>' +
      BuildParamList(FConfig.Option('send_params', DEFAULT_SEND_PARAMS),
        ['doctype', DocType(ARequest.Kind), 'alias', ARequest.ReceiverAlias, 'sender_alias', ARequest.SenderAlias,
         'uuid', ARequest.Uuid, 'taxno', ARequest.ReceiverTaxNo]) +
      '<document xmlns:a="' + NS_EF + '">' +
      '<a:binaryData><a:Value>' + LData + '</a:Value><a:contentType>application/zip</a:contentType></a:binaryData>' +
      '<a:currentDate>' + FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now) + '</a:currentDate>' +
      '<a:fileName>' + E(ARequest.Uuid) + '.zip</a:fileName>' +
      '<a:hash>' + LHash + '</a:hash>' +
      '</document></SendDocument>');
    CheckResult(LResponse, 'SendDocumentResult', 'SendDocument');
    Result.ProviderRef := TSoapClient.Text(LResponse, 'refId');
    Result.Message := TSoapClient.Text(TSoapClient.Find(LResponse, 'SendDocumentResult'), 'resultMsg');
  finally
    LSoap.Free;
  end;
end;

function TELogoIntegrator.QueryStatus(AKind: TEInvDocKind; const AUuid: string): TEInvStatusResult;
var
  LSoap: TSoapClient;
  LResponse, LInfo: IXMLNode;
begin
  Result := Default(TEInvStatusResult);
  Login;
  LSoap := TSoapClient.Create(FConfig.BaseUrl, FConfig.TimeoutSeconds);
  try
    LResponse := LSoap.Call(ACTION_PREFIX + 'GetDocumentStatus',
      '<GetDocumentStatus xmlns="' + NS_TNS + '">' +
      '<sessionID>' + E(FSession) + '</sessionID>' +
      '<uuid>' + E(AUuid) + '</uuid>' +
      BuildParamList(FConfig.Option('status_params', DEFAULT_STATUS_PARAMS), ['doctype', DocType(AKind), 'uuid', AUuid]) +
      '</GetDocumentStatus>');
    CheckResult(LResponse, 'GetDocumentStatusResult', 'GetDocumentStatus');
    LInfo := TSoapClient.Find(LResponse, 'statusInfo');
    Result.Code := StrToIntDef(TSoapClient.Text(LInfo, 'code'), 0);
    Result.Description := TSoapClient.Text(LInfo, 'description');
    Result.Status := MapStatus(Result.Code, SameText(TSoapClient.Text(LInfo, 'isCancel'), 'true'));
  finally
    LSoap.Free;
  end;
end;

function TELogoIntegrator.QueryTaxpayer(const ATaxNo: string): TEInvTaxpayerInfo;
var
  LSoap: TSoapClient;
  LResponse, LUser: IXMLNode;

  function Aliases(const AListName: string): TArray<string>;
  var
    LNode: IXMLNode;
    LAlias: string;
  begin
    Result := [];
    for LNode in TSoapClient.Children(TSoapClient.Find(LUser, AListName), 'GibUserInfoType') do
    begin
      LAlias := Trim(TSoapClient.Text(LNode, 'Alias'));
      if LAlias <> '' then
        Result := Result + [LAlias];
    end;
  end;

  function FirstTitle: string;
  var
    LList: string;
    LNode: IXMLNode;
  begin
    Result := '';
    for LList in ['InvoicePkList', 'InvoiceGbList', 'DespatchAdvicePkList', 'DespatchAdviceGbList'] do
      for LNode in TSoapClient.Children(TSoapClient.Find(LUser, LList), 'GibUserInfoType') do
      begin
        Result := Trim(TSoapClient.Text(LNode, 'Title'));
        if Result <> '' then
          Exit;
      end;
  end;

begin
  Result := Default(TEInvTaxpayerInfo);
  Result.TaxNo := ATaxNo;
  Login;
  LSoap := TSoapClient.Create(FConfig.BaseUrl, FConfig.TimeoutSeconds);
  try
    LResponse := LSoap.Call(ACTION_PREFIX + 'CheckGibUser',
      '<CheckGibUser xmlns="' + NS_TNS + '">' +
      '<sessionID>' + E(FSession) + '</sessionID>' +
      '<vknTcknList xmlns:b="' + NS_ARR + '"><b:string>' + E(ATaxNo) + '</b:string></vknTcknList>' +
      '</CheckGibUser>');
    CheckResult(LResponse, 'CheckGibUserResult', 'CheckGibUser');
    LUser := TSoapClient.Find(TSoapClient.Find(LResponse, 'userList'), 'GibUserType');
    if not Assigned(LUser) then
      Exit;
    Result.Found := True;
    Result.InvoicePkAliases := Aliases('InvoicePkList');
    Result.InvoiceGbAliases := Aliases('InvoiceGbList');
    Result.DespatchPkAliases := Aliases('DespatchAdvicePkList');
    Result.DespatchGbAliases := Aliases('DespatchAdviceGbList');
    Result.Title := FirstTitle;
  finally
    LSoap.Free;
  end;
end;

initialization
  TEInvIntegrators.RegisterProvider(ELOGO_PROVIDER_CODE,
    function(const AConfig: TApiServiceConfig): IEInvIntegrator
    begin
      Result := TELogoIntegrator.Create(AConfig);
    end);

end.
