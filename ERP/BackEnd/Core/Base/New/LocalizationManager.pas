unit LocalizationManager;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Classes;

type
  TLocalizationManager = class
  private
    class var FLock: TObject;
    class var FInstance: TLocalizationManager;
    class var FCurrentLanguage: string;
    class var FTranslations: TDictionary<string, TDictionary<string, string>>;

    class procedure InitializeTranslations;
    class procedure LoadDefaultTranslations;
    class constructor Create;
    class destructor Destroy;
    constructor Create;
  public
    class function Instance: TLocalizationManager;
    class procedure SetLanguage(const ALanguageCode: string);
    class function GetCurrentLanguage: string;
    class function Translate(const AKey: string; const ADefault: string = ''): string; overload;
    class function Translate(const AKey: string; const AParams: array of const; const ADefault: string = ''): string; overload;
    class function GetAvailableLanguages: TArray<string>;
    class procedure AddTranslation(const ALanguageCode, AKey, AValue: string);
    class procedure LoadTranslationsFromFile(const AFileName: string);
  end;

implementation

uses
  System.JSON, System.IOUtils;

class constructor TLocalizationManager.Create;
begin
  FLock := TObject.Create;
  FCurrentLanguage := 'en';
  FTranslations := TDictionary<string, TDictionary<string, string>>.Create;
  InitializeTranslations;
end;

class destructor TLocalizationManager.Destroy;
var
  LanguageDict: TDictionary<string, string>;
begin
  if Assigned(FTranslations) then
  begin
    for LanguageDict in FTranslations.Values do
      LanguageDict.Free;
    FreeAndNil(FTranslations);
  end;
  if Assigned(FLock) then
    FreeAndNil(FLock);
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

constructor TLocalizationManager.Create;
begin
  inherited Create;
end;

class function TLocalizationManager.Instance: TLocalizationManager;
begin
  if not Assigned(FInstance) then
    FInstance := TLocalizationManager.Create;
  Result := FInstance;
end;

class procedure TLocalizationManager.InitializeTranslations;
begin
  LoadDefaultTranslations;
end;

class procedure TLocalizationManager.LoadDefaultTranslations;
begin
  if not FTranslations.ContainsKey('en') then
    FTranslations.Add('en', TDictionary<string, string>.Create);

  FTranslations['en'].AddOrSetValue('validation.required', 'Field is required');
  FTranslations['en'].AddOrSetValue('validation.minlength', 'Field must be at least %d characters long');
  FTranslations['en'].AddOrSetValue('validation.maxlength', 'Field must not exceed %d characters');
  FTranslations['en'].AddOrSetValue('validation.range', 'Field must be between %s and %s');
  FTranslations['en'].AddOrSetValue('validation.email', 'Invalid email format');
  FTranslations['en'].AddOrSetValue('validation.regex', 'Invalid format');

  FTranslations['en'].AddOrSetValue('person.name.required', 'Person name is required');
  FTranslations['en'].AddOrSetValue('person.age.required', 'Person age is required');
  FTranslations['en'].AddOrSetValue('person.salary.required', 'Salary is required');
  FTranslations['en'].AddOrSetValue('person.country.required', 'Country is required');
  FTranslations['en'].AddOrSetValue('person.city.required', 'City is required');

  if not FTranslations.ContainsKey('tr') then
    FTranslations.Add('tr', TDictionary<string, string>.Create);

  FTranslations['tr'].AddOrSetValue('validation.required', 'Alan zorunludur');
  FTranslations['tr'].AddOrSetValue('validation.minlength', 'Alan en az %d karakter uzunluğunda olmalıdır');
  FTranslations['tr'].AddOrSetValue('validation.maxlength', 'Alan %d karakteri geçemez');
  FTranslations['tr'].AddOrSetValue('validation.range', 'Alan %s ile %s arasında olmalıdır');
  FTranslations['tr'].AddOrSetValue('validation.email', 'Geçersiz e-posta formatı');
  FTranslations['tr'].AddOrSetValue('validation.regex', 'Geçersiz format');

  FTranslations['tr'].AddOrSetValue('person.name.required', 'Kişi adı zorunludur');
  FTranslations['tr'].AddOrSetValue('person.age.required', 'Kişi yaşı zorunludur');
  FTranslations['tr'].AddOrSetValue('person.salary.required', 'Maaş zorunludur');
  FTranslations['tr'].AddOrSetValue('person.country.required', 'Ülke zorunludur');
  FTranslations['tr'].AddOrSetValue('person.city.required', 'Şehir zorunludur');

  if not FTranslations.ContainsKey('de') then
    FTranslations.Add('de', TDictionary<string, string>.Create);

  FTranslations['de'].AddOrSetValue('validation.required', 'Feld ist erforderlich');
  FTranslations['de'].AddOrSetValue('validation.minlength', 'Feld muss mindestens %d Zeichen lang sein');
  FTranslations['de'].AddOrSetValue('validation.maxlength', 'Feld darf %d Zeichen nicht überschreiten');
  FTranslations['de'].AddOrSetValue('validation.range', 'Feld muss zwischen %s und %s liegen');
  FTranslations['de'].AddOrSetValue('validation.email', 'Ungültiges E-Mail-Format');
  FTranslations['de'].AddOrSetValue('validation.regex', 'Ungültiges Format');

  FTranslations['de'].AddOrSetValue('person.name.required', 'Personenname ist erforderlich');
  FTranslations['de'].AddOrSetValue('person.age.required', 'Personenalter ist erforderlich');
  FTranslations['de'].AddOrSetValue('person.salary.required', 'Gehalt ist erforderlich');
  FTranslations['de'].AddOrSetValue('person.country.required', 'Land ist erforderlich');
  FTranslations['de'].AddOrSetValue('person.city.required', 'Stadt ist erforderlich');
