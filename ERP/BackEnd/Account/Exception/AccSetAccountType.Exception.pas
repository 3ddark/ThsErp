unit AccSetAccountType.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccSetAccountTypeException = class(EAppException);

  EAccSetAccountTypeExceptionAccountTypeKeyUnique = class(EAccSetAccountTypeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccSetAccountTypeExceptionAccountTypeKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.AccountTypeKeyUnique, 'This account type key already exists.');
end;

end.
