unit FinMoneyAccount.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinMoneyAccountException = class(EAppException);

  EFinMoneyAccountExceptionCodeUnique = class(EFinMoneyAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyAccountExceptionNameUnique = class(EFinMoneyAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyAccountExceptionIbanUnique = class(EFinMoneyAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyAccountExceptionIbanInvalid = class(EFinMoneyAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyAccountExceptionBankRequired = class(EFinMoneyAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyAccountExceptionBranchBank = class(EFinMoneyAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyAccountExceptionHasTransactions = class(EFinMoneyAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinMoneyAccountExceptionCurrencyLocked = class(EFinMoneyAccountException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinMoneyAccountExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.CodeUnique, 'This code already exists.');
end;

class function EFinMoneyAccountExceptionNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.NameUnique, 'This name already exists.');
end;

class function EFinMoneyAccountExceptionIbanUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.IbanUnique, 'This IBAN is already used by another account.');
end;

class function EFinMoneyAccountExceptionIbanInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.IbanInvalid, 'Invalid IBAN.');
end;

class function EFinMoneyAccountExceptionBankRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.BankRequired, 'Bank is required for bank accounts.');
end;

class function EFinMoneyAccountExceptionBranchBank.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.BranchBank, 'The branch does not belong to the selected bank.');
end;

class function EFinMoneyAccountExceptionHasTransactions.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.HasTransactions, 'This account has transactions. Delete the transactions first.');
end;

class function EFinMoneyAccountExceptionCurrencyLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinMoneyAccount.CurrencyLocked, 'The currency cannot be changed after transactions.');
end;

end.
