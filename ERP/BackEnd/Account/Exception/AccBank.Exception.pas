unit AccBank.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccBankException = class(EAppException);

  EAccBankExceptionBankNameUnique = class(EAccBankException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccBankExceptionBankNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccBank.BankNameUnique, 'This bank name already exists.');
end;

end.
