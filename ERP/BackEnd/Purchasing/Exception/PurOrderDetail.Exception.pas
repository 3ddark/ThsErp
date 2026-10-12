unit PurOrderDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurOrderDetailException = class(EAppException);

  EPurOrderDetailExceptionRateRange = class(EPurOrderDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderDetailExceptionLineUnique = class(EPurOrderDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderDetailExceptionDraftOnly = class(EPurOrderDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderDetailExceptionInventoryMismatch = class(EPurOrderDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurOrderDetailExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.RateRange, 'Rates must be between 0 and 100.');
end;

class function EPurOrderDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.LineUnique, 'This line number already exists.');
end;

class function EPurOrderDetailExceptionDraftOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.DraftOnly, 'Only draft orders can be changed.');
end;

class function EPurOrderDetailExceptionInventoryMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrderDetail.InventoryMismatch, 'The stock card does not match the linked line.');
end;

end.
