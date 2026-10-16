unit SlsInvoiceDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('sls_invoice_detail')]
  // Fatura kalemi. Faturanın Lines listesinde durum (yeni / kayıtlı / silinecek) TDetailEntity'den; başlığa tipli
  // erişim SlsInvoice birimindeki class helper ile (Line.Header.InvoiceNo)
  TSlsInvoiceDetail = class(TDetailEntity)
  private
    FSlsInvoiceId: Int64;
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
    FSlsDispatchDetailId: Int64;
    FSlsOrderDetailId: Int64;
    FDescription: string;

    // View (vw_sls_invoice_detail) okunabilir alanları
    FInvoiceNo: string;
    FCurrency: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FDispatchNo: string;
    FOrderNo: string;
  public
    [Column('sls_invoice_id')]
    [Required()]
    property SlsInvoiceId: Int64 read FSlsInvoiceId write FSlsInvoiceId;

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

    [Column('sls_dispatch_detail_id')]
    property SlsDispatchDetailId: Int64 read FSlsDispatchDetailId write FSlsDispatchDetailId;

    [Column('sls_order_detail_id')]
    property SlsOrderDetailId: Int64 read FSlsOrderDetailId write FSlsOrderDetailId;

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
    property DispatchNo: string read FDispatchNo write FDispatchNo;

    [NotMapped]
    property OrderNo: string read FOrderNo write FOrderNo;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsInvoiceDetail;
  end;

implementation

constructor TSlsInvoiceDetail.Create;
begin
  inherited;
end;

destructor TSlsInvoiceDetail.Destroy;
begin
  inherited;
end;

function TSlsInvoiceDetail.Clone: TSlsInvoiceDetail;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TSlsInvoiceDetail.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.SlsInvoiceId := Self.SlsInvoiceId;
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
  Result.SlsDispatchDetailId := Self.SlsDispatchDetailId;
  Result.SlsOrderDetailId := Self.SlsOrderDetailId;
  Result.Description := Self.Description;
  Result.InvoiceNo := Self.InvoiceNo;
  Result.Currency := Self.Currency;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.DispatchNo := Self.DispatchNo;
  Result.OrderNo := Self.OrderNo;
end;

end.
