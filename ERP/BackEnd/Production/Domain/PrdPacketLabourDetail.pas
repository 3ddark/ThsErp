unit PrdPacketLabourDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('prd_packet_labour_detail')]
  TPrdPacketLabourDetail = class(TEntity)
  private
    FPrdPacketLabourId: Int64;
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
    [Column('prd_packet_labour_id')]
    property PrdPacketLabourId: Int64 read FPrdPacketLabourId write FPrdPacketLabourId;

    [Column('prd_labour_id')]
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
  Result := TPrdPacketLabourDetail.Create;
  Result.Id := Self.Id;
  Result.PrdPacketLabourId := Self.PrdPacketLabourId;
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
