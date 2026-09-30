unit EmpLanguageAbility.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpLanguageAbilityException = class(EAppException);

  EEmpLanguageAbilityExceptionEmployeeLanguageUnique = class(EEmpLanguageAbilityException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpLanguageAbilityExceptionEmployeeLanguageUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.EmployeeLanguageUnique, 'This language is already defined for the employee.');
end;

end.
