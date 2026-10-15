unit SlsInvoiceDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESlsInvoiceDetailException = class(EAppException);

  ESlsInvoiceDetailExceptionRateRange = class(ESlsInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceDetailExceptionLineUnique = class(ESlsInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceDetailExceptionInventoryMismatch = class(ESlsInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceDetailExceptionCustomerMismatch = class(ESlsInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceDetailExceptionSourceConflict = class(ESlsInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceDetailExceptionWarehouseRequired = class(ESlsInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceDetailExceptionOrderStatus = class(ESlsInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESlsInvoiceDetailExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.RateRange, 'Rates must be between 0 and 100.');
end;

class function ESlsInvoiceDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.LineUnique, 'This line number already exists.');
end;

class function ESlsInvoiceDetailExceptionInventoryMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.InventoryMismatch, 'The stock card does not match the linked line.');
end;

class function ESlsInvoiceDetailExceptionCustomerMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.CustomerMismatch, 'The linked document belongs to another customer.');
end;

class function ESlsInvoiceDetailExceptionSourceConflict.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.SourceConflict, 'A line can be linked either to a delivery note or to an order line.');
end;

class function ESlsInvoiceDetailExceptionWarehouseRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.WarehouseRequired, 'Lines without a delivery note reduce stock: select a shipping warehouse on the invoice.');
end;

class function ESlsInvoiceDetailExceptionOrderStatus.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoiceDetail.OrderStatus, 'Only approved orders can be delivered.');
end;

end.
