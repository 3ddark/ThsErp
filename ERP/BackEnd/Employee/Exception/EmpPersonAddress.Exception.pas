unit EmpPersonAddress.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEmpPersonAddressException = class(EAppException);

  EEmpPersonAddressExceptionValidDateRange = class(EEmpPersonAddressException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEmpPersonAddressExceptionValidDateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ValidDateRange, 'Valid-to date cannot be earlier than valid-from date.');
end;

end.
