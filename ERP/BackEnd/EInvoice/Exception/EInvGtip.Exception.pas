unit EInvGtip.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvGtipException = class(EAppException);

  EEInvGtipExceptionCodeUnique = class(EEInvGtipException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvGtipExceptionInUse = class(EEInvGtipException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvGtipExceptionCodeInvalid = class(EEInvGtipException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvGtipExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvGtip.CodeUnique, 'This code already exists.');
end;

class function EEInvGtipExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvGtip.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

class function EEInvGtipExceptionCodeInvalid.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvGtip.CodeInvalid, 'GTIP code must be 12 digits (e.g. 0206.22.00.00.00).');
end;

end.
