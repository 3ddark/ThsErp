unit PurInvoiceDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('pur_invoice_detail')]
  TPurInvoiceDetail = class(TDetailEntity)
  private
    FPurInvoiceId: Int64;
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
    FPurReceiptDetailId: Int64;
    FDescription: string;

    // View (vw_pur_invoice_detail) okunabilir alanları
    FInvoiceNo: string;
    FCurrency: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FReceiptNo: string;
  public
    [Column('pur_invoice_id')]
    [Required()]
    property PurInvoiceId: Int64 read FPurInvoiceId write FPurInvoiceId;

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

    [Column('pur_receipt_detail_id')]
    property PurReceiptDetailId: Int64 read FPurReceiptDetailId write FPurReceiptDetailId;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property InvoiceNo: string read FInvoiceNo write FInvoiceNo;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property UomCode: string read FUomCode write FUomCode;

    [NotMapped]
    property ReceiptNo: string read FReceiptNo write FReceiptNo;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurInvoiceDetail;
  end;

implementation

constructor TPurInvoiceDetail.Create;
begin
  inherited;
end;

destructor TPurInvoiceDetail.Destroy;
begin
  inherited;
end;

function TPurInvoiceDetail.Clone: TPurInvoiceDetail;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TPurInvoiceDetail.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.PurInvoiceId := Self.PurInvoiceId;
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
  Result.PurReceiptDetailId := Self.PurReceiptDetailId;
  Result.Description := Self.Description;
  Result.InvoiceNo := Self.InvoiceNo;
  Result.Currency := Self.Currency;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.ReceiptNo := Self.ReceiptNo;
end;

end.
