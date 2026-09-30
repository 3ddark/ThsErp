unit AccLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

const
  // acc_set_account_type satırları (kod içinde sabit id olarak kullanılır)
  ACC_ACCOUNT_TYPE_MAIN         = 1;  // ANA: ana hesap (ör. 120)
  ACC_ACCOUNT_TYPE_INTERMEDIATE = 2;  // ARA: ara hesap (ör. 120-001)
  ACC_ACCOUNT_TYPE_DETAIL       = 3;  // SON: hareket gören hesap (ör. 120-001-001)

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0/NULL = seçilmemiş)
  //   taxpayer_type (acc_account_taxpayer): 1 Tüzel kişi, 2 Gerçek kişi (Migrations/20260929_11)
  TAccLookupKind = (alkTaxpayerType);

  TAccLookup = class
  public
    class function Items(AKind: TAccLookupKind): TArray<string>;
    class function Text(AKind: TAccLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TAccLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TAccLookupKind);
  end;

implementation

class function TAccLookup.Items(AKind: TAccLookupKind): TArray<string>;
begin
  case AKind of
    alkTaxpayerType:
      Result := [TLocalizationManager.Translate(TLangKeys.TAccOption.TaxpayerLegal, 'Legal Entity'),
                 TLocalizationManager.Translate(TLangKeys.TAccOption.TaxpayerReal, 'Real Person')];
  else
    Result := [];
  end;
end;

class function TAccLookup.Text(AKind: TAccLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TAccLookup.IsValid(AKind: TAccLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TAccLookup.FillItems(AItems: TStrings; AKind: TAccLookupKind);
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

end.
