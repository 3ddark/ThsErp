unit EmpTransportation.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpTransportationException = class(EAppException);

  EEmpTransportationExceptionCarNoUnique = class(EEmpTransportationException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpTransportationExceptionCarNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpTransportation.CarNoUnique, 'This car number already exists.');
end;

end.
