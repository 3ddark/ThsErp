unit EmpSection.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpSectionException = class(EAppException);

  EEmpSectionExceptionSectionKeyUnique = class(EEmpSectionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpSectionExceptionSectionKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpSection.SectionKeyUnique, 'This section key already exists.');
end;

end.
