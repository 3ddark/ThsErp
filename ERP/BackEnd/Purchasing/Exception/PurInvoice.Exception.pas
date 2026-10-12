unit PurInvoice.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurInvoiceException = class(EAppException);

  EPurInvoiceExceptionNoUnique = class(EPurInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

  EPurInvoiceExceptionDueDate = class(EPurInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

  EPurInvoiceExceptionKeyFieldsLocked = class(EPurInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

  EPurInvoiceExceptionNothingToInvoice = class(EPurInvoiceException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurInvoiceExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurInvoice.NoUnique, 'This invoice number already exists for the supplier.');
end;

class function EPurInvoiceExceptionDueDate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurInvoice.DueDate, 'Due date cannot be earlier than the invoice date.');
end;

class function EPurInvoiceExceptionKeyFieldsLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurInvoice.KeyFieldsLocked, 'Supplier, order and currency cannot be changed after lines are entered.');
end;

class function EPurInvoiceExceptionNothingToInvoice.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurInvoice.NothingToInvoice, 'There is no remaining quantity to invoice.');
end;

end.
