unit SlsOfferDetail;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Teklif kalemi. Teklifin Lines listesinde durum (yeni / kayıtlı / silinecek) TDetailEntity'den; başlığa tipli
  // erişim SlsOffer birimindeki class helper ile (Line.Header.OfferNo)
  [Table('sls_offer_detail')]
  TSlsOfferDetail = class(TDetailEntity)
  private
    FSlsOfferId: Int64;
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
    FOrderedQuantity: Currency;
    FDescription: string;

    // View (vw_sls_offer_detail) okunabilir alanları
    FOfferNo: string;
    FCurrency: string;
    FInventoryCode: string;
    FInventoryName: string;
    FUomCode: string;
  public
    [Column('sls_offer_id')]
    [Required()]
    property SlsOfferId: Int64 read FSlsOfferId write FSlsOfferId;

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

    [Column('ordered_quantity')]
    property OrderedQuantity: Currency read FOrderedQuantity write FOrderedQuantity;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property OfferNo: string read FOfferNo write FOfferNo;

    [NotMapped]
    property Currency: string read FCurrency write FCurrency;

    [NotMapped]
    property InventoryCode: string read FInventoryCode write FInventoryCode;

    [NotMapped]
    property InventoryName: string read FInventoryName write FInventoryName;

    [NotMapped]
    property UomCode: string read FUomCode write FUomCode;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TSlsOfferDetail;
  end;

implementation

constructor TSlsOfferDetail.Create;
begin
  inherited;
end;

destructor TSlsOfferDetail.Destroy;
begin
  inherited;
end;

function TSlsOfferDetail.Clone: TSlsOfferDetail;
begin
  // başlık referansı kopyalanmaz (kopyayı sahiplenen başlık verir)
  Result := TSlsOfferDetail.Create;
  Result.Id := Self.Id;
  Result.Deleted := Self.Deleted;
  Result.SlsOfferId := Self.SlsOfferId;
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
  Result.OrderedQuantity := Self.OrderedQuantity;
  Result.Description := Self.Description;
  Result.OfferNo := Self.OfferNo;
  Result.Currency := Self.Currency;
  Result.InventoryCode := Self.InventoryCode;
  Result.InventoryName := Self.InventoryName;
  Result.UomCode := Self.UomCode;
end;

end.
