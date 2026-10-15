unit SlsOrderDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESlsOrderDetailException = class(EAppException);

  ESlsOrderDetailExceptionRateRange = class(ESlsOrderDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderDetailExceptionLineUnique = class(ESlsOrderDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderDetailExceptionDraftOnly = class(ESlsOrderDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderDetailExceptionInventoryMismatch = class(ESlsOrderDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESlsOrderDetailExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.RateRange, 'Rates must be between 0 and 100.');
end;

class function ESlsOrderDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.LineUnique, 'This line number already exists.');
end;

class function ESlsOrderDetailExceptionDraftOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.DraftOnly, 'Only draft orders can be changed.');
end;

class function ESlsOrderDetailExceptionInventoryMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrderDetail.InventoryMismatch, 'The stock card does not match the linked line.');
end;

end.
