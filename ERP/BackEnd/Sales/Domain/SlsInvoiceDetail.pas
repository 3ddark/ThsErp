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
    // e-Belge (UBL-TR)
    FEinvGtipId: Int64;
    FEinvWithholdingId: Int64;
    FWithholdingAmount: Currency;
    FSellerEinvDiibLineId: Int64;
    FBuyerEinvDiibLineId: Int64;
    FEinvPackagingTypeId: Int64;
    FPackageNo: string;
    FPackageQuantity: Currency;
    FPackageBrand: string;

    // View (vw_sls_invoice_detail) okunabilir alanları
    FInvoiceNo: string;
    FAccAccountId: Int64;
    FCurrency: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
    FDispatchNo: string;
    FOrderNo: string;
    FGtipCode: string;
    FWithholdingCode: string;
    FWithholdingRate: Currency;
    FSellerDiibLineCode: string;
    FBuyerDiibLineCode: string;
    FDiibProductDescription: string;
    FPackagingTypeCode: string;
    FUomEinvCode: string;
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

    // faturanın müşterisi (alıcı DİİB satırı seçimi)
    [NotMapped]
    property AccAccountId: Int64 read FAccAccountId write FAccAccountId;

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

    // e-Belge (UBL-TR) — GTİP, tevkifat, DİİB satır kodları, ihracat kap bilgisi
    [Column('einv_gtip_id')]
    property EinvGtipId: Int64 read FEinvGtipId write FEinvGtipId;

    [Column('einv_withholding_id')]
    property EinvWithholdingId: Int64 read FEinvWithholdingId write FEinvWithholdingId;

    [Column('withholding_amount')]
    property WithholdingAmount: Currency read FWithholdingAmount write FWithholdingAmount;

    [Column('seller_einv_diib_line_id')]
    property SellerEinvDiibLineId: Int64 read FSellerEinvDiibLineId write FSellerEinvDiibLineId;

    [Column('buyer_einv_diib_line_id')]
    property BuyerEinvDiibLineId: Int64 read FBuyerEinvDiibLineId write FBuyerEinvDiibLineId;

    [Column('einv_packaging_type_id')]
    property EinvPackagingTypeId: Int64 read FEinvPackagingTypeId write FEinvPackagingTypeId;

    [Column('package_no')]
    [MaxLength(32)]
    property PackageNo: string read FPackageNo write FPackageNo;

    [Column('package_quantity')]
    property PackageQuantity: Currency read FPackageQuantity write FPackageQuantity;

    [Column('package_brand')]
    [MaxLength(64)]
    property PackageBrand: string read FPackageBrand write FPackageBrand;

    [NotMapped]
    property GtipCode: string read FGtipCode write FGtipCode;

    [NotMapped]
    property WithholdingCode: string read FWithholdingCode write FWithholdingCode;

    [NotMapped]
    property WithholdingRate: Currency read FWithholdingRate write FWithholdingRate;

    [NotMapped]
    property SellerDiibLineCode: string read FSellerDiibLineCode write FSellerDiibLineCode;

    [NotMapped]
    property BuyerDiibLineCode: string read FBuyerDiibLineCode write FBuyerDiibLineCode;

    [NotMapped]
    property DiibProductDescription: string read FDiibProductDescription write FDiibProductDescription;

    [NotMapped]
    property PackagingTypeCode: string read FPackagingTypeCode write FPackagingTypeCode;

    [NotMapped]
    property UomEinvCode: string read FUomEinvCode write FUomEinvCode;

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
  Result.AccAccountId := Self.AccAccountId;
  Result.Currency := Self.Currency;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
  Result.DispatchNo := Self.DispatchNo;
  Result.OrderNo := Self.OrderNo;
  Result.EinvGtipId := Self.EinvGtipId;
  Result.EinvWithholdingId := Self.EinvWithholdingId;
  Result.WithholdingAmount := Self.WithholdingAmount;
  Result.SellerEinvDiibLineId := Self.SellerEinvDiibLineId;
  Result.BuyerEinvDiibLineId := Self.BuyerEinvDiibLineId;
  Result.EinvPackagingTypeId := Self.EinvPackagingTypeId;
  Result.PackageNo := Self.PackageNo;
  Result.PackageQuantity := Self.PackageQuantity;
  Result.PackageBrand := Self.PackageBrand;
  Result.GtipCode := Self.GtipCode;
  Result.WithholdingCode := Self.WithholdingCode;
  Result.WithholdingRate := Self.WithholdingRate;
  Result.SellerDiibLineCode := Self.SellerDiibLineCode;
  Result.BuyerDiibLineCode := Self.BuyerDiibLineCode;
  Result.DiibProductDescription := Self.DiibProductDescription;
  Result.PackagingTypeCode := Self.PackagingTypeCode;
  Result.UomEinvCode := Self.UomEinvCode;
end;

end.
