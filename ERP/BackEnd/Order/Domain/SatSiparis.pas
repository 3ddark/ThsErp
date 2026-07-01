unit SatSiparis;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, SatSiparisDetay,
  SetSatSiparisDurum, SysCity, EmpPersonnel, StkInventory, SysCountry,
  SetEInvFaturaTipleri, SetEInvTeslimSekli, SetEInvOdemeSekli,
  SetEInvPaketTipi, SetEInvTasimaUcreti;

type
  [Table('sls_order')]
  TSatSiparis = class(TEntity)
  private
    FTeklifId: Int64;
    FIrsaliyeId: Int64;
    FFaturaId: Int64;
    FTotalAmount: Extended;
    FDiscountAmount: Extended;
    FSubtotal: Extended;
    FTaxRate1: Integer;
    FTaxAmount1: Extended;
    FTaxRate2: Integer;
    FTaxAmount2: Extended;
    FTaxRate3: Integer;
    FTaxAmount3: Extended;
    FTaxRate4: Integer;
    FTaxAmount4: Extended;
    FTaxRate5: Integer;
    FTaxAmount5: Extended;
    FGrandTotal: Extended;
    FOperationTypeId: Int64;
    FOrderNumber: string;
    FOrderDate: TDate;
    FDeliveryDate: TDate;
    FCustomerCode: string;
    FCustomerName: string;
    FTaxOffice: string;
    FTaxNumber: string;
    FCountryId: Int64;
    FCityId: Int64;
    FDistrict: string;
    FNeighborhood: string;
    FAvenue: string;
    FStreet: string;
    FPostalCode: string;
    FBuildingName: string;
    FDoorNumber: string;
    FCustomerRepresentativeId: Int64;
    FContactName: string;
    FReference: string;
    FCurrencyCode: string;
    FExchangeRateUsd: Extended;
    FExchangeRateEur: Extended;
    FDescription: string;
    FProformaNo: Integer;
    FStatusId: Int64;
    FDeliveryMethodId: Int64;
    FPaymentMethodId: Int64;
    FPacketTypeId: Int64;
    FTransportChargeId: Int64;
    FSetSatSiparisDurum: TSetSatSiparisDurum;
    FCity: TSysCity;
    FCountry: TSysCountry;
    FCustomerRepresentative: TEmpPersonnel;
    FFaturaTipi: TSetEInvFaturaTipleri;
    FTeslimSekli: TSetEInvTeslimSekli;
    FOdemeSekli: TSetEInvOdemeSekli;
    FPaketTipi: TSetEInvPaketTipi;
    FTasimaUcreti: TSetEInvTasimaUcreti;
  public
    [Column('id'), Required()]
    property Id: Int64 read FId write FId;

    [Column('teklif_id')]
    property TeklifId: Int64 read FTeklifId write FTeklifId;

    [Column('irsaliye_id')]
    property IrsaliyeId: Int64 read FIrsaliyeId write FIrsaliyeId;

    [Column('fatura_id')]
    property FaturaId: Int64 read FFaturaId write FFaturaId;

    [Column('total_amount'), Required()]
    property TotalAmount: Extended read FTotalAmount write FTotalAmount;

    [Column('discount_amount'), Required()]
    property DiscountAmount: Extended read FDiscountAmount write FDiscountAmount;

    [Column('subtotal'), Required()]
    property Subtotal: Extended read FSubtotal write FSubtotal;

    [Column('tax_rate_1'), Required()]
    property TaxRate1: Integer read FTaxRate1 write FTaxRate1;

    [Column('tax_amount_1'), Required()]
    property TaxAmount1: Extended read FTaxAmount1 write FTaxAmount1;

    [Column('tax_rate_2'), Required()]
    property TaxRate2: Integer read FTaxRate2 write FTaxRate2;

    [Column('tax_amount_2'), Required()]
    property TaxAmount2: Extended read FTaxAmount2 write FTaxAmount2;

    [Column('tax_rate_3'), Required()]
    property TaxRate3: Integer read FTaxRate3 write FTaxRate3;

    [Column('tax_amount_3'), Required()]
    property TaxAmount3: Extended read FTaxAmount3 write FTaxAmount3;

    [Column('tax_rate_4'), Required()]
    property TaxRate4: Integer read FTaxRate4 write FTaxRate4;

    [Column('tax_amount_4'), Required()]
    property TaxAmount4: Extended read FTaxAmount4 write FTaxAmount4;

    [Column('tax_rate_5'), Required()]
    property TaxRate5: Integer read FTaxRate5 write FTaxRate5;

    [Column('tax_amount_5'), Required()]
    property TaxAmount5: Extended read FTaxAmount5 write FTaxAmount5;

    [Column('grand_total'), Required()]
    property GrandTotal: Extended read FGrandTotal write FGrandTotal;

    [Column('operation_type_id')]
    property OperationTypeId: Int64 read FOperationTypeId write FOperationTypeId;

    [Column('order_number'), MaxLength(16)]
    property OrderNumber: string read FOrderNumber write FOrderNumber;

    [Column('order_date')]
    property OrderDate: TDate read FOrderDate write FOrderDate;

    [Column('delivery_date')]
    property DeliveryDate: TDate read FDeliveryDate write FDeliveryDate;

    [Column('customer_code'), MaxLength(16)]
    property CustomerCode: string read FCustomerCode write FCustomerCode;

    [Column('customer_name'), MaxLength(128)]
    property CustomerName: string read FCustomerName write FCustomerName;

    [Column('tax_office'), MaxLength(32)]
    property TaxOffice: string read FTaxOffice write FTaxOffice;

    [Column('tax_number'), MaxLength(32)]
    property TaxNumber: string read FTaxNumber write FTaxNumber;

    [Column('country_id')]
    property CountryId: Int64 read FCountryId write FCountryId;

    [Column('city_id')]
    property CityId: Int64 read FCityId write FCityId;

    [Column('district'), MaxLength(32)]
    property District: string read FDistrict write FDistrict;

    [Column('neighborhood'), MaxLength(40)]
    property Neighborhood: string read FNeighborhood write FNeighborhood;

    [Column('avenue'), MaxLength(40)]
    property Avenue: string read FAvenue write FAvenue;

    [Column('street'), MaxLength(40)]
    property Street: string read FStreet write FStreet;

    [Column('postal_code'), MaxLength(7)]
    property PostalCode: string read FPostalCode write FPostalCode;

    [Column('building_name'), MaxLength(40)]
    property BuildingName: string read FBuildingName write FBuildingName;

    [Column('door_number'), MaxLength(6)]
    property DoorNumber: string read FDoorNumber write FDoorNumber;

    [Column('customer_representative_id')]
    property CustomerRepresentativeId: Int64 read FCustomerRepresentativeId write FCustomerRepresentativeId;

    [Column('contact_name'), MaxLength(32)]
    property ContactName: string read FContactName write FContactName;

    [Column('reference'), MaxLength(128)]
    property Reference: string read FReference write FReference;

    [Column('currency_code'), Required(), MaxLength(3)]
    property CurrencyCode: string read FCurrencyCode write FCurrencyCode;

    [Column('exchange_rate_usd')]
    property ExchangeRateUsd: Extended read FExchangeRateUsd write FExchangeRateUsd;

    [Column('exchange_rate_eur')]
    property ExchangeRateEur: Extended read FExchangeRateEur write FExchangeRateEur;

    [Column('description'), MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [Column('proforma_no')]
    property ProformaNo: Integer read FProformaNo write FProformaNo;

    [Column('status_id')]
    property StatusId: Int64 read FStatusId write FStatusId;

    [Column('delivery_method_id')]
    property DeliveryMethodId: Int64 read FDeliveryMethodId write FDeliveryMethodId;

    [Column('payment_method_id')]
    property PaymentMethodId: Int64 read FPaymentMethodId write FPaymentMethodId;

    [Column('packet_type_id')]
    property PacketTypeId: Int64 read FPacketTypeId write FPacketTypeId;

    [Column('transport_charge_id')]
    property TransportChargeId: Int64 read FTransportChargeId write FTransportChargeId;

    [BelongsTo('status_id', 'id')]
    property SetSatSiparisDurum: TSetSatSiparisDurum read FSetSatSiparisDurum write FSetSatSiparisDurum;

    [BelongsTo('city_id', 'id')]
    property City: TSysCity read FCity write FCity;

    [BelongsTo('country_id', 'id')]
    property Country: TSysCountry read FCountry write FCountry;

    [BelongsTo('customer_representative_id', 'id')]
    property CustomerRepresentative: TEmpPersonnel read FCustomerRepresentative write FCustomerRepresentative;

    // Lookup relations (operation_type maps to fatura tipi set)
    [BelongsTo('operation_type_id', 'id')]
    property FaturaTipi: TSetEInvFaturaTipleri read FFaturaTipi write FFaturaTipi;

    [BelongsTo('delivery_method_id', 'id')]
    property TeslimSekli: TSetEInvTeslimSekli read FTeslimSekli write FTeslimSekli;

    [BelongsTo('payment_method_id', 'id')]
    property OdemeSekli: TSetEInvOdemeSekli read FOdemeSekli write FOdemeSekli;

    [BelongsTo('packet_type_id', 'id')]
    property PaketTipi: TSetEInvPaketTipi read FPaketTipi write FPaketTipi;

    [BelongsTo('transport_charge_id', 'id')]
    property TasimaUcreti: TSetEInvTasimaUcreti read FTasimaUcreti write FTasimaUcreti;

    // Nested entity for detail lines
    FListDetay: TObjectList<TSatSiparisDetay>;
    [Nested('header_id', 'id')]
    property ListDetay: TObjectList<TSatSiparisDetay> read FListDetay write FListDetay;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSatSiparis.Create();
begin
  inherited;
  FSetSatSiparisDurum := TSetSatSiparisDurum.Create;
  FCity := TSysCity.Create;
  FCountry := TSysCountry.Create;
  FCustomerRepresentative := TEmpPersonnel.Create;
  FFaturaTipi := TSetEInvFaturaTipleri.Create;
  FTeslimSekli := TSetEInvTeslimSekli.Create;
  FOdemeSekli := TSetEInvOdemeSekli.Create;
  FPaketTipi := TSetEInvPaketTipi.Create;
  FTasimaUcreti := TSetEInvTasimaUcreti.Create;
  FListDetay := TObjectList<TSatSiparisDetay>.Create;
end;

destructor TSatSiparis.Destroy;
begin
  FreeAndNil(FSetSatSiparisDurum);
  FreeAndNil(FCity);
  FreeAndNil(FCountry);
  FreeAndNil(FCustomerRepresentative);
  FreeAndNil(FFaturaTipi);
  FreeAndNil(FTeslimSekli);
  FreeAndNil(FOdemeSekli);
  FreeAndNil(FPaketTipi);
  FreeAndNil(FTasimaUcreti);
  FreeAndNil(FListDetay);
  inherited;
end;

end.
