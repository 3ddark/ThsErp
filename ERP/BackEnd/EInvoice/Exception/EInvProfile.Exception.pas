unit EInvProfile.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvProfileException = class(EAppException);

  EEInvProfileExceptionCodeUnique = class(EEInvProfileException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvProfileExceptionInUse = class(EEInvProfileException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvProfileExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvProfile.CodeUnique, 'This code already exists.');
end;

class function EEInvProfileExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvProfile.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

end.
