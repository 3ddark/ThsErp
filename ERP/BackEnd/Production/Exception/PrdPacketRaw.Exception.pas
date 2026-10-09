unit PrdPacketRaw.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdPacketRawException = class(EAppException);

  EPrdPacketRawExceptionPacketNameUnique = class(EPrdPacketRawException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdPacketRawExceptionPacketNameUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdPacketRaw.PacketNameUnique, 'This packet already exists.');
end;

end.
