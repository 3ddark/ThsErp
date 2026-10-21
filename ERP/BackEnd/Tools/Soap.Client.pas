unit Soap.Client;

// SOAP 1.1 (document / literal) istemcisi: zarf + THTTPClient POST + yanıt gövdesindeki ilk eleman. Entegratör sınıfları
// (e-Belge sağlayıcıları ...) Body içeriğini kendi şemalarına göre metin olarak kurar. Ayrıştırma OmniXML (COM gerektirmez);
// düğümler ad alanı önekinden bağımsız (yerel ad) aranır. HTTP hatası / SOAP Fault -> ESoapException. Bağımlılıksız.

interface

uses
  System.SysUtils, System.Classes, Xml.XMLIntf;

type
  ESoapException = class(Exception);

  TSoapClient = class
  private
    FUrl: string;
    FTimeoutMs: Integer;
    FResponse: IXMLDocument;   // dönen düğümler bu belgeye aittir (istemci yaşadıkça geçerli)
  public
    constructor Create(const AUrl: string; ATimeoutSeconds: Integer);

    // AAction: SOAPAction başlığı; ABodyXml: Body içeriği (operasyon elemanı, ad alanlarıyla). Dönen: yanıt elemanı
    function Call(const AAction, ABodyXml: string): IXMLNode;

    class function Escape(const AText: string): string; static;
    class function LocalName(ANode: IXMLNode): string; static;
    // ilk eşleşen alt düğüm (derinlemesine), yoksa nil
    class function Find(ANode: IXMLNode; const ALocalName: string): IXMLNode; static;
    // ilk eşleşen alt düğümün metni (yoksa '')
    class function Text(ANode: IXMLNode; const ALocalName: string): string; static;
    // doğrudan alt elemanlardan adı eşleşenler
    class function Children(ANode: IXMLNode; const ALocalName: string): TArray<IXMLNode>; static;

    property Url: string read FUrl;
  end;

implementation

uses
  System.Net.HttpClient, System.Net.URLClient, System.NetConsts, Xml.XMLDoc, Xml.xmldom, Xml.omnixmldom;

constructor TSoapClient.Create(const AUrl: string; ATimeoutSeconds: Integer);
begin
  inherited Create;
  FUrl := AUrl;
  if ATimeoutSeconds <= 0 then
    ATimeoutSeconds := 60;
  FTimeoutMs := ATimeoutSeconds * 1000;
end;

class function TSoapClient.Escape(const AText: string): string;
begin
  Result := AText.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
    .Replace('''', '&apos;');
end;

class function TSoapClient.LocalName(ANode: IXMLNode): string;
var
  LPos: Integer;
begin
  Result := ANode.NodeName;
  LPos := Pos(':', Result);
  if LPos > 0 then
    Result := Copy(Result, LPos + 1, MaxInt);
end;

class function TSoapClient.Find(ANode: IXMLNode; const ALocalName: string): IXMLNode;
var
  I: Integer;
  LChild: IXMLNode;
begin
  Result := nil;
  if not Assigned(ANode) then
    Exit;
  for I := 0 to ANode.ChildNodes.Count - 1 do
  begin
    LChild := ANode.ChildNodes[I];
    if LChild.NodeType <> ntElement then
      Continue;
    if SameText(LocalName(LChild), ALocalName) then
      Exit(LChild);
    Result := Find(LChild, ALocalName);
    if Assigned(Result) then
      Exit;
  end;
end;

class function TSoapClient.Text(ANode: IXMLNode; const ALocalName: string): string;
var
  LNode: IXMLNode;
begin
  Result := '';
  LNode := Find(ANode, ALocalName);
  // boş / nil (i:nil="true") eleman ya da alt elemanlı düğüm: metin yok
  if Assigned(LNode) and LNode.IsTextElement then
    Result := LNode.Text;
end;

class function TSoapClient.Children(ANode: IXMLNode; const ALocalName: string): TArray<IXMLNode>;
var
  I: Integer;
  LChild: IXMLNode;
begin
  Result := [];
  if not Assigned(ANode) then
    Exit;
  for I := 0 to ANode.ChildNodes.Count - 1 do
  begin
    LChild := ANode.ChildNodes[I];
    if (LChild.NodeType = ntElement) and SameText(LocalName(LChild), ALocalName) then
      Result := Result + [LChild];
  end;
end;

function TSoapClient.Call(const AAction, ABodyXml: string): IXMLNode;
var
  LClient: THTTPClient;
  LRequest: TStringStream;
  LResponseStream: TBytesStream;
  LResponse: IHTTPResponse;
  LDocObj: TXMLDocument;
  LBody, LFault: IXMLNode;
  LBytes: TBytes;
begin
  if FUrl = '' then
    raise ESoapException.Create('SOAP: service URL is empty');
  LClient := THTTPClient.Create;
  LRequest := TStringStream.Create(
    '<?xml version="1.0" encoding="utf-8"?>' +
    '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body>' + ABodyXml + '</s:Body></s:Envelope>',
    TEncoding.UTF8, False);
  LResponseStream := TBytesStream.Create;
  try
    LClient.ConnectionTimeout := FTimeoutMs;
    LClient.ResponseTimeout := FTimeoutMs;
    LClient.ContentType := 'text/xml; charset=utf-8';
    LClient.CustomHeaders['SOAPAction'] := '"' + AAction + '"';
    try
      LResponse := LClient.Post(FUrl, LRequest, LResponseStream);
    except
      on E: ENetException do
        raise ESoapException.CreateFmt('%s: %s', [FUrl, E.Message]);
    end;
    LBytes := Copy(LResponseStream.Bytes, 0, LResponseStream.Size);

    // SOAP Fault HTTP 500 ile gelir: önce gövde ayrıştırılır, Fault yoksa HTTP hatası
    FResponse := nil;
    if Length(LBytes) > 0 then
    begin
      LDocObj := TXMLDocument.Create(nil);
      LDocObj.DOMVendor := GetDOMVendor(sOmniXmlVendor);
      FResponse := LDocObj;
      try
        LResponseStream.Position := 0;
        FResponse.LoadFromStream(LResponseStream);
      except
        FResponse := nil;
      end;
    end;
    LBody := nil;
    if Assigned(FResponse) and Assigned(FResponse.DocumentElement) then
      LBody := Find(FResponse.DocumentElement, 'Body');
    LFault := Find(LBody, 'Fault');
    if Assigned(LFault) then
      raise ESoapException.CreateFmt('%s: SOAP Fault %s - %s', [AAction, Text(LFault, 'faultcode'), Text(LFault, 'faultstring')]);
    if LResponse.StatusCode <> 200 then
      raise ESoapException.CreateFmt('%s: HTTP %d %s', [FUrl, LResponse.StatusCode, LResponse.StatusText]);
    if not Assigned(LBody) then
      raise ESoapException.CreateFmt('%s: SOAP response has no body', [AAction]);

    Result := nil;
    for var I := 0 to LBody.ChildNodes.Count - 1 do
      if LBody.ChildNodes[I].NodeType = ntElement then
        Exit(LBody.ChildNodes[I]);
    raise ESoapException.CreateFmt('%s: SOAP body is empty', [AAction]);
  finally
    LResponseStream.Free;
    LRequest.Free;
    LClient.Free;
  end;
end;

end.
