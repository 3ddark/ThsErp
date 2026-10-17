unit EInvPackagingType.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvPackagingTypeException = class(EAppException);

  EEInvPackagingTypeExceptionCodeUnique = class(EEInvPackagingTypeException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvPackagingTypeExceptionInUse = class(EEInvPackagingTypeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvPackagingTypeExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvPackagingType.CodeUnique, 'This code already exists.');
end;

class function EEInvPackagingTypeExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvPackagingType.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

end.
