unit PrdBomPacketLabour.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPrdBomPacketLabourException = class(EAppException);

  EPrdBomPacketLabourExceptionPacketUnique = class(EPrdBomPacketLabourException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPrdBomPacketLabourExceptionPacketUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.PacketUnique, 'This packet is already in the BoM.');
end;

end.
