unit SlsDispatchDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESlsDispatchDetailException = class(EAppException);

  ESlsDispatchDetailExceptionInventoryMismatch = class(ESlsDispatchDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchDetailExceptionOrderMismatch = class(ESlsDispatchDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchDetailExceptionInvoiced = class(ESlsDispatchDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchDetailExceptionLineUnique = class(ESlsDispatchDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESlsDispatchDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.LineUnique, 'This line number already exists.');
end;

class function ESlsDispatchDetailExceptionInventoryMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.InventoryMismatch, 'The stock card does not match the linked line.');
end;

class function ESlsDispatchDetailExceptionOrderMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.OrderMismatch, 'The order line does not belong to the delivery note''s order.');
end;

class function ESlsDispatchDetailExceptionInvoiced.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.Invoiced, 'Invoiced lines cannot be reduced, moved or deleted.');
end;

end.
