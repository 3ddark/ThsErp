unit PrdPacketRaw;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_packet_raw')]
  TPrdPacketRaw = class(TEntity)
  private
    FPacketName: string;

    // View (vw_prd_packet_raw) okunabilir alanları
    FItemCount: string;
  public
    [Column('packet_name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property PacketName: string read FPacketName write FPacketName;

    [NotMapped]
    property ItemCount: string read FItemCount write FItemCount;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdPacketRaw;
  end;

implementation

constructor TPrdPacketRaw.Create;
begin
  inherited;
end;

destructor TPrdPacketRaw.Destroy;
begin
  inherited;
end;

function TPrdPacketRaw.Clone: TPrdPacketRaw;
begin
  Result := TPrdPacketRaw.Create;
  Result.Id := Self.Id;
  Result.PacketName := Self.PacketName;
  Result.ItemCount := Self.ItemCount;
end;

end.
