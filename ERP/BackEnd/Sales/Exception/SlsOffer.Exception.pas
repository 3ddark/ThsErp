unit SlsOffer.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESlsOfferException = class(EAppException);

  ESlsOfferExceptionNoUnique = class(ESlsOfferException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOfferExceptionDraftOnly = class(ESlsOfferException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOfferExceptionNoLines = class(ESlsOfferException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOfferExceptionHasOrders = class(ESlsOfferException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOfferExceptionValidUntil = class(ESlsOfferException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOfferExceptionPaymentTerm = class(ESlsOfferException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESlsOfferExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOffer.NoUnique, 'This offer number already exists.');
end;

class function ESlsOfferExceptionDraftOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOffer.DraftOnly, 'Only draft offers can be changed.');
end;

class function ESlsOfferExceptionNoLines.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOffer.NoLines, 'The offer has no lines.');
end;

class function ESlsOfferExceptionHasOrders.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOffer.HasOrders, 'Lines of this offer are already on orders.');
end;

class function ESlsOfferExceptionValidUntil.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOffer.ValidUntil, 'Valid-until date cannot be earlier than the offer date.');
end;

class function ESlsOfferExceptionPaymentTerm.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOffer.PaymentTerm, 'Payment term must be between 0 and 365 days.');
end;

end.
