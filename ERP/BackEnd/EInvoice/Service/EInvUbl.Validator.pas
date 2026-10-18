unit EInvUbl.Validator;

// UBL-TR XML'in GİB şemasıyla (fatura: xsdrt/maindoc/UBL-Invoice-2.1.xsd, e-İrsaliye: UBL-DespatchAdvice-2.1.xsd; belge
// türü kök elemandan) doğrulanması ve GİB görselliğiyle (general.xslt / irsaliye.xslt) HTML önizlemesi; MSXML 6.0
// (XSD 1.0 / XSLT 1.0). Dosyalar exe yanındaki Resource\EInvoice altında:
//   xsdrt\...           GİB paketinin şemaları; UBL-xmldsig-core-schema-2.1.xsd'den DOCTYPE kaldırıldı (MSXML DTD'yi reddeder)
//   general.xslt        GİB paketi; XPath 2.0 exists() -> boolean() (MSXML XSLT 1.0)
//   irsaliye.xslt       GİB paketi (değişiklik yok)
// İmzasız taslakta ext:ExtensionContent boştur (imzayı entegratör ekler); şema orada bir eleman istediği için yalnız
// doğrulama kopyasına yer tutucu konur, saklanan XML değişmez.

interface

uses
  System.SysUtils, System.Classes;

type
  TEInvUblValidator = class
  private
    class function IsDespatch(const AXml: string): Boolean; static;
    class function SchemaFile(ADespatch: Boolean): string; static;
    class function XsltFile(ADespatch: Boolean): string; static;
    class procedure EnsureCom; static;
  public
    class function ResourceDir: string; static;
    // True = şemaya uygun; AMessage = ilk şema hatası (satır no ile)
    class function Validate(const AXml: string; out AMessage: string): Boolean; static;
    // GİB general.xslt (fatura) / irsaliye.xslt (e-İrsaliye) ile HTML
    class function ToHtml(const AXml: string): string; static;
  end;

implementation

uses
  Winapi.Windows, Winapi.ActiveX, Winapi.msxml, System.Variants, LocalizationManager;

const
  UBL_NS_INVOICE = 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2';
  UBL_NS_DESPATCH = 'urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2';
  UNSIGNED_EMPTY = '<ext:ExtensionContent/>';
  UNSIGNED_PLACEHOLDER = '<ext:ExtensionContent><ths:Unsigned xmlns:ths="urn:ths:erp:einvoice:unsigned"/></ext:ExtensionContent>';

threadvar
  GComReady: Boolean;

var
  // şema seti belge türü başına bir kez yüklenir (ilk yükleme ~ yüz ms); COM nesnesi oluşturan iş parçacığına aittir
  GSchemaCache: array[Boolean] of IXMLDOMSchemaCollection2;
  GSchemaThread: array[Boolean] of Cardinal;

class function TEInvUblValidator.ResourceDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Resource' + PathDelim + 'EInvoice' + PathDelim;
end;

// kök eleman DespatchAdvice ise e-İrsaliye (önce <?xml ...?> bildirimi gelir)
class function TEInvUblValidator.IsDespatch(const AXml: string): Boolean;
begin
  Result := Pos('<DespatchAdvice', Copy(AXml, 1, 512)) > 0;
end;

class function TEInvUblValidator.SchemaFile(ADespatch: Boolean): string;
begin
  if ADespatch then
    Result := ResourceDir + 'xsdrt' + PathDelim + 'maindoc' + PathDelim + 'UBL-DespatchAdvice-2.1.xsd'
  else
    Result := ResourceDir + 'xsdrt' + PathDelim + 'maindoc' + PathDelim + 'UBL-Invoice-2.1.xsd';
end;

class function TEInvUblValidator.XsltFile(ADespatch: Boolean): string;
begin
  if ADespatch then
    Result := ResourceDir + 'irsaliye.xslt'
  else
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
  LDespatch: Boolean;
begin
  Result := False;
  AMessage := '';
  LDespatch := IsDespatch(AXml);
  if not FileExists(SchemaFile(LDespatch)) then
  begin
    AMessage := Format(TLocalizationManager.Translate(TLangKeys.TEInvDocument.MsgSchemaMissing,
      'e-Document schema files not found: %s'), [SchemaFile(LDespatch)]);
    Exit;
  end;
  try
    EnsureCom;
    if (GSchemaCache[LDespatch] <> nil) and (GSchemaThread[LDespatch] = GetCurrentThreadId) then
      LCache := GSchemaCache[LDespatch]
    else
    begin
      LCache := CoXMLSchemaCache60.Create;
      if LDespatch then
        LCache.add(UBL_NS_DESPATCH, SchemaFile(True))
      else
        LCache.add(UBL_NS_INVOICE, SchemaFile(False));
      if GSchemaCache[LDespatch] = nil then
      begin
        GSchemaCache[LDespatch] := LCache;
        GSchemaThread[LDespatch] := GetCurrentThreadId;
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
  LXslt: string;
begin
  LXslt := XsltFile(IsDespatch(AXml));
  if not FileExists(LXslt) then
    raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TEInvDocument.MsgSchemaMissing,
      'e-Document schema files not found: %s'), [LXslt]));
  EnsureCom;
  LDoc := CoDOMDocument60.Create;
  LDoc.async := False;
  if not LDoc.loadXML(AXml) then
    raise Exception.Create(Trim(LDoc.parseError.reason));
  LXsl := CoDOMDocument60.Create;
  LXsl.async := False;
  if not LXsl.load(LXslt) then
    raise Exception.Create(Trim(LXsl.parseError.reason));
  Result := LDoc.transformNode(LXsl);
end;

end.
