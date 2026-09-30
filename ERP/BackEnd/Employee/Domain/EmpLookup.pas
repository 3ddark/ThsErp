unit EmpLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0/NULL = seçilmemiş)
  //   gender            : 1 Erkek, 2 Kadın
  //   military_status   : 1 Yaptı, 2 Muaf, 3 Yapmadı (NULL olabilir)
  //   marital_status    : 1 Bekar, 2 Evli
  //   *_level (dil)     : 1 Az, 2 Orta, 3 İyi, 4 Çok İyi
  //   blood_type / clothing_size: DB'de metin olarak aynen saklanır (varchar, NULL olabilir);
  //   liste çevrilmez, DB CHECK kısıtıyla aynıdır (Migrations/20260929_08)
  TEmpLookupKind = (elkGender, elkMilitaryStatus, elkMaritalStatus, elkLanguageLevel, elkBloodType, elkClothingSize);

  TEmpLookup = class
  public
    class function Items(AKind: TEmpLookupKind): TArray<string>;
    class function Text(AKind: TEmpLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TEmpLookupKind; AValue: Integer): Boolean; overload;
    class function IsValid(AKind: TEmpLookupKind; const AText: string): Boolean; overload;
    class procedure FillItems(AItems: TStrings; AKind: TEmpLookupKind);
    // Sayısal aralık (ör. çocuk / ikramiye sayısı 0-30): ItemIndex = AMin'den itibaren sıra
    class procedure FillRange(AItems: TStrings; AMin, AMax: Integer);
  end;

implementation

class function TEmpLookup.Items(AKind: TEmpLookupKind): TArray<string>;

  function Tr(const AKey, ADefault: string): string;
  begin
    Result := TLocalizationManager.Translate(AKey, ADefault);
  end;

begin
  case AKind of
    elkGender:
      Result := [Tr(TLangKeys.TEmpOption.GenderMale, 'Male'),
                 Tr(TLangKeys.TEmpOption.GenderFemale, 'Female')];
    elkMilitaryStatus:
      Result := [Tr(TLangKeys.TEmpOption.MilitaryCompleted, 'Completed'),
                 Tr(TLangKeys.TEmpOption.MilitaryExempt, 'Exempt'),
                 Tr(TLangKeys.TEmpOption.MilitaryNotCompleted, 'Not Completed')];
    elkMaritalStatus:
      Result := [Tr(TLangKeys.TEmpOption.MaritalSingle, 'Single'),
                 Tr(TLangKeys.TEmpOption.MaritalMarried, 'Married')];
    elkLanguageLevel:
      Result := [Tr(TLangKeys.TEmpOption.LevelBasic, 'Basic'),
                 Tr(TLangKeys.TEmpOption.LevelIntermediate, 'Intermediate'),
                 Tr(TLangKeys.TEmpOption.LevelGood, 'Good'),
                 Tr(TLangKeys.TEmpOption.LevelFluent, 'Fluent')];
    elkBloodType:
      Result := ['A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-', '0 Rh+', '0 Rh-'];
    elkClothingSize:
      Result := ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL'];
  else
    Result := [];
  end;
end;

class function TEmpLookup.Text(AKind: TEmpLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TEmpLookup.IsValid(AKind: TEmpLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class function TEmpLookup.IsValid(AKind: TEmpLookupKind; const AText: string): Boolean;
var
  LItem: string;
begin
  for LItem in Items(AKind) do
    if LItem = AText then
      Exit(True);
  Result := False;
end;

class procedure TEmpLookup.FillItems(AItems: TStrings; AKind: TEmpLookupKind);
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

class procedure TEmpLookup.FillRange(AItems: TStrings; AMin, AMax: Integer);
var
  I: Integer;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    for I := AMin to AMax do
      AItems.Add(IntToStr(I));
  finally
    AItems.EndUpdate;
  end;
end;

end.
