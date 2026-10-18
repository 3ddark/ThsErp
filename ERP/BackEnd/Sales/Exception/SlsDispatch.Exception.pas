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

  ESlsDispatchExceptionEInvLocked = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionEInvProfileKind = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionTransportRequired = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionVehicleIsTrailer = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionTrailerNotTrailer = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionTrailerDuplicate = class(ESlsDispatchException)
  protected
    class function GetMessage: string; override;
  end;

  ESlsDispatchExceptionDriverDuplicate = class(ESlsDispatchException)
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

class function ESlsDispatchExceptionEInvLocked.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.EInvLocked, 'The e-despatch advice was sent; the delivery note cannot be changed or deleted.');
end;

class function ESlsDispatchExceptionEInvProfileKind.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.EInvProfileKind, 'The selected profile is not a despatch advice profile.');
end;

class function ESlsDispatchExceptionTransportRequired.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TransportRequired, 'e-Despatch advice needs the carrier company, or the vehicle plate and at least one driver.');
end;

class function ESlsDispatchExceptionVehicleIsTrailer.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.VehicleIsTrailer, 'The selected vehicle is a trailer; select it as a trailer.');
end;

class function ESlsDispatchExceptionTrailerNotTrailer.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TrailerNotTrailer, 'The selected trailer is not defined as a trailer.');
end;

class function ESlsDispatchExceptionTrailerDuplicate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TrailerDuplicate, 'The same trailer is selected twice.');
end;

class function ESlsDispatchExceptionDriverDuplicate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.DriverDuplicate, 'The same driver is selected twice.');
end;

end.
