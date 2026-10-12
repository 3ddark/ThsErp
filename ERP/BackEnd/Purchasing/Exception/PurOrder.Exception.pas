unit PurOrder.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurOrderException = class(EAppException);

  EPurOrderExceptionNoUnique = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionNoLines = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionHasReceipts = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionDeleteStatus = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionNotEditable = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionKeyFieldsLocked = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionPaymentTerm = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionDeliveryDate = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionRequestNotApproved = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

  EPurOrderExceptionNothingToOrder = class(EPurOrderException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurOrderExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.NoUnique, 'This order number already exists.');
end;

class function EPurOrderExceptionNoLines.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.NoLines, 'The order has no lines.');
end;

class function EPurOrderExceptionHasReceipts.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.HasReceipts, 'Goods were received for this order.');
end;

class function EPurOrderExceptionDeleteStatus.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.DeleteStatus, 'Only draft or cancelled orders can be deleted.');
end;

class function EPurOrderExceptionNotEditable.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.NotEditable, 'Received or cancelled orders cannot be changed.');
end;

class function EPurOrderExceptionKeyFieldsLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.KeyFieldsLocked, 'Supplier, order and currency cannot be changed after lines are entered.');
end;

class function EPurOrderExceptionPaymentTerm.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.PaymentTerm, 'Payment term must be between 0 and 365 days.');
end;

class function EPurOrderExceptionDeliveryDate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.DeliveryDate, 'Delivery date cannot be earlier than the order date.');
end;

class function EPurOrderExceptionRequestNotApproved.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.RequestNotApproved, 'Only approved requests can be converted to orders.');
end;

class function EPurOrderExceptionNothingToOrder.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurOrder.NothingToOrder, 'There is no remaining quantity to order.');
end;

end.
