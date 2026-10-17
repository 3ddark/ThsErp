unit EInvPaymentMeans.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvPaymentMeansException = class(EAppException);

  EEInvPaymentMeansExceptionCodeUnique = class(EEInvPaymentMeansException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvPaymentMeansExceptionInUse = class(EEInvPaymentMeansException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvPaymentMeansExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvPaymentMeans.CodeUnique, 'This code already exists.');
end;

class function EEInvPaymentMeansExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvPaymentMeans.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

end.
