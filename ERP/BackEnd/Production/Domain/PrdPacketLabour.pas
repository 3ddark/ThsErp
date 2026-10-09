unit PrdPacketLabour;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_packet_labour')]
  TPrdPacketLabour = class(TEntity)
  private
    FPacketName: string;

    // View (vw_prd_packet_labour) okunabilir alanları
    FItemCount: string;
  public
    [Column('packet_name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property PacketName: string read FPacketName write FPacketName;

    [NotMapped]
    property ItemCount: string read FItemCount write FItemCount;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdPacketLabour;
  end;

implementation

constructor TPrdPacketLabour.Create;
begin
  inherited;
end;

destructor TPrdPacketLabour.Destroy;
begin
  inherited;
end;

function TPrdPacketLabour.Clone: TPrdPacketLabour;
begin
  Result := TPrdPacketLabour.Create;
  Result.Id := Self.Id;
  Result.PacketName := Self.PacketName;
  Result.ItemCount := Self.ItemCount;
end;

end.
