unit EInvLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

const
  // einv_profile.document_kind (DB CHECK 1-2)
  EINV_DOC_INVOICE  = 1;  // fatura senaryosu
  EINV_DOC_DESPATCH = 2;  // irsaliye senaryosu

  // einv_tax_exemption.exemption_group (DB CHECK 1-7) — UBL-TR Kod Listeleri v1.43 başlıkları
  EINV_EXGRP_VAT_PARTIAL   = 1;  // KDV kısmi istisna (2xx)
  EINV_EXGRP_VAT_FULL      = 2;  // KDV tam istisna (3xx)
  EINV_EXGRP_OTHER         = 3;  // diğer işlem türü (555)
  EINV_EXGRP_SCT           = 4;  // ÖTV istisna (1xx)
  EINV_EXGRP_LODGING       = 5;  // konaklama vergisi istisna (001)
  EINV_EXGRP_SPECIAL_BASE  = 6;  // özel matrah (8xx)
  EINV_EXGRP_EXPORT_REG    = 7;  // ihraç kayıtlı / DİİB / geçici kabul (70x)

  // einv_diib.holder_type (DB CHECK 1-2)
  EINV_DIIB_OWN      = 1;  // firmamızın DİİB'i (satıcı DİİB satır kodu)
  EINV_DIIB_CUSTOMER = 2;  // müşterinin / ihracatçının DİİB'i (alıcı DİİB satır kodu)

  // einv_diib_line.line_kind (DB CHECK 1-2)
  EINV_DIIB_LINE_EXPORT = 1;  // ihraç edilecek eşya
  EINV_DIIB_LINE_IMPORT = 2;  // ithal edilecek eşya

  // sls_invoice.einv_status (DB CHECK 1-7, NULL = e-belge değil)
  EINV_STATUS_DRAFT     = 1;  // taslak (senaryo seçildi, gönderilmedi)
  EINV_STATUS_QUEUED    = 2;  // gönderim kuyruğunda
  EINV_STATUS_SENT      = 3;  // GİB / alıcıya iletildi
  EINV_STATUS_ACCEPTED  = 4;  // kabul (ticari fatura uygulama yanıtı)
  EINV_STATUS_REJECTED  = 5;  // red (ticari fatura uygulama yanıtı)
  EINV_STATUS_ERROR     = 6;  // hata (zarf / şema / imza)
  EINV_STATUS_CANCELLED = 7;  // iptal (e-arşiv)

  // Kod listesindeki sabit değerler (iş kuralları)
  EINV_PROFILE_BASIC      = 'TEMELFATURA';
  EINV_PROFILE_COMMERCIAL = 'TICARIFATURA';
  EINV_PROFILE_ARCHIVE    = 'EARSIVFATURA';
  EINV_PROFILE_EXPORT     = 'IHRACAT';
  EINV_TYPE_SALES         = 'SATIS';
  EINV_TYPE_EXEMPTION     = 'ISTISNA';
  // e-İrsaliye: temel senaryo, irsaliye tipi (MATBUDAN = kağıt irsaliyenin sonradan e-İrsaliyesi; şimdilik yalnız SEVK)
  EINV_PROFILE_DESPATCH   = 'TEMELIRSALIYE';
  EINV_DESPATCH_TYPE      = 'SEVK';

  GTIP_LENGTH = 12;

  // einv_series.series_scope (DB CHECK 1-3): e-Fatura senaryoları / e-Arşiv / e-İrsaliye
  EINV_SERIES_INVOICE = 1;
  EINV_SERIES_ARCHIVE = 2;
  EINV_SERIES_DESPATCH = 3;

  // GİB belge numarası: 3 karakter seri + 4 hane yıl + 9 hane sıra (GIB2026000000001)
  EINV_NO_LENGTH = 16;
  EINV_SEQ_DIGITS = 9;

  // IHRACAT senaryosu: fatura alıcısı Gümrük ve Ticaret Bakanlığı (GİB örneği IHRACAT.xml); malı alan BuyerCustomerParty
  EINV_EXPORT_CUSTOMER_VKN  = '1460415308';
  EINV_EXPORT_CUSTOMER_NAME = 'Gümrük ve Ticaret Bakanlığı Gümrükler Genel Müdürlüğü- Bilgi İşlem Dairesi Başkanlığı';
  EINV_EXPORT_CUSTOMER_CITY = 'Ankara';
  EINV_EXPORT_CUSTOMER_DISTRICT = 'Ulus';
  EINV_EXPORT_CUSTOMER_TAX_OFFICE = 'Ulus';
  // e-Arşiv: kimlik numarası bilinmeyen nihai tüketici (GİB)
  EINV_UNKNOWN_TCKN = '11111111111';

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0 = seçilmemiş)
  TEInvLookupKind = (elkDocumentKind, elkExemptionGroup, elkDiibHolder, elkDiibLineKind, elkEInvStatus, elkSeriesScope);

  TEInvLookup = class
  public
    class function Items(AKind: TEInvLookupKind): TArray<string>;
    class function Text(AKind: TEInvLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TEInvLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TEInvLookupKind);

    // GTİP: yalnız rakamlar (noktalar / boşluklar atılır)
    class function NormalizeGtip(const AValue: string): string;
    class function IsValidGtip(const AValue: string): Boolean;
    // 0206.22.00.00.00 biçimi (4.2.2.2.2)
    class function FormatGtip(const AValue: string): string;

    // e-belge gönderildikten sonra fatura değiştirilemez / silinemez (taslak ve hatalı olan düzeltilebilir)
    class function IsEInvLocked(AStatus: Integer): Boolean;

    // Belge numarası: seri (3 büyük harf / rakam) + yıl + 9 hane sıra
    class function IsValidSeriesCode(const ACode: string): Boolean;
    class function IsValidEInvNo(const ANo: string): Boolean;
    class function MakeEInvNo(const ASeriesCode: string; AYear: Integer; ASequence: Int64): string;
    // senaryonun seri kapsamı: EARSIVFATURA -> e-Arşiv, ...IRSALIYE -> e-İrsaliye, diğerleri e-Fatura
    class function SeriesScopeOf(const AProfileCode: string): Integer;
    // UBL / ISO 4217 para birimi kodu (sys_currency eski 'TL' kodu -> 'TRY')
    class function UblCurrency(const ACurrency: string): string;

    // Tekillik kontrolünde hariç tutulacak id: yalnız güncellemede kaydın kendisi (kopya / yeni kayıtta 0)
    class function ExcludeId(AId: Int64; AIsUpdate: Boolean): Int64;

    // Araç plakası: boşluk / tire atılır, büyük harf (34 ABC 123 -> 34ABC123); 4-16 harf / rakam
    class function NormalizePlate(const AValue: string): string;
    class function IsValidPlate(const AValue: string): Boolean;
    // TC kimlik no: 11 hane, ilk hane 0 değil, 10. ve 11. hane kontrol haneleri
    class function IsValidNationalId(const AValue: string): Boolean;
    // GİB etiketi (alias): urn:mail:{etiket}@{alan}, boşluksuz (urn:mail:defaultpk@firma.com.tr); DB CHECK ile aynı kural
    class function IsValidAlias(const AValue: string): Boolean;
  end;

