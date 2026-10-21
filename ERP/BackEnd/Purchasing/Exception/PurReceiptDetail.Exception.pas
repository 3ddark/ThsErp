unit PurReceiptDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurReceiptDetailException = class(EAppException);

  EPurReceiptDetailExceptionInventoryMismatch = class(EPurReceiptDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurReceiptDetailExceptionOrderMismatch = class(EPurReceiptDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurReceiptDetailExceptionInvoiced = class(EPurReceiptDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurReceiptDetailExceptionLineUnique = class(EPurReceiptDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurReceiptDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.LineUnique, 'This line number is already used on the goods receipt.');
end;

class function EPurReceiptDetailExceptionInventoryMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.InventoryMismatch, 'The stock card does not match the linked line.');
end;

class function EPurReceiptDetailExceptionOrderMismatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.OrderMismatch, 'The order line does not belong to the receipt''s order.');
end;

class function EPurReceiptDetailExceptionInvoiced.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.Invoiced, 'Invoiced lines cannot be reduced, moved or deleted.');
end;

end.
