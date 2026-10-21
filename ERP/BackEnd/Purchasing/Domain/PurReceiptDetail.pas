unit PurReceiptDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Mal kabul kalemi. Mal kabulün Lines listesinde durum (yeni / kayıtlı / silinecek) TDetailEntity'den; başlığa tipli
  // erişim PurReceipt birimindeki class helper ile (Line.Header.ReceiptNo)
  [Table('pur_receipt_detail')]
  TPurReceiptDetail = class(TDetailEntity)
  private
    FPurReceiptId: Int64;
    FLineNo: SmallInt;
    FStkInventoryId: Int64;
    FQuantity: Currency;
    FUnitPrice: Currency;
    FPurOrderDetailId: Int64;
    FDescription: string;

    // View (vw_pur_receipt_detail) okunabilir alanları
    FReceiptNo: string;
    FCurrency: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FOrderNo: string;
    FAmount: Currency;
    FInvoicedQuantity: Currency;
  public
    [Column('pur_receipt_id')]
    [Required()]
    property PurReceiptId: Int64 read FPurReceiptId write FPurReceiptId;

    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('stk_inventory_id')]
    [Required()]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('unit_price')]
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;

    [Column('pur_order_detail_id')]
    property PurOrderDetailId: Int64 read FPurOrderDetailId write FPurOrderDetailId;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property ReceiptNo: string read FReceiptNo write FReceiptNo;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property UomCode: string read FUomCode write FUomCode;

    [NotMapped]
    property OrderNo: string read FOrderNo write FOrderNo;

    // miktar x birim maliyet (görüntü; belge toplamı)
    [NotMapped]
    property Amount: Currency read FAmount write FAmount;

    // alış faturalarına aktarılan miktar (view; fatura kalemlerinden)
    [NotMapped]
    property InvoicedQuantity: Currency read FInvoicedQuantity write FInvoicedQuantity;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPurReceiptDetail;
  end;

implementation

constructor TPurReceiptDetail.Create;
begin
  inherited;
end;

destructor TPurReceiptDetail.Destroy;
begin
  inherited;
end;

function TPurReceiptDetail.Clone: TPurReceiptDetail;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TPurReceiptDetail.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.PurReceiptId := Self.PurReceiptId;
  Result.LineNo := Self.LineNo;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.Quantity := Self.Quantity;
  Result.UnitPrice := Self.UnitPrice;
  Result.PurOrderDetailId := Self.PurOrderDetailId;
  Result.Description := Self.Description;
  Result.ReceiptNo := Self.ReceiptNo;
  Result.Currency := Self.Currency;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.OrderNo := Self.OrderNo;
  Result.Amount := Self.Amount;
  Result.InvoicedQuantity := Self.InvoicedQuantity;
end;

end.
