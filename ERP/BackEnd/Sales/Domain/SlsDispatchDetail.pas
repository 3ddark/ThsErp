unit SlsDispatchDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // İrsaliye kalemi. İrsaliyenin Lines listesinde durum (yeni / kayıtlı / silinecek) TDetailEntity'den; başlığa tipli
  // erişim SlsDispatch birimindeki class helper ile (Line.Header.DispatchNo)
  [Table('sls_dispatch_detail')]
  TSlsDispatchDetail = class(TDetailEntity)
  private
    FSlsDispatchId: Int64;
    FLineNo: SmallInt;
    FStkInventoryId: Int64;
    FQuantity: Currency;
    FUnitPrice: Currency;
    FSlsOrderDetailId: Int64;
    FDescription: string;

    // View (vw_sls_dispatch_detail) okunabilir alanları
    FDispatchNo: string;
    FCurrency: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FOrderNo: string;
    FAmount: Currency;
    FInvoicedQuantity: Currency;
  public
    [Column('line_no')]
    property LineNo: SmallInt read FLineNo write FLineNo;

    [Column('sls_dispatch_id')]
    [Required()]
    property SlsDispatchId: Int64 read FSlsDispatchId write FSlsDispatchId;

    [Column('stk_inventory_id')]
    [Required()]
    property StkInventoryId: Int64 read FStkInventoryId write FStkInventoryId;

    [Column('quantity')]
    property Quantity: Currency read FQuantity write FQuantity;

    [Column('unit_price')]
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;

    [Column('sls_order_detail_id')]
    property SlsOrderDetailId: Int64 read FSlsOrderDetailId write FSlsOrderDetailId;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property DispatchNo: string read FDispatchNo write FDispatchNo;

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

    // miktar x net fiyat (view: amount); bellekte servis hesaplar
    [NotMapped]
    property Amount: Currency read FAmount write FAmount;

    // faturalanan miktar (view: invoiced_quantity, fatura kalemlerinden)
    [NotMapped]
    property InvoicedQuantity: Currency read FInvoicedQuantity write FInvoicedQuantity;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsDispatchDetail;
  end;

implementation

constructor TSlsDispatchDetail.Create;
begin
  inherited;
end;

destructor TSlsDispatchDetail.Destroy;
begin
  inherited;
end;

function TSlsDispatchDetail.Clone: TSlsDispatchDetail;
begin
  Result := TSlsDispatchDetail.Create;
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.LineNo := Self.LineNo;
  Result.Amount := Self.Amount;
  Result.InvoicedQuantity := Self.InvoicedQuantity;
  Result.SlsDispatchId := Self.SlsDispatchId;
  Result.StkInventoryId := Self.StkInventoryId;
  Result.Quantity := Self.Quantity;
  Result.UnitPrice := Self.UnitPrice;
  Result.SlsOrderDetailId := Self.SlsOrderDetailId;
  Result.Description := Self.Description;
  Result.DispatchNo := Self.DispatchNo;
  Result.Currency := Self.Currency;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.OrderNo := Self.OrderNo;
end;

end.
