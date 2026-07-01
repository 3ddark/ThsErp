unit SatSiparisDetay;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sls_order_detail')]
  TSatSiparisDetay = class(TEntity)
  private
    FHeaderId: Int64;
    FTeklifDetayId: Int64;
    FIrsaliyeDetayId: Int64;
    FFaturaDetayId: Int64;
    FStokKodu: string;
    FStockDescription: string;
    FUserDescription: string;
    FReferans: string;
    FMiktar: Extended;
    FOutgoingQuantity: Extended;
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
    FEn: Extended;
    FBoy: Extended;
    FHeight: Extended;
    FNetWeight: Extended;
    FGrossWeight: Extended;
    FVolume: Extended;
    FThickness: Integer;
  public
    [Column('id'), Required()]
    property Id: Int64 read FId write FId;

    [Column('header_id')]
    property HeaderId: Int64 read FHeaderId write FHeaderId;

    [Column('teklif_detay_id')]
    property TeklifDetayId: Int64 read FTeklifDetayId write FTeklifDetayId;

    [Column('irsaliye_detay_id')]
    property IrsaliyeDetayId: Int64 read FIrsaliyeDetayId write FIrsaliyeDetayId;

    [Column('fatura_detay_id')]
    property FaturaDetayId: Int64 read FFaturaDetayId write FFaturaDetayId;

    [Column('stok_kodu'), MaxLength(32)]
    property StokKodu: string read FStokKodu write FStokKodu;

    [Column('stock_description'), MaxLength(128)]
    property StockDescription: string read FStockDescription write FStockDescription;

    [Column('user_description'), MaxLength(128)]
    property UserDescription: string read FUserDescription write FUserDescription;

    [Column('referans'), MaxLength(128)]
    property Referans: string read FReferans write FReferans;

    [Column('miktar'), Required()]
    property Miktar: Extended read FMiktar write FMiktar;

    [Column('outgoing_quantity'), Required()]
    property OutgoingQuantity: Extended read FOutgoingQuantity write FOutgoingQuantity;

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

    [Column('en')]
    property En: Extended read FEn write FEn;

    [Column('boy')]
    property Boy: Extended read FBoy write FBoy;

    [Column('height_en')]
    property Height: Extended read FHeight write FHeight;

    [Column('net_weight')]
    property NetWeight: Extended read FNetWeight write FNetWeight;

    [Column('gross_weight')]
    property GrossWeight: Extended read FGrossWeight write FGrossWeight;

    [Column('volume')]
    property Volume: Extended read FVolume write FVolume;

    [Column('thickness')]
    property Thickness: Integer read FThickness write FThickness;

    constructor Create(); override;
  end;

implementation

constructor TSatSiparisDetay.Create();
begin
  inherited;
  FIsAnaUrun := False;
end;

end.
