unit PrdPacketRawDetail;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_packet_raw_detail')]
  TPrdPacketRawDetail = class(TEntity)
  private
    FHeaderId: Int64;
    FReceteId: Int64;
    FSkuCode: string;
    FQuantity: Double;
  public
    [Column('header_id'), Required()]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    [Column('recete_id')]
    property ReceteId: Int64 read FReceteId write FReceteId;

    [Column('sku_code'), MaxLength(32)]
    property SkuCode: string read FSkuCode write FSkuCode;

    [Column('quantity')]
    property Quantity: Double read FQuantity write FQuantity;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdPacketRawDetail.Create();
begin
  inherited;
end;

destructor TPrdPacketRawDetail.Destroy;
begin
  inherited;
end;

end.
