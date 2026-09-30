unit AccAccount.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccAccountException = class(EAppException);

  EAccAccountExceptionCodeUnique = class(EAccAccountException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccAccountExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccAccount.CodeUnique, 'This account code already exists.');
end;

end.
