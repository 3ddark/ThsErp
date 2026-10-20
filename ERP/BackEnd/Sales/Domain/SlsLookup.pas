unit SlsLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

const
  // sls_offer.status (DB CHECK 1-5)
  SLS_OFF_DRAFT     = 1;  // taslak (kalemler düzenlenebilir)
  SLS_OFF_SENT      = 2;  // müşteriye gönderildi (siparişe dönüştürülebilir)
  SLS_OFF_REJECTED  = 3;  // müşteri reddetti
  SLS_OFF_ORDERED   = 4;  // tamamı siparişe dönüştü (otomatik)
  SLS_OFF_CLOSED    = 5;  // kapandı

  // sls_order.status (DB CHECK 1-5)
  SLS_ORD_DRAFT     = 1;  // taslak (kalemler düzenlenebilir)
  SLS_ORD_APPROVED  = 2;  // onaylandı (sevk / irsaliyeli fatura yapılabilir)
  SLS_ORD_PARTIAL   = 3;  // kısmi sevk (otomatik)
  SLS_ORD_DELIVERED = 4;  // tamamı sevk edildi (otomatik)
  SLS_ORD_CANCELLED = 5;  // iptal

  // sls_dispatch.status (DB CHECK 1-2, servis tutar)
  SLS_DSP_WAITING   = 1;  // bekliyor: tamamı faturalanmamış (kısmen faturalanan dahil)
  SLS_DSP_CLOSED    = 2;  // kapandı: tüm kalemler faturalandı

  // sls_offer.sale_type (DB CHECK 1-5): fatura tipi / senaryosuna karşılık gelir; ihracatta teslim şartı Incoterms,
  // diğerlerinde yurt içi teslim şekilleri (einv_delivery_term.is_incoterms)
  SLS_SALE_DOMESTIC          = 1;  // satış (SATIS)
  SLS_SALE_EXPORT            = 2;  // ihracat (IHRACAT)
  SLS_SALE_EXPORT_REGISTERED = 3;  // ihraç kayıtlı (IHRACKAYITLI)
  SLS_SALE_EXEMPT            = 4;  // istisna (ISTISNA)
  SLS_SALE_WITHHOLDING       = 5;  // tevkifatlı (TEVKIFAT)

  // belge numarası önekleri (+ 6 hane)
  SLS_PREFIX_OFFER    = 'ST';
  SLS_PREFIX_ORDER    = 'SS';
  SLS_PREFIX_DISPATCH = 'SI';
  SLS_PREFIX_INVOICE  = 'SF';

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0 = seçilmemiş)
  TSlsLookupKind = (slkOfferStatus, slkOrderStatus, slkDispatchStatus, slkSaleType);

  TSlsLookup = class
  public
    class function Items(AKind: TSlsLookupKind): TArray<string>;
    class function Text(AKind: TSlsLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TSlsLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TSlsLookupKind);

    // Tutar hanesine (sys_decimal_place.total), yarım değerler sıfırdan uzağa yuvarlanır
    class function RoundAmount(AValue: Currency): Currency;
    // brüt = miktar x fiyat, iskonto = brüt x oran, net = brüt - iskonto, KDV = net x oran, toplam = net + KDV
    class procedure CalculateLine(AQuantity, AUnitPrice, ADiscountRate, AVatRate: Currency;
      out AGross, ADiscount, ANet, AVat, ATotal: Currency);
    class function CanChangeOfferStatus(AFrom, ATo: Integer): Boolean;
    class function CanChangeOrderStatus(AFrom, ATo: Integer): Boolean;
  end;

implementation

uses
  SysDecimalPlace.Cache;

class function TSlsLookup.Items(AKind: TSlsLookupKind): TArray<string>;
begin
  case AKind of
    slkOfferStatus:
      Result := [TLocalizationManager.Translate(TLangKeys.TSlsOption.OffDraft, 'Draft'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.OffSent, 'Sent'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.OffRejected, 'Rejected'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.OffOrdered, 'Ordered'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.OffClosed, 'Closed')];
    slkOrderStatus:
      Result := [TLocalizationManager.Translate(TLangKeys.TSlsOption.OrdDraft, 'Draft'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.OrdApproved, 'Approved'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.OrdPartial, 'Partially Delivered'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.OrdDelivered, 'Delivered'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.OrdCancelled, 'Cancelled')];
    slkDispatchStatus:
      Result := [TLocalizationManager.Translate(TLangKeys.TSlsOption.DspWaiting, 'Waiting'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.DspClosed, 'Closed')];
    slkSaleType:
      Result := [TLocalizationManager.Translate(TLangKeys.TSlsOption.SaleDomestic, 'Sale'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.SaleExport, 'Export'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.SaleExportRegistered, 'Export-Registered Sale'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.SaleExempt, 'Tax-Exempt'),
                 TLocalizationManager.Translate(TLangKeys.TSlsOption.SaleWithholding, 'With Withholding')];
  else
    Result := [];
  end;
end;

class function TSlsLookup.Text(AKind: TSlsLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TSlsLookup.IsValid(AKind: TSlsLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TSlsLookup.FillItems(AItems: TStrings; AKind: TSlsLookupKind);
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

class function TSlsLookup.RoundAmount(AValue: Currency): Currency;
begin
  Result := TDecimalPlaces.RoundTotal(AValue);
end;

class procedure TSlsLookup.CalculateLine(AQuantity, AUnitPrice, ADiscountRate, AVatRate: Currency;
  out AGross, ADiscount, ANet, AVat, ATotal: Currency);
begin
  AGross := RoundAmount(AQuantity * AUnitPrice);
  ADiscount := RoundAmount(AGross * ADiscountRate / 100);
  ANet := AGross - ADiscount;
  AVat := RoundAmount(ANet * AVatRate / 100);
  ATotal := ANet + AVat;
end;

class function TSlsLookup.CanChangeOfferStatus(AFrom, ATo: Integer): Boolean;
begin
  case AFrom of
    SLS_OFF_DRAFT:    Result := ATo in [SLS_OFF_SENT, SLS_OFF_REJECTED];
    SLS_OFF_SENT:     Result := ATo in [SLS_OFF_DRAFT, SLS_OFF_REJECTED, SLS_OFF_CLOSED];
    SLS_OFF_REJECTED: Result := ATo = SLS_OFF_DRAFT;
    SLS_OFF_ORDERED:  Result := ATo = SLS_OFF_CLOSED;
  else
    Result := False;
  end;
end;

class function TSlsLookup.CanChangeOrderStatus(AFrom, ATo: Integer): Boolean;
begin
  case AFrom of
    SLS_ORD_DRAFT:     Result := ATo in [SLS_ORD_APPROVED, SLS_ORD_CANCELLED];
    SLS_ORD_APPROVED:  Result := ATo in [SLS_ORD_DRAFT, SLS_ORD_CANCELLED];
    SLS_ORD_CANCELLED: Result := ATo = SLS_ORD_DRAFT;
  else
    Result := False;  // kısmi / tamamı sevk: irsaliye / irsaliyeli faturadan otomatik
  end;
end;

end.
