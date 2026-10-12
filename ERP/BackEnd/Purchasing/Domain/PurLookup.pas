unit PurLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

const
  // pur_request.status (DB CHECK 1-5)
  PUR_REQ_DRAFT     = 1;  // taslak (kalemler düzenlenebilir)
  PUR_REQ_APPROVED  = 2;  // onaylandı (siparişe dönüştürülebilir)
  PUR_REQ_REJECTED  = 3;  // reddedildi
  PUR_REQ_ORDERED   = 4;  // tamamı siparişe dönüştü (otomatik)
  PUR_REQ_CLOSED    = 5;  // kapandı

  // pur_order.status (DB CHECK 1-5)
  PUR_ORD_DRAFT     = 1;  // taslak (kalemler düzenlenebilir)
  PUR_ORD_APPROVED  = 2;  // onaylandı (mal kabul yapılabilir)
  PUR_ORD_PARTIAL   = 3;  // kısmi teslim (otomatik)
  PUR_ORD_RECEIVED  = 4;  // tamamı teslim alındı (otomatik)
  PUR_ORD_CANCELLED = 5;  // iptal

  // belge numarası önekleri (+ 6 hane)
  PUR_PREFIX_REQUEST = 'PT';
  PUR_PREFIX_ORDER   = 'PS';
  PUR_PREFIX_RECEIPT = 'MK';

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0 = seçilmemiş)
  TPurLookupKind = (plkRequestStatus, plkOrderStatus);

  TPurLookup = class
  public
    class function Items(AKind: TPurLookupKind): TArray<string>;
    class function Text(AKind: TPurLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TPurLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TPurLookupKind);

    // 2 haneye, yarım değerler sıfırdan uzağa yuvarlanır (Round bankacı yuvarlaması yapar)
    class function RoundAmount(AValue: Currency): Currency;
    // brüt = miktar x fiyat, iskonto = brüt x oran, net = brüt - iskonto, KDV = net x oran, toplam = net + KDV
    class procedure CalculateLine(AQuantity, AUnitPrice, ADiscountRate, AVatRate: Currency;
      out AGross, ADiscount, ANet, AVat, ATotal: Currency);
    class function CanChangeRequestStatus(AFrom, ATo: Integer): Boolean;
    class function CanChangeOrderStatus(AFrom, ATo: Integer): Boolean;
  end;

implementation

class function TPurLookup.Items(AKind: TPurLookupKind): TArray<string>;
begin
  case AKind of
    plkRequestStatus:
      Result := [TLocalizationManager.Translate(TLangKeys.TPurOption.ReqDraft, 'Draft'),
                 TLocalizationManager.Translate(TLangKeys.TPurOption.ReqApproved, 'Approved'),
                 TLocalizationManager.Translate(TLangKeys.TPurOption.ReqRejected, 'Rejected'),
                 TLocalizationManager.Translate(TLangKeys.TPurOption.ReqOrdered, 'Ordered'),
                 TLocalizationManager.Translate(TLangKeys.TPurOption.ReqClosed, 'Closed')];
    plkOrderStatus:
      Result := [TLocalizationManager.Translate(TLangKeys.TPurOption.OrdDraft, 'Draft'),
                 TLocalizationManager.Translate(TLangKeys.TPurOption.OrdApproved, 'Approved'),
                 TLocalizationManager.Translate(TLangKeys.TPurOption.OrdPartial, 'Partially Received'),
                 TLocalizationManager.Translate(TLangKeys.TPurOption.OrdReceived, 'Received'),
                 TLocalizationManager.Translate(TLangKeys.TPurOption.OrdCancelled, 'Cancelled')];
  else
    Result := [];
  end;
end;

class function TPurLookup.Text(AKind: TPurLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TPurLookup.IsValid(AKind: TPurLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TPurLookup.FillItems(AItems: TStrings; AKind: TPurLookupKind);
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

class function TPurLookup.RoundAmount(AValue: Currency): Currency;
var
  LCents: Int64;
begin
  if AValue >= 0 then
    LCents := Trunc(AValue * 100 + 0.5)
  else
    LCents := -Trunc(-AValue * 100 + 0.5);
  Result := LCents / 100;
end;

class procedure TPurLookup.CalculateLine(AQuantity, AUnitPrice, ADiscountRate, AVatRate: Currency;
  out AGross, ADiscount, ANet, AVat, ATotal: Currency);
begin
  AGross := RoundAmount(AQuantity * AUnitPrice);
  ADiscount := RoundAmount(AGross * ADiscountRate / 100);
  ANet := AGross - ADiscount;
  AVat := RoundAmount(ANet * AVatRate / 100);
  ATotal := ANet + AVat;
end;

class function TPurLookup.CanChangeRequestStatus(AFrom, ATo: Integer): Boolean;
begin
  case AFrom of
    PUR_REQ_DRAFT:    Result := ATo in [PUR_REQ_APPROVED, PUR_REQ_REJECTED];
    PUR_REQ_APPROVED: Result := ATo in [PUR_REQ_DRAFT, PUR_REQ_REJECTED, PUR_REQ_CLOSED];
    PUR_REQ_REJECTED: Result := ATo = PUR_REQ_DRAFT;
    PUR_REQ_ORDERED:  Result := ATo = PUR_REQ_CLOSED;
  else
    Result := False;
  end;
end;

class function TPurLookup.CanChangeOrderStatus(AFrom, ATo: Integer): Boolean;
begin
  case AFrom of
    PUR_ORD_DRAFT:     Result := ATo in [PUR_ORD_APPROVED, PUR_ORD_CANCELLED];
    PUR_ORD_APPROVED:  Result := ATo in [PUR_ORD_DRAFT, PUR_ORD_CANCELLED];
    PUR_ORD_CANCELLED: Result := ATo = PUR_ORD_DRAFT;
  else
    Result := False;  // kısmi / tamamı teslim: mal kabullerden otomatik
  end;
end;

end.
