unit Tcmb.ExchangeRates;

// TCMB gösterge niteliğindeki günlük döviz kurları: https://www.tcmb.gov.tr/kurlar/today.xml (son bülten) veya arşiv
// kurlar/YYYYMM/DDMMYYYY.xml. Bağımlılıksız istemci: indirme (THTTPClient, zaman aşımlı) + ayrıştırma (OmniXML, COM
// gerektirmez; arka plan thread'inde çalışabilir). Kurlar 1 birim içindir (Unit = 100 olanlar bölünür), TRY karşılığı.

interface

uses
  System.SysUtils;

type
  TTcmbRate = record
    Currency: string;
    // 0 = bültende yok
    ForexBuying: Double;
    ForexSelling: Double;
    BanknoteBuying: Double;
    BanknoteSelling: Double;
  end;

  TTcmbBulletin = record
    BulletinDate: TDate;
    Rates: TArray<TTcmbRate>;
  end;

  ETcmbException = class(Exception);

  TTcmbClient = class
  public
    // ADate = 0: today.xml (son yayımlanan bülten)
    class function BulletinUrl(ADate: TDate = 0): string;
    class function Download(ADate: TDate = 0; ATimeoutMs: Integer = 8000): TBytes;
    class function Parse(const AXml: TBytes): TTcmbBulletin;
    class function Fetch(ADate: TDate = 0; ATimeoutMs: Integer = 8000): TTcmbBulletin;
  end;

implementation

uses
  System.Classes, System.Variants, System.DateUtils, System.Net.HttpClient, System.Net.URLClient,
  Xml.XMLIntf, Xml.XMLDoc, Xml.xmldom, Xml.omnixmldom;

const
  TCMB_BASE_URL = 'https://www.tcmb.gov.tr/kurlar/';

class function TTcmbClient.BulletinUrl(ADate: TDate): string;
begin
  if ADate <= 0 then
    Result := TCMB_BASE_URL + 'today.xml'
  else
    Result := TCMB_BASE_URL + FormatDateTime('yyyymm', ADate) + '/' + FormatDateTime('ddmmyyyy', ADate) + '.xml';
end;

class function TTcmbClient.Download(ADate: TDate; ATimeoutMs: Integer): TBytes;
var
  LClient: THTTPClient;
  LStream: TBytesStream;
  LResponse: IHTTPResponse;
  LUrl: string;
begin
  LUrl := BulletinUrl(ADate);
  LClient := THTTPClient.Create;
  LStream := TBytesStream.Create;
  try
    LClient.ConnectionTimeout := ATimeoutMs;
    LClient.ResponseTimeout := ATimeoutMs;
    LResponse := LClient.Get(LUrl, LStream);
    if LResponse.StatusCode <> 200 then
      raise ETcmbException.CreateFmt('%s: HTTP %d %s', [LUrl, LResponse.StatusCode, LResponse.StatusText]);
    Result := Copy(LStream.Bytes, 0, LStream.Size);
  finally
    LStream.Free;
    LClient.Free;
  end;
end;

class function TTcmbClient.Parse(const AXml: TBytes): TTcmbBulletin;
var
  LDocObj: TXMLDocument;
  LDoc: IXMLDocument;
  LRoot, LNode: IXMLNode;
  LStream: TBytesStream;
  LRate: TTcmbRate;
  LUnit, I, n: Integer;
  LText: string;
  LParts: TArray<string>;

  function ChildValue(const AName: string): Double;
  var
    LChild: IXMLNode;
  begin
    Result := 0;
    LChild := LNode.ChildNodes.FindNode(AName);
    if Assigned(LChild) then
      Result := StrToFloatDef(Trim(LChild.Text), 0, TFormatSettings.Invariant) / LUnit;
  end;

begin
  Result := Default(TTcmbBulletin);
  // OmniXML: COM (MSXML) gerektirmez, arka plan thread'inde de çalışır
  LDocObj := TXMLDocument.Create(nil);
  LDocObj.DOMVendor := GetDOMVendor(sOmniXmlVendor);
  LDoc := LDocObj;
  LStream := TBytesStream.Create(AXml);
  try
    LDoc.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;

  LRoot := LDoc.DocumentElement;
  if not Assigned(LRoot) then
    raise ETcmbException.Create('TCMB: empty document');

  // Date="10/17/2026" (ay/gün/yıl), yoksa Tarih="17.10.2026"
  if LRoot.HasAttribute('Date') then
  begin
    LParts := VarToStr(LRoot.Attributes['Date']).Split(['/']);
    if Length(LParts) = 3 then
      Result.BulletinDate := EncodeDate(StrToInt(LParts[2]), StrToInt(LParts[0]), StrToInt(LParts[1]));
  end;
  if (Result.BulletinDate <= 0) and LRoot.HasAttribute('Tarih') then
  begin
    LParts := VarToStr(LRoot.Attributes['Tarih']).Split(['.']);
    if Length(LParts) = 3 then
      Result.BulletinDate := EncodeDate(StrToInt(LParts[2]), StrToInt(LParts[1]), StrToInt(LParts[0]));
  end;
  if Result.BulletinDate <= 0 then
    raise ETcmbException.Create('TCMB: bulletin date not found');

  SetLength(Result.Rates, LRoot.ChildNodes.Count);
  n := 0;
  for I := 0 to LRoot.ChildNodes.Count - 1 do
  begin
    LNode := LRoot.ChildNodes[I];
    if (LNode.NodeType <> ntElement) or not SameText(LNode.NodeName, 'Currency') or not LNode.HasAttribute('Kod') then
      Continue;
    LUnit := 1;
    if Assigned(LNode.ChildNodes.FindNode('Unit')) then
    begin
      LText := Trim(LNode.ChildNodes.FindNode('Unit').Text);
      LUnit := StrToIntDef(LText, 1);
      if LUnit <= 0 then
        LUnit := 1;
    end;
    LRate := Default(TTcmbRate);
    LRate.Currency := UpperCase(Trim(VarToStr(LNode.Attributes['Kod'])));
    LRate.ForexBuying := ChildValue('ForexBuying');
    LRate.ForexSelling := ChildValue('ForexSelling');
    LRate.BanknoteBuying := ChildValue('BanknoteBuying');
    LRate.BanknoteSelling := ChildValue('BanknoteSelling');
    // döviz alışı olmayan (ör. yalnız çapraz kur verilen) satırlar alınmaz
    if (LRate.Currency = '') or (LRate.ForexBuying <= 0) then
      Continue;
    Result.Rates[n] := LRate;
    Inc(n);
  end;
  SetLength(Result.Rates, n);
end;

class function TTcmbClient.Fetch(ADate: TDate; ATimeoutMs: Integer): TTcmbBulletin;
begin
  Result := Parse(Download(ADate, ATimeoutMs));
end;

end.
