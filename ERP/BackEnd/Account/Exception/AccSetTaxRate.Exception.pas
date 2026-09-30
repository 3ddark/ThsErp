unit AccSetTaxRate.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccSetTaxRateException = class(EAppException);

  EAccSetTaxRateExceptionTaxRateUnique = class(EAccSetTaxRateException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccSetTaxRateExceptionTaxRateUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.TaxRateUnique, 'This tax rate already exists.');
end;

end.
