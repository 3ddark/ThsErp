unit PrdPacketLabourDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_packet_labour_detail')]
  TPrdPacketLabourDetail = class(TDetailEntity)
  private
    FPrdPacketLabourId: Int64;
    FLineNo: SmallInt;
    FPrdLabourId: Int64;
    FQuantity: Currency;

    // View (vw_prd_packet_labour_detail) okunabilir alanları
    FPacketName: string;
    FLabourCode: string;
    FLabourName: string;
    FUnitPrice: string;
    FCurrency: string;
    FTotalAmount: string;
  public
    [Column('prd_packet_labour_id'), Required()]
    property PrdPacketLabourId: Int64 read FPrdPacketLabourId write FPrdPacketLabourId;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('prd_labour_id'), Required()]
    property PrdLabourId: Int64 read FPrdLabourId write FPrdLabourId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [NotMapped]
    property PacketName: string read FPacketName write FPacketName;

    [NotMapped]
    property LabourCode: string read FLabourCode write FLabourCode;

    [NotMapped]
    property LabourName: string read FLabourName write FLabourName;

    [NotMapped]
    property UnitPrice: string read FUnitPrice write FUnitPrice;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property TotalAmount: string read FTotalAmount write FTotalAmount;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdPacketLabourDetail;
  end;

implementation

constructor TPrdPacketLabourDetail.Create;
begin
  inherited;
end;

destructor TPrdPacketLabourDetail.Destroy;
begin
  inherited;
end;

function TPrdPacketLabourDetail.Clone: TPrdPacketLabourDetail;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TPrdPacketLabourDetail.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.PrdPacketLabourId := Self.PrdPacketLabourId;
  Result.LineNo := Self.LineNo;
  Result.PrdLabourId := Self.PrdLabourId;
  Result.Quantity := Self.Quantity;
  Result.PacketName := Self.PacketName;
  Result.LabourCode := Self.LabourCode;
  Result.LabourName := Self.LabourName;
  Result.UnitPrice := Self.UnitPrice;
  Result.Currency := Self.Currency;
  Result.TotalAmount := Self.TotalAmount;
end;

end.
