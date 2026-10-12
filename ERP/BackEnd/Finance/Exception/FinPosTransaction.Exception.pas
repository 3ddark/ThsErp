unit FinPosTransaction.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EFinPosTransactionException = class(EAppException);

  EFinPosTransactionExceptionPosPassive = class(EFinPosTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinPosTransactionExceptionInstallmentRange = class(EFinPosTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinPosTransactionExceptionRateRange = class(EFinPosTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinPosTransactionExceptionLastDigitsInvalid = class(EFinPosTransactionException)
  protected
    class function GetMessage: string; override;
  end;

  EFinPosTransactionExceptionValueDateBefore = class(EFinPosTransactionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EFinPosTransactionExceptionPosPassive.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.PosPassive, 'The POS terminal is not active.');
end;

class function EFinPosTransactionExceptionInstallmentRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.InstallmentRange, 'Installment count must be between 1 and 36.');
end;

class function EFinPosTransactionExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.RateRange, 'Commission rate must be between 0 and 100.');
end;

class function EFinPosTransactionExceptionLastDigitsInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.LastDigitsInvalid, 'Last 4 digits must consist of 4 numbers.');
end;

class function EFinPosTransactionExceptionValueDateBefore.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ValueDateBefore, 'Value date cannot be earlier than the transaction date.');
end;

end.
