unit PurQuotationDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurQuotationDetailException = class(EAppException);

  EPurQuotationDetailExceptionRateRange = class(EPurQuotationDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationDetailExceptionLineUnique = class(EPurQuotationDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationDetailExceptionDraftOnly = class(EPurQuotationDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationDetailExceptionInventoryMismatch = class(EPurQuotationDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationDetailExceptionRequestMismatch = class(EPurQuotationDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurQuotationDetailExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.RateRange, 'Rates must be between 0 and 100.');
end;

class function EPurQuotationDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.LineUnique, 'This line number already exists.');
end;

class function EPurQuotationDetailExceptionDraftOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.DraftOnly, 'Only draft quotations can be changed.');
end;

class function EPurQuotationDetailExceptionInventoryMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.InventoryMismatch, 'The stock card does not match the linked request line.');
end;

class function EPurQuotationDetailExceptionRequestMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotationDetail.RequestMismatch, 'The linked request line belongs to another request.');
end;

end.
