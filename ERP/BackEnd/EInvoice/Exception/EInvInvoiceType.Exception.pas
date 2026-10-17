unit EInvInvoiceType.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvInvoiceTypeException = class(EAppException);

  EEInvInvoiceTypeExceptionCodeUnique = class(EEInvInvoiceTypeException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvInvoiceTypeExceptionInUse = class(EEInvInvoiceTypeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvInvoiceTypeExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.CodeUnique, 'This code already exists.');
end;

class function EEInvInvoiceTypeExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

end.
