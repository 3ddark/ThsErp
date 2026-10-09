unit StkInventory;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Ambar bazında stok (vw_stk_inventory_warehouse) - stok kartı "Özetler" sekmesi
  TStkInventoryWarehouseStock = record
    WarehouseName: string;
    Quantity: Double;
  end;

  // Cins bilgisi değeri (etiket stk_kind_property'den, değer stk_card_kind_info'dan)
  TStkInventoryKindValue = record
    Caption: string;
    Value: string;
  end;

  [Table('stk_inventory')]
  TStkInventory = class(TEntity)
  private
    FCode: string;
    FName: string;
    FStkGroupId: Int64;
    FStkProductTypeId: Int64;
    FSysUomId: Int64;
    FSellable: Boolean;
    FBuyingPrice: Currency;
    FBuyingCurrency: string;
    FBuyingDiscount: Currency;
    FSalesPrice: Currency;
    FSalesCurrency: string;
    FSalesDiscount: Currency;
    FExportPrice: Currency;
    FExportCurrency: string;
    FSpecialCode: string;
    FBrand: string;
    FWidth: Double;
    FLength: Double;
    FHeight: Double;
    FWeight: Double;
    FSupplyDuration: SmallInt;
    FMinStockAmount: Double;
    FSysCountryId: Int64;
    FHsNo: string;
    FDiibProductDescription: string;
    FProductOverview: string;

    // Karta özel muhasebe ayarları (boş = gruptan / KDV oranından gelen değer)
    FVatRate: Currency;
    FHasVatRate: Boolean;
    FRawMaterialStockAccount: string;
    FRawMaterialUsageAccount: string;
    FSemiProductAccount: string;
    FSalesAccount: string;
    FSalesReturnAccount: string;
    FPurchaseAccount: string;
    FPurchaseReturnAccount: string;

    // View (vw_stk_inventory) okunabilir alanları
    FGroupName: string;
    FProductTypeName: string;
    FUomName: string;
    FCountryName: string;
    FCurrentQuantity: string;
    FAverageCost: string;
    FDefaultVatRate: string;
    FDefaultRawMaterialStockAccount: string;
    FDefaultRawMaterialUsageAccount: string;
    FDefaultSemiProductAccount: string;
    FDefaultSalesAccount: string;
    FDefaultSalesReturnAccount: string;
    FDefaultPurchaseAccount: string;
    FDefaultPurchaseReturnAccount: string;

    // stk_image (1:1) - yalnız FindById ile yüklenir; ImageLoaded False iken kayıtta resme dokunulmaz
    FImage: TBytes;
    FImageLoaded: Boolean;
    procedure SetImage(const AValue: TBytes);
  public
    [Column('code')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('stk_group_id')]
    property StkGroupId: Int64 read FStkGroupId write FStkGroupId;

    [Column('stk_product_type_id')]
    property StkProductTypeId: Int64 read FStkProductTypeId write FStkProductTypeId;

    [Column('sys_uom_id')]
    property SysUomId: Int64 read FSysUomId write FSysUomId;

    [Column('sellable')]
    property Sellable: Boolean read FSellable write FSellable;

    [Column('buying_price')]
    property BuyingPrice: Currency read FBuyingPrice write FBuyingPrice;

    [Column('buying_currency')]
    [MaxLength(3)]
    property BuyingCurrency: string read FBuyingCurrency write FBuyingCurrency;

    [Column('buying_discount')]
    property BuyingDiscount: Currency read FBuyingDiscount write FBuyingDiscount;

    [Column('sales_price')]
    property SalesPrice: Currency read FSalesPrice write FSalesPrice;

    [Column('sales_currency')]
    [MaxLength(3)]
    property SalesCurrency: string read FSalesCurrency write FSalesCurrency;

    [Column('sales_discount')]
    property SalesDiscount: Currency read FSalesDiscount write FSalesDiscount;

    [Column('export_price')]
    property ExportPrice: Currency read FExportPrice write FExportPrice;

    [Column('export_currency')]
    [MaxLength(3)]
    property ExportCurrency: string read FExportCurrency write FExportCurrency;

    [Column('special_code')]
    [MaxLength(16)]
    property SpecialCode: string read FSpecialCode write FSpecialCode;

    [Column('brand')]
    [MaxLength(32)]
    property Brand: string read FBrand write FBrand;

    [Column('width')]
    property Width: Double read FWidth write FWidth;

    [Column('length')]
    property Length: Double read FLength write FLength;

    [Column('height')]
    property Height: Double read FHeight write FHeight;

    [Column('weight')]
    property Weight: Double read FWeight write FWeight;

    [Column('supply_duration')]
    property SupplyDuration: SmallInt read FSupplyDuration write FSupplyDuration;

    [Column('min_stock_amount')]
    property MinStockAmount: Double read FMinStockAmount write FMinStockAmount;

    [Column('sys_country_id')]
    property SysCountryId: Int64 read FSysCountryId write FSysCountryId;

    [Column('hs_no')]
    [MaxLength(16)]
    property HsNo: string read FHsNo write FHsNo;

    [Column('diib_product_description')]
    [MaxLength(64)]
    property DiibProductDescription: string read FDiibProductDescription write FDiibProductDescription;

    [Column('product_overview')]
    property ProductOverview: string read FProductOverview write FProductOverview;

    // HasVatRate False = NULL (grubun KDV oranı geçerli); 0 da geçerli bir karta özel orandır
    [Column('vat_rate')]
    property VatRate: Currency read FVatRate write FVatRate;

    [NotMapped]
    property HasVatRate: Boolean read FHasVatRate write FHasVatRate;

    [Column('raw_material_stock_account')]
    [MaxLength(16)]
    property RawMaterialStockAccount: string read FRawMaterialStockAccount write FRawMaterialStockAccount;

    [Column('raw_material_usage_account')]
    [MaxLength(16)]
    property RawMaterialUsageAccount: string read FRawMaterialUsageAccount write FRawMaterialUsageAccount;

    [Column('semi_product_account')]
    [MaxLength(16)]
    property SemiProductAccount: string read FSemiProductAccount write FSemiProductAccount;

    [Column('sales_account')]
    [MaxLength(16)]
    property SalesAccount: string read FSalesAccount write FSalesAccount;

    [Column('sales_return_account')]
    [MaxLength(16)]
    property SalesReturnAccount: string read FSalesReturnAccount write FSalesReturnAccount;

    [Column('purchase_account')]
    [MaxLength(16)]
    property PurchaseAccount: string read FPurchaseAccount write FPurchaseAccount;

    [Column('purchase_return_account')]
    [MaxLength(16)]
    property PurchaseReturnAccount: string read FPurchaseReturnAccount write FPurchaseReturnAccount;

    [NotMapped]
    property GroupName: string read FGroupName write FGroupName;

    [NotMapped]
    property ProductTypeName: string read FProductTypeName write FProductTypeName;

    [NotMapped]
    property UomName: string read FUomName write FUomName;

    [NotMapped]
    property CountryName: string read FCountryName write FCountryName;

    [NotMapped]
    property CurrentQuantity: string read FCurrentQuantity write FCurrentQuantity;

    [NotMapped]
    property AverageCost: string read FAverageCost write FAverageCost;

    // Karta özel değer boşken uygulanacak değerler (vw_stk_inventory.default_*)
    [NotMapped]
    property DefaultVatRate: string read FDefaultVatRate write FDefaultVatRate;

    [NotMapped]
    property DefaultRawMaterialStockAccount: string read FDefaultRawMaterialStockAccount write FDefaultRawMaterialStockAccount;

    [NotMapped]
    property DefaultRawMaterialUsageAccount: string read FDefaultRawMaterialUsageAccount write FDefaultRawMaterialUsageAccount;

    [NotMapped]
    property DefaultSemiProductAccount: string read FDefaultSemiProductAccount write FDefaultSemiProductAccount;

    [NotMapped]
    property DefaultSalesAccount: string read FDefaultSalesAccount write FDefaultSalesAccount;

    [NotMapped]
    property DefaultSalesReturnAccount: string read FDefaultSalesReturnAccount write FDefaultSalesReturnAccount;

    [NotMapped]
    property DefaultPurchaseAccount: string read FDefaultPurchaseAccount write FDefaultPurchaseAccount;

    [NotMapped]
    property DefaultPurchaseReturnAccount: string read FDefaultPurchaseReturnAccount write FDefaultPurchaseReturnAccount;

    [NotMapped]
    property Image: TBytes read FImage write SetImage;

    [NotMapped]
    property ImageLoaded: Boolean read FImageLoaded write FImageLoaded;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TStkInventory;
  end;

