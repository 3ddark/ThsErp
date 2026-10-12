unit FinCompanyBankAccount.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinCompanyBankAccountException = class(EAppException);

  EFinCompanyBankAccountExceptionIbanInvalid = class(EFinCompanyBankAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCompanyBankAccountExceptionIbanUnique = class(EFinCompanyBankAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCompanyBankAccountExceptionSortRange = class(EFinCompanyBankAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCompanyBankAccountExceptionInUse = class(EFinCompanyBankAccountException)
  protected
    class function GetMessage: string; override;
  end;

  EFinCompanyBankAccountExceptionCurrencyLocked = class(EFinCompanyBankAccountException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinCompanyBankAccountExceptionIbanInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.IbanInvalid, 'Invalid IBAN.');
end;

class function EFinCompanyBankAccountExceptionIbanUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.IbanUnique, 'This IBAN is already defined.');
end;

class function EFinCompanyBankAccountExceptionSortRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.SortRange, 'Sort order must be between 0 and 999.');
end;

class function EFinCompanyBankAccountExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.InUse, 'The account is used on cheques / promissory notes.');
end;

class function EFinCompanyBankAccountExceptionCurrencyLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinCompanyBankAccount.CurrencyLocked, 'The currency cannot be changed while the account is used.');
end;

end.
