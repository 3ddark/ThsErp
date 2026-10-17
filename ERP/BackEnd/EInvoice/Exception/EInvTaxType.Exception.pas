unit EInvTaxType.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EEInvTaxTypeException = class(EAppException);

  EEInvTaxTypeExceptionCodeUnique = class(EEInvTaxTypeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EEInvTaxTypeExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TEInvTaxType.CodeUnique, 'This code already exists.');
end;

end.
