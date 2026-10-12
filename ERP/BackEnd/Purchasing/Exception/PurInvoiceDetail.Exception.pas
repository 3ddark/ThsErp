unit PurInvoiceDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurInvoiceDetailException = class(EAppException);

  EPurInvoiceDetailExceptionRateRange = class(EPurInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurInvoiceDetailExceptionLineUnique = class(EPurInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurInvoiceDetailExceptionInventoryMismatch = class(EPurInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurInvoiceDetailExceptionSupplierMismatch = class(EPurInvoiceDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurInvoiceDetailExceptionRateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.RateRange, 'Rates must be between 0 and 100.');
end;

class function EPurInvoiceDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.LineUnique, 'This line number already exists.');
end;

class function EPurInvoiceDetailExceptionInventoryMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.InventoryMismatch, 'The stock card does not match the linked line.');
end;

class function EPurInvoiceDetailExceptionSupplierMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurInvoiceDetail.SupplierMismatch, 'The goods receipt belongs to another supplier.');
end;

end.
