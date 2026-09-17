unit SysLanguage.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysLanguageException = class(EAppException);

  ESysLanguageExceptionLocaleUnique = class(ESysLanguageException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysLanguageExceptionLocaleUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysLanguage.LocaleUnique, 'The locale has already been assigned. It cannot be assigned again.');
end;

end.
