unit SlsOfferDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESlsOfferDetailException = class(EAppException);

  ESlsOfferDetailExceptionRateRange = class(ESlsOfferDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOfferDetailExceptionLineUnique = class(ESlsOfferDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOfferDetailExceptionDraftOnly = class(ESlsOfferDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESlsOfferDetailExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.RateRange, 'Rates must be between 0 and 100.');
end;

class function ESlsOfferDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.LineUnique, 'This line number already exists.');
end;

class function ESlsOfferDetailExceptionDraftOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.DraftOnly, 'Only draft offers can be changed.');
end;

end.
