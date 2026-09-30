unit AccTransferCode.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccTransferCodeException = class(EAppException);

  EAccTransferCodeExceptionTransferCodeUnique = class(EAccTransferCodeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccTransferCodeExceptionTransferCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccTransferCode.TransferCodeUnique, 'This transfer code already exists.');
end;

end.
