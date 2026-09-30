unit EmpUnit.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpUnitException = class(EAppException);

  EEmpUnitExceptionUnitKeyUnique = class(EEmpUnitException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpUnitExceptionUnitKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpUnit.UnitKeyUnique, 'This unit key already exists in the section.');
end;

end.
