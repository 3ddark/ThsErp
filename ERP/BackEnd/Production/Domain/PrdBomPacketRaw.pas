unit PrdBomPacketRaw;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_bom_packet_raw')]
  TPrdBomPacketRaw = class(TDetailEntity)
  private
    FPrdBomId: Int64;
    FLineNo: SmallInt;
    FPrdPacketRawId: Int64;
    FQuantity: Currency;

    // View (vw_prd_bom_packet_raw) okunabilir alanları
    FBomName: string;
    FPacketName: string;
  public
    [Column('prd_bom_id'), Required()]
    property PrdBomId: Int64 read FPrdBomId write FPrdBomId;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('prd_packet_raw_id'), Required()]
    property PrdPacketRawId: Int64 read FPrdPacketRawId write FPrdPacketRawId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [NotMapped]
    property BomName: string read FBomName write FBomName;

    [NotMapped]
    property PacketName: string read FPacketName write FPacketName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdBomPacketRaw;
  end;

implementation

constructor TPrdBomPacketRaw.Create;
begin
  inherited;
  FQuantity := 1;
end;

destructor TPrdBomPacketRaw.Destroy;
begin
  inherited;
end;

function TPrdBomPacketRaw.Clone: TPrdBomPacketRaw;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TPrdBomPacketRaw.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.PrdBomId := Self.PrdBomId;
  Result.LineNo := Self.LineNo;
  Result.PrdPacketRawId := Self.PrdPacketRawId;
  Result.Quantity := Self.Quantity;
  Result.BomName := Self.BomName;
  Result.PacketName := Self.PacketName;
end;

end.
