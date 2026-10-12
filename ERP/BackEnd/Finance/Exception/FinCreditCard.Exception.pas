unit FinCreditCard.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinCreditCardException = class(EAppException);

  EFinCreditCardExceptionNameUnique = class(EFinCreditCardException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCreditCardExceptionHasTransactions = class(EFinCreditCardException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCreditCardExceptionLastDigitsInvalid = class(EFinCreditCardException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCreditCardExceptionDayInvalid = class(EFinCreditCardException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinCreditCardExceptionNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.NameUnique, 'This card name already exists.');
end;

class function EFinCreditCardExceptionHasTransactions.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.HasTransactions, 'This record has transactions. Delete the transactions first.');
end;

class function EFinCreditCardExceptionLastDigitsInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.LastDigitsInvalid, 'Last 4 digits must consist of 4 numbers.');
end;

class function EFinCreditCardExceptionDayInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.DayInvalid, 'Statement and payment days must be between 1 and 31.');
end;

end.
