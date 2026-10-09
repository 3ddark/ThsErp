unit PrdPacketLabour.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdPacketLabourException = class(EAppException);

  EPrdPacketLabourExceptionPacketNameUnique = class(EPrdPacketLabourException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdPacketLabourExceptionPacketNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdPacketLabour.PacketNameUnique, 'This packet already exists.');
end;

end.