implementation

uses
  System.RegularExpressions;

class function TEInvLookup.Items(AKind: TEInvLookupKind): TArray<string>;
begin
  case AKind of
    elkDocumentKind:
      Result := [TLocalizationManager.Translate(TLangKeys.TEInvOption.DocInvoice, 'Invoice'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.DocDespatch, 'Despatch Advice')];
    elkExemptionGroup:
      Result := [TLocalizationManager.Translate(TLangKeys.TEInvOption.ExgrpVatPartial, 'VAT Partial Exemption'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.ExgrpVatFull, 'VAT Full Exemption'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.ExgrpOther, 'Other Transaction Type'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.ExgrpSct, 'Special Consumption Tax Exemption'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.ExgrpLodging, 'Accommodation Tax Exemption'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.ExgrpSpecialBase, 'Special Tax Base'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.ExgrpExportReg, 'Export Registered / DIIB')];
    elkDiibHolder:
      Result := [TLocalizationManager.Translate(TLangKeys.TEInvOption.DiibOwn, 'Our Company (Seller)'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.DiibCustomer, 'Customer / Exporter (Buyer)')];
    elkDiibLineKind:
      Result := [TLocalizationManager.Translate(TLangKeys.TEInvOption.DiibLineExport, 'Export'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.DiibLineImport, 'Import')];
    elkEInvStatus:
      Result := [TLocalizationManager.Translate(TLangKeys.TEInvOption.StatusDraft, 'Draft'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.StatusQueued, 'Queued'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.StatusSent, 'Sent'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.StatusAccepted, 'Accepted'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.StatusRejected, 'Rejected'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.StatusError, 'Error'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.StatusCancelled, 'Cancelled')];
    elkSeriesScope:
      Result := [TLocalizationManager.Translate(TLangKeys.TEInvOption.SeriesInvoice, 'e-Invoice'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.SeriesArchive, 'e-Archive Invoice'),
                 TLocalizationManager.Translate(TLangKeys.TEInvOption.SeriesDespatch, 'e-Despatch Advice')];
  else
    Result := [];
  end;
end;

