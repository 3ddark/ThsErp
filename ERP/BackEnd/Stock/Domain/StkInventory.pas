unit StkInventory;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
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

    // View (vw_stk_inventory) okunabilir alanları
    FGroupName: string;
    FProductTypeName: string;
    FUomName: string;
    FCountryName: string;
    FCurrentQuantity: string;
    FAverageCost: string;

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
  Result.GroupName := Self.GroupName;
  Result.ProductTypeName := Self.ProductTypeName;
  Result.UomName := Self.UomName;
  Result.CountryName := Self.CountryName;
  Result.CurrentQuantity := Self.CurrentQuantity;
  Result.AverageCost := Self.AverageCost;
  Result.FImage := Copy(Self.FImage);
  Result.FImageLoaded := Self.FImageLoaded;
end;

end.
