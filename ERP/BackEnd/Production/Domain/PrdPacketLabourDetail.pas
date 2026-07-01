unit PrdPacketLabourDetail;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_packet_labour_detail')]
  TPrdPacketLabourDetail = class(TEntity)
  private
    FHeaderId: Int64;
    FLaborCode: string;
    FQuantity: Double;
  public
    [Column('header_id'), Required()]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    [Column('labor_code'), MaxLength(32)]
    property LaborCode: string read FLaborCode write FLaborCode;

    [Column('quantity')]
    property Quantity: Double read FQuantity write FQuantity;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdPacketLabourDetail.Create();
begin
  inherited;
end;

destructor TPrdPacketLabourDetail.Destroy;
begin
  inherited;
end;

end.
