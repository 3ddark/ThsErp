unit PurQuotation.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurQuotationException = class(EAppException);

  EPurQuotationExceptionNoUnique = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionNoLines = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionDeleteStatus = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionNotEditable = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionValidUntil = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionDeliveryDate = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionDeliveryDays = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionPaymentTerm = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionRequestNotApproved = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionNothingToQuote = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionSupplierHasQuotation = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionAlreadySelected = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

  EPurQuotationExceptionNotApproved = class(EPurQuotationException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurQuotationExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.NoUnique, 'This quotation number already exists.');
end;

class function EPurQuotationExceptionNoLines.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.NoLines, 'The quotation has no lines.');
end;

class function EPurQuotationExceptionDeleteStatus.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.DeleteStatus, 'Only draft, rejected or not selected quotations can be deleted.');
end;

class function EPurQuotationExceptionNotEditable.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.NotEditable, 'Only draft quotations can be changed.');
end;

class function EPurQuotationExceptionValidUntil.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.ValidUntil, 'Valid until date cannot be before the quotation date.');
end;

class function EPurQuotationExceptionDeliveryDate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.DeliveryDate, 'Delivery date cannot be before the quotation date.');
end;

class function EPurQuotationExceptionDeliveryDays.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.DeliveryDays, 'Delivery time must be between 0 and 999 days.');
end;

class function EPurQuotationExceptionPaymentTerm.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.PaymentTerm, 'Payment term must be between 0 and 365 days.');
end;

class function EPurQuotationExceptionRequestNotApproved.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.RequestNotApproved, 'Quotations can only be requested for approved purchase requests.');
end;

class function EPurQuotationExceptionNothingToQuote.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.NothingToQuote, 'The request has no open quantity.');
end;

class function EPurQuotationExceptionSupplierHasQuotation.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.SupplierHasQuotation, 'This supplier already has an open quotation for the request.');
end;

class function EPurQuotationExceptionAlreadySelected.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.AlreadySelected, 'Another quotation of this request is already selected.');
end;

class function EPurQuotationExceptionNotApproved.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurQuotation.NotApproved, 'Only approved quotations can be converted to an order.');
end;

end.