end;

class procedure TLocalizationManager.SetLanguage(const ALanguageCode: string);
begin
  TMonitor.Enter(FLock);
  try
    if FTranslations.ContainsKey(ALanguageCode) then
      FCurrentLanguage := ALanguageCode
    else
      FCurrentLanguage := 'en';
  finally
    TMonitor.Exit(FLock);
  end;
end;

class function TLocalizationManager.GetCurrentLanguage: string;
begin
  Result := FCurrentLanguage;
end;

class function TLocalizationManager.Translate(const AKey: string; const ADefault: string): string;
begin
  if FTranslations.ContainsKey(FCurrentLanguage) and
     FTranslations[FCurrentLanguage].ContainsKey(AKey)
  then
    Result := FTranslations[FCurrentLanguage][AKey]
  else if FTranslations.ContainsKey('en') and
          FTranslations['en'].ContainsKey(AKey)
  then
    Result := FTranslations['en'][AKey]
  else if ADefault <> '' then
    Result := ADefault
  else
    Result := AKey;
end;

class function TLocalizationManager.Translate(const AKey: string; const AParams: array of const; const ADefault: string): string;
var
  Template: string;
begin
  Template := Translate(AKey, ADefault);
  try
    Result := Format(Template, AParams);
  except
    Result := Template;
  end;
end;

class function TLocalizationManager.GetAvailableLanguages: TArray<string>;
begin
  Result := FTranslations.Keys.ToArray;
end;

class procedure TLocalizationManager.AddTranslation(const ALanguageCode, AKey, AValue: string);
begin
  if not FTranslations.ContainsKey(ALanguageCode) then
    FTranslations.Add(ALanguageCode, TDictionary<string, string>.Create);

  FTranslations[ALanguageCode].AddOrSetValue(AKey, AValue);
end;

class procedure TLocalizationManager.LoadTranslationsFromFile(const AFileName: string);
var
  JsonText: string;
  JsonObj, LangObj: TJSONObject;
  LangPair: TJSONPair;
  TransPair: TJSONPair;
  LanguageCode: string;
begin
  if not TFile.Exists(AFileName) then
    Exit;

  try
    JsonText := TFile.ReadAllText(AFileName, TEncoding.UTF8);
    JsonObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
    try
      if Assigned(JsonObj) then
      begin
        for LangPair in JsonObj do
        begin
          LanguageCode := LangPair.JsonString.Value;
          if LangPair.JsonValue is TJSONObject then
          begin
            LangObj := LangPair.JsonValue as TJSONObject;

            if not FTranslations.ContainsKey(LanguageCode) then
              FTranslations.Add(LanguageCode, TDictionary<string, string>.Create);

            for TransPair in LangObj do
              FTranslations[LanguageCode].AddOrSetValue(
                TransPair.JsonString.Value,
                TransPair.JsonValue.Value);
          end;
        end;
      end;
    finally
      JsonObj.Free;
    end;
  except
    // JSON parsing error - ignore and use defaults
  end;
end;

end.
