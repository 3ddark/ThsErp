unit PrdPacketRawDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_packet_raw_detail')]
  TPrdPacketRawDetail = class(TDetailEntity)
  private
    FPrdPacketRawId: Int64;
    FLineNo: SmallInt;
    FStkInventoryId: Int64;
    FSubPrdBomId: Int64;
    FQuantity: Currency;

    // View (vw_prd_packet_raw_detail) okunabilir alanları
    FPacketName: string;
    FInventoryCode: string;
    FInventoryName: string;
    FSubBomName: string;
  public
    [Column('prd_packet_raw_id'), Required()]
    property PrdPacketRawId: Int64 read FPrdPacketRawId write FPrdPacketRawId;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('stk_inventory_id'), Required()]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('sub_prd_bom_id')]
    property SubPrdBomId: Int64 read FSubPrdBomId write FSubPrdBomId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [NotMapped]
    property PacketName: string read FPacketName write FPacketName;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property SubBomName: string read FSubBomName write FSubBomName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdPacketRawDetail;
  end;

implementation

constructor TPrdPacketRawDetail.Create;
begin
  inherited;
end;

destructor TPrdPacketRawDetail.Destroy;
begin
  inherited;
end;

function TPrdPacketRawDetail.Clone: TPrdPacketRawDetail;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TPrdPacketRawDetail.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.PrdPacketRawId := Self.PrdPacketRawId;
  Result.LineNo := Self.LineNo;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.SubPrdBomId := Self.SubPrdBomId;
  Result.Quantity := Self.Quantity;
  Result.PacketName := Self.PacketName;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.SubBomName := Self.SubBomName;
end;

end.