implementation

constructor TStkInventory.Create;
begin
  inherited;
  FSellable := True;
  FHasVatRate := False;
  FImage := nil;
  FImageLoaded := False;
end;

procedure TStkInventory.SetImage(const AValue: TBytes);
begin
  FImage := Copy(AValue);
  FImageLoaded := True;
end;

destructor TStkInventory.Destroy;
begin
  inherited;
end;

function TStkInventory.Clone: TStkInventory;
begin
  Result := TStkInventory.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.StkGroupId := Self.StkGroupId;
  Result.StkProductTypeId := Self.StkProductTypeId;
  Result.SysUomId := Self.SysUomId;
  Result.Sellable := Self.Sellable;
  Result.BuyingPrice := Self.BuyingPrice;
  Result.BuyingCurrency := Self.BuyingCurrency;
  Result.BuyingDiscount := Self.BuyingDiscount;
  Result.SalesPrice := Self.SalesPrice;
  Result.SalesCurrency := Self.SalesCurrency;
  Result.SalesDiscount := Self.SalesDiscount;
  Result.ExportPrice := Self.ExportPrice;
  Result.ExportCurrency := Self.ExportCurrency;
  Result.SpecialCode := Self.SpecialCode;
  Result.Brand := Self.Brand;
  Result.Width := Self.Width;
  Result.Length := Self.Length;
  Result.Height := Self.Height;
  Result.Weight := Self.Weight;
  Result.SupplyDuration := Self.SupplyDuration;
  Result.MinStockAmount := Self.MinStockAmount;
  Result.SysCountryId := Self.SysCountryId;
  Result.HsNo := Self.HsNo;
  Result.DiibProductDescription := Self.DiibProductDescription;
  Result.ProductOverview := Self.ProductOverview;
  Result.VatRate := Self.VatRate;
  Result.HasVatRate := Self.HasVatRate;
  Result.RawMaterialStockAccount := Self.RawMaterialStockAccount;
  Result.RawMaterialUsageAccount := Self.RawMaterialUsageAccount;
  Result.SemiProductAccount := Self.SemiProductAccount;
  Result.SalesAccount := Self.SalesAccount;
  Result.SalesReturnAccount := Self.SalesReturnAccount;
  Result.PurchaseAccount := Self.PurchaseAccount;
  Result.PurchaseReturnAccount := Self.PurchaseReturnAccount;
  Result.GroupName := Self.GroupName;
  Result.ProductTypeName := Self.ProductTypeName;
  Result.UomName := Self.UomName;
  Result.CountryName := Self.CountryName;
  Result.CurrentQuantity := Self.CurrentQuantity;
  Result.AverageCost := Self.AverageCost;
  Result.DefaultVatRate := Self.DefaultVatRate;
  Result.DefaultRawMaterialStockAccount := Self.DefaultRawMaterialStockAccount;
  Result.DefaultRawMaterialUsageAccount := Self.DefaultRawMaterialUsageAccount;
  Result.DefaultSemiProductAccount := Self.DefaultSemiProductAccount;
  Result.DefaultSalesAccount := Self.DefaultSalesAccount;
  Result.DefaultSalesReturnAccount := Self.DefaultSalesReturnAccount;
  Result.DefaultPurchaseAccount := Self.DefaultPurchaseAccount;
  Result.DefaultPurchaseReturnAccount := Self.DefaultPurchaseReturnAccount;
  Result.FImage := Copy(Self.FImage);
  Result.FImageLoaded := Self.FImageLoaded;
end;

end.
