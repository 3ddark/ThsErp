unit FinMoneyTransaction.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinMoneyTransactionException = class(EAppException);

  EFinMoneyTransactionExceptionAccountPassive = class(EFinMoneyTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyTransactionExceptionSameAccount = class(EFinMoneyTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyTransactionExceptionCurrencyMismatch = class(EFinMoneyTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyTransactionExceptionIbanInvalid = class(EFinMoneyTransactionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinMoneyTransactionExceptionAccountPassive.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.AccountPassive, 'The cash / bank account is not active.');
end;

class function EFinMoneyTransactionExceptionSameAccount.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.SameAccount, 'Source and target accounts must be different.');
end;

class function EFinMoneyTransactionExceptionCurrencyMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.CurrencyMismatch, 'Transfers are only allowed between accounts with the same currency.');
end;

class function EFinMoneyTransactionExceptionIbanInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.IbanInvalid, 'Invalid IBAN.');
end;

end.