class function TEInvLookup.Text(AKind: TEInvLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TEInvLookup.IsValid(AKind: TEInvLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TEInvLookup.FillItems(AItems: TStrings; AKind: TEInvLookupKind);
var
  LText: string;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    for LText in Items(AKind) do
      AItems.Add(LText);
  finally
    AItems.EndUpdate;
  end;
end;

class function TEInvLookup.NormalizeGtip(const AValue: string): string;
var
  LChar: Char;
begin
  Result := '';
  for LChar in AValue do
    if CharInSet(LChar, ['0'..'9']) then
      Result := Result + LChar;
end;

class function TEInvLookup.IsValidGtip(const AValue: string): Boolean;
var
  LChar: Char;
begin
  if Length(AValue) <> GTIP_LENGTH then
    Exit(False);
  for LChar in AValue do
    if not CharInSet(LChar, ['0'..'9']) then
      Exit(False);
  Result := True;
end;

class function TEInvLookup.FormatGtip(const AValue: string): string;
begin
  if not IsValidGtip(AValue) then
    Exit(AValue);
  Result := Copy(AValue, 1, 4) + '.' + Copy(AValue, 5, 2) + '.' + Copy(AValue, 7, 2) + '.' +
            Copy(AValue, 9, 2) + '.' + Copy(AValue, 11, 2);
end;

class function TEInvLookup.ExcludeId(AId: Int64; AIsUpdate: Boolean): Int64;
begin
  if AIsUpdate then
    Result := AId
  else
    Result := 0;
end;

class function TEInvLookup.IsEInvLocked(AStatus: Integer): Boolean;
begin
  Result := AStatus in [EINV_STATUS_QUEUED, EINV_STATUS_SENT, EINV_STATUS_ACCEPTED, EINV_STATUS_REJECTED,
    EINV_STATUS_CANCELLED];
end;

class function TEInvLookup.IsValidSeriesCode(const ACode: string): Boolean;
var
  LChar: Char;
begin
  if Length(ACode) <> 3 then
    Exit(False);
  for LChar in ACode do
    if not CharInSet(LChar, ['A'..'Z', '0'..'9']) then
      Exit(False);
  Result := True;
end;

class function TEInvLookup.IsValidEInvNo(const ANo: string): Boolean;
var
  i: Integer;
begin
  if (Length(ANo) <> EINV_NO_LENGTH) or not IsValidSeriesCode(Copy(ANo, 1, 3)) then
    Exit(False);
  for i := 4 to EINV_NO_LENGTH do
    if not CharInSet(ANo[i], ['0'..'9']) then
      Exit(False);
  Result := True;
end;

class function TEInvLookup.MakeEInvNo(const ASeriesCode: string; AYear: Integer; ASequence: Int64): string;
begin
  Result := ASeriesCode + Format('%.4d', [AYear]) + Format('%.9d', [ASequence]);
end;

class function TEInvLookup.SeriesScopeOf(const AProfileCode: string): Integer;
begin
  if AProfileCode = EINV_PROFILE_ARCHIVE then
    Result := EINV_SERIES_ARCHIVE
  else if AProfileCode.EndsWith('IRSALIYE') then
    Result := EINV_SERIES_DESPATCH
  else
    Result := EINV_SERIES_INVOICE;
end;

class function TEInvLookup.IsValidAlias(const AValue: string): Boolean;
begin
  Result := TRegEx.IsMatch(AValue, '^urn:mail:[^@\s]+@[^@\s]+$', [roIgnoreCase]);
end;

class function TEInvLookup.NormalizePlate(const AValue: string): string;
var
  LChar: Char;
begin
  Result := '';
  for LChar in AnsiUpperCase(AValue) do
    if not CharInSet(LChar, [' ', '-', '.', #9]) then
      Result := Result + LChar;
end;

class function TEInvLookup.IsValidPlate(const AValue: string): Boolean;
var
  LChar: Char;
begin
  if (Length(AValue) < 4) or (Length(AValue) > 16) then
    Exit(False);
  for LChar in AValue do
    if not CharInSet(LChar, ['A'..'Z', '0'..'9']) then
      Exit(False);
  Result := True;
end;

class function TEInvLookup.IsValidNationalId(const AValue: string): Boolean;
var
  LDigits: array[1..11] of Integer;
  LOdd, LEven, i: Integer;
begin
  if Length(AValue) <> 11 then
    Exit(False);
  for i := 1 to 11 do
  begin
    if not CharInSet(AValue[i], ['0'..'9']) then
      Exit(False);
    LDigits[i] := Ord(AValue[i]) - Ord('0');
  end;
  if LDigits[1] = 0 then
    Exit(False);
  LOdd := LDigits[1] + LDigits[3] + LDigits[5] + LDigits[7] + LDigits[9];
  LEven := LDigits[2] + LDigits[4] + LDigits[6] + LDigits[8];
  if ((LOdd * 7 - LEven) mod 10 + 10) mod 10 <> LDigits[10] then
    Exit(False);
  Result := (LOdd + LEven + LDigits[10]) mod 10 = LDigits[11];
end;

class function TEInvLookup.UblCurrency(const ACurrency: string): string;
begin
  Result := UpperCase(Trim(ACurrency));
  if (Result = 'TL') or (Result = '') then
    Result := 'TRY';
end;

end.
