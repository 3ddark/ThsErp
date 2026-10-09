unit PrdBomPacketRaw.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdBomPacketRawException = class(EAppException);

  EPrdBomPacketRawExceptionPacketUnique = class(EPrdBomPacketRawException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdBomPacketRawExceptionPacketUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.PacketUnique, 'This packet is already in the BoM.');
end;

end.
