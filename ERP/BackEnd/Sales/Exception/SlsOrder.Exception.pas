unit SlsOrder.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESlsOrderException = class(EAppException);

  ESlsOrderExceptionNoUnique = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionNoLines = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionHasDeliveries = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionDeleteStatus = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionNotEditable = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionKeyFieldsLocked = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionPaymentTerm = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionDeliveryDate = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionOfferNotSent = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsOrderExceptionNothingToOrder = class(ESlsOrderException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESlsOrderExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.NoUnique, 'This order number already exists.');
end;

class function ESlsOrderExceptionNoLines.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.NoLines, 'The order has no lines.');
end;

class function ESlsOrderExceptionHasDeliveries.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.HasDeliveries, 'Goods were delivered for this order.');
end;

class function ESlsOrderExceptionDeleteStatus.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.DeleteStatus, 'Only draft or cancelled orders can be deleted.');
end;

class function ESlsOrderExceptionNotEditable.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.NotEditable, 'Delivered or cancelled orders cannot be changed.');
end;

class function ESlsOrderExceptionKeyFieldsLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.KeyFieldsLocked, 'Customer, order and currency cannot be changed after lines are entered.');
end;

class function ESlsOrderExceptionPaymentTerm.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.PaymentTerm, 'Payment term must be between 0 and 365 days.');
end;

class function ESlsOrderExceptionDeliveryDate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.DeliveryDate, 'Delivery date cannot be earlier than the order date.');
end;

class function ESlsOrderExceptionOfferNotSent.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.OfferNotSent, 'Only sent offers can be converted to orders.');
end;

class function ESlsOrderExceptionNothingToOrder.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsOrder.NothingToOrder, 'There is no remaining quantity to order.');
end;

end.
