unit SlsInvoice.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESlsInvoiceException = class(EAppException);

  ESlsInvoiceExceptionNoUnique = class(ESlsInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceExceptionDueDate = class(ESlsInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceExceptionKeyFieldsLocked = class(ESlsInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceExceptionNothingToInvoice = class(ESlsInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceExceptionWarehouseRequired = class(ESlsInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsInvoiceExceptionOrderStatus = class(ESlsInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESlsInvoiceExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.NoUnique, 'This invoice number already exists.');
end;

class function ESlsInvoiceExceptionDueDate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.DueDate, 'Due date cannot be earlier than the invoice date.');
end;

class function ESlsInvoiceExceptionKeyFieldsLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.KeyFieldsLocked, 'Customer, order and currency cannot be changed after lines are entered.');
end;

class function ESlsInvoiceExceptionNothingToInvoice.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.NothingToInvoice, 'There is no remaining quantity to invoice.');
end;

class function ESlsInvoiceExceptionWarehouseRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.WarehouseRequired, 'Lines without a delivery note reduce stock: select a shipping warehouse.');
end;

class function ESlsInvoiceExceptionOrderStatus.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.OrderStatus, 'Only approved orders can be delivered.');
end;

end.
