unit Ths.Utils.TCMBDovizKuru;

interface

uses
  System.SysUtils, System.IOUtils, System.DateUtils, system.Types,
  System.Net.HttpClientComponent, Xml.XMLIntf, Xml.XMLDoc;

type
  TTCMBDovizKuru = record
    Tarih: TDate;
    Kod: string;
    Aciklama: string;
    ForexBuying: Double;
    ForexSelling: Double;
    BanknoteBuying: Double;
    BanknoteSelling: Double;
  end;

  TTCMBDovizKuruList = TArray<TTCMBDovizKuru>;

  TMerkezBankDovizKurlari = class
    class function TCMB_DovizKurlari(ATarih: TDate): TTCMBDovizKuruList;
  end;

implementation

uses Ths.Utils.InternetConnection;

class function TMerkezBankDovizKurlari.TCMB_DovizKurlari(ATarih: TDate): TTCMBDovizKuruList;
var
  LURL: string;
  LClient: TNetHTTPClient;
  LXMLDocument: IXMLDocument;
  LXML: string;
  LNode: IXMLNode;
  LDate: string;
  LYil, LAy, LGun: Word;
begin
  if not TInternetConnection.Check then
    Exit;

  SetLength(Result, 0);
  LClient := TNetHTTPClient.Create(nil);
  try
    if CompareDateTime(ATarih, DateOf(Now)) = EqualsValue then
    begin
      LURL := 'https://www.tcmb.gov.tr/kurlar/today.xml';
    end
    else
    begin
      DecodeDate(ATarih, LYil, LAy, LGun);
      LURL := 'https://www.tcmb.gov.tr/kurlar/';
      LURL := LURL + Format('%4d', [LYil]) + Format('%2d', [LAy]);
      LURL := LURL + '/' + Format('%2d', [LGun]) + Format('%2d', [LAy]) + Format('%4d', [LYil]) + '.xml';
    end;

    LXML := LClient.Get( LURL ).ContentAsString;
    if LXML.IsEmpty then
      Exit;

    LXMLDocument := TXMLDocument.Create(nil);
    LXMLDocument.ParseOptions := LXMLDocument.ParseOptions + [poPreserveWhiteSpace];
    LXMLDocument.LoadFromXML(LXML);

    if LXMLDocument.DocumentElement.HasAttribute('Tarih') then
      LDate := LXMLDocument.DocumentElement.Attributes['Tarih'];

    LNode :=  LXMLDocument.DocumentElement.ChildNodes.FindNode('Currency');
    while LNode <> nil do
    begin
      SetLength(Result, Length(Result)+1);

      Result[Length(Result)-1].Tarih := ATarih;
      Result[Length(Result)-1].Kod := LNode.Attributes['Kod'];
      Result[Length(Result)-1].Aciklama := LNode.ChildNodes.Nodes['Isim'].Text;
      Result[Length(Result)-1].ForexBuying := StrToFloatDef(LNode.ChildNodes.Nodes['ForexBuying'].Text.Replace('.', ','), 0);
      Result[Length(Result)-1].ForexSelling := StrToFloatDef(LNode.ChildNodes.Nodes['ForexSelling'].Text.Replace('.', ','), 0);
      Result[Length(Result)-1].BanknoteBuying := StrToFloatDef(LNode.ChildNodes.Nodes['BanknoteBuying'].Text.Replace('.', ','), 0);
      Result[Length(Result)-1].BanknoteSelling := StrToFloatDef(LNode.ChildNodes.Nodes['BanknoteSelling'].Text.Replace('.', ','), 0);

      LNode := LNode.NextSibling; // ntTEXT
      LNode := LNode.NextSibling; // Currency
    end;
  finally
    LClient.Free;
  end;
end;

end.
