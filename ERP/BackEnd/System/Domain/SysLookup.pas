unit SysLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0 = seçilmemiş)
  TSysLookupKind = (sylApiEnvironment);

  TSysLookup = class
  public
    class function Items(AKind: TSysLookupKind): TArray<string>;
    class function Text(AKind: TSysLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TSysLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TSysLookupKind);
    // Tekillik kontrolünde hariç tutulacak id: yalnız güncellemede kaydın kendisi
    class function ExcludeId(AId: Int64; AIsUpdate: Boolean): Int64;
    // servis türü kodu: küçük harf / rakam / alt çizgi, harfle başlar, 2-32 karakter
    class function IsValidServiceKind(const AValue: string): Boolean;
  end;

implementation

class function TSysLookup.Items(AKind: TSysLookupKind): TArray<string>;
begin
  case AKind of
    sylApiEnvironment:
      Result := [TLocalizationManager.Translate(TLangKeys.TSysOption.EnvTest, 'Test'),
                 TLocalizationManager.Translate(TLangKeys.TSysOption.EnvLive, 'Live')];
  else
    Result := [];
  end;
end;

class function TSysLookup.Text(AKind: TSysLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TSysLookup.IsValid(AKind: TSysLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TSysLookup.FillItems(AItems: TStrings; AKind: TSysLookupKind);
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

class function TSysLookup.ExcludeId(AId: Int64; AIsUpdate: Boolean): Int64;
begin
  if AIsUpdate then
    Result := AId
  else
    Result := 0;
end;

class function TSysLookup.IsValidServiceKind(const AValue: string): Boolean;
var
  i: Integer;
begin
  if (Length(AValue) < 2) or (Length(AValue) > 32) or not CharInSet(AValue[1], ['a'..'z']) then
    Exit(False);
  for i := 2 to Length(AValue) do
    if not CharInSet(AValue[i], ['a'..'z', '0'..'9', '_']) then
      Exit(False);
  Result := True;
end;

end.
