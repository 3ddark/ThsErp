unit EInvVehicle.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvVehicleException = class(EAppException);

  EEInvVehicleExceptionPlateUnique = class(EEInvVehicleException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvVehicleExceptionPlateInvalid = class(EEInvVehicleException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvVehicleExceptionInUse = class(EEInvVehicleException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvVehicleExceptionPlateUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.PlateUnique, 'This plate number already exists.');
end;

class function EEInvVehicleExceptionPlateInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.PlateInvalid, 'Plate number must be 4-16 letters / digits (e.g. 34ABC123).');
end;

class function EEInvVehicleExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.InUse, 'This record is used on despatch advices. Make it passive instead of deleting it.');
end;

end.
