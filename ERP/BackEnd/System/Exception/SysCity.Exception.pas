unit SysCity.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysCityException = class(EAppException);

  ESysCityExceptionCityCountryUnique = class(ESysCityException)
  protected
    class function GetMessage: string; override;
  end;

  ESysCityExceptionCountryRequired = class(ESysCityException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysCityExceptionCountryRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysCity.CountryRequired, 'Country is required for the city.');
end;

class function ESysCityExceptionCityCountryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysCity.CityCountryUnique, 'The specified city already exists for this country.');
end;

end.
