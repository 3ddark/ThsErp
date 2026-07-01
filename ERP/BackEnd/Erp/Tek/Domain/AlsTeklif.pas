unit AlsTeklif;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, AlsTeklifDetay,
  SysCity, EmpPersonnel, StkInventory, SysCountry,
  SetEInvFaturaTipleri, SetSatTeklifDurum;

type
  [Table('pur_offer')]
  TAlsTeklif = class(TEntity)
  private
    FOrderId: Int64;
    FIrsaliyeId: Int64;
    FFaturaId: Int64;
    FIsConfirmed: Boolean;
    FTotalAmount: Extended;
    FDiscountAmount: Extended;
    FAraToplam: Extended;
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
    FGenelToplam: Extended;
    FOperationTypeId: Int64;
    FOfferNumber: string;
    FOfferDate: TDate;
    FValidityDate: TDate;
    FCustomerCode: string;
    FCustomerName: string;
    FTaxOffice: string;
    FTaxNumber: string;
    FCountryId: Int64;
    FCityId: Int64;
    FDistrict: string;
    FMahalle: string;
    FSemt: string;
    FAvenue: string;
    FStreet: string;
    FBuildingName: string;
    FDoorNumber: string;
    FPostaKodu: string;
    FWeb: string;
    FEmail: string;
    FCustomerRepresentative: string;
    FContactName: string;
    FContactPhone: string;
    FReferans: string;
    FCurrencyCode: string;
    FExchangeRateUsd: Extended;
    FExchangeRateEur: Extended;
    FDescription: string;
    FWithholdingCode: string;
    FWithholdingDescription: string;
    FWithholdingShare: Smallint;
    FWithholdingDenominator: Smallint;
    FAlsTeklifDetayList: TObjectList<TAlsTeklifDetay>;
    FCity: TSysCity;
    FCountry: TSysCountry;
    FFaturaTipi: TSetEInvFaturaTipleri;
  public
    [Column('id'), Required()]
    property Id: Int64 read FId write FId;

    [Column('order_id')]
    property OrderId: Int64 read FOrderId write FOrderId;

    [Column('irsaliye_id')]
    property IrsaliyeId: Int64 read FIrsaliyeId write FIrsaliyeId;

    [Column('fatura_id')]
    property FaturaId: Int64 read FFaturaId write FFaturaId;

    [Column('is_confirmed'), Required()]
    property IsConfirmed: Boolean read FIsConfirmed write FIsConfirmed;

    [Column('total_amount'), Required()]
    property TotalAmount: Extended read FTotalAmount write FTotalAmount;

    [Column('discount_amount'), Required()]
    property DiscountAmount: Extended read FDiscountAmount write FDiscountAmount;

    [Column('ara_toplam'), Required()]
    property AraToplam: Extended read FAraToplam write FAraToplam;

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

    [Column('genel_toplam'), Required()]
    property GenelToplam: Extended read FGenelToplam write FGenelToplam;

    [Column('operation_type_id')]
    property OperationTypeId: Int64 read FOperationTypeId write FOperationTypeId;

    [Column('offer_number'), Required(), MaxLength(16)]
    property OfferNumber: string read FOfferNumber write FOfferNumber;

    [Column('offer_date'), Required()]
    property OfferDate: TDate read FOfferDate write FOfferDate;

    [Column('validity_date'), Required()]
    property ValidityDate: TDate read FValidityDate write FValidityDate;

    [Column('customer_code'), MaxLength(16)]
    property CustomerCode: string read FCustomerCode write FCustomerCode;

    [Column('customer_name'), MaxLength(128)]
    property CustomerName: string read FCustomerName write FCustomerName;

    [Column('tax_office'), Required(), MaxLength(32)]
    property TaxOffice: string read FTaxOffice write FTaxOffice;

    [Column('tax_number'), Required(), MaxLength(32)]
    property TaxNumber: string read FTaxNumber write FTaxNumber;

    [Column('country_id')]
    property CountryId: Int64 read FCountryId write FCountryId;

    [Column('city_id')]
    property CityId: Int64 read FCityId write FCityId;

    [Column('district'), MaxLength(64)]
    property District: string read FDistrict write FDistrict;

    [Column('mahalle'), MaxLength(64)]
    property Mahalle: string read FMahalle write FMahalle;

    [Column('semt'), MaxLength(64)]
    property Semt: string read FSemt write FSemt;

    [Column('cadde'), MaxLength(64)]
    property Avenue: string read FAvenue write FAvenue;

    [Column('sokak'), MaxLength(64)]
    property Street: string read FStreet write FStreet;

    [Column('building_name'), MaxLength(64)]
    property BuildingName: string read FBuildingName write FBuildingName;

    [Column('door_number'), MaxLength(16)]
    property DoorNumber: string read FDoorNumber write FDoorNumber;

    [Column('posta_kodu'), MaxLength(16)]
    property PostaKodu: string read FPostaKodu write FPostaKodu;

    [Column('web'), MaxLength(64)]
    property Web: string read FWeb write FWeb;

    [Column('email'), MaxLength(128)]
    property Email: string read FEmail write FEmail;

    [Column('customer_representative'), MaxLength(64)]
    property CustomerRepresentative: string read FCustomerRepresentative write FCustomerRepresentative;

    [Column('contact_name'), MaxLength(32)]
    property ContactName: string read FContactName write FContactName;

    [Column('contact_phone'), MaxLength(24)]
    property ContactPhone: string read FContactPhone write FContactPhone;

    [Column('referans'), MaxLength(128)]
    property Referans: string read FReferans write FReferans;

    [Column('currency_code'), Required(), MaxLength(3)]
    property CurrencyCode: string read FCurrencyCode write FCurrencyCode;

    [Column('exchange_rate_usd')]
    property ExchangeRateUsd: Extended read FExchangeRateUsd write FExchangeRateUsd;

    [Column('exchange_rate_eur')]
    property ExchangeRateEur: Extended read FExchangeRateEur write FExchangeRateEur;

    [Column('description'), MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [Column('withholding_code'), MaxLength(8)]
    property WithholdingCode: string read FWithholdingCode write FWithholdingCode;

    [Column('withholding_description'), MaxLength(128)]
    property WithholdingDescription: string read FWithholdingDescription write FWithholdingDescription;

    [Column('withholding_share')]
    property WithholdingShare: Smallint read FWithholdingShare write FWithholdingShare;

    [Column('withholding_denominator')]
    property WithholdingDenominator: Smallint read FWithholdingDenominator write FWithholdingDenominator;

    // BelongsTo relationships
    [BelongsTo('city_id', 'id')]
    property City: TSysCity read FCity write FCity;

    [BelongsTo('country_id', 'id')]
    property Country: TSysCountry read FCountry write FCountry;

    [BelongsTo('operation_type_id', 'id')]
    property FaturaTipi: TSetEInvFaturaTipleri read FFaturaTipi write FFaturaTipi;

    // Nested detail lines
    [Nested('header_id', 'id')]
    property AlsTeklifDetayList: TObjectList<TAlsTeklifDetay> read FAlsTeklifDetayList write FAlsTeklifDetayList;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAlsTeklif.Create();
begin
  inherited;
  FCity := TSysCity.Create;
  FCountry := TSysCountry.Create;
  FFaturaTipi := TSetEInvFaturaTipleri.Create;
  FAlsTeklifDetayList := TObjectList<TAlsTeklifDetay>.Create;
end;

destructor TAlsTeklif.Destroy;
begin
  FreeAndNil(FCity);
  FreeAndNil(FCountry);
  FreeAndNil(FFaturaTipi);
  FreeAndNil(FAlsTeklifDetayList);
  inherited;
end;

end.
