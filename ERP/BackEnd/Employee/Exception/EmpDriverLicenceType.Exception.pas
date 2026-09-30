unit EmpDriverLicenceType.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpDriverLicenseTypeException = class(EAppException);

  EEmpDriverLicenseTypeExceptionLicenseNameUnique = class(EEmpDriverLicenseTypeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpDriverLicenseTypeExceptionLicenseNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpDriverLicenseType.LicenseNameUnique, 'This license class already exists.');
end;

end.
