unit AlsTeklifDetay;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('pur_offer_detail')]
  TAlsTeklifDetay = class(TEntity)
  private
    FHeaderId: Int64;
    FOrderIdDetailId: Int64;
    FDeliveryNoteDetailId: Int64;
    FInvoiceDetailId: Int64;
    FSkuCode: string;
    FStockDescription: string;
    FUserDescription: string;
    FReferans: string;
    FMiktar: Extended;
    FUomCode: string;
    FDiscountRate: Extended;
    FTaxRate: Integer;
    FFiyat: Extended;
    FNetFiyat: Extended;
    FAmount: Extended;
    FDiscountAmount: Extended;
    FNetAmount: Extended;
    FTaxAmount: Extended;
    FTotalAmount: Extended;
    FIsAnaUrun: Boolean;
    FReferansAnaUrunId: Int64;
    FGtipNo: string;
    FMenseiUlkeAdi: string;
  public
    [Column('id'), Required()]
    property Id: Int64 read FId write FId;

    [Column('header_id')]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    [Column('order_detail_id')]
    property OrderIdDetailId: Int64 read FOrderIdDetailId write FOrderIdDetailId;

    [Column('delivery_note_detail_id')]
    property DeliveryNoteDetailId: Int64 read FDeliveryNoteDetailId write FDeliveryNoteDetailId;

    [Column('invoice_detail_id')]
    property InvoiceDetailId: Int64 read FInvoiceDetailId write FInvoiceDetailId;

    [Column('sku_code'), MaxLength(32)]
    property SkuCode: string read FSkuCode write FSkuCode;

    [Column('stock_description'), MaxLength(128)]
    property StockDescription: string read FStockDescription write FStockDescription;

    [Column('user_description'), MaxLength(128)]
    property UserDescription: string read FUserDescription write FUserDescription;

    [Column('referans'), MaxLength(128)]
    property Referans: string read FReferans write FReferans;

    [Column('miktar'), Required()]
    property Miktar: Extended read FMiktar write FMiktar;

    [Column('uom_code'), MaxLength(8)]
    property UomCode: string read FUomCode write FUomCode;

    [Column('discount_rate')]
    property DiscountRate: Extended read FDiscountRate write FDiscountRate;

    [Column('tax_rate'), Required()]
    property TaxRate: Integer read FTaxRate write FTaxRate;

    [Column('fiyat')]
    property Fiyat: Extended read FFiyat write FFiyat;

    [Column('net_fiyat'), Required()]
    property NetFiyat: Extended read FNetFiyat write FNetFiyat;

    [Column('amount'), Required()]
    property Amount: Extended read FAmount write FAmount;

    [Column('discount_amount'), Required()]
    property DiscountAmount: Extended read FDiscountAmount write FDiscountAmount;

    [Column('net_amount'), Required()]
    property NetAmount: Extended read FNetAmount write FNetAmount;

    [Column('tax_amount'), Required()]
    property TaxAmount: Extended read FTaxAmount write FTaxAmount;

    [Column('total_amount'), Required()]
    property TotalAmount: Extended read FTotalAmount write FTotalAmount;

    [Column('is_ana_urun'), Required()]
    property IsAnaUrun: Boolean read FIsAnaUrun write FIsAnaUrun;

    [Column('referans_ana_urun_id')]
    property ReferansAnaUrunId: Int64 read FReferansAnaUrunId write FReferansAnaUrunId;

    [Column('gtip_no'), MaxLength(16)]
    property GtipNo: string read FGtipNo write FGtipNo;

    [Column('mensei_ulke_adi'), MaxLength(128)]
    property MenseiUlkeAdi: string read FMenseiUlkeAdi write FMenseiUlkeAdi;

    constructor Create(); override;
  end;

implementation

constructor TAlsTeklifDetay.Create();
begin
  inherited;
  FIsAnaUrun := False;
end;

end.
