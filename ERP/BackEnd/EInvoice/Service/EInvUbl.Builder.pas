unit EInvUbl.Builder;

// UBL-TR 1.2.1 satış faturası (xsdrt/maindoc/UBL-Invoice-2.1.xsd) ve e-İrsaliye (UBL-DespatchAdvice-2.1.xsd) XML'i; eleman
// sırası XSD sequence'ına göre. Saf birim: veri (TEInvUblInvoice / TEInvUblDespatch) -> XML metni; DB / COM yok. İmza (ext:UBLExtensions içeriği) entegratörce eklenir,
// ExtensionContent boş bırakılır. Eksik / hatalı veri AProblems'e yazılır (XML yine üretilir: önizleme / düzeltme için).
//
// Tutarlar (TR uygulaması): kalem LineExtensionAmount = net (iskonto sonrası), AllowanceCharge = kalem iskontosu;
// belge LineExtensionAmount = brüt toplam, AllowanceTotalAmount = toplam iskonto, TaxExclusiveAmount = net,
// TaxInclusiveAmount = net + KDV, PayableAmount = TaxInclusiveAmount - tevkifat. KDV alt toplamları orana göre; istisna
// kodu yalnız %0 KDV alt toplamına (ve %0 kalemlere) yazılır. Tevkifat hem kalemde hem belgede (kod bazında).

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Generics.Defaults,
  EInvUbl.Model;

type
  TEInvUblBuilder = class
  private
    FSb: TStringBuilder;
    FInv: TEInvUblInvoice;
    FDsp: TEInvUblDespatch;
    FProblems: TStrings;
    FIndent: Integer;
    procedure Line(const AText: string);
    procedure Open(const ATag: string; const AAttrs: string = '');
    procedure Close(const ATag: string);
    procedure Elem(const ATag, AValue: string; const AAttrs: string = '');
    procedure ElemOpt(const ATag, AValue: string; const AAttrs: string = '');
    procedure Amount(const ATag: string; AValue: Currency);
    procedure Problem(const AText: string);
    procedure WriteAddress(const ATag: string; const A: TEInvUblAddress);
    procedure WritePartyBody(const P: TEInvUblParty);
    procedure WriteParty(const P: TEInvUblParty);
    procedure WriteSignature(const ASupplier: TEInvUblParty);
    procedure WriteExportCustomer;
    procedure WriteExportBuyer;
    procedure WriteTaxTotal;
    procedure WriteWithholdingTotal;
    procedure WriteMonetaryTotal;
    procedure WriteLine(L: TEInvUblLine);
    procedure CheckParty(const P: TEInvUblParty; const ARole: string; ARequireTaxOffice: Boolean);
    procedure CheckData;
    function Build: string;
    procedure CheckDespatchData;
    procedure WriteDespatchShipment;
    procedure WriteDespatchLine(L: TEInvUblDespatchLine);
    function BuildDespatchXml: string;
  public
    // XML (UTF-8 bildirimli metin) + veri sorunları (boş = sorun yok)
    class function BuildInvoice(AInvoice: TEInvUblInvoice; AProblems: TStrings): string;
    class function BuildDespatch(ADespatch: TEInvUblDespatch; AProblems: TStrings): string;
    class function Esc(const AValue: string): string; static;
    class function Num(AValue: Currency; ADecimals: Integer): string; static;
    class function Qty(AValue: Currency): string; static;
    class function DateStr(AValue: TDate): string; static;
    class function TimeStr(AValue: TTime): string; static;
    class function TaxIdScheme(const ATaxNo: string): string; static;
  end;

const
  UBL_NS_INVOICE = 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2';
  UBL_NS_DESPATCH = 'urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2';
  UBL_NS_CAC = 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';
  UBL_NS_CBC = 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';
  UBL_NS_EXT = 'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2';
  UBL_TAX_VAT_CODE = '0015';   // Vergi Kodları Listesi: KDV
  UBL_TAX_VAT_NAME = 'KDV';

implementation

uses
  EInvLookup, LocalizationManager;

type
  K = TLangKeys.TEInvDocument;

var
  GInvariant: TFormatSettings;

{ yardımcılar }

class function TEInvUblBuilder.Esc(const AValue: string): string;
var
  LChar: Char;
  LSb: TStringBuilder;
