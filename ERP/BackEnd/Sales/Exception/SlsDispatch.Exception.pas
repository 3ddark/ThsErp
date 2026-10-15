unit SlsDispatch.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESlsDispatchException = class(EAppException);

  ESlsDispatchExceptionNoUnique = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionOrderCustomer = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionOrderStatus = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionKeyFieldsLocked = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionHasInvoices = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionNothingToDispatch = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESlsDispatchExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.NoUnique, 'This delivery note number already exists.');
end;

class function ESlsDispatchExceptionOrderCustomer.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.OrderCustomer, 'The order belongs to another customer.');
end;

class function ESlsDispatchExceptionOrderStatus.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.OrderStatus, 'Only approved orders can be delivered.');
end;

class function ESlsDispatchExceptionKeyFieldsLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.KeyFieldsLocked, 'Customer, order and currency cannot be changed after lines are entered.');
end;

class function ESlsDispatchExceptionHasInvoices.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.HasInvoices, 'Lines of this delivery note are invoiced.');
end;

class function ESlsDispatchExceptionNothingToDispatch.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.NothingToDispatch, 'There is no remaining quantity to deliver.');
end;

end.
