unit EInvTaxExemption.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvTaxExemptionException = class(EAppException);

  EEInvTaxExemptionExceptionCodeUnique = class(EEInvTaxExemptionException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvTaxExemptionExceptionInUse = class(EEInvTaxExemptionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvTaxExemptionExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.CodeUnique, 'This code already exists.');
end;

class function EEInvTaxExemptionExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

end.
