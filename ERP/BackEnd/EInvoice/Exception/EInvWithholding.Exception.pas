unit EInvWithholding.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvWithholdingException = class(EAppException);

  EEInvWithholdingExceptionCodeUnique = class(EEInvWithholdingException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvWithholdingExceptionInUse = class(EEInvWithholdingException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvWithholdingExceptionRateRange = class(EEInvWithholdingException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvWithholdingExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.CodeUnique, 'This code already exists.');
end;

class function EEInvWithholdingExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

class function EEInvWithholdingExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.RateRange, 'Withholding rate must be greater than 0 and at most 100.');
end;

end.
