unit PrdPacketRawDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdPacketRawDetailException = class(EAppException);

  EPrdPacketRawDetailExceptionInventoryUnique = class(EPrdPacketRawDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdPacketRawDetailExceptionInventoryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.InventoryUnique, 'This raw material is already in the packet.');
end;

end.
