unit AccAccountAddress.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccAccountAddressException = class(EAppException);

  EAccAccountAddressExceptionValidDateRange = class(EAccAccountAddressException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccAccountAddressExceptionValidDateRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccAccountAddress.ValidDateRange, 'Valid-to date cannot be earlier than valid-from date.');
end;

end.
