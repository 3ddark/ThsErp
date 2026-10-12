unit PurReceipt.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurReceiptException = class(EAppException);

  EPurReceiptExceptionNoUnique = class(EPurReceiptException)
  protected
    class function GetMessage: string; override;
  end;

  EPurReceiptExceptionOrderSupplier = class(EPurReceiptException)
  protected
    class function GetMessage: string; override;
  end;

  EPurReceiptExceptionOrderStatus = class(EPurReceiptException)
  protected
    class function GetMessage: string; override;
  end;

  EPurReceiptExceptionKeyFieldsLocked = class(EPurReceiptException)
  protected
    class function GetMessage: string; override;
  end;

  EPurReceiptExceptionHasInvoices = class(EPurReceiptException)
  protected
    class function GetMessage: string; override;
  end;

  EPurReceiptExceptionNothingToReceive = class(EPurReceiptException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurReceiptExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceipt.NoUnique, 'This receipt number already exists.');
end;

class function EPurReceiptExceptionOrderSupplier.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceipt.OrderSupplier, 'The order belongs to another supplier.');
end;

class function EPurReceiptExceptionOrderStatus.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceipt.OrderStatus, 'Goods can only be received for approved orders.');
end;

class function EPurReceiptExceptionKeyFieldsLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceipt.KeyFieldsLocked, 'Supplier, order and currency cannot be changed after lines are entered.');
end;

class function EPurReceiptExceptionHasInvoices.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceipt.HasInvoices, 'Lines of this receipt are invoiced.');
end;

class function EPurReceiptExceptionNothingToReceive.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurReceipt.NothingToReceive, 'There is no remaining quantity to receive.');
end;

end.
