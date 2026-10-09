unit PrdLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

const
  // prd_labour.cost_type (DB CHECK 1-3)
  PRD_COST_LABOUR   = 1;  // işçilik
  PRD_COST_MACHINE  = 2;  // makine
  PRD_COST_OVERHEAD = 3;  // genel üretim gideri

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0 = seçilmemiş)
  TPrdLookupKind = (plkCostType);

  TPrdLookup = class
  public
    class function Items(AKind: TPrdLookupKind): TArray<string>;
    class function Text(AKind: TPrdLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TPrdLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TPrdLookupKind);
  end;

implementation

class function TPrdLookup.Items(AKind: TPrdLookupKind): TArray<string>;
begin
  case AKind of
    plkCostType:
      Result := [TLocalizationManager.Translate(TLangKeys.TPrdOption.CostLabour, 'Labour'),
                 TLocalizationManager.Translate(TLangKeys.TPrdOption.CostMachine, 'Machine'),
                 TLocalizationManager.Translate(TLangKeys.TPrdOption.CostOverhead, 'Overhead')];
  else
    Result := [];
  end;
end;

class function TPrdLookup.Text(AKind: TPrdLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TPrdLookup.IsValid(AKind: TPrdLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TPrdLookup.FillItems(AItems: TStrings; AKind: TPrdLookupKind);
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
