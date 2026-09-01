unit SysCountry.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysCountryException = class(EAppException);

  ESysCountryExceptionCodeUnique = class(ESysCountryException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysCountryExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysCountry.CodeUnique, 'The country code %s has already been assigned. It cannot be reassigned.');
end;

end.
