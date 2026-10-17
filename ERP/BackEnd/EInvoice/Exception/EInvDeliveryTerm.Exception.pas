unit EInvDeliveryTerm.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvDeliveryTermException = class(EAppException);

  EEInvDeliveryTermExceptionCodeUnique = class(EEInvDeliveryTermException)
  protected
    class function GetMessage: string; override;
  end;

  EEInvDeliveryTermExceptionInUse = class(EEInvDeliveryTermException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvDeliveryTermExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.CodeUnique, 'This code already exists.');
end;

class function EEInvDeliveryTermExceptionInUse.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.InUse, 'This record is in use. Make it passive instead of deleting it.');
end;

end.
