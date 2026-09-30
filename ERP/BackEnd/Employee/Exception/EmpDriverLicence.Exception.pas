unit EmpDriverLicence.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpDriverLicenceException = class(EAppException);

  EEmpDriverLicenceExceptionEmployeeLicenseUnique = class(EEmpDriverLicenceException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpDriverLicenceExceptionEmployeeLicenseUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpDriverAbility.EmployeeLicenseUnique, 'This license class is already defined for the employee.');
end;

end.
