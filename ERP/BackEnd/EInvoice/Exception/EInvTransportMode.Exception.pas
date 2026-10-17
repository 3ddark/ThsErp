unit EInvTransportMode.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvTransportModeException = class(EAppException);

  EEInvTransportModeExceptionCodeUnique = class(EEInvTransportModeException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvTransportModeExceptionInUse = class(EEInvTransportModeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvTransportModeExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.CodeUnique, 'This code already exists.');
end;

class function EEInvTransportModeExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

end.
