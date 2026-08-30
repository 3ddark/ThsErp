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
  Result := TLocalizationManager.Translate(TLangKeys.TSysCity.CityCountryUnique, '%s Şehri bu %s zaten atanmış. Tekrar atanamaz.');
end;

end.
