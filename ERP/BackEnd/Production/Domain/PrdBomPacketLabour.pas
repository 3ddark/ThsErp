unit PrdBomPacketLabour;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_bom_packet_labour')]
  TPrdBomPacketLabour = class(TEntity)
  private
    FPrdBomId: Int64;
    FPrdPacketLabourId: Int64;
    FQuantity: Currency;

    // View (vw_prd_bom_packet_labour) okunabilir alanları
    FBomName: string;
    FPacketName: string;
  public
    [Column('prd_bom_id'), Required()]
    property PrdBomId: Int64 read FPrdBomId write FPrdBomId;

    [Column('prd_packet_labour_id'), Required()]
    property PrdPacketLabourId: Int64 read FPrdPacketLabourId write FPrdPacketLabourId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [NotMapped]
    property BomName: string read FBomName write FBomName;

    [NotMapped]
    property PacketName: string read FPacketName write FPacketName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdBomPacketLabour;
  end;

implementation

constructor TPrdBomPacketLabour.Create;
begin
  inherited;
  FQuantity := 1;
end;

destructor TPrdBomPacketLabour.Destroy;
begin
  inherited;
end;

function TPrdBomPacketLabour.Clone: TPrdBomPacketLabour;
begin
  Result := TPrdBomPacketLabour.Create;
  Result.Id := Self.Id;
  Result.PrdBomId := Self.PrdBomId;
  Result.PrdPacketLabourId := Self.PrdPacketLabourId;
  Result.Quantity := Self.Quantity;
  Result.BomName := Self.BomName;
  Result.PacketName := Self.PacketName;
end;

end.
