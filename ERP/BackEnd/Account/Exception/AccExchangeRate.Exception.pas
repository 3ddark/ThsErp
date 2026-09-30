unit AccExchangeRate.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccExchangeRateException = class(EAppException);

  EAccExchangeRateExceptionRateDateCurrencyUnique = class(EAccExchangeRateException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccExchangeRateExceptionRateDateCurrencyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.RateDateCurrencyUnique, 'An exchange rate for this date and currency already exists.');
end;

end.
