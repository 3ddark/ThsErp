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

implementation

class function ESysCityExceptionCityCountryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysCity.CityCountryUnique, 'City %s has already been assigned to this %s. It cannot be assigned again.');
end;

end.
