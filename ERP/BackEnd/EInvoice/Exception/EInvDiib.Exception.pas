unit EInvDiib.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvDiibException = class(EAppException);

  EEInvDiibExceptionDocumentNoUnique = class(EEInvDiibException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDiibExceptionAccountRequired = class(EEInvDiibException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDiibExceptionDateRange = class(EEInvDiibException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDiibExceptionInUse = class(EEInvDiibException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvDiibExceptionDocumentNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDiib.DocumentNoUnique, 'This DIIB number already exists.');
end;

class function EEInvDiibExceptionAccountRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDiib.AccountRequired, 'Select the customer / exporter who holds the certificate.');
end;

class function EEInvDiibExceptionDateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDiib.DateRange, 'The validity date cannot be before the issue date.');
end;

class function EEInvDiibExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDiib.InUse, 'Lines of this certificate are used on invoices. Make it passive instead of deleting it.');
end;

end.
