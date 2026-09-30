unit EmpTask.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpTaskException = class(EAppException);

  EEmpTaskExceptionTaskKeyUnique = class(EEmpTaskException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpTaskExceptionTaskKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpTask.TaskKeyUnique, 'This task key already exists.');
end;

end.
