unit EInvUbl.Validator;

// UBL-TR XML'in GİB şemasıyla (xsdrt/maindoc/UBL-Invoice-2.1.xsd) doğrulanması ve GİB görselliğiyle (general.xslt) HTML
// önizlemesi; MSXML 6.0 (XSD 1.0 / XSLT 1.0). Dosyalar exe yanındaki Resource\EInvoice altında:
//   xsdrt\...           GİB paketinin şemaları; UBL-xmldsig-core-schema-2.1.xsd'den DOCTYPE kaldırıldı (MSXML DTD'yi reddeder)
//   general.xslt        GİB paketi; XPath 2.0 exists() -> boolean() (MSXML XSLT 1.0)
// İmzasız taslakta ext:ExtensionContent boştur (imzayı entegratör ekler); şema orada bir eleman istediği için yalnız
// doğrulama kopyasına yer tutucu konur, saklanan XML değişmez.

interface

uses
  System.SysUtils, System.Classes;

type
  TEInvUblValidator = class
  private
    class function SchemaFile: string; static;
    class function XsltFile: string; static;
    class procedure EnsureCom; static;
  public
    class function ResourceDir: string; static;
    // True = şemaya uygun; AMessage = ilk şema hatası (satır no ile)
    class function Validate(const AXml: string; out AMessage: string): Boolean; static;
    // GİB general.xslt ile HTML
    class function ToHtml(const AXml: string): string; static;
  end;

implementation

uses
  Winapi.Windows, Winapi.ActiveX, Winapi.msxml, System.Variants, LocalizationManager;

const
  UBL_NS_INVOICE = 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2';
  UNSIGNED_EMPTY = '<ext:ExtensionContent/>';
  UNSIGNED_PLACEHOLDER = '<ext:ExtensionContent><ths:Unsigned xmlns:ths="urn:ths:erp:einvoice:unsigned"/></ext:ExtensionContent>';

threadvar
  GComReady: Boolean;

var
  // şema seti bir kez yüklenir (ilk yükleme ~ yüz ms); COM nesnesi oluşturan iş parçacığına aittir
  GSchemaCache: IXMLDOMSchemaCollection2;
  GSchemaThread: Cardinal;

class function TEInvUblValidator.ResourceDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Resource' + PathDelim + 'EInvoice' + PathDelim;
end;

class function TEInvUblValidator.SchemaFile: string;
begin
  Result := ResourceDir + 'xsdrt' + PathDelim + 'maindoc' + PathDelim + 'UBL-Invoice-2.1.xsd';
end;

class function TEInvUblValidator.XsltFile: string;
begin
  Result := ResourceDir + 'general.xslt';
end;

// MSXML COM nesneleri iş parçacığına bağlıdır; VCL ana iş parçacığında COM zaten açıktır (S_FALSE), konsolda açılır
class procedure TEInvUblValidator.EnsureCom;
begin
  if not GComReady then
  begin
    CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    GComReady := True;
  end;
end;

class function TEInvUblValidator.Validate(const AXml: string; out AMessage: string): Boolean;
var
  LDoc: IXMLDOMDocument3;
  LCache: IXMLDOMSchemaCollection2;
  LXml: string;
begin
  Result := False;
  AMessage := '';
  if not FileExists(SchemaFile) then
  begin
    AMessage := Format(TLocalizationManager.Translate(TLangKeys.TEInvDocument.MsgSchemaMissing,
      'e-Document schema files not found: %s'), [SchemaFile]);
    Exit;
  end;
  try
    EnsureCom;
    if (GSchemaCache <> nil) and (GSchemaThread = GetCurrentThreadId) then
      LCache := GSchemaCache
    else
    begin
      LCache := CoXMLSchemaCache60.Create;
      LCache.add(UBL_NS_INVOICE, SchemaFile);
      if GSchemaCache = nil then
      begin
        GSchemaCache := LCache;
        GSchemaThread := GetCurrentThreadId;
      end;
    end;
    LXml := StringReplace(AXml, UNSIGNED_EMPTY, UNSIGNED_PLACEHOLDER, []);
    LDoc := CoDOMDocument60.Create;
    LDoc.async := False;
    LDoc.validateOnParse := True;
    LDoc.resolveExternals := False;
    LDoc.schemas := LCache;
    Result := LDoc.loadXML(LXml);
    if not Result then
      AMessage := Format(TLocalizationManager.Translate(TLangKeys.TEInvDocument.MsgSchemaInvalid,
        'Not valid against the UBL-TR schema (line %d): %s'), [LDoc.parseError.line, Trim(LDoc.parseError.reason)]);
  except
    on E: Exception do
    begin
      Result := False;
      AMessage := Format(TLocalizationManager.Translate(TLangKeys.TEInvDocument.MsgValidatorError,
        'Schema validation could not be run: %s'), [E.Message]);
    end;
  end;
end;

class function TEInvUblValidator.ToHtml(const AXml: string): string;
var
  LDoc, LXsl: IXMLDOMDocument3;
begin
  if not FileExists(XsltFile) then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvDocument.MsgSchemaMissing,
      'e-Document schema files not found: %s'), [XsltFile]));
  EnsureCom;
  LDoc := CoDOMDocument60.Create;
  LDoc.async := False;
  if not LDoc.loadXML(AXml) then
    raise Exception.Create(Trim(LDoc.parseError.reason));
  LXsl := CoDOMDocument60.Create;
  LXsl.async := False;
  if not LXsl.load(XsltFile) then
    raise Exception.Create(Trim(LXsl.parseError.reason));
  Result := LDoc.transformNode(LXsl);
end;

end.
