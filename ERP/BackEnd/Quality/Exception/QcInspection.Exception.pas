unit QcInspection.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EQcInspectionException = class(EAppException);

  EQcInspectionExceptionModuleDisabled = class(EQcInspectionException)
  protected
    class function GetMessage: string; override;
  end;

  EQcInspectionExceptionNoUnique = class(EQcInspectionException)
  protected
    class function GetMessage: string; override;
  end;

  EQcInspectionExceptionLineInspected = class(EQcInspectionException)
  protected
    class function GetMessage: string; override;
  end;

  EQcInspectionExceptionReceiptLineNotFound = class(EQcInspectionException)
  protected
    class function GetMessage: string; override;
  end;

  EQcInspectionExceptionNotRequired = class(EQcInspectionException)
  protected
    class function GetMessage: string; override;
  end;

  EQcInspectionExceptionRejectedQuantity = class(EQcInspectionException)
  protected
    class function GetMessage: string; override;
  end;

  EQcInspectionExceptionDispositionRequired = class(EQcInspectionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EQcInspectionExceptionModuleDisabled.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcInspection.ModuleDisabled, 'Incoming quality control is disabled in the company settings.');
end;

class function EQcInspectionExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcInspection.NoUnique, 'This inspection number already exists.');
end;

class function EQcInspectionExceptionLineInspected.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcInspection.LineInspected, 'This goods receipt line already has an inspection record.');
end;

class function EQcInspectionExceptionReceiptLineNotFound.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcInspection.ReceiptLineNotFound, 'The goods receipt line was not found.');
end;

class function EQcInspectionExceptionNotRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcInspection.NotRequired, 'No quality control is defined for this stock card or its group.');
end;

class function EQcInspectionExceptionRejectedQuantity.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcInspection.RejectedQuantity, 'Rejected quantity must be between 0 and the received quantity.');
end;

class function EQcInspectionExceptionDispositionRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TQcInspection.DispositionRequired, 'Select a disposition for the rejected quantity.');
end;

end.
