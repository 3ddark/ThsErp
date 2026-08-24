unit StkInventory;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_inventory')]
  TStkInventory = class(TEntity)
  private
    FSellable: Boolean;
    FCode: string;
    FName: string;
    FGroupId: Int64;
    FMeasurementId: Int64;
    FProductType: SmallInt;
    FBuyingDiscount: Double;
    FSalesDiscount: Double;
    FBuyingPrice: Double;
    FBuyingCurrency: string;
    FSalesPrice: Double;
    FSalesCurrency: string;
    FExportPrice: Double;
    FExportCurrency: string;
    FWidth: Double;
    FLength: Double;
    FHeight: Double;
    FWeight: Double;
    FSupplyDuration: Integer;
    FSpecialCode: string;
    FBrand: string;
    FOriginId: Int64;
    FHsNo: string;
    FDiibProductDescription: string;
    FMinStockAmount: Double;
    FProductOverview: string;
  public
    [Column('sellable')]
    Property Sellable: Boolean read FSellable write FSellable;

    [Column('code'), MaxLength(64), Required()]
    Property Code: string read FCode write FCode;

    [Column('name'), MaxLength(128), Required()]
    Property Name: string read FName write FName;

    [Column('group_id')]
    Property GroupId: Int64 read FGroupId write FGroupId;

    [Column('measurement_id')]
    Property MeasurementId: Int64 read FMeasurementId write FMeasurementId;

    [Column('product_type')]
    Property ProductType: SmallInt read FProductType write FProductType;

    [Column('buying_discount')]
    Property BuyingDiscount: Double read FBuyingDiscount write FBuyingDiscount;

    [Column('sales_discount')]
    Property SalesDiscount: Double read FSalesDiscount write FSalesDiscount;

    [Column('buying_price')]
    Property BuyingPrice: Double read FBuyingPrice write FBuyingPrice;

    [Column('buying_currency'), MaxLength(8)]
    Property BuyingCurrency: string read FBuyingCurrency write FBuyingCurrency;

    [Column('sales_price')]
    Property SalesPrice: Double read FSalesPrice write FSalesPrice;

    [Column('sales_currency'), MaxLength(8)]
    Property SalesCurrency: string read FSalesCurrency write FSalesCurrency;

    [Column('export_price')]
    Property ExportPrice: Double read FExportPrice write FExportPrice;

    [Column('export_currency'), MaxLength(8)]
    Property ExportCurrency: string read FExportCurrency write FExportCurrency;

    [Column('width')]
    Property Width: Double read FWidth write FWidth;

    [Column('length')]
    Property Length: Double read FLength write FLength;

    [Column('height')]
    Property Height: Double read FHeight write FHeight;

    [Column('weight')]
    Property Weight: Double read FWeight write FWeight;

    [Column('supply_duration')]
    Property SupplyDuration: Integer read FSupplyDuration write FSupplyDuration;

    [Column('special_code'), MaxLength(64)]
    Property SpecialCode: string read FSpecialCode write FSpecialCode;

    [Column('brand'), MaxLength(64)]
    Property Brand: string read FBrand write FBrand;

    [Column('origin_id')]
    Property OriginId: Int64 read FOriginId write FOriginId;

    [Column('hs_no'), MaxLength(32)]
    Property HsNo: string read FHsNo write FHsNo;

    [Column('diib_product_description'), MaxLength(256)]
    Property DiibProductDescription: string read FDiibProductDescription write FDiibProductDescription;

    [Column('min_stock_amount')]
    Property MinStockAmount: Double read FMinStockAmount write FMinStockAmount;

    [Column('product_overview'), MaxLength(512)]
    Property ProductOverview: string read FProductOverview write FProductOverview;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkInventory.Create;
begin
  inherited;
  FSellable := True;
  FProductType := 0;
  FBuyingDiscount := 0;
  FSalesDiscount := 0;
  FBuyingPrice := 0;
  FSalesPrice := 0;
  FExportPrice := 0;
  FWidth := 0;
  FLength := 0;
  FHeight := 0;
  FWeight := 0;
  FSupplyDuration := 0;
  FMinStockAmount := 0;
end;

destructor TStkInventory.Destroy;
begin
  inherited;
end;

end.
