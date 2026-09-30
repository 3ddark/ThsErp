unit EmpLanguage.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpLanguageException = class(EAppException);

  EEmpLanguageExceptionLanguageNameUnique = class(EEmpLanguageException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpLanguageExceptionLanguageNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpLanguage.LanguageNameUnique, 'This language already exists.');
end;

end.