begin
  LSb := TStringBuilder.Create(Length(AValue) + 16);
  try
    for LChar in AValue do
      case LChar of
        '&': LSb.Append('&amp;');
        '<': LSb.Append('&lt;');
        '>': LSb.Append('&gt;');
        '"': LSb.Append('&quot;');
        '''': LSb.Append('&apos;');
        #9, #10, #13: LSb.Append(' ');
      else
        // XML 1.0'da geçersiz kontrol karakterleri atılır
        if Ord(LChar) >= 32 then
          LSb.Append(LChar);
      end;
    Result := Trim(LSb.ToString);
  finally
    LSb.Free;
  end;
end;

class function TEInvUblBuilder.Num(AValue: Currency; ADecimals: Integer): string;
begin
  Result := CurrToStrF(AValue, ffFixed, ADecimals, GInvariant);
end;

// miktar / birim fiyat: gereksiz sıfırsız (en çok 4 hane; Currency hassasiyeti)
class function TEInvUblBuilder.Qty(AValue: Currency): string;
begin
  Result := FormatFloat('0.####', AValue, GInvariant);
end;

class function TEInvUblBuilder.DateStr(AValue: TDate): string;
begin
  Result := FormatDateTime('yyyy"-"mm"-"dd', AValue);
end;

class function TEInvUblBuilder.TaxIdScheme(const ATaxNo: string): string;
begin
  if Length(ATaxNo) = 11 then
    Result := 'TCKN'
  else
    Result := 'VKN';
end;

procedure TEInvUblBuilder.Line(const AText: string);
begin
  FSb.Append(StringOfChar(' ', FIndent * 2)).Append(AText).Append(#13#10);
end;

procedure TEInvUblBuilder.Open(const ATag, AAttrs: string);
begin
  if AAttrs = '' then
    Line('<' + ATag + '>')
  else
    Line('<' + ATag + ' ' + AAttrs + '>');
  Inc(FIndent);
end;

procedure TEInvUblBuilder.Close(const ATag: string);
begin
  Dec(FIndent);
  Line('</' + ATag + '>');
end;

procedure TEInvUblBuilder.Elem(const ATag, AValue, AAttrs: string);
var
  LOpen: string;
begin
  if AAttrs = '' then
    LOpen := '<' + ATag
  else
    LOpen := '<' + ATag + ' ' + AAttrs;
  if Esc(AValue) = '' then
    Line(LOpen + '/>')
  else
    Line(LOpen + '>' + Esc(AValue) + '</' + ATag + '>');
end;

procedure TEInvUblBuilder.ElemOpt(const ATag, AValue, AAttrs: string);
begin
  if Esc(AValue) <> '' then
    Elem(ATag, AValue, AAttrs);
end;

procedure TEInvUblBuilder.Amount(const ATag: string; AValue: Currency);
begin
  Elem(ATag, Num(AValue, 2), 'currencyID="' + Esc(FInv.Currency) + '"');
end;

procedure TEInvUblBuilder.Problem(const AText: string);
begin
  if Assigned(FProblems) and (FProblems.IndexOf(AText) < 0) then
    FProblems.Add(AText);
end;

{ veri denetimi (GİB'in reddedeceği eksikler; XSD bunları yakalamaz) }

procedure TEInvUblBuilder.CheckParty(const P: TEInvUblParty; const ARole: string; ARequireTaxOffice: Boolean);
var
  LChar: Char;
  LDigits: Boolean;
begin
  if not P.Found then
  begin
    Problem(Format(TLocalizationManager.Translate(K.MsgPartyNotFound, '%s: record not found'), [ARole]));
    Exit;
  end;
  LDigits := P.TaxNo <> '';
  for LChar in P.TaxNo do
    if not CharInSet(LChar, ['0'..'9']) then
      LDigits := False;
  if not LDigits or not (Length(P.TaxNo) in [10, 11]) then
    Problem(Format(TLocalizationManager.Translate(K.MsgTaxNo,
      '%s: tax number (10 digits) / national ID (11 digits) is missing or invalid'), [ARole]));
  if P.IsPerson and ((Trim(P.FirstName) = '') or (Trim(P.FamilyName) = '')) then
    Problem(Format(TLocalizationManager.Translate(K.MsgPersonName,
      '%s: first and last name are required for a natural person'), [ARole]));
  if not P.IsPerson and (Trim(P.Name) = '') then
    Problem(Format(TLocalizationManager.Translate(K.MsgPartyName, '%s: company name is required'), [ARole]));
  if ARequireTaxOffice and (Trim(P.TaxOffice) = '') then
    Problem(Format(TLocalizationManager.Translate(K.MsgTaxOffice, '%s: tax office is required'), [ARole]));
  if (Trim(P.Address.CityName) = '') or (Trim(P.Address.CitySubdivisionName) = '') then
    Problem(Format(TLocalizationManager.Translate(K.MsgAddressCity,
      '%s: city and district are required in the address'), [ARole]));
end;

procedure TEInvUblBuilder.CheckData;
var
  L: TEInvUblLine;
  LRole: string;
begin
  if not TEInvLookup.IsValidEInvNo(FInv.EInvNo) then
    Problem(Format(TLocalizationManager.Translate(K.MsgEInvNo,
      'Document number is not in GIB format (3-character series + year + 9 digits): %s'), [FInv.EInvNo]));
  if Length(FInv.Uuid) <> 36 then
    Problem(TLocalizationManager.Translate(K.MsgUuid, 'UUID (ETTN) is missing'));
  if FInv.ProfileCode = '' then
    Problem(TLocalizationManager.Translate(K.MsgProfile, 'e-Document profile is not selected'));
  if FInv.InvoiceTypeCode = '' then
    Problem(TLocalizationManager.Translate(K.MsgInvoiceType, 'Invoice type is not selected'));
  if FInv.Lines.Count = 0 then
    Problem(TLocalizationManager.Translate(K.MsgNoLines, 'The invoice has no lines'));
  CheckParty(FInv.Supplier, TLocalizationManager.Translate(K.RoleSupplier, 'Seller (application settings)'), True);
  if FInv.IsExport then
  begin
    LRole := TLocalizationManager.Translate(K.RoleExportBuyer, 'Export buyer (account)');
    if not FInv.Customer.Found or (Trim(FInv.Customer.Name) = '') then
      Problem(Format(TLocalizationManager.Translate(K.MsgPartyName, '%s: company name is required'), [LRole]));
    if Trim(FInv.Customer.Address.CityName) = '' then
      Problem(Format(TLocalizationManager.Translate(K.MsgCityOnly, '%s: city is required in the address'), [LRole]));
  end
  else
    CheckParty(FInv.Customer, TLocalizationManager.Translate(K.RoleCustomer, 'Buyer (account)'), False);
  for L in FInv.Lines do
    if L.UnitCode = '' then
      Problem(Format(TLocalizationManager.Translate(K.MsgUnitCode,
        'Line %d: the e-document code of unit "%s" is not defined'), [L.LineNo, L.UomCode]));
end;

{ bölümler }

procedure TEInvUblBuilder.WriteAddress(const ATag: string; const A: TEInvUblAddress);
begin
  Open(ATag);
  ElemOpt('cbc:StreetName', A.StreetName);
  ElemOpt('cbc:BuildingName', A.BuildingName);
  ElemOpt('cbc:BuildingNumber', A.BuildingNumber);
  Elem('cbc:CitySubdivisionName', A.CitySubdivisionName);
  Elem('cbc:CityName', A.CityName);
  ElemOpt('cbc:PostalZone', A.PostalZone);
  Open('cac:Country');
  ElemOpt('cbc:IdentificationCode', A.CountryCode);
  Elem('cbc:Name', A.CountryName);
  Close('cac:Country');
  Close(ATag);
end;

procedure TEInvUblBuilder.WriteParty(const P: TEInvUblParty);
begin
  Open('cac:Party');
  WritePartyBody(P);
  Close('cac:Party');
end;

// PartyType içeriği (cac:Party ve cac:CarrierParty ortak)
procedure TEInvUblBuilder.WritePartyBody(const P: TEInvUblParty);
begin
  ElemOpt('cbc:WebsiteURI', P.Website);
  Open('cac:PartyIdentification');
  Elem('cbc:ID', P.TaxNo, 'schemeID="' + TaxIdScheme(P.TaxNo) + '"');
  Close('cac:PartyIdentification');
  if not P.IsPerson then
  begin
    Open('cac:PartyName');
    Elem('cbc:Name', P.Name);
    Close('cac:PartyName');
  end;
  WriteAddress('cac:PostalAddress', P.Address);
  if P.TaxOffice <> '' then
  begin
    Open('cac:PartyTaxScheme');
    Open('cac:TaxScheme');
    Elem('cbc:Name', P.TaxOffice);
    Close('cac:TaxScheme');
    Close('cac:PartyTaxScheme');
  end;
  if (P.Phone <> '') or (P.Fax <> '') or (P.Email <> '') then
  begin
    Open('cac:Contact');
    ElemOpt('cbc:Telephone', P.Phone);
    ElemOpt('cbc:Telefax', P.Fax);
    ElemOpt('cbc:ElectronicMail', P.Email);
    Close('cac:Contact');
  end;
  if P.IsPerson then
  begin
    Open('cac:Person');
    Elem('cbc:FirstName', P.FirstName);
    Elem('cbc:FamilyName', P.FamilyName);
    Close('cac:Person');
  end;
end;

procedure TEInvUblBuilder.WriteSignature(const ASupplier: TEInvUblParty);
begin
  Open('cac:Signature');
  Elem('cbc:ID', ASupplier.TaxNo, 'schemeID="VKN_TCKN"');
  Open('cac:SignatoryParty');
  Open('cac:PartyIdentification');
  Elem('cbc:ID', ASupplier.TaxNo, 'schemeID="' + TaxIdScheme(ASupplier.TaxNo) + '"');
  Close('cac:PartyIdentification');
  WriteAddress('cac:PostalAddress', ASupplier.Address);
  Close('cac:SignatoryParty');
  Open('cac:DigitalSignatureAttachment');
  Open('cac:ExternalReference');
  Elem('cbc:URI', '#Signature');
  Close('cac:ExternalReference');
  Close('cac:DigitalSignatureAttachment');
  Close('cac:Signature');
end;

// IHRACAT: fatura alıcısı Gümrük ve Ticaret Bakanlığı (GİB örneği)
procedure TEInvUblBuilder.WriteExportCustomer;
begin
  Open('cac:AccountingCustomerParty');
  Open('cac:Party');
  Open('cac:PartyIdentification');
  Elem('cbc:ID', EINV_EXPORT_CUSTOMER_VKN, 'schemeID="VKN"');
  Close('cac:PartyIdentification');
  Open('cac:PartyName');
  Elem('cbc:Name', EINV_EXPORT_CUSTOMER_NAME);
  Close('cac:PartyName');
  Open('cac:PostalAddress');
  Elem('cbc:CitySubdivisionName', EINV_EXPORT_CUSTOMER_DISTRICT);
  Elem('cbc:CityName', EINV_EXPORT_CUSTOMER_CITY);
  Open('cac:Country');
  Elem('cbc:Name', 'Türkiye');
  Close('cac:Country');
  Close('cac:PostalAddress');
  Open('cac:PartyTaxScheme');
  Open('cac:TaxScheme');
  Elem('cbc:Name', EINV_EXPORT_CUSTOMER_TAX_OFFICE);
  Close('cac:TaxScheme');
  Close('cac:PartyTaxScheme');
  Close('cac:Party');
  Close('cac:AccountingCustomerParty');
end;

// IHRACAT: malı alan yabancı alıcı (PARTYTYPE = EXPORT, ülkesindeki vergi no PartyLegalEntity/CompanyID)
procedure TEInvUblBuilder.WriteExportBuyer;
var
  P: TEInvUblParty;
begin
  P := FInv.Customer;
  Open('cac:BuyerCustomerParty');
  Open('cac:Party');
  Open('cac:PartyIdentification');
  Elem('cbc:ID', 'EXPORT', 'schemeID="PARTYTYPE"');
  Close('cac:PartyIdentification');
  Open('cac:PartyName');
  Elem('cbc:Name', P.Name);
  Close('cac:PartyName');
  WriteAddress('cac:PostalAddress', P.Address);
  Open('cac:PartyLegalEntity');
  Elem('cbc:RegistrationName', P.Name);
  ElemOpt('cbc:CompanyID', P.TaxNo);
  Close('cac:PartyLegalEntity');
  Close('cac:Party');
  Close('cac:BuyerCustomerParty');
end;

procedure TEInvUblBuilder.WriteTaxTotal;
var
  LRates: TList<Currency>;
  LRate: Currency;
  L: TEInvUblLine;
  LBase, LTax: Currency;
  n: Integer;
begin
  LRates := TList<Currency>.Create;
  try
    for L in FInv.Lines do
      if not LRates.Contains(L.VatRate) then
        LRates.Add(L.VatRate);
    LRates.Sort;
    Open('cac:TaxTotal');
    Amount('cbc:TaxAmount', FInv.VatAmount);
    n := 0;
    for LRate in LRates do
    begin
      LBase := 0;
      LTax := 0;
      for L in FInv.Lines do
        if L.VatRate = LRate then
        begin
          LBase := LBase + L.NetAmount;
          LTax := LTax + L.VatAmount;
        end;
      Inc(n);
      Open('cac:TaxSubtotal');
      Amount('cbc:TaxableAmount', LBase);
      Amount('cbc:TaxAmount', LTax);
      Elem('cbc:CalculationSequenceNumeric', IntToStr(n));
      Elem('cbc:Percent', Qty(LRate));
      Open('cac:TaxCategory');
      if (LRate = 0) and (FInv.ExemptionCode <> '') then
      begin
        Elem('cbc:TaxExemptionReasonCode', FInv.ExemptionCode);
        Elem('cbc:TaxExemptionReason', FInv.ExemptionName);
      end;
      Open('cac:TaxScheme');
      Elem('cbc:Name', UBL_TAX_VAT_NAME);
      Elem('cbc:TaxTypeCode', UBL_TAX_VAT_CODE);
      Close('cac:TaxScheme');
      Close('cac:TaxCategory');
      Close('cac:TaxSubtotal');
    end;
    Close('cac:TaxTotal');
  finally
    LRates.Free;
  end;
end;

procedure TEInvUblBuilder.WriteWithholdingTotal;
var
  LCodes: TList<string>;
  LCode: string;
  L: TEInvUblLine;
  LBase, LTax, LRate: Currency;
begin
  if FInv.WithholdingAmount = 0 then
    Exit;
  LCodes := TList<string>.Create;
  try
    for L in FInv.Lines do
      if (L.WithholdingCode <> '') and not LCodes.Contains(L.WithholdingCode) then
        LCodes.Add(L.WithholdingCode);
    Open('cac:WithholdingTaxTotal');
    Amount('cbc:TaxAmount', FInv.WithholdingAmount);
    for LCode in LCodes do
    begin
      LBase := 0;
      LTax := 0;
      LRate := 0;
      for L in FInv.Lines do
        if L.WithholdingCode = LCode then
        begin
          LBase := LBase + L.VatAmount;
          LTax := LTax + L.WithholdingAmount;
          LRate := L.WithholdingRate;
        end;
      Open('cac:TaxSubtotal');
      Amount('cbc:TaxableAmount', LBase);
      Amount('cbc:TaxAmount', LTax);
      Elem('cbc:Percent', Qty(LRate));
      Open('cac:TaxCategory');
      Open('cac:TaxScheme');
      Elem('cbc:TaxTypeCode', LCode);
      Close('cac:TaxScheme');
      Close('cac:TaxCategory');
      Close('cac:TaxSubtotal');
    end;
    Close('cac:WithholdingTaxTotal');
  finally
    LCodes.Free;
  end;
end;

procedure TEInvUblBuilder.WriteMonetaryTotal;
begin
  Open('cac:LegalMonetaryTotal');
  Amount('cbc:LineExtensionAmount', FInv.GrossAmount);
  Amount('cbc:TaxExclusiveAmount', FInv.NetAmount);
  Amount('cbc:TaxInclusiveAmount', FInv.NetAmount + FInv.VatAmount);
  Amount('cbc:AllowanceTotalAmount', FInv.DiscountAmount);
  Amount('cbc:PayableAmount', FInv.NetAmount + FInv.VatAmount - FInv.WithholdingAmount);
  Close('cac:LegalMonetaryTotal');
end;

procedure TEInvUblBuilder.WriteLine(L: TEInvUblLine);
var
  LCustoms, LDiib: Boolean;
begin
  LCustoms := FInv.IsExport;
  LDiib := (L.SellerDiibLineCode <> '') or (L.BuyerDiibLineCode <> '');
  Open('cac:InvoiceLine');
  Elem('cbc:ID', IntToStr(L.LineNo));
  ElemOpt('cbc:Note', L.Description);
  if LCustoms and (L.PackageBrand <> '') then
    Elem('cbc:Note', 'Package Brand: ' + L.PackageBrand);
  if L.UnitCode <> '' then
    Elem('cbc:InvoicedQuantity', Qty(L.Quantity), 'unitCode="' + Esc(L.UnitCode) + '"')
  else
    Elem('cbc:InvoicedQuantity', Qty(L.Quantity), 'unitCode="C62"');
  Amount('cbc:LineExtensionAmount', L.NetAmount);

  // ihracat: teslim adresi / şartı, GTİP, taşıma şekli, kap; ihraç kayıtlı (702): GTİP + DİİB satır kodları
  if LCustoms or LDiib or (L.GtipCode <> '') then
  begin
    Open('cac:Delivery');
    if LCustoms then
    begin
      WriteAddress('cac:DeliveryAddress', FInv.Customer.Address);
      Open('cac:DeliveryTerms');
      Elem('cbc:ID', FInv.DeliveryTermCode, 'schemeID="INCOTERMS"');
      Close('cac:DeliveryTerms');
    end;
    Open('cac:Shipment');
    Elem('cbc:ID', '');
    if L.GtipCode <> '' then
    begin
      Open('cac:GoodsItem');
      Elem('cbc:RequiredCustomsID', L.GtipCode);
      Close('cac:GoodsItem');
    end;
    if LCustoms and (FInv.TransportModeCode <> '') then
    begin
      Open('cac:ShipmentStage');
      Elem('cbc:TransportModeCode', FInv.TransportModeCode);
      Close('cac:ShipmentStage');
    end;
    if (LCustoms and (L.PackagingTypeCode <> '')) or LDiib then
    begin
      Open('cac:TransportHandlingUnit');
      if LCustoms and (L.PackagingTypeCode <> '') then
      begin
        Open('cac:ActualPackage');
        ElemOpt('cbc:ID', L.PackageNo);
        Elem('cbc:Quantity', Qty(L.PackageQuantity));
        Elem('cbc:PackagingTypeCode', L.PackagingTypeCode);
        Close('cac:ActualPackage');
      end;
      if L.SellerDiibLineCode <> '' then
      begin
        Open('cac:CustomsDeclaration');
        Elem('cbc:ID', L.SellerDiibNo);
        Open('cac:IssuerParty');
        Open('cac:PartyIdentification');
        Elem('cbc:ID', L.SellerDiibLineCode, 'schemeID="SATICIDIBSATIRKOD"');
        Close('cac:PartyIdentification');
        WriteAddress('cac:PostalAddress', FInv.Supplier.Address);
        Close('cac:IssuerParty');
        Close('cac:CustomsDeclaration');
      end;
      if L.BuyerDiibLineCode <> '' then
      begin
        Open('cac:CustomsDeclaration');
        Elem('cbc:ID', L.BuyerDiibNo);
        Open('cac:IssuerParty');
        Open('cac:PartyIdentification');
        Elem('cbc:ID', L.BuyerDiibLineCode, 'schemeID="ALICIDIBSATIRKOD"');
        Close('cac:PartyIdentification');
        WriteAddress('cac:PostalAddress', FInv.Customer.Address);
        Close('cac:IssuerParty');
        Close('cac:CustomsDeclaration');
      end;
      Close('cac:TransportHandlingUnit');
    end;
    Close('cac:Shipment');
    Close('cac:Delivery');
  end;

  if L.DiscountAmount <> 0 then
  begin
    Open('cac:AllowanceCharge');
    Elem('cbc:ChargeIndicator', 'false');
    Elem('cbc:MultiplierFactorNumeric', FormatFloat('0.######', L.DiscountRate / 100, GInvariant));
    Amount('cbc:Amount', L.DiscountAmount);
    Amount('cbc:BaseAmount', L.GrossAmount);
    Close('cac:AllowanceCharge');
  end;

  Open('cac:TaxTotal');
  Amount('cbc:TaxAmount', L.VatAmount);
  Open('cac:TaxSubtotal');
  Amount('cbc:TaxableAmount', L.NetAmount);
  Amount('cbc:TaxAmount', L.VatAmount);
  Elem('cbc:Percent', Qty(L.VatRate));
  Open('cac:TaxCategory');
  if (L.VatRate = 0) and (FInv.ExemptionCode <> '') then
  begin
    Elem('cbc:TaxExemptionReasonCode', FInv.ExemptionCode);
    Elem('cbc:TaxExemptionReason', FInv.ExemptionName);
  end;
  Open('cac:TaxScheme');
  Elem('cbc:Name', UBL_TAX_VAT_NAME);
  Elem('cbc:TaxTypeCode', UBL_TAX_VAT_CODE);
  Close('cac:TaxScheme');
  Close('cac:TaxCategory');
  Close('cac:TaxSubtotal');
  Close('cac:TaxTotal');

  if L.WithholdingCode <> '' then
  begin
    Open('cac:WithholdingTaxTotal');
    Amount('cbc:TaxAmount', L.WithholdingAmount);
    Open('cac:TaxSubtotal');
    Amount('cbc:TaxableAmount', L.VatAmount);
    Amount('cbc:TaxAmount', L.WithholdingAmount);
    Elem('cbc:Percent', Qty(L.WithholdingRate));
    Open('cac:TaxCategory');
    Open('cac:TaxScheme');
    Elem('cbc:TaxTypeCode', L.WithholdingCode);
    Close('cac:TaxScheme');
    Close('cac:TaxCategory');
    Close('cac:TaxSubtotal');
    Close('cac:WithholdingTaxTotal');
  end;

  Open('cac:Item');
  Elem('cbc:Name', L.InventoryName);
  if L.InventoryCode <> '' then
  begin
    Open('cac:SellersItemIdentification');
    Elem('cbc:ID', L.InventoryCode);
    Close('cac:SellersItemIdentification');
  end;
  Close('cac:Item');
  Open('cac:Price');
  Elem('cbc:PriceAmount', Qty(L.UnitPrice), 'currencyID="' + Esc(FInv.Currency) + '"');
  Close('cac:Price');
  Close('cac:InvoiceLine');
end;

function TEInvUblBuilder.Build: string;
var
  L: TEInvUblLine;
begin
  CheckData;
  Line('<?xml version="1.0" encoding="UTF-8"?>');
  Open('Invoice', 'xmlns="' + UBL_NS_INVOICE + '" xmlns:cac="' + UBL_NS_CAC + '" xmlns:cbc="' + UBL_NS_CBC +
    '" xmlns:ext="' + UBL_NS_EXT + '"');
  // imza kabı: içerik entegratörün mali mühür imzasıdır
  Open('ext:UBLExtensions');
  Open('ext:UBLExtension');
  Line('<ext:ExtensionContent/>');
  Close('ext:UBLExtension');
  Close('ext:UBLExtensions');
  Elem('cbc:UBLVersionID', '2.1');
  Elem('cbc:CustomizationID', 'TR1.2');
  Elem('cbc:ProfileID', FInv.ProfileCode);
  Elem('cbc:ID', FInv.EInvNo);
  Elem('cbc:CopyIndicator', 'false');
  Elem('cbc:UUID', UpperCase(FInv.Uuid));
  Elem('cbc:IssueDate', DateStr(FInv.IssueDate));
  Elem('cbc:InvoiceTypeCode', FInv.InvoiceTypeCode);
  ElemOpt('cbc:Note', FInv.Description);
  if FInv.InvoiceNo <> '' then
    Elem('cbc:Note', 'Fatura No: ' + FInv.InvoiceNo);
  Elem('cbc:DocumentCurrencyCode', FInv.Currency);
  if FInv.Currency <> 'TRY' then
    Elem('cbc:PricingCurrencyCode', FInv.Currency);
  Elem('cbc:LineCountNumeric', IntToStr(FInv.Lines.Count));
  WriteSignature(FInv.Supplier);
  Open('cac:AccountingSupplierParty');
  WriteParty(FInv.Supplier);
  Close('cac:AccountingSupplierParty');
  if FInv.IsExport then
  begin
    WriteExportCustomer;
    WriteExportBuyer;
  end
  else
  begin
    Open('cac:AccountingCustomerParty');
    WriteParty(FInv.Customer);
    Close('cac:AccountingCustomerParty');
  end;
  if (FInv.PaymentMeansCode <> '') then
  begin
    Open('cac:PaymentMeans');
    Elem('cbc:PaymentMeansCode', FInv.PaymentMeansCode);
    if FInv.DueDate > 0 then
      Elem('cbc:PaymentDueDate', DateStr(FInv.DueDate));
    Close('cac:PaymentMeans');
  end;
  if (FInv.DueDate > 0) and (FInv.PaymentMeansCode = '') then
  begin
    Open('cac:PaymentTerms');
    Elem('cbc:PaymentDueDate', DateStr(FInv.DueDate));
    Close('cac:PaymentTerms');
  end;
  if FInv.Currency <> 'TRY' then
  begin
    Open('cac:PricingExchangeRate');
    Elem('cbc:SourceCurrencyCode', FInv.Currency);
    Elem('cbc:TargetCurrencyCode', 'TRY');
    Elem('cbc:CalculationRate', FormatFloat('0.######', FInv.ExchangeRate, GInvariant));
    Close('cac:PricingExchangeRate');
    if FInv.ExchangeRate <= 0 then
      Problem(TLocalizationManager.Translate(K.MsgExchangeRate, 'Exchange rate is required for a foreign currency invoice'));
  end;
  WriteTaxTotal;
  WriteWithholdingTotal;
  WriteMonetaryTotal;
  for L in FInv.Lines do
    WriteLine(L);
  Close('Invoice');
  Result := FSb.ToString;
end;

class function TEInvUblBuilder.BuildInvoice(AInvoice: TEInvUblInvoice; AProblems: TStrings): string;
var
  B: TEInvUblBuilder;
begin
  B := TEInvUblBuilder.Create;
  try
    B.FInv := AInvoice;
    B.FProblems := AProblems;
    B.FSb := TStringBuilder.Create(16384);
    try
      Result := B.Build;
    finally
      B.FSb.Free;
    end;
  finally
    B.Free;
  end;
end;

{ e-İrsaliye (DespatchAdvice; GİB UBL-TR İrsaliye kılavuzu V1.2) }

class function TEInvUblBuilder.TimeStr(AValue: TTime): string;
begin
  Result := FormatDateTime('hh":"nn":"ss', AValue);
end;

procedure TEInvUblBuilder.CheckDespatchData;
var
  L: TEInvUblDespatchLine;
begin
  if not TEInvLookup.IsValidEInvNo(FDsp.EInvNo) then
    Problem(Format(TLocalizationManager.Translate(K.MsgEInvNo,
      'Document number is not in GIB format (3-character series + year + 9 digits): %s'), [FDsp.EInvNo]));
  if Length(FDsp.Uuid) <> 36 then
    Problem(TLocalizationManager.Translate(K.MsgUuid, 'UUID (ETTN) is missing'));
  if FDsp.ProfileCode = '' then
    Problem(TLocalizationManager.Translate(K.MsgProfile, 'e-Document profile is not selected'));
  if FDsp.Lines.Count = 0 then
    Problem(TLocalizationManager.Translate(K.MsgDespatchNoLines, 'The delivery note has no lines'));
  CheckParty(FDsp.Supplier, TLocalizationManager.Translate(K.RoleDespatchSupplier, 'Despatching party (application settings)'), True);
  CheckParty(FDsp.Customer, TLocalizationManager.Translate(K.RoleDeliveryCustomer, 'Receiving party (account)'), False);
  if FDsp.HasCarrier then
    CheckParty(FDsp.Carrier, TLocalizationManager.Translate(K.RoleCarrier, 'Carrier (account)'), False)
  else if (FDsp.VehiclePlate = '') or (Length(FDsp.Drivers) = 0) then
    Problem(TLocalizationManager.Translate(K.MsgTransport, 'Carrier company, or vehicle plate and driver are missing'));
  for L in FDsp.Lines do
    if L.UnitCode = '' then
      Problem(Format(TLocalizationManager.Translate(K.MsgUnitCode,
        'Line %d: the e-document code of unit "%s" is not defined'), [L.LineNo, L.UomCode]));
end;

// Gönderi: araç plakası + şoförler (ShipmentStage), taşıyıcı + fiili sevk tarihi / saati (Delivery), dorseler
// (TransportHandlingUnit). Tutar (GoodsItem/ValueAmount) yazılmaz.
procedure TEInvUblBuilder.WriteDespatchShipment;
var
  D: TEInvUblDriver;
  LPlate: string;
begin
  Open('cac:Shipment');
  Elem('cbc:ID', '');
  if (FDsp.VehiclePlate <> '') or (Length(FDsp.Drivers) > 0) then
  begin
    Open('cac:ShipmentStage');
    if FDsp.VehiclePlate <> '' then
    begin
      Open('cac:TransportMeans');
      Open('cac:RoadTransport');
      Elem('cbc:LicensePlateID', FDsp.VehiclePlate, 'schemeID="PLAKA"');
      Close('cac:RoadTransport');
      Close('cac:TransportMeans');
    end;
    for D in FDsp.Drivers do
    begin
      Open('cac:DriverPerson');
      Elem('cbc:FirstName', D.FirstName);
      Elem('cbc:FamilyName', D.FamilyName);
      Elem('cbc:Title', 'Şoför');
      Elem('cbc:NationalityID', D.NationalId);
      Close('cac:DriverPerson');
    end;
    Close('cac:ShipmentStage');
  end;
  Open('cac:Delivery');
  if FDsp.HasCarrier then
  begin
    Open('cac:CarrierParty');
    // CarrierParty bir Party'dir (cac:Party sarmalayıcısı yok)
    WritePartyBody(FDsp.Carrier);
    Close('cac:CarrierParty');
  end;
  Open('cac:Despatch');
  Elem('cbc:ActualDespatchDate', DateStr(FDsp.IssueDate));
  Elem('cbc:ActualDespatchTime', TimeStr(FDsp.DespatchTime));
  Close('cac:Despatch');
  Close('cac:Delivery');
  if Length(FDsp.TrailerPlates) > 0 then
  begin
    Open('cac:TransportHandlingUnit');
    for LPlate in FDsp.TrailerPlates do
    begin
      Open('cac:TransportEquipment');
      Elem('cbc:ID', LPlate, 'schemeID="DORSEPLAKA"');
      Close('cac:TransportEquipment');
    end;
    Close('cac:TransportHandlingUnit');
  end;
  Close('cac:Shipment');
end;

procedure TEInvUblBuilder.WriteDespatchLine(L: TEInvUblDespatchLine);
begin
  Open('cac:DespatchLine');
  Elem('cbc:ID', IntToStr(L.LineNo));
  Elem('cbc:DeliveredQuantity', Qty(L.Quantity), 'unitCode="' + Esc(L.UnitCode) + '"');
  Open('cac:OrderLineReference');
  if L.OrderLineNo > 0 then
    Elem('cbc:LineID', IntToStr(L.OrderLineNo))
  else
    Elem('cbc:LineID', '');
  Close('cac:OrderLineReference');
  Open('cac:Item');
  ElemOpt('cbc:Description', L.Description);
  Elem('cbc:Name', L.InventoryName);
  if L.InventoryCode <> '' then
  begin
    Open('cac:SellersItemIdentification');
    Elem('cbc:ID', L.InventoryCode);
    Close('cac:SellersItemIdentification');
  end;
  Close('cac:Item');
  Close('cac:DespatchLine');
end;

function TEInvUblBuilder.BuildDespatchXml: string;
var
  L: TEInvUblDespatchLine;
begin
  CheckDespatchData;
  Line('<?xml version="1.0" encoding="UTF-8"?>');
  Open('DespatchAdvice', 'xmlns="' + UBL_NS_DESPATCH + '" xmlns:cac="' + UBL_NS_CAC + '" xmlns:cbc="' + UBL_NS_CBC +
    '" xmlns:ext="' + UBL_NS_EXT + '"');
  Open('ext:UBLExtensions');
  Open('ext:UBLExtension');
  Line('<ext:ExtensionContent/>');
  Close('ext:UBLExtension');
  Close('ext:UBLExtensions');
  Elem('cbc:UBLVersionID', '2.1');
  Elem('cbc:CustomizationID', 'TR1.2.1');
  Elem('cbc:ProfileID', FDsp.ProfileCode);
  Elem('cbc:ID', FDsp.EInvNo);
  Elem('cbc:CopyIndicator', 'false');
  Elem('cbc:UUID', UpperCase(FDsp.Uuid));
  Elem('cbc:IssueDate', DateStr(FDsp.IssueDate));
  Elem('cbc:IssueTime', TimeStr(FDsp.DespatchTime));
  Elem('cbc:DespatchAdviceTypeCode', EINV_DESPATCH_TYPE);
  ElemOpt('cbc:Note', FDsp.Description);
  if FDsp.DispatchNo <> '' then
    Elem('cbc:Note', 'İrsaliye No: ' + FDsp.DispatchNo);
  Elem('cbc:LineCountNumeric', IntToStr(FDsp.Lines.Count));
  if FDsp.OrderNo <> '' then
  begin
    Open('cac:OrderReference');
    Elem('cbc:ID', FDsp.OrderNo);
    Elem('cbc:IssueDate', DateStr(FDsp.OrderDate));
    Close('cac:OrderReference');
  end;
  WriteSignature(FDsp.Supplier);
  Open('cac:DespatchSupplierParty');
  WriteParty(FDsp.Supplier);
  Close('cac:DespatchSupplierParty');
  Open('cac:DeliveryCustomerParty');
  WriteParty(FDsp.Customer);
  Close('cac:DeliveryCustomerParty');
  WriteDespatchShipment;
  for L in FDsp.Lines do
    WriteDespatchLine(L);
  Close('DespatchAdvice');
  Result := FSb.ToString;
end;

class function TEInvUblBuilder.BuildDespatch(ADespatch: TEInvUblDespatch; AProblems: TStrings): string;
var
  B: TEInvUblBuilder;
begin
  B := TEInvUblBuilder.Create;
  try
    B.FDsp := ADespatch;
    B.FProblems := AProblems;
    B.FSb := TStringBuilder.Create(8192);
    try
      Result := B.BuildDespatchXml;
    finally
      B.FSb.Free;
    end;
  finally
    B.Free;
  end;
end;

initialization
  GInvariant := TFormatSettings.Invariant;

end.
