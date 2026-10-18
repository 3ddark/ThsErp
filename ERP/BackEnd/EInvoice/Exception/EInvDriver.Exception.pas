unit EInvDriver.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvDriverException = class(EAppException);

  EEInvDriverExceptionNationalIdUnique = class(EEInvDriverException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDriverExceptionNationalIdInvalid = class(EEInvDriverException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDriverExceptionInUse = class(EEInvDriverException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvDriverExceptionNationalIdUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDriver.NationalIdUnique, 'A driver with this national ID already exists.');
end;

class function EEInvDriverExceptionNationalIdInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDriver.NationalIdInvalid, 'National ID (TCKN) is not valid (11 digits, check digits).');
end;

class function EEInvDriverExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDriver.InUse, 'This record is used on despatch advices. Make it passive instead of deleting it.');
end;

end.
