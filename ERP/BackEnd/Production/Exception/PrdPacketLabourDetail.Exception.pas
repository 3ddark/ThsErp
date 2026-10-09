unit PrdPacketLabourDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdPacketLabourDetailException = class(EAppException);

  EPrdPacketLabourDetailExceptionLabourUnique = class(EPrdPacketLabourDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdPacketLabourDetailExceptionLabourUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabourDetail.LabourUnique, 'This labour is already in the packet.');
end;

end.
