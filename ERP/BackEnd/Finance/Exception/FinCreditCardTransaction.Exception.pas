unit FinCreditCardTransaction.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinCreditCardTransactionException = class(EAppException);

  EFinCreditCardTransactionExceptionCardPassive = class(EFinCreditCardTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCreditCardTransactionExceptionInstallmentRange = class(EFinCreditCardTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCreditCardTransactionExceptionInstallmentOnlySpending = class(EFinCreditCardTransactionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinCreditCardTransactionExceptionCardPassive.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.CardPassive, 'The credit card is not active.');
end;

class function EFinCreditCardTransactionExceptionInstallmentRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.InstallmentRange, 'Installment count must be between 1 and 36.');
end;

class function EFinCreditCardTransactionExceptionInstallmentOnlySpending.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.InstallmentOnlySpending, 'Installments are only allowed for spending.');
end;

end.
