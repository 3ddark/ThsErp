unit PurOrderDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('pur_order_detail')]
  TPurOrderDetail = class(TEntity)
  private
    FPurOrderId: Int64;
    FLineNo: SmallInt;
    FStkInventoryId: Int64;
    FQuantity: Currency;
    FUnitPrice: Currency;
    FDiscountRate: Currency;
    FVatRate: Currency;
    FGrossAmount: Currency;
    FDiscountAmount: Currency;
    FNetAmount: Currency;
    FVatAmount: Currency;
    FTotalAmount: Currency;
    FReceivedQuantity: Currency;
    FDeliveryDate: TDate;
    FPurRequestDetailId: Int64;
    FDescription: string;

    // View (vw_pur_order_detail) okunabilir alanları
    FOrderNo: string;
    FCurrency: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FRequestNo: string;
  public
    [Column('pur_order_id')]
    [Required()]
    property PurOrderId: Int64 read FPurOrderId write FPurOrderId;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('stk_inventory_id')]
    [Required()]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('unit_price')]
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;

    [Column('discount_rate')]
    property DiscountRate: Currency read FDiscountRate write FDiscountRate;

    [Column('vat_rate')]
    property VatRate: Currency read FVatRate write FVatRate;

    [Column('gross_amount')]
    property GrossAmount: Currency read FGrossAmount write FGrossAmount;

    [Column('discount_amount')]
    property DiscountAmount: Currency read FDiscountAmount write FDiscountAmount;

    [Column('net_amount')]
    property NetAmount: Currency read FNetAmount write FNetAmount;

    [Column('vat_amount')]
    property VatAmount: Currency read FVatAmount write FVatAmount;

    [Column('total_amount')]
    property TotalAmount: Currency read FTotalAmount write FTotalAmount;

    [Column('received_quantity')]
    property ReceivedQuantity: Currency read FReceivedQuantity write FReceivedQuantity;

    [Column('delivery_date')]
    property DeliveryDate: TDate read FDeliveryDate write FDeliveryDate;

    [Column('pur_request_detail_id')]
    property PurRequestDetailId: Int64 read FPurRequestDetailId write FPurRequestDetailId;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property OrderNo: string read FOrderNo write FOrderNo;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property UomCode: string read FUomCode write FUomCode;

    [NotMapped]
    property RequestNo: string read FRequestNo write FRequestNo;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurOrderDetail;
  end;

implementation

constructor TPurOrderDetail.Create;
begin
  inherited;
end;

destructor TPurOrderDetail.Destroy;
begin
  inherited;
end;

function TPurOrderDetail.Clone: TPurOrderDetail;
begin
  Result := TPurOrderDetail.Create;
  Result.Id := Self.Id;
  Result.PurOrderId := Self.PurOrderId;
  Result.LineNo := Self.LineNo;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.Quantity := Self.Quantity;
  Result.UnitPrice := Self.UnitPrice;
  Result.DiscountRate := Self.DiscountRate;
  Result.VatRate := Self.VatRate;
  Result.GrossAmount := Self.GrossAmount;
  Result.DiscountAmount := Self.DiscountAmount;
  Result.NetAmount := Self.NetAmount;
  Result.VatAmount := Self.VatAmount;
  Result.TotalAmount := Self.TotalAmount;
  Result.ReceivedQuantity := Self.ReceivedQuantity;
  Result.DeliveryDate := Self.DeliveryDate;
  Result.PurRequestDetailId := Self.PurRequestDetailId;
  Result.Description := Self.Description;
  Result.OrderNo := Self.OrderNo;
  Result.Currency := Self.Currency;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.RequestNo := Self.RequestNo;
end;

end.
