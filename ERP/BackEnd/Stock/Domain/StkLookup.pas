unit StkLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

const
  // stk_transaction.transaction_type (DB CHECK ile ambar alanlarına bağlı)
  STK_TRANSACTION_IN       = 1;  // giriş: yalnız hedef ambar
  STK_TRANSACTION_OUT      = 2;  // çıkış: yalnız kaynak ambar
  STK_TRANSACTION_TRANSFER = 3;  // transfer: kaynak ve hedef ambar (farklı)

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0 = seçilmemiş)
  TStkLookupKind = (slkTransactionType);

  TStkLookup = class
  public
    class function Items(AKind: TStkLookupKind): TArray<string>;
    class function Text(AKind: TStkLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TStkLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TStkLookupKind);
  end;

implementation

class function TStkLookup.Items(AKind: TStkLookupKind): TArray<string>;
begin
  case AKind of
    slkTransactionType:
      Result := [TLocalizationManager.Translate(TLangKeys.TStkOption.TransactionIn, 'Incoming'),
                 TLocalizationManager.Translate(TLangKeys.TStkOption.TransactionOut, 'Outgoing'),
                 TLocalizationManager.Translate(TLangKeys.TStkOption.TransactionTransfer, 'Transfer')];
  else
    Result := [];
  end;
end;

class function TStkLookup.Text(AKind: TStkLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TStkLookup.IsValid(AKind: TStkLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TStkLookup.FillItems(AItems: TStrings; AKind: TStkLookupKind);
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
