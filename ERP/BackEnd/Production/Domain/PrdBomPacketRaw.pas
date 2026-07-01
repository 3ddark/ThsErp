unit PrdBomPacketRaw;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_bom_packet_raw')]
  TPrdBomPacketRaw = class(TEntity)
  private
    FHeaderId: Int64;
    FPaketId: Int64;
    FQuantity: double;
  public
    [Column('header_id')]
    [Required]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    [Column('paket_id')]
    [Required]
    property PaketId: Int64 read FPaketId write FPaketId;

    [Column('quantity')]
    property Quantity: double read FQuantity write FQuantity;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdBomPacketRaw.Create();
begin
  inherited;
end;

destructor TPrdBomPacketRaw.Destroy;
begin
  inherited;
end;

end.
