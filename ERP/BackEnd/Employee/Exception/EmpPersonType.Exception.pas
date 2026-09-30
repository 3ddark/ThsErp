unit EmpPersonType.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpPersonTypeException = class(EAppException);

  EEmpPersonTypeExceptionPersonTypeKeyUnique = class(EEmpPersonTypeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpPersonTypeExceptionPersonTypeKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpPersonType.PersonTypeKeyUnique, 'This employee type key already exists.');
end;

end.
